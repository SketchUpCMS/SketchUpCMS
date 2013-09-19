# Tai Sakuma <sakuma@fnal.gov>


##____________________________________________________________________________||
# to use OSX system Ruby
$LOAD_PATH.push("/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8")

# to use MacPorts Ruby
# $LOAD_PATH.push("/opt/local/lib/ruby/site_ruby/", "/opt/local/lib/ruby/1.8")

##____________________________________________________________________________||
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)) + "/lib")

##____________________________________________________________________________||
# The path to gratr.
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)) + "/gratr/lib")

##____________________________________________________________________________||
