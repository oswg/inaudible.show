#!/usr/bin/env ruby
# Fix excerpts: with media -> <!-- more --> before media; without media -> <!-- more --> after 2 paras

def has_media?(content)
  content =~ /<iframe|<figure[^>]*youtube|youtube\.com/i
end

def first_media_pos(content)
  # Prefer <div before iframe (podcast player wrapper) over raw <iframe>
  div_match = content.match(/<div[^>]*>\s*<iframe/i)
  iframe_match = content.match(/<iframe/i)
  figure_match = content.match(/<figure[^>]*youtube/i)
  [div_match&.begin(0), iframe_match&.begin(0), figure_match&.begin(0)].compact.min
end

def process_post_with_media(body)
  body = body.gsub(/\s*<!--\s*more\s*-->\s*\n?/, "")
  pos = first_media_pos(body)
  return body unless pos

  body.insert(pos, "\n\n<!-- more -->\n\n")
end

def find_end_of_second_para(body)
  # Find end of 2nd </p> tag
  ends = []
  body.scan(/<\/p\s*>/i) { ends << $~.end(0) }
  return ends[1] if ends.size >= 2
  return ends[0] if ends.size >= 1

  # No </p>: use double-newline blocks (markdown paragraphs)
  parts = body.split(/\n\n+/, 3)
  return nil if parts.empty?
  return parts[0].length + 2 if parts.size >= 2
  body.length
end

def process_post_without_media(body)
  body = body.gsub(/\s*<!--\s*more\s*-->\s*\n?/, "")
  pos = find_end_of_second_para(body)
  return body unless pos
  body.insert(pos, "\n\n<!-- more -->\n\n")
end

count = 0
Dir.glob("_posts/*.markdown").each do |path|
  content = File.read(path)
  next unless content =~ /\A(---\s*\n.*?\n---\s*\n)(.*)/m
  front_matter, body = $1, $2

  new_body = has_media?(body) ? process_post_with_media(body) : process_post_without_media(body)

  if new_body != body
    File.write(path, front_matter + new_body)
    count += 1
    puts "Updated: #{path}"
  end
end
puts "Done. Updated #{count} files."
