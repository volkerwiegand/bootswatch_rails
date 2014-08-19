module BootswatchRails
  class Engine < Rails::Engine
    initializer "BootswatchRails themes" do |app|
      app.config.assets.precompile += %w(amelia.css cerulean.css cosmo.css custom.css cyborg.css darkly.css flatly.css journal.css lumen.css paper.css readable.css sandstone.css simplex.css slate.css spacelab.css superhero.css united.css yeti.css)
      app.config.assets.paths << File.expand_path('../../../vendor/assets/fonts', __FILE__)
    end
  end
end

