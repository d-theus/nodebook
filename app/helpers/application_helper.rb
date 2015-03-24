module ApplicationHelper
  def inline_svg(name, path='app/assets/images')
    name += '.svg' unless name.ends_with?('.svg')
    raw File.open(File.join(path,name)).read
  end
end
