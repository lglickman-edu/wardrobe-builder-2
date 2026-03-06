class OutfitsController < ApplicationController
  def index
    matching_outfits = Outfit.all
    matching_user_outfits = matching_outfits.where({ :user_id => current_user.id })
    @list_of_outfits = matching_user_outfits.order({ :created_at => :desc })

    render({ :template => "outfit_templates/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_outfits = Outfit.where({ :id => the_id, :user_id => current_user.id })
    @the_outfit = matching_outfits.at(0)

    if @the_outfit.nil?
      redirect_to("/outfits", { :alert => "Outfit not found." })
      return
    end

    outfit_item_ids = @the_outfit.outfit_items.pluck(:item_id)
    @items_by_id = current_user.items.where(id: outfit_item_ids).index_by(&:id)

    render({ :template => "outfit_templates/show" })
  end

  def create
    the_outfit = Outfit.new
    the_outfit.user_id = current_user.id
    the_outfit.name = params.fetch("query_name")
    the_outfit.occasion = params["query_occasion"]
    the_outfit.season = params["query_season"]
    the_outfit.notes = params["query_notes"]
    the_outfit.archived_at = nil
    the_outfit.style_id = params["query_style_id"].presence

    if the_outfit.save
      Array(params["outfit_items"]&.values).each do |entry|
        OutfitItem.create!(
          outfit_id: the_outfit.id,
          item_id: entry["item_id"],
          role: entry["role"]
        )
      end

      redirect_to("/outfits/#{the_outfit.id}", { notice: "Outfit created successfully." })
    else
      redirect_to("/outfits", { alert: the_outfit.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_outfit = Outfit.where({ :id => the_id, :user_id => current_user.id }).at(0)

    the_outfit.name = params.fetch("query_name")
    the_outfit.occasion = params.fetch("query_occasion")
    the_outfit.season = params.fetch("query_season")
    the_outfit.notes = params.fetch("query_notes")
    the_outfit.archived_at = nil
    the_outfit.style_id = params["query_style_id"].presence

    if the_outfit.save
      redirect_to("/outfits/#{the_outfit.id}", { :notice => "Outfit updated successfully." })
    else
      redirect_to("/outfits/#{the_outfit.id}", { :alert => the_outfit.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_outfit = Outfit.where({ :id => the_id, :user_id => current_user.id }).at(0)

    the_outfit.destroy

    redirect_to("/outfits", { :notice => "Outfit deleted successfully." })
  end
end
