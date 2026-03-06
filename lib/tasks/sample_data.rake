desc "Fill the database tables with some sample data"
task sample_data: :environment do
  email = ENV.fetch("email", "demo@wardrobe.dev").to_s
  password = ENV.fetch("password", "password123").to_s
  name = ENV.fetch("name", "Demo User").to_s

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

    OutfitItem.joins(:outfit).where(outfits: { user_id: user.id }).delete_all
    Outfit.where(user_id: user.id).delete_all
    Style.where(user_id: user.id).delete_all
    Item.where(user_id: user.id).delete_all

    puts "Cleared existing wardrobe data for #{user.email}"

    sample_image_file_for = lambda do |filename|
      path = Rails.root.join("public", "sample_images", filename)

      unless File.exist?(path)
        raise "Missing sample image: #{path}"
      end

      File.open(path)
    end

    create_style = lambda do |user_record, style_name, description:, rules_hash:|
      style = Style.new
      style.user_id = user_record.id
      style.name = style_name
      style.description = description if style.respond_to?(:description=)
      style.rules_json = JSON.generate(rules_hash) if style.respond_to?(:rules_json=)
      style.archived_at = nil if style.respond_to?(:archived_at=)
      style.save!
      style
    end

    create_item = lambda do |user_record, attrs|
      item = Item.new
      item.user_id = user_record.id
      item.name = attrs.fetch(:name)
      item.category = attrs.fetch(:category)
      item.color = attrs[:color]
      item.season = attrs[:season] || "all"
      item.notes = attrs[:notes]
      item.archived_at = nil if item.respond_to?(:archived_at=)

      if item.respond_to?(:tags_json=)
        item.tags_json = JSON.generate(Array(attrs[:tags] || []))
      end

      if attrs[:image_filename].present?
        file = sample_image_file_for.call(attrs[:image_filename])
        begin
          item.image_url = file
          item.save!
        ensure
          file.close unless file.closed?
        end
      else
        item.save!
      end

      puts "Created item: #{item.name} | image_url: #{item[:image_url].inspect}"
      item
    end

    create_outfit = lambda do |user_record, attrs|
      outfit = Outfit.new
      outfit.user_id = user_record.id
      outfit.name = attrs.fetch(:name)
      outfit.occasion = attrs[:occasion] if outfit.respond_to?(:occasion=)
      outfit.season = attrs[:season] if outfit.respond_to?(:season=)
      outfit.notes = attrs[:notes] if outfit.respond_to?(:notes=)
      outfit.style_id = attrs[:style_id] if outfit.respond_to?(:style_id=) && attrs[:style_id].present?
      outfit.archived_at = nil if outfit.respond_to?(:archived_at=)
      outfit.save!
      outfit
    end

    create_outfit_item = lambda do |outfit, item, role: nil|
      outfit_item = OutfitItem.new
      outfit_item.outfit_id = outfit.id
      outfit_item.item_id = item.id
      outfit_item.role = role if outfit_item.respond_to?(:role=)
      outfit_item.save!
      outfit_item
    end

    minimal = create_style.call(
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

    street = create_style.call(
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

    smart = create_style.call(
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
      {
        name: "White Oxford Shirt",
        category: "tops",
        color: "white",
        season: "all",
        tags: %w[smart classic],
        image_filename: "white_oxford_shirt.jpg"
      },
      {
        name: "Black Turtleneck",
        category: "tops",
        color: "black",
        season: "winter",
        tags: %w[minimal],
        image_filename: "black_turtleneck.jpg"
      },
      {
        name: "Gray Hoodie",
        category: "tops",
        color: "gray",
        season: "all",
        tags: %w[street comfy],
        image_filename: "gray_hoodie.jpg"
      },
      {
        name: "Navy Knit Sweater",
        category: "tops",
        color: "navy",
        season: "winter",
        tags: %w[smart],
        image_filename: "navy_knit_sweater.jpg"
      },
      {
        name: "Dark Denim Jeans",
        category: "bottoms",
        color: "indigo",
        season: "all",
        tags: %w[street],
        image_filename: "dark_denim_jeans.jpg"
      },
      {
        name: "Black Slim Trousers",
        category: "bottoms",
        color: "black",
        season: "all",
        tags: %w[minimal smart],
        image_filename: "black_slim_trousers.jpg"
      },
      {
        name: "Khaki Chinos",
        category: "bottoms",
        color: "khaki",
        season: "all",
        tags: %w[smart],
        image_filename: "khaki_chinos.jpg"
      },
      {
        name: "White Sneakers",
        category: "shoes",
        color: "white",
        season: "all",
        tags: %w[street],
        image_filename: "white_sneakers.jpg"
      },
      {
        name: "Black Leather Loafers",
        category: "shoes",
        color: "black",
        season: "all",
        tags: %w[smart],
        image_filename: "black_leather_loafers.jpg"
      },
      {
        name: "Black Chelsea Boots",
        category: "shoes",
        color: "black",
        season: "winter",
        tags: %w[minimal smart],
        image_filename: "black_chelsea_boots.jpg"
      },
      {
        name: "Black Overcoat",
        category: "outerwear",
        color: "black",
        season: "winter",
        tags: %w[smart minimal],
        image_filename: "black_overcoat.jpg"
      },
      {
        name: "Blue Denim Jacket",
        category: "outerwear",
        color: "blue",
        season: "all",
        tags: %w[street],
        image_filename: "blue_denim_jacket.jpg"
      },
      {
        name: "Black Leather Belt",
        category: "accessory",
        color: "black",
        season: "all",
        tags: %w[smart minimal],
        image_filename: "black_leather_belt.jpg"
      },
      {
        name: "Silver Watch",
        category: "accessory",
        color: "silver",
        season: "all",
        tags: %w[classic],
        image_filename: "silver_watch.jpg"
      }
    ].each do |attrs|
      item = create_item.call(user, attrs)
      items[attrs[:name]] = item
    end

    o1 = create_outfit.call(
      user,
      name: "Minimal Winter",
      occasion: "daily",
      season: "winter",
      notes: "Monochrome layering. Swap boots for loafers if warmer.",
      style_id: minimal.id
    )
    create_outfit_item.call(o1, items["Black Turtleneck"], role: "top")
    create_outfit_item.call(o1, items["Black Slim Trousers"], role: "bottom")
    create_outfit_item.call(o1, items["Black Chelsea Boots"], role: "shoes")
    create_outfit_item.call(o1, items["Black Overcoat"], role: "outerwear")
    create_outfit_item.call(o1, items["Silver Watch"], role: "accessory")

    o2 = create_outfit.call(
      user,
      name: "Street Layer",
      occasion: "casual",
      season: "all",
      notes: "Easy daily uniform.",
      style_id: street.id
    )
    create_outfit_item.call(o2, items["Gray Hoodie"], role: "top")
    create_outfit_item.call(o2, items["Dark Denim Jeans"], role: "bottom")
    create_outfit_item.call(o2, items["White Sneakers"], role: "shoes")
    create_outfit_item.call(o2, items["Blue Denim Jacket"], role: "outerwear")

    o3 = create_outfit.call(
      user,
      name: "Smart Casual Office",
      occasion: "work",
      season: "all",
      notes: "Good default for meetings.",
      style_id: smart.id
    )
    create_outfit_item.call(o3, items["White Oxford Shirt"], role: "top")
    create_outfit_item.call(o3, items["Khaki Chinos"], role: "bottom")
    create_outfit_item.call(o3, items["Black Leather Loafers"], role: "shoes")
    create_outfit_item.call(o3, items["Black Leather Belt"], role: "accessory")

    puts "Seeded for #{user.email}:"
    puts "  Styles:      #{Style.where(user_id: user.id).count}"
    puts "  Items:       #{Item.where(user_id: user.id).count}"
    puts "  Outfits:     #{Outfit.where(user_id: user.id).count}"
    puts "  OutfitItems: #{OutfitItem.joins(:outfit).where(outfits: { user_id: user.id }).count}"
  end
end
