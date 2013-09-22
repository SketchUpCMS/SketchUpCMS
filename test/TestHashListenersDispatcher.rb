#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require 'test/unit'
require "stringio"

require "lib/HashListenersDispatcher"
require "lib/ddlcallbacks_listeners"
  
##____________________________________________________________________________||
class TestHashListenersDispatcher < Test::Unit::TestCase

  class MockListener < DDLListener
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
    def listener_enter(name, attributes)
      message = [:listener_enter, name, attributes]
      @allMessages << message
      @lastMessage = message
    end
    def listener_exit(name)
      message = [:listener_exit, name]
      @allMessages << message
      @lastMessage = message
    end
  end

  def test_initial_state
    hld = HashListenersDispatcher.new
    assert_nil(hld.currentListener)
    assert_nil(hld.currentTagName)
    aSectionListener = DDLListener.new
    hld.add_listner("ASection", aSectionListener)
    assert_nil(hld.currentListener)
    assert_nil(hld.currentTagName)
  end
  
  def test_currentListener
    hld = HashListenersDispatcher.new
    aSectionListener = DDLListener.new
    hld.add_listner("ASection", aSectionListener)
    hld.tag_start("ASection", {})
    assert_equal(aSectionListener, hld.currentListener)
    hld.tag_start("A", {})
    assert_equal(aSectionListener, hld.currentListener)
    hld.text("abcde")
    assert_equal(aSectionListener, hld.currentListener)
    hld.tag_end("A")
    assert_equal(aSectionListener, hld.currentListener)
    hld.tag_end("ASection")
    assert_nil(hld.currentListener)
  end
  
  def test_currentTagName
    hld = HashListenersDispatcher.new
    aSectionListener = DDLListener.new
    hld.add_listner("ASection", aSectionListener)
    hld.tag_start("ASection", {})
    assert_equal("ASection", hld.currentTagName)
    hld.tag_start("A", {})
    assert_equal("ASection", hld.currentTagName)
    hld.text("abcde")
    assert_equal("ASection", hld.currentTagName)
    hld.tag_end("A")
    assert_equal("ASection", hld.currentTagName)
    hld.tag_end("ASection")
    assert_nil(hld.currentTagName)
  end
  
  def test_callbacks
    hld = HashListenersDispatcher.new
    aSectionListener = MockListener.new
    hld.add_listner("ASection", aSectionListener)
    hld.tag_start("ASection", {})
    assert_equal([:listener_enter, "ASection", {}], aSectionListener.lastMessage)
    hld.tag_start("A", {})
    assert_equal([:tag_start, "A", {}], aSectionListener.lastMessage)
    hld.text("abcde")
    assert_equal([:text, "abcde"], aSectionListener.lastMessage)
    hld.tag_end("A")
    assert_equal([:tag_end, "A"], aSectionListener.lastMessage)
    hld.tag_end("ASection")
    assert_equal([:listener_exit, "ASection"], aSectionListener.lastMessage)

    assert_equal([
                  [:listener_enter, "ASection", {}],
                  [:tag_start, "A", {}],
                  [:text, "abcde"],
                  [:tag_end, "A"],
                  [:listener_exit, "ASection"]],
                 aSectionListener.allMessages)
  end

  def test_twoListeners
    hld = HashListenersDispatcher.new
    aSectionListener = MockListener.new
    bSectionListener = MockListener.new
    hld.add_listner("ASection", aSectionListener)
    hld.add_listner("BSection", bSectionListener)
    hld.tag_start("ASection", {})
    assert_equal([:listener_enter, "ASection", {}], aSectionListener.lastMessage)
    hld.tag_start("A", {})
    assert_equal([:tag_start, "A", {}], aSectionListener.lastMessage)
    hld.text("abcde")
    assert_equal([:text, "abcde"], aSectionListener.lastMessage)
    hld.tag_end("A")
    assert_equal([:tag_end, "A"], aSectionListener.lastMessage)
    hld.tag_end("ASection")
    assert_equal([:listener_exit, "ASection"], aSectionListener.lastMessage)

    hld.tag_start("BSection", {})
    assert_equal([:listener_enter, "BSection", {}], bSectionListener.lastMessage)
    hld.tag_start("B", {})
    assert_equal([:tag_start, "B", {}], bSectionListener.lastMessage)
    hld.text("fghijk")
    assert_equal([:text, "fghijk"], bSectionListener.lastMessage)
    hld.tag_end("B")
    assert_equal([:tag_end, "B"], bSectionListener.lastMessage)
    hld.tag_end("BSection")
    assert_equal([:listener_exit, "BSection"], bSectionListener.lastMessage)

    assert_equal([
                  [:listener_enter, "ASection", {}],
                  [:tag_start, "A", {}],
                  [:text, "abcde"],
                  [:tag_end, "A"],
                  [:listener_exit, "ASection"]],
                 aSectionListener.allMessages)

    assert_equal([
                  [:listener_enter, "BSection", {}],
                  [:tag_start, "B", {}],
                  [:text, "fghijk"],
                  [:tag_end, "B"],
                  [:listener_exit, "BSection"]],
                 bSectionListener.allMessages)
  end

end

##____________________________________________________________________________||
