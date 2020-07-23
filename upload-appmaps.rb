#!/usr/bin/env ruby
# frozen_string_literal: true

# Install this file to the bin directory of your project.
# You might want to rename it upload-appmaps and set the executable bit:
# chmod a+x bin/upload-appmaps

# Invoke this script with command line options to the AppLand CLI.
# Two typical options that you'll want to provide:
# * -a option to specify the fully qualified org-name/app-name.
# * Path(s) to the appmap.json files you want to upload.

# Usage example:
# ./bin/upload-appmaps -a '"org-name/project-name"' tmp/appmap/minitest

def env_var(key)
  var = ENV[key]
  if var.nil? || var.empty?
    nil
  else
    var
  end
end

def env_var?(key)
  !env_var(key).nil?
end

def debug?
  env_var?('DEBUG')
end

def dry_run?
  env_var?('DRY_RUN')
end

def ci_branch
  # In pull requests, TRAVIS_BRANCH is "master". Huh?
  env_var('TRAVIS_PULL_REQUEST_BRANCH') || env_var('TRAVIS_BRANCH')
end

def ci?
  !ci_branch.nil?
end

def git_last_tag
  tag = `git describe --tags --abbrev=0`.strip
  puts "tag: #{tag}" if debug?
  tag.empty? ? nil : tag
end

def git_commits_since_tag(tag)
  `git log #{git_last_tag}..HEAD --oneline`.split("\n").length.tap do |length|
    puts "commits since #{tag}: #{length}" if debug?
  end
end

args = %w(appland upload)

if ci_branch
  args << [ '-b', ci_branch ]
end

if ci?
  args << %w(-e ci)
  args << '--no-open'
end

if ci_branch == 'master'
  tag = git_last_tag
  if tag && git_commits_since_tag(tag) == 0
    args << '-v'
    args << tag
  end
end

args += ARGV unless ARGV.length == 0

puts args.join(' ') if debug?

Kernel.exec(args.join(' ')) unless dry_run?
