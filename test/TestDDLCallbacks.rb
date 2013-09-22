#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require 'test/unit'
require "stringio"

require "lib/ddlcallbacks"
  
##____________________________________________________________________________||
class TestDDLCallbacks < Test::Unit::TestCase

  class MockListenerDispatcher < ListenerDispatcher
    def tag_start(name, attributes)
      return "tag_start", name, attributes
    end
    def text(text)
      return "text", text
    end
    def tag_end(name)
      return "tag_end", name
    end
  end

  def setup  
    @listenerDispatcher = MockListenerDispatcher.new
    @callBacks = DDLCallbacks.new
    @callBacks.listenersDispatcher = @listenerDispatcher
  end

  def test_callbacks
    # <A a="abc">abcde</A>
    assert_equal(["tag_start", "A", {"a"=>"abc"}], @callBacks.tag_start("A", {"a" => "abc"}))
    assert_equal(["text", "abcde"], @callBacks.text("abcde"))
    assert_equal(["tag_end", "A"], @callBacks.tag_end("A"))
  end

  def test_rexml
    xmlstring = '"<A a="abc">abcde</A>"'
    file = StringIO.new(xmlstring)

    REXML::Document.parse_stream(file, @callBacks)
  end
  
end

##____________________________________________________________________________||
