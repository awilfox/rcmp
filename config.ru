$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
%w[config irc shorten github web].map {|r| require("rcmp/#{r}") }

run RCMP::Web