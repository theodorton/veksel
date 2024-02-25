module Veksel
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load "tasks/veksel_tasks.rake"
    end
  end
end
