#!/usr/bin/ruby
require 'xcodeproj'

project = Xcodeproj::Project.open("SQLite.xcodeproj")
sqlite_file = project['Tests']['SQLiteTests'].new_file('firefly.sqlite')

target = project.targets.select { |target| target.name == 'SQLiteTests' }.first
target.add_file_references([sqlite_file])

resources_folder = "7"
phase = target.new_copy_files_build_phase()
phase.dst_subfolder_spec = resources_folder
phase.add_file_reference(sqlite_file)   

project.save()
