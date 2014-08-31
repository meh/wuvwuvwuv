require 'rake'
require 'rake/clean'

CLEAN.include('index.html')

task :default do
	sh 'bundle exec lissio build -f'
	sh 'wget https://github.com/meh/npapi-mumble-link/releases/download/v1.0.0.1/npMumbleLink.dll -O npMumbleLink.dll'
	sh 'zip -9r wuvwuvwuv.zip index.html manifest.json npMumbleLink.dll img/ css/'
end
