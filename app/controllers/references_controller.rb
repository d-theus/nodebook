class ReferencesController < ApplicationController
  def index
    respond_to do |f|
      f.js
    end
  end

  def new
  end

  def destroy
  end
end
