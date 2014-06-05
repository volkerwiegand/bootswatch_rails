module BootswatchRails
  class Engine < Rails::Engine
    initializer "BootswatchRails themes" do |app|
      app.config.assets.precompile += %w()
      app.config.assets.paths << File.expand_path('../../../vendor/assets/fonts', __FILE__)
    end
  end
end

