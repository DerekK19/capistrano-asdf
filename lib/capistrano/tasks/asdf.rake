ASDF_USER_PATH = "~/.asdf"
ASDF_DEFAULT_TOOLS = %w{ruby nodejs}
# Ruby related bins
ASDF_DEFAULT_RUBY_BINS = %w{rake gem bundle ruby rails}
# Nodejs related bin
ASDF_DEFAULT_NODEJS_BINS = %w{node npm yarn}

namespace :asdf do
  desc "Prints the ASDF tools versions on the target host"
  task :check do
    on roles(fetch(:asdf_roles, :all)) do
      execute("source #{fetch(:asdf_path)}/asdf.sh; asdf current")
    end
  end
  
  task :map_ruby_bins do
    if fetch(:asdf_tools).include?('ruby')
      fetch(:asdf_map_ruby_bins).each do |mapped_command|
        SSHKit.config.command_map.prefix[mapped_command.to_sym].unshift("source #{fetch(:asdf_path)}/asdf.sh;")
      end
    end
  end

  task :map_nodejs_bins do
    if fetch(:asdf_tools).include?('nodejs')
      fetch(:asdf_map_nodejs_bins).each do |mapped_command|
        SSHKit.config.command_map.prefix[mapped_command.to_sym].unshift("source #{fetch(:asdf_path)}/asdf.sh;")
      end
    end
  end
  
end

Capistrano::DSL.stages.each do |stage|
  after stage, 'asdf:map_ruby_bins'
  after stage, 'asdf:map_nodejs_bins'
end

namespace :load do
  task :defaults do
    set :asdf_path, -> {
      asdf_path = fetch(:asdf_custom_path)
      asdf_path ||= ASDF_USER_PATH
    }

    set :asdf_tools, fetch(:asdf_tools, ASDF_DEFAULT_TOOLS)

    set :asdf_map_ruby_bins, fetch(:asdf_map_ruby_bins, ASDF_DEFAULT_RUBY_BINS)
    set :asdf_map_nodejs_bins, fetch(:asdf_map_nodejs_bins, ASDF_DEFAULT_NODEJS_BINS)
  end
end
