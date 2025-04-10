class Kubevpn < Formula
  desc "Offers a Cloud-Native Dev Environment that connects to your K8s cluster network"
  homepage "https://www.kubevpn.dev"
  url "https://github.com/kubenetworks/kubevpn/archive/refs/tags/v2.6.0.tar.gz"
  sha256 "68687bf51785f83de0efdd71881de087f8a148442926b8af6a4b364c067cd920"
  license "MIT"
  head "https://github.com/kubenetworks/kubevpn.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a71538f08785a751178c832f87016f049507b15cbda2dd1eceb9ecdf33e72184"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "825dfb8dd830b688fd5e4953a98b04070a3e91fbf5269c29ff7c4343d8394329"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "f0a24202bed988e11ab129969ad26c104d08c18e67bbb4009ce3e38aececb63c"
    sha256 cellar: :any_skip_relocation, sonoma:        "bc1d98aeec58b5b6a8e38db1b2cf862cacf2591c3ca9532d85c2eb79a6b6dc8b"
    sha256 cellar: :any_skip_relocation, ventura:       "acd32b9e857df0c9196a11314013664ac7cb28d35e29a760e7aedeb8729e9914"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "310798a8c6ab30c43cc18959b3580295ef89f1a6337ab2bb542e25e86771ddaa"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "7484884e9a9b52eb2771edc6a8369f9a49fa305dd4ea18f26a1d512ef33265c5"
  end

  depends_on "go" => :build

  def install
    goos = Utils.safe_popen_read("#{Formula["go"].bin}/go", "env", "GOOS").chomp
    goarch = Utils.safe_popen_read("#{Formula["go"].bin}/go", "env", "GOARCH").chomp
    tags = "noassets"
    project = "github.com/wencaiwulue/kubevpn/v2"
    ldflags = %W[
      -s -w
      -X #{project}/pkg/config.Image=ghcr.io/kubenetworks/kubevpn:v#{version}
      -X #{project}/pkg/config.Version=v#{version}
      -X #{project}/pkg/config.GitCommit=brew
      -X #{project}/cmd/kubevpn/cmds.BuildTime=#{time.iso8601}
      -X #{project}/cmd/kubevpn/cmds.Branch=master
      -X #{project}/cmd/kubevpn/cmds.OsArch=#{goos}/#{goarch}
    ]
    system "go", "build", *std_go_args(ldflags:, tags:), "./cmd/kubevpn"

    generate_completions_from_executable(bin/"kubevpn", "completion")
  end

  test do
    assert_match "Version: v#{version}", shell_output("#{bin}/kubevpn version")
    assert_path_exists testpath/".kubevpn/config.yaml"
    assert_path_exists testpath/".kubevpn/daemon"
  end
end
