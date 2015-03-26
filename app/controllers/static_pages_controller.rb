class StaticPagesController < ApplicationController
  def welcome
    if user_signed_in?
      redirect_to '/nodes'
    end
  end

  def about
  end
end
