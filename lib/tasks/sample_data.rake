desc "Fill the database tables with some sample data"
task({ sample_data: :environment }) do
  email = (ENV["email"] || "demo@wardrobe.dev").to_s
  password = (ENV["password"] || "password123").to_s
  name = (ENV["name"] || "Demo User").to_s

  ActiveRecord::Base.transaction do
    user = User.find_or_initialize_by(email: email)
    if user.new_record?
      user.name = name if user.respond_to?(:name=)
      user.password = password if user.respond_to?(:password=)
      user.password_confirmation = password if user.respond_to?(:password_confirmation=)
      user.save!
      puts "Created user: #{user.email}"
    else
      puts "Using existing user: #{user.email}"
    end

    upsert_style = lambda do |user, style_name, description:, rules_hash:|
      style = Style.where(user_id: user.id, name: style_name).first_or_initialize
      style.description = description if style.respond_to?(:description=)
      style.rules_json = JSON.generate(rules_hash) if style.respond_to?(:rules_json=)
      style.archived_at = nil if style.respond_to?(:archived_at=)
      style.save!
      style
    end

    upsert_item = lambda do |user, attrs|
      item = Item.where(user_id: user.id, name: attrs.fetch(:name)).first_or_initialize
      item.category = attrs.fetch(:category)
      item.color = attrs[:color]
      item.season = attrs[:season] || "all"
      item.image_url = attrs[:image_url]
      item.notes = attrs[:notes]
      if item.respond_to?(:tags_json=)
        item.tags_json = JSON.generate(Array(attrs[:tags] || []))
      end
      item.archived_at = nil if item.respond_to?(:archived_at=)
      item.save!
      item
    end

    upsert_outfit = lambda do |user, attrs|
      outfit = Outfit.where(user_id: user.id, name: attrs.fetch(:name)).first_or_initialize
      outfit.occasion = attrs[:occasion] if outfit.respond_to?(:occasion=)
      outfit.season = attrs[:season] if outfit.respond_to?(:season=)
      outfit.notes = attrs[:notes] if outfit.respond_to?(:notes=)
      outfit.style_id = attrs[:style_id] if outfit.respond_to?(:style_id=) && attrs[:style_id].present?
      outfit.archived_at = nil if outfit.respond_to?(:archived_at=)
      outfit.save!
      outfit
    end

    ensure_outfit_item = lambda do |outfit, item, role: nil|
      oi = OutfitItem.where(outfit_id: outfit.id, item_id: item.id).first_or_initialize
      oi.role = role if oi.respond_to?(:role=)
      oi.save!
      oi
    end

    minimal = upsert_style.call(
      user,
      "Minimal Monochrome",
      description: "Clean lines, neutral palette, low pattern.",
      rules_hash: {
        required_categories: %w[tops bottoms shoes],
        preferred_colors: %w[black white gray beige],
        avoid_colors: %w[neon],
        min_formality: 2,
        max_formality: 5,
        season: "all"
      }
    )

    street = upsert_style.call(
      user,
      "Street Casual",
      description: "Comfort-first, sneakers, layers, relaxed silhouettes.",
      rules_hash: {
        required_categories: %w[tops bottoms shoes],
        preferred_colors: %w[black white gray blue green],
        min_formality: 1,
        max_formality: 3,
        season: "all"
      }
    )

    smart = upsert_style.call(
      user,
      "Smart Casual",
      description: "Office-friendly without being formal.",
      rules_hash: {
        required_categories: %w[tops bottoms shoes],
        preferred_colors: %w[navy gray white brown black],
        min_formality: 3,
        max_formality: 5,
        season: "all"
      }
    )

    items = {}

    [
      { name: "White Oxford Shirt", category: "tops", color: "white", season: "all", tags: %w[smart classic] },
      { name: "Black Turtleneck", category: "tops", color: "black", season: "winter", tags: %w[minimal] },
      { name: "Gray Hoodie", category: "tops", color: "gray", season: "all", tags: %w[street comfy] },
      { name: "Navy Knit Sweater", category: "tops", color: "navy", season: "winter", tags: %w[smart] },

      { name: "Dark Denim Jeans", category: "bottoms", color: "indigo", season: "all", tags: %w[street] },
      { name: "Black Slim Trousers", category: "bottoms", color: "black", season: "all", tags: %w[minimal smart] },
      { name: "Khaki Chinos", category: "bottoms", color: "khaki", season: "all", tags: %w[smart] },

      { name: "White Sneakers", category: "shoes", color: "white", season: "all", tags: %w[street] },
      { name: "Black Leather Loafers", category: "shoes", color: "black", season: "all", tags: %w[smart] },
      { name: "Black Chelsea Boots", category: "shoes", color: "black", season: "winter", tags: %w[minimal smart] },

      { name: "Black Overcoat", category: "outerwear", color: "black", season: "winter", tags: %w[smart minimal] },
      { name: "Blue Denim Jacket", category: "outerwear", color: "blue", season: "all", tags: %w[street] },

      { name: "Black Leather Belt", category: "accessory", color: "black", season: "all", tags: %w[smart minimal] },
      { name: "Silver Watch", category: "accessory", color: "silver", season: "all", tags: %w[classic] }
    ].each do |attrs|
      item = upsert_item.call(user, attrs)
      items[attrs[:name]] = item
    end

    o1 = upsert_outfit.call(
      user,
      name: "Minimal Winter",
      occasion: "daily",
      season: "winter",
      notes: "Monochrome layering. Swap boots for loafers if warmer.",
      style_id: minimal.id
    )
    ensure_outfit_item.call(o1, items["Black Turtleneck"], role: "top")
    ensure_outfit_item.call(o1, items["Black Slim Trousers"], role: "bottom")
    ensure_outfit_item.call(o1, items["Black Chelsea Boots"], role: "shoes")
    ensure_outfit_item.call(o1, items["Black Overcoat"], role: "outerwear")
    ensure_outfit_item.call(o1, items["Silver Watch"], role: "accessory")

    o2 = upsert_outfit.call(
      user,
      name: "Street Layer",
      occasion: "casual",
      season: "all",
      notes: "Easy daily uniform.",
      style_id: street.id
    )
    ensure_outfit_item.call(o2, items["Gray Hoodie"], role: "top")
    ensure_outfit_item.call(o2, items["Dark Denim Jeans"], role: "bottom")
    ensure_outfit_item.call(o2, items["White Sneakers"], role: "shoes")
    ensure_outfit_item.call(o2, items["Blue Denim Jacket"], role: "outerwear")

    o3 = upsert_outfit.call(
      user,
      name: "Smart Casual Office",
      occasion: "work",
      season: "all",
      notes: "Good default for meetings.",
      style_id: smart.id
    )
    ensure_outfit_item.call(o3, items["White Oxford Shirt"], role: "top")
    ensure_outfit_item.call(o3, items["Khaki Chinos"], role: "bottom")
    ensure_outfit_item.call(o3, items["Black Leather Loafers"], role: "shoes")
    ensure_outfit_item.call(o3, items["Black Leather Belt"], role: "accessory")

    puts "Seeded for #{user.email}:"
    puts "  Styles:      #{Style.where(user_id: user.id).count}"
    puts "  Items:       #{Item.where(user_id: user.id).count}"
    puts "  Outfits:     #{Outfit.where(user_id: user.id).count}"
    puts "  OutfitItems: #{OutfitItem.joins(:outfit).where(outfits: { user_id: user.id }).count}"
  end
end
