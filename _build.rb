#!/usr/bin/env ruby

require "open3"
#-----------------------
# CONFIG
#-----------------------
js = %w{
  lib/js/phonegap.js
  lib/js/jquery.js
  lib/js/jqtouch.js
  lib/js/icanhaz.js
  lib/js/underscore.js
  lib/js/SAiOSKeychainPlugin.js
  src/javascript/subscribe.js
}
css = %w{
  lib/theme/jqtouch.css
  lib/theme/theme.css
  src/css/master.css
}

def concat(files, output, type)
  f = ''
  files.each do |file|
    f_in = File.open(file, "r")
    f_in.each {|f_str| f << f_str}
    f_in.close
  end
  output_file = File.new("www/assets/#{output}", "w")
  compressed = ''
  Open3.popen3 "yuicompressor --type #{type}" do |stdin, stdout, stderr|
    stdin.write f
    stdin.close
    compressed = stdout.read
  end
  
  output_file.puts(compressed)
  output_file.close
end

assets = '
<link rel="stylesheet" href="assets/subscribe.css" />
<script src="assets/subscribe.js"></script>  
'

index = File.read('src/index.html')
index = index.gsub(/<!-- ASSETS_MARK -->(.*?)<!-- ASSETS_MARK -->/m, assets)

# Write back out to the file
index_www = File.new("www/index.html", "w")
index_www.puts index
index_www.close


# Move images
`rsync -vac --delete lib/theme/img/ www/assets/img/`
`rsync -vac --delete src/images/ www/images/`

# Compile coffeescript
`coffee --bare --join ~/Sites/com.benubois.subscribe/src/javascript/subscribe.js --compile ~/Sites/com.benubois.subscribe/src/coffeescript/*.coffee`

# Build css
concat(css, 'subscribe.css', 'css')

# Build js
concat(js, 'subscribe.js', 'js')

