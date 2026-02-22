#!/usr/bin/env ruby
# 1. Posts WITH media: move <!-- more --> to before the first media element
# 2. Posts WITHOUT media: add <!-- more --> after 2 paragraphs

MEDIA_PATTERNS = [
  /<iframe/i,
  /<figure[^>]*wp-block-embed|wp-embed-youtube/i,
  /youtube\.com\/embed|youtube\.com\/watch/i,
  /player\.captivate\.fm/i
].freeze

def has_media?(content)
  MEDIA_PATTERNS.any? { |re| content =~ re }
end

def has_more?(content)
  content =~ /<!--\s*more\s*-->/
end

def remove_more(content)
  content.gsub(/\n*<!--\s*more\s*-->\n*/i, "\n")
end

def find_first_media_line(content)
  content.each_line.with_index do |line, i|
    return i if MEDIA_PATTERNS.any? { |re| line =~ re }
  end
  nil
end

def insert_more_before_media(content)
  lines = content.each_line.to_a
  media_idx = find_first_media_line(content)
  return content unless media_idx

  # Remove any existing more
  new_lines = remove_more(lines.join).each_line.to_a
  # Re-find media index after removal
  media_idx = find_first_media_line(new_lines.join)
  return content if media_idx.nil?

  # Don't insert if more is already right before media
  return content if media_idx > 0 && new_lines[media_idx - 1].strip =~ /<!--\s*more\s*-->/

  # Insert <!-- more --> before media line
  new_lines.insert(media_idx, "\n<!-- more -->\n\n")
  new_lines.join
end

def add_more_after_two_paragraphs(content)
  return content if has_more?(content)

  # Split out front matter
  if content =~ /\A(---\n.*?\n---\n)(.*)\z/m
    front_matter = $1
    body = $2
  else
    return content
  end

  # Find paragraphs: <p>...</p> or blocks separated by \n\n
  para_count = 0
  insert_pos = nil

  if body =~ /<p>/
    # HTML paragraphs
    pos = 0
    while pos < body.length
      start_idx = body.index("<p>", pos)
      break unless start_idx
      end_idx = body.index("</p>", start_idx)
      break unless end_idx
      para_count += 1
      if para_count == 2
        insert_pos = end_idx + 4  # After </p>
        break
      end
      pos = end_idx + 4
    end
  else
    # Plain text: paragraphs separated by blank lines
    paragraphs = body.split(/\n\n+/)
    if paragraphs.length >= 2
      # Find position after 2nd paragraph
      first_two = paragraphs[0] + "\n\n" + paragraphs[1]
      insert_pos = first_two.length
    elsif paragraphs.length == 1
      # Single block - add after first sentence or at 300 chars?
      insert_pos = [paragraphs[0].length, 400].min
    end
  end

  return content unless insert_pos

  before = body[0...insert_pos]
  after = body[insert_pos..-1]
  new_body = before.rstrip + "\n\n<!-- more -->\n\n" + after.lstrip
  front_matter + new_body
end

count_media = 0
count_no_media = 0

Dir.glob("_posts/*.markdown").each do |path|
  content = File.read(path)
  new_content = if has_media?(content)
    count_media += 1
    insert_more_before_media(content)
  else
    count_no_media += 1
    add_more_after_two_paragraphs(content)
  end

  if new_content != content
    File.write(path, new_content)
    puts "Updated: #{path}"
  end
end

puts "Done. Processed #{count_media} with media, #{count_no_media} without."
