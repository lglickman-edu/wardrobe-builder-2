Rails.application.routes.draw do
  

  # CREATE
  post("/insert_outfit", { :controller => "outfits", :action => "create" })

  # READ
  get("/outfits", { :controller => "outfits", :action => "index" })

  get("/outfits/:path_id", { :controller => "outfits", :action => "show" })

  # UPDATE

  post("/modify_outfit/:path_id", { :controller => "outfits", :action => "update" })

  # DELETE
  get("/delete_outfit/:path_id", { :controller => "outfits", :action => "destroy" })

  #------------------------------

  # Routes for the Item resource:

  # CREATE
  post("/insert_item", { :controller => "items", :action => "create" })

  # READ
  get("/items", { :controller => "items", :action => "index" })

  patch("/items/:id/toggle_clean", { :controller => "items", :action => "toggle_clean"})

  get("/items/:path_id", { :controller => "items", :action => "show" })

  # UPDATE

  post("/modify_item/:path_id", { :controller => "items", :action => "update" })

  # DELETE
  get("/delete_item/:path_id", { :controller => "items", :action => "destroy" })

  #------------------------------

  devise_for :users
  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:
  # get("/your_first_screen", { :controller => "pages", :action => "first" })
  get("/", { :controller => "wardrobe", :action => "index"})
  post("/generate", { :controller => "wardrobe", :action => "generate"})
end
