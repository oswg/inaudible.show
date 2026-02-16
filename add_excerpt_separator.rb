#!/usr/bin/env ruby
# Add <!--more--> before Show Notes h2 in all posts

count = 0
Dir.glob("_posts/*.markdown").each do |path|
  content = File.read(path)
  next unless content.include?("Show Notes") && !content.include?("<!--more-->")

  # Insert <!--more--> before <h2...>Show Notes (handles Show&nbsp;Notes too)
  new_content = content.gsub(/(\n)(\s*<h2[^>]*>Show\s*Notes)/i) do
    "#{$1}<!--more-->#{$1}#{$2}"
  end

  if new_content != content
    File.write(path, new_content)
    count += 1
    puts "Updated: #{path}"
  end
end
puts "Done. Updated #{count} files."
