#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require 'test/unit'
require "stringio"

require "DDLCallbacks/ListenerDispatcher"
require "DDLCallbacks/DDLCallbacks"
  
##____________________________________________________________________________||
class TestDDLCallbacks < Test::Unit::TestCase

  class MockListenerDispatcher < ListenerDispatcher
    attr_accessor :allMessages, :lastMessage
    def initialize
      @allMessages = [ ]
      @lastMessage = [ ]
    end

    def tag_start(name, attributes)
      message = [:tag_start, name, attributes]
      @allMessages << message
      @lastMessage = message
    end
    def text(text)
      message = [:text, text]
      @allMessages << message
      @lastMessage = message
    end
    def tag_end(name)
      message = [:tag_end, name]
      @allMessages << message
      @lastMessage = message
    end
  end

  def setup  
    @listenerDispatcher = MockListenerDispatcher.new
    @callBacks = DDLCallbacks.new
    @callBacks.listenersDispatcher = @listenerDispatcher
  end

  def test_callbacks
    # <A a="abc">abcde</A>
    @callBacks.tag_start("A", {"a" => "abc"})
    assert_equal([:tag_start, "A", {"a"=>"abc"}], @listenerDispatcher.lastMessage)

    @callBacks.text("abcde")
    assert_equal([:text, "abcde"], @listenerDispatcher.lastMessage)

    @callBacks.tag_end("A")
    assert_equal([:tag_end, "A"], @listenerDispatcher.lastMessage)

    assert_equal([[:tag_start, "A", {"a"=>"abc"}], [:text, "abcde"], [:tag_end, "A"]], @listenerDispatcher.allMessages)
  end

  def test_rexml
    xmlstring = '<A a="abc">abcde</A>'
    file = StringIO.new(xmlstring)

    REXML::Document.parse_stream(file, @callBacks)
    assert_equal([[:tag_start, "A", {"a"=>"abc"}], [:text, "abcde"], [:tag_end, "A"]], @listenerDispatcher.allMessages)
  end
  
end

##____________________________________________________________________________||
