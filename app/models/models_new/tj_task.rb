# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/models/tj_macro.rb
##
# The Abstract Notion of a TaskJuggler Task
class TjTask < ActiveRecord::Base
  unloadable
  ##
  # The code identifier
  attr_accessor :code
  ##
  # The name
  attr_accessor :name
end
