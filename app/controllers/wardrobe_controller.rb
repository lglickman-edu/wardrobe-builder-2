class WardrobeController < ApplicationController
  before_action :authenticate_user!

  def index
    render template: "wardrobe_templates/index"
  end

  def generate
    items = current_user.items.where(clean: true).order(:category, :name)
    @items_by_id = current_user.items.index_by(&:id)

    wardrobe_payload = {
      items: items.map do |item|
        {
          id: item.id,
          name: item.name.to_s,
          category: item.category.to_s, 
          color: item.color.to_s,
          season: item.season.to_s,
          #formality_level: extract_int(item, :formality_level, default: 3),
          #warmth_level: extract_int(item, :warmth_level, default: 3),
          notes: item.notes.to_s
        }
      end
    }

    chat = AI::Chat.new
    chat.proxy = true
    chat.model = "gpt-5.2"
    chat.reasoning_effort = nil

    chat.system(<<~SYS)
      You are a wardrobe stylist.
      Build outfit recommendations only from the provided wardrobe items.
      Do not invent clothing that is not present.
      Prefer coherent color matching, sensible layering, and complete outfits.
      Return STRICT JSON matching the schema.
    SYS

    chat.user(<<~MSG)
      Here is the user's wardrobe inventory as JSON:

      #{wardrobe_payload.to_json}

      Generate 3 outfit recommendations.
      Occasion: everyday
      Desired style: minimal / smart casual
      Weather: mild
    MSG

    chat.schema = {
      name: "outfit_recommendations",
      strict: true,
      schema: {
        type: "object",
        properties: {
          outfits: {
            type: "array",
            items: {
              type: "object",
              properties: {
                outfit_name: { type: "string" },
                style_name: { type: "string" },
                occasion: { type: "string" },
                reasoning: { type: "string" },
                warmth_level: { type: "integer" },
                formality_level: { type: "integer" },
                item_ids: {
                  type: "array",
                  items: { type: "integer" }
                },
                items_by_role: {
                  type: "object",
                  properties: {
                    tops: { type: "integer" },
                    bottoms: { type: "integer" },
                    shoes: { type: "integer" },
                    outerwear: {
                      anyOf: [
                        { type: "integer" },
                        { type: "null" }
                      ]
                    },
                    accessories: {
                      type: "array",
                      items: { type: "integer" }
                    }
                  },
                  required: ["tops", "bottoms", "shoes", "outerwear", "accessories"],
                  additionalProperties: false
                }
              },
              required: [
                "outfit_name",
                "style_name",
                "occasion",
                "reasoning",
                "warmth_level",
                "formality_level",
                "item_ids",
                "items_by_role"
              ],
              additionalProperties: false
            }
          }
        },
        required: ["outfits"],
        additionalProperties: false
      }
    }

    @response = chat.generate!
    @parsed = @response[:content]

    @recommended_outfits = @parsed[:outfits]
    @items_by_id = items.index_by(&:id)

    @input_wardrobe_payload = {
      items: items.map do |item|
        {
          id: item.id,
          name: item.name.to_s,
          category: item.category.to_s, 
          color: item.color.to_s,
          season: item.season.to_s,
          
          notes: item.notes.to_s
        }
      end
    }

    render({ :template => "wardrobe_templates/show"})
  end

end
