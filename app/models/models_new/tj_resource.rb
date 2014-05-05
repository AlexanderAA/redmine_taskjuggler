# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/models/tj_macro.rb
##
# The Extending of a Resource or Task within the Project declaration in TaskJuggler
# Used by Composite Resource and Leaf Resource
class TjResource < ActiveRecord::Base
  unloadable
  ##
  # The code identifier
  attr_accessor :code
  ##
  # The name
  attr_accessor :name
end