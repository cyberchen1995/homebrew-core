class Ggc < Formula
  desc "Modern Git CLI"
  homepage "https://github.com/bmf-san/ggc"
  url "https://github.com/bmf-san/ggc/archive/refs/tags/v4.0.0.tar.gz"
  sha256 "6256153b5f79c8320860978456645442fd696ed8a8bb706418cc4e1627661023"
  license "MIT"
  head "https://github.com/bmf-san/ggc.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d5c90d1ce1628856a578dad08808c60f0badf35f2bb68b69cdfeb14e2eec8747"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "d5c90d1ce1628856a578dad08808c60f0badf35f2bb68b69cdfeb14e2eec8747"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "d5c90d1ce1628856a578dad08808c60f0badf35f2bb68b69cdfeb14e2eec8747"
    sha256 cellar: :any_skip_relocation, sonoma:        "50461dd8611510ca7afece9e1b7ba59111c219052b9f4061470c079000daa804"
    sha256 cellar: :any_skip_relocation, ventura:       "50461dd8611510ca7afece9e1b7ba59111c219052b9f4061470c079000daa804"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "85c4badeeb5e2c11988efc1a67d543675c32c541f759bb6abafdd55f527ce00b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4c6192cdf939eda59d01d6ff5370b78c79356c074ff00e2b0dc2d1800117c728"
  end

  depends_on "go" => :build

  def install
    ldflags = "-s -w -X main.version=#{version} -X main.commit=#{tap.user}"
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ggc version")

    # `vim` not found in `PATH`
    return if OS.linux? && ENV["HOMEBREW_GITHUB_ACTIONS"]

    assert_equal "main", shell_output("#{bin}/ggc config get default.branch").chomp
  end
end
