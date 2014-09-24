require 'rake'
require 'rake/clean'

CLEAN.include('index.html')

task :default do
	sh 'bundle exec lissio build -f'
	sh 'wget https://github.com/meh/npapi-mumble-link/releases/download/v1.0.0.3/npMumbleLink.dll -O npMumbleLink.dll'
	sh 'wget https://github.com/meh/npapi-clipboard/releases/download/v1.0.0.2/npClipboard.dll -O npClipboard.dll'
	sh 'chmod +rx npMumbleLink.dll npClipboard.dll'
	sh 'zip -9r wuvwuvwuv.zip index.html manifest.json npMumbleLink.dll npClipboard.dll img/ css/'
end
