class Gsmartcontrol < Formula
  desc "Graphical user interface for smartctl"
  homepage "https://gsmartcontrol.shaduri.dev/"
  url "https://downloads.sourceforge.net/project/gsmartcontrol/2.0.0/gsmartcontrol-2.0.0.tar.gz"
  sha256 "64817d65e26186fa0434cc133ac8ac40c30f21e30dc261dd43d5390d7801d455"
  license any_of: ["GPL-2.0-only", "GPL-3.0-only"]

  bottle do
    sha256 arm64_sequoia:  "1916242e52844623186a4201ab67c2628709cd82848547346551ef12287e44fd"
    sha256 arm64_sonoma:   "52f08b5e92b71c55d6a4473e80fb5e1ae28ab5047a945c56d9f4f70890f9118f"
    sha256 arm64_ventura:  "3aee46b42e8a8612fcade8c0cd1999c6138c9e1336609a597074b384718e2ec4"
    sha256 arm64_monterey: "dc55153f945458a5b23a761059a57eaa4061b68cb5b5b67233fb78b8f084ebdc"
    sha256 sonoma:         "476e51e7542659e03c0b9ca44168cb46903583255a94f473273dd5a87b9ea6ba"
    sha256 ventura:        "99e1970cfadccca078b0c4b6974b23c30e2fa163a286215cb1c11bbf1860a715"
    sha256 monterey:       "425969b9249d3222383c4834850710e5b2a919720201c61fd547e4c8fd298a03"
    sha256 x86_64_linux:   "13ae669fbe45d24eef652a14415e744470be3a8863b472b41b328b808fd134d5"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "atkmm@2.28"
  depends_on "cairo"
  depends_on "cairomm@1.14"
  depends_on "glib"
  depends_on "glibmm@2.66"
  depends_on "gtk+3"
  depends_on "gtkmm3"
  depends_on "libsigc++@2"
  depends_on "pangomm@2.46"
  depends_on "pcre2"
  depends_on "smartmontools"

  on_macos do
    depends_on "llvm" => :build if DevelopmentTools.clang_build_version <= 1500

    depends_on "at-spi2-core"
    depends_on "gdk-pixbuf"
    depends_on "gettext"
    depends_on "harfbuzz"
    depends_on "pango"
  end

  on_linux do
    depends_on "gcc"
    depends_on "pango"
  end

  fails_with :clang do
    build 1500
    cause "Requires C++20 support"
  end

  fails_with :gcc do
    version "11"
    cause "Requires C++20"
  end

  def install
    ENV.llvm_clang if OS.mac? && DevelopmentTools.clang_build_version <= 1500

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system sbin/"gsmartcontrol", "--version"
  end
end
