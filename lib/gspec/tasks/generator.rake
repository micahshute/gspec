task :file_utils do 
    require 'fileutils'
end

namespace :spec do 

    desc "Create test file for a class" 
    task :create_for, [:name] => :file_utils do |task, args|  
        file = Dir.pwd
        Dir.mkdir(file + '/spec') unless Dir.exist?(file + "/spec")
        
        starting_file = file + "/spec"
        klass = args[:name]
        proj_name = __dir__.split('/').last.downcase
        path_components = klass.split('::')
        namespace = path_components.shift if path_components.first.downcase == proj_name
        dirs = path_components[0...-1].map{|d| d.gsub(/(\w)([A-Z])/, '\1_\2').downcase}
        filename = path_components.last.gsub(/(\w)([A-Z])/, '\1_\2').downcase
        dirs.each.with_index do |d, i|
            prev_dirs = dirs[0...i].join("/")
            curr_dir = "/#{prev_dirs}/#{d}"
            Dir.mkdir(starting_file+ curr_dir) unless Dir.exist?(starting_file + curr_dir)
        end
        relpath = dirs.length > 0 ? "/#{dirs.join('/')}/#{filename}_spec.rb" : "/#{filename}_spec.rb"
        
        begin
            raise Errno::EEXIST if File.file?(starting_file + relpath)
            file = File.open(starting_file + relpath, 'w')
            boilerplate = <<-TEST
RSpec.describe #{klass} do 

  it "does something useful" do
    expect(false).to eq(true)
  end

end

TEST

            file.write(boilerplate)
            file.close
        rescue Errno::EEXIST => e
            puts "The test for #{klass} has already been created"

        end

    end

end