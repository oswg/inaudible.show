# frozen_string_literal: true

# Sets page.youtube_id from front matter or the first YouTube embed in the post body.
module Jekyll
  YOUTUBE_EMBED = /youtube\.com\/embed\/([a-zA-Z0-9_-]{11})/

  Jekyll::Hooks.register :posts, :post_init do |post|
    next if post.data["youtube_id"]
    next unless post.path && File.file?(post.path)

    raw = File.read(post.path)
    body = raw.sub(/\A---\s*\n.*?\n---\s*\n/m, "")
    m = body.match(YOUTUBE_EMBED)
    post.data["youtube_id"] = m[1] if m
  end
end