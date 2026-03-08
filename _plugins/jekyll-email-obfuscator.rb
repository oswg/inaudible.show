# frozen_string_literal: true

# jekyll-email-obfuscator
#
# Hides your email from bots while keeping it visible and clickable for humans.
# Renders the address as a raster PNG (no extractable text) and builds the
# mailto link only on click via JavaScript.
#
# Setup:
#   1. Add email to _config.yml:  email: you@example.com
#   2. Copy assets/footer-contact.js from this plugin's template (see below)
#   3. In your footer: {% if site.email %}{% include email_obfuscation.html %}{% endif %}
#   4. In your layout (before </body>): {% if site.email %}<script src="{{ '/assets/footer-contact.js' | relative_url }}"></script>{% endif %}
#   5. Add CSS: .footer-email { height: 1.4em; vertical-align: middle; }
#              .footer-email-link { text-decoration: none; }
#
# When ImageMagick (magick or convert) is installed, the plugin generates
# assets/email.png at build time. Otherwise, commit a pre-generated
# assets/email.png (e.g. for GitHub Pages). Run: echo -n 'you@example.com' > /tmp/e.txt
# then: magick -background transparent -fill black -font Times-New-Roman
#       -pointsize 16 "label:@/tmp/e.txt" -strip assets/email.png
#
# License: MIT

require "base64"
require "fileutils"
require "open3"
require "tempfile"

module Jekyll
  module EmailObfuscator
    def self.generate(site)
      return unless site.config["email"]

      email = site.config["email"].to_s
      return if email.empty? || !email.include?("@")

      parts = email.split("@", 2)
      return unless parts.length == 2

      assets_dir = File.join(site.dest, "assets")
      FileUtils.mkdir_p(assets_dir)

      # 1. Generate PNG (no plaintext; strips metadata)
      png_path = File.join(assets_dir, "email.png")
      generate_png(email, png_path)

      # 2. Generate footer-contact.js (base64-encoded mailto)
      user_b64 = Base64.strict_encode64(parts[0])
      domain_b64 = Base64.strict_encode64(parts[1])
      js = <<~JS
        document.querySelectorAll('.footer-email-link').forEach(function (a) {
          a.addEventListener('click', function (e) {
            e.preventDefault();
            try {
              var u = atob("#{user_b64}");
              var d = atob("#{domain_b64}");
              if (u && d) location.href = 'mailto:' + u + '@' + d;
            } catch (_) {}
          });
        });
      JS
      File.write(File.join(assets_dir, "footer-contact.js"), js)
    end

    def self.generate_png(email, dest_path)
      Tempfile.create(["email", ".txt"]) do |f|
        f.write(email)
        f.close
        exe = find_executable("magick") || find_executable("convert")
        if exe
          args = ["-background", "transparent", "-fill", "black",
                  "-font", "Times-New-Roman", "-pointsize", "16",
                  "label:@#{f.path}", "-strip"]
          args << (exe.include?("magick") ? "png:#{dest_path}" : dest_path)
          _out, err, status = Open3.capture3(exe, *args)
          Jekyll.logger.warn "Email obfuscator:", err unless status.success?
        else
          Jekyll.logger.warn "Email obfuscator:", "ImageMagick not found. Commit assets/email.png for GitHub Pages."
        end
      end
    rescue StandardError => e
      Jekyll.logger.warn "Email obfuscator:", e.message
    end

    def self.find_executable(name)
      paths = ENV["PATH"].to_s.split(File::PATH_SEPARATOR)
      paths.each do |path|
        exe = File.join(path, name)
        return exe if File.executable?(exe) && !File.directory?(exe)
      end
      nil
    end
  end

  Jekyll::Hooks.register :site, :post_write do |site|
    EmailObfuscator.generate(site)
  end
end
