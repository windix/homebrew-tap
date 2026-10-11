class Vcs < Formula
  desc "Creates video contact sheets (previews) of videos"
  homepage "https://github.com/windix/video-contact-sheet"
  url "https://github.com/windix/video-contact-sheet/archive/refs/tags/v1.14.0.tar.gz"
  sha256 "ba65fc75040d656cb99d86e88a30db8742637a48c203e3ae25fce0de80cf4dd5"
  license "LGPL-2.0-or-later"
  head "https://github.com/windix/video-contact-sheet.git", branch: "master"

  depends_on "docbook" => :build
  depends_on "docbook-xsl" => :build
  depends_on "ffmpeg"
  depends_on "ghostscript"
  depends_on "imagemagick"

  uses_from_macos "libxslt" => :build

  on_macos do
    depends_on "gnu-getopt"
  end

  def install
    cd "dist" do
      # Generate the man pages (vcs.1 and vcs.conf.5) from DocBook sources
      ENV["XML_CATALOG_FILES"] = etc/"xml/catalog"
      system "make", "-C", "docs", "vcs.1", "vcs.conf.5",
             "DOCBOOK_XSL=#{formula_opt_prefix("docbook-xsl")}/docbook-xsl"

      system "make", "install", "prefix=#{prefix}"
    end
  end

  test do
    system formula_opt_bin("ffmpeg")/"ffmpeg", "-f", "rawvideo", "-s", "hd720",
           "-pix_fmt", "yuv420p", "-r", "30", "-t", "5", "-i", "/dev/zero",
           testpath/"video.mp4"
    assert_path_exists testpath/"video.mp4"

    system bin/"vcs", "-i", "1", "-o", testpath/"sheet.png", testpath/"video.mp4"
    assert_path_exists testpath/"sheet.png"
  end
end
