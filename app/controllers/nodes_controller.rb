class NodesController < ApplicationController
  before_action :fetch_node, only: [:show, :edit, :update, :destroy]
  before_action :construct_node, only: [:new]

  def new
  end

  def instant_new_for
    @parent = Node.find(params[:id])
    @node = @parent.neighbours.build
    render partial: 'instant_form'
  end

  def create
    @node = Node.new(node_params)
    if @node.save
      make_references
      redirect_to node_path(@node)
    else
      flash[:error] = 'Failed to create node.'
      render :new
    end
  end

  def edit
  end

  def update
    if child_params
      @parent = Node.find(params[:id])
      @child = @parent.neighbours.build(child_params)
      if @child.save
        make_references(@child)
        @parent.content += "\n[#{@child.title}]: \"/nodes/#{@child.id}\""
        make_references(@parent)
        flash[:errors] = 'Failed to associate nodes'
      else
        flash[:errors] = 'Failed to create child'
      end
      redirect_to '/'
    else
      if @node.update(node_params)
        make_references(@node)
        redirect_to node_path(@node)
      else
        flash[:errors] = 'Failed to update node'
        render 'edit'
      end
    end
  end

  def destroy
    if Node.destroy(params[:id])
      redirect_to '/'
    else
      flash[:error] = 'Deletion failed'
      render 'edit'
    end
  end

  def show
  end

  def index
    respond_to do |f|
      f.html
      f.js
    end
  end
  private

  def fetch_node
    @node = Node.find(params[:id])
  end

  def construct_node
    @node = Node.new
  end

  def node_params
    params.require(:node).permit(:title, :content, :level)
  end

  def child_params
    if params[:node][:node]
      params.require(:node).require(:node).permit(:title, :content)
    end
  end

  def make_references(node = nil)
    node ||= @node
    old = node.references.map(&:neighbour_id)
    actual = node.refs_from_source
    node.references.where('neighbour_id in (?)', old - actual).delete_all
    node.references.build( (actual - old).map { |n| {neighbour_id: n} })
    node.save!
  end
end
