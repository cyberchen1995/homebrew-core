class Cxgo < Formula
  desc "Transpiling C to Go"
  homepage "https://github.com/gotranspile/cxgo"
  url "https://github.com/gotranspile/cxgo/archive/refs/tags/v0.5.2.tar.gz"
  sha256 "942393dc381dcf47724c93b5d6c4cd7695c0000628ecb7f30c5b99be4676ae83"
  license "MIT"
  head "https://github.com/gotranspile/cxgo.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d9a9a62216f8300ad29ae5fe74a68b83e5ed4a045049b4591773db6cc0e966a6"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "d9a9a62216f8300ad29ae5fe74a68b83e5ed4a045049b4591773db6cc0e966a6"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "d9a9a62216f8300ad29ae5fe74a68b83e5ed4a045049b4591773db6cc0e966a6"
    sha256 cellar: :any_skip_relocation, sonoma:        "ee676dcdd16dfa2269b7258badf53eefdb46098bca204967434b04de4f373508"
    sha256 cellar: :any_skip_relocation, ventura:       "ee676dcdd16dfa2269b7258badf53eefdb46098bca204967434b04de4f373508"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "03f4af4d55caab6d3fa0f3cfa536754c2cd8ef70ee4a8f42a27cb60b06adad6f"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X main.version=#{version}
      -X main.commit=#{tap.user}
      -X main.date=#{time.iso8601}
    ]

    system "go", "build", *std_go_args(ldflags:), "./cmd/cxgo"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdio.h>
      int main() {
        printf("Hello, World!");
        return 0;
      }
    C

    expected = <<~GO
      package main

      import (
      \t"github.com/gotranspile/cxgo/runtime/stdio"
      \t"os"
      )

      func main() {
      \tstdio.Printf("Hello, World!")
      \tos.Exit(0)
      }
    GO

    system bin/"cxgo", "file", testpath/"test.c"
    assert_equal expected, (testpath/"test.go").read

    assert_match version.to_s, shell_output("#{bin}/cxgo version")
  end
end
