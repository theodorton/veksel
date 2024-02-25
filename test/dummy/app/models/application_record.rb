class ApplicationRecord < ActiveRecord::Base
  if Rails::VERSION::MAJOR >= 7
    primary_abstract_class
  end
end
