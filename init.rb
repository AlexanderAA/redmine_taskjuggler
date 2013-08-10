#require 'redmine'
#
## Patches to the Redmine core. (Why do I do this ?)
#require 'dispatcher'
#require 'issue_patch'
#require 'user_patch'
#Dispatcher.to_prepare do
#  Issue.send(:include, IssuePatch)
#  Query.send(:include, UserPatch)
#end

Redmine::Plugin.register :redmine_taskjuggler do
  name 'Redmine Taskjuggler plugin'
  author 'Christopher Mann <christopher@mann.fr>'
  description 'This plug exports project status into TaskJuggler and imports the dates too !'
  version '0.1.0'
  url 'https://github.com/chris2fr/redmine_taskjuggler'
  author_url 'http://mann.fr'
  menu	:project_menu, :taskjuggler, { :controller => 'redmine_taskjuggler', :action => 'index' }, :caption => :taskjuggler_label, :param => :project_identifier
  permission :taskjuggler, {:taskjuggler => [:index, :export, :initial_export]}, :public => true
  #menu :project_menu, :taskjuggler, { :controller => 'taskjuggler', :action => 'test' }, :caption => 'Task Juggler File', :after => :activity, :param => :project_identifier
  #menu :application_menu, :tjstatus, { :controller => 'tjstatus', :action => 'index' }, :caption => 'Task Juggler'
end
