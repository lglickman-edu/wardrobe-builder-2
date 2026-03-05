class ItemsController < ApplicationController
  def index
    matching_items = Item.all
    current_user_items = matching_items.where({ :user_id => current_user})
    @list_of_items = current_user_items.order({ :created_at => :desc })

    render({ :template => "item_templates/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_items = Item.where({ :id => the_id })

    @the_item = matching_items.at(0)

    render({ :template => "item_templates/show" })
  end

  def create
    the_item = Item.new
    the_item.user_id = params.fetch("query_user_id")
    the_item.name = params.fetch("query_name")
    the_item.category = params.fetch("query_category")
    the_item.color = params.fetch("query_color")
    the_item.season = params.fetch("query_season")
    the_item.image_url = params.fetch("image_url")
    the_item.notes = params.fetch("query_notes")
    the_item.tags_json = params.fetch("query_tags_json")
    the_item.archived_at = params.fetch("query_archived_at")

    if the_item.valid?
      the_item.save
      redirect_to("/items", { :notice => "Item created successfully." })
    else
      redirect_to("/items", { :alert => the_item.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_item = Item.where({ :id => the_id }).at(0)

    the_item.user_id = params.fetch("query_user_id")
    the_item.name = params.fetch("query_name")
    the_item.category = params.fetch("query_category")
    the_item.color = params.fetch("query_color")
    the_item.season = params.fetch("query_season")
    the_item.image_url = params.fetch("image_url")
    the_item.notes = params.fetch("query_notes")
    the_item.tags_json = params.fetch("query_tags_json")
    the_item.archived_at = params.fetch("query_archived_at")

    if the_item.valid?
      the_item.save
      redirect_to("/items/#{the_item.id}", { :notice => "Item updated successfully." } )
    else
      redirect_to("/items/#{the_item.id}", { :alert => the_item.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_item = Item.where({ :id => the_id }).at(0)

    the_item.destroy

    redirect_to("/items", { :notice => "Item deleted successfully." } )
  end
end
