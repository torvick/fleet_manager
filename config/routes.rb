# config/routes.rb
Rails.application.routes.draw do
  # Helper para cargar sub-archivos de rutas
  def draw(name)
    instance_eval(Rails.root.join("config/routes/#{name}.rb").read)
  end

  draw :health
  draw :api
  draw :web
end
