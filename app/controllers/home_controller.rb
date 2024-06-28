class HomeController < ApplicationController
  def index
    render json: { msg: "Check `/posts.json` for the latest POSTS!" }
  end
end
