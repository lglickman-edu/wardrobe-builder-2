class OutfitItemsController < ApplicationController
  def index
    matching_outfit_items = OutfitItem.all

    @list_of_outfit_items = matching_outfit_items.order({ :created_at => :desc })

    render({ :template => "outfit_item_templates/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_outfit_items = OutfitItem.where({ :id => the_id })

    @the_outfit_item = matching_outfit_items.at(0)

    render({ :template => "outfit_item_templates/show" })
  end

  def create
    the_outfit_item = OutfitItem.new
    the_outfit_item.outfit_id = params.fetch("query_outfit_id")
    the_outfit_item.item_id = params.fetch("query_item_id")
    the_outfit_item.role = params.fetch("query_role")

    if the_outfit_item.valid?
      the_outfit_item.save
      redirect_to("/outfit_items", { :notice => "Outfit item created successfully." })
    else
      redirect_to("/outfit_items", { :alert => the_outfit_item.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_outfit_item = OutfitItem.where({ :id => the_id }).at(0)

    the_outfit_item.outfit_id = params.fetch("query_outfit_id")
    the_outfit_item.item_id = params.fetch("query_item_id")
    the_outfit_item.role = params.fetch("query_role")

    if the_outfit_item.valid?
      the_outfit_item.save
      redirect_to("/outfit_items/#{the_outfit_item.id}", { :notice => "Outfit item updated successfully." } )
    else
      redirect_to("/outfit_items/#{the_outfit_item.id}", { :alert => the_outfit_item.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_outfit_item = OutfitItem.where({ :id => the_id }).at(0)

    the_outfit_item.destroy

    redirect_to("/outfit_items", { :notice => "Outfit item deleted successfully." } )
  end
end
