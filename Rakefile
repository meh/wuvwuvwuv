require 'rake'
require 'rake/clean'

CLEAN.include('index.html')

task :default do
	sh 'bundle exec lissio build -f'
	sh 'zip -9r wuvwuvwuv.zip index.html manifest.json img/ css/'
end
