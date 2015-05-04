class NodesController < ApplicationController
  before_action :authenticate_user!
  before_action :fetch_node, only: [:show, :edit, :update, :destroy]
  before_action :new_node, only: [:new, :create]

  def new
    @node.x = params[:x]
    @node.y = params[:y]
    respond_to do |f|
      f.html { render layout: !request.xhr? }
    end
  end

  def sync
    nodes = JSON.parse params[:nodes]
    nodes.each do |node|
      current_user.nodes
      .find(node['id'])
      .update(x: node['x'], y: node['y'])
    end
    render nothing: true, status: 200
  end

  def create
    @node.update_attributes(node_params)
    if @node.save
      make_references
      redirect_to node_path(@node)
    else
      flash[:alert] = 'Failed to create node.'
      render :new
    end
  end

  def edit
    respond_to do |f|
      f.html { render layout: !request.xhr? }
    end
  end

  def update
    if child_params
      @parent = Node.find(params[:id])
      @child = @parent.neighbours.build(child_params)
      @child.user = current_user
      if @child.save
        make_references(@child)
        @parent.content += "\n[#{@child.title}]: /nodes/#{@child.id}"
        unless make_references(@parent)
          flash[:alert] = 'Failed to associate nodes'
        end
        redirect_to node_path(@child)
      else
        flash[:alert] = 'Failed to create child'
        redirect_to '/'
      end
    else
      if @node.update(node_params)
        make_references(@node)
        redirect_to node_path(@node)
      else
        flash[:alert] = 'Failed to update node'
        render 'edit'
      end
    end
  end

  def destroy
    if Node.destroy(params[:id])
      redirect_to '/'
    else
      flash[:alert] = 'Deletion failed'
      render 'edit'
    end
  end

  def show
    respond_to do |f|
      f.html { render layout: !request.xhr? }
    end
  end

  def index
    respond_to do |f|
      f.html
      f.js
    end
  end

  def search
    @results = Node.find_by_sql(
      'SELECT title FROM nodes WHERE title LIKE ?',
      [params[:query]])
    respond_to do |f|
      f.js
    end
  end

  private

  def fetch_node
    @node = current_user.nodes.find(params[:id])
  end

  def node_params
    params.require(:node).permit(:title, :content, :level, :x, :y)
  end

  def child_params
    if params[:node][:node]
      params.require(:node).require(:node).permit(:title, :content, :level)
    end
  end

  def make_references(node = nil)
    node ||= @node
    old = node.references.map(&:neighbour_id)
    actual = node.refs_from_source
    node.references.where('neighbour_id in (?)', old - actual).delete_all
    node.references.build( (actual - old).map { |n| {neighbour_id: n} })
    node.save
  end

  def new_node
    @node = current_user.nodes.build
  end
end
