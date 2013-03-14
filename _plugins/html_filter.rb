# encoding: utf-8
require 'rubygems'
require 'nokogiri'

module Liquid
  module StandardFilters
    
    def truncateline(raw, max_length = 15, continuation_string = "...")
      index = raw.index("\n")
      raw[0, index]
    end
      
  end
end