Gem::Specification.new do |s|
  s.name        = 'rimesync'
  s.version     = '0.1.0'
  s.licenses    = ['Apache-2']
  s.authors     = ['OSU Open Source Lab', 'Chaitanya Gupta']
  s.homepage    = 'https://github.com/osuosl/rimesync'
  s.summary     = 'A ruby Gem to interface with the TimeSync API.'
  s.description = 'A ruby Gem to interface with the TimeSync API.'

  s.required_ruby_version     = '>= 1.9.3'

  s.add_dependency 'bcrypt', '= 3.1.11'
  s.add_dependency 'rest-client', '= 1.8.0'
  s.add_dependency 'webmock', '= 2.1.0'

  s.files         = `git ls-files`.split('\n')
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split('\n')
end
