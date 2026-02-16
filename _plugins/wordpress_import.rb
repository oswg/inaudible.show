#!/usr/bin/env ruby
# frozen_string_literal: true

# Import WordPress export XML into Jekyll _posts
# Usage: ruby _plugins/wordpress_import.rb [path/to/export.xml]
# Wrapped in __FILE__ check so it doesn't run when Jekyll loads plugins

require "rexml/document"
require "date"
require "fileutils"

def extract_text(element)
  return "" unless element
  element.texts.map(&:value).join
end

def extract_cdata(element)
  return "" unless element
  element.cdatas.map(&:value).join
end

def clean_content(html)
  # Strip WordPress block comments
  html.gsub(/<!--\s*\/?wp:[^>]*-->\n?/, "")
     .gsub(%r{https://inaudible\.show/?}, "")
     .gsub('href="/', 'href="/')
end

def parse_wp_date(date_str)
  return nil if date_str.nil? || date_str.empty? || date_str.include?("0000-00-00")
  DateTime.parse(date_str)
rescue ArgumentError
  nil
end

if __FILE__ == $PROGRAM_NAME
  xml_path = ARGV[0] || Dir.glob(File.expand_path("~/Downloads/inaudible*.xml")).first
  abort "Usage: ruby wordpress_import.rb [path/to/export.xml]" unless xml_path && File.exist?(xml_path)

  doc = REXML::Document.new(File.read(xml_path))
posts_dir = File.join(__dir__, "..", "_posts")
pages_dir = File.join(__dir__, "..")
FileUtils.mkdir_p(posts_dir)

posts_created = 0
pages_updated = 0

doc.elements.each("rss/channel/item") do |item|
  post_type = extract_cdata(item.elements["wp:post_type"]) || extract_text(item.elements["wp:post_type"])
  status = extract_cdata(item.elements["wp:status"]) || extract_text(item.elements["wp:status"])
  next unless status == "publish"

  title = extract_cdata(item.elements["title"]) || extract_text(item.elements["title"])
  next if title.nil? || title.strip.empty?

  post_date = parse_wp_date(extract_cdata(item.elements["wp:post_date"]))
  post_name = extract_cdata(item.elements["wp:post_name"]) || extract_text(item.elements["wp:post_name"]) || ""
  content_elem = item.elements["content:encoded"]
  content = content_elem ? (extract_cdata(content_elem) || extract_text(content_elem)) : ""

  categories = []
  item.elements.each("category[@domain='category']") do |cat|
    nicename = cat.attributes["nicename"]
    categories << (nicename || extract_text(cat)) unless (nicename || "").empty?
  end

  if post_type == "post"
    date = post_date || DateTime.now
    slug = post_name.to_s.strip
    slug = "post-#{posts_created}" if slug.empty?

    permalink = slug.start_with?("/") ? slug : "/#{slug}/"
    date_str = date.strftime("%Y-%m-%d %H:%M:%S %z")

    front_matter = {
      "layout" => "post",
      "title" => title.gsub(/"/, '\\"'),
      "date" => date_str,
      "permalink" => permalink
    }
    front_matter["categories"] = categories unless categories.empty?

    fm = front_matter.map { |k, v| "#{k}: #{v.inspect}" }.join("\n")
    body = clean_content(content)
    safe_slug = slug.gsub(%r{[^\w-]+}, "-").gsub(/-+/, "-").sub(/\A-|-\z/, "")
    safe_slug = "post-#{posts_created}" if safe_slug.empty?
    filename = "#{date.strftime('%Y-%m-%d')}-#{safe_slug}.markdown"

    filepath = File.join(posts_dir, filename)
    File.write(filepath, "---\n#{fm}\n---\n\n#{body}\n")
    posts_created += 1
    puts "Created: #{filename}"
  elsif post_type == "page" && post_name == "about-the-podcast"
    body = clean_content(content)
    File.write(
      File.join(pages_dir, "about.markdown"),
      "---\nlayout: page\ntitle: About the podcast\npermalink: /about-the-podcast/\n---\n\n#{body}\n"
    )
    pages_updated += 1
    puts "Updated: about.markdown"
  end
end

  puts "\nDone. Created #{posts_created} posts, updated #{pages_updated} pages."
end
