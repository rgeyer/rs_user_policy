Gem::Specification.new do |gem|
  gem.name = "rs_user_policy"
  gem.version = "0.0.1"
  gem.homepage = "http://www.rightscale.com"
  gem.license = "MIT"
  gem.summary = %Q{Manages users across many different child accounts of a RightScale Enterprise Master Account}
  gem.description = gem.summary
  gem.email = "ryan.geyer@rightscale.com"
  gem.authors = ["Ryan J. Geyer"]
  gem.executables << 'rs_user_policy'

  gem.add_dependency('right_api_client', '~> 1.5.9')
  gem.add_dependency('trollop', '~> 1.16')
  
  gem.files = Dir.glob("{bin}/**/*") + ["LICENSE.txt", "README.rdoc"]
end
