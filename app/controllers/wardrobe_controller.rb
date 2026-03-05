class WardrobeController < ApplicationController
def index
  render({ :template => "wardrobe_templates/index"})
end
end
