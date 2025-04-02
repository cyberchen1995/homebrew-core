class Otf2 < Formula
  desc "Open Trace Format 2 file handling library"
  homepage "https://www.vi-hps.org/projects/score-p/"
  url "https://perftools.pages.jsc.fz-juelich.de/cicd/otf2/tags/otf2-3.1.1/otf2-3.1.1.tar.gz"
  sha256 "5a4e013a51ac4ed794fe35c55b700cd720346fda7f33ec84c76b86a5fb880a6e"
  license "BSD-3-Clause"

  livecheck do
    url :homepage
    regex(/href=.*?otf2[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    rebuild 3
    sha256 arm64_sequoia: "18aef1ecedd99e58b0e22bdfc91546a955f5822e6f1a6ec75af72a8728979919"
    sha256 arm64_sonoma:  "e92a47a55518b35a251e5338380ba439431a8e14906b063a0e9cbf0c13139255"
    sha256 arm64_ventura: "c8a95435b0dd75f2eb1c3b9a4b55cd635304faf7aeca446de076e6ca3135b2c8"
    sha256 sonoma:        "b1e76426024a317b51be2752cdbc580e9c9d1d5d10a5a0a8e3e3ccd0929f1aac"
    sha256 ventura:       "004ed0f51b9ad93c4e1435dbe9424528d00ac935c4e5b6d69ae8c65348526cf5"
    sha256 arm64_linux:   "6044ae68460166dbed17ffa8f8acdb2441088104f0ec9c5a6270c620725fe0a5"
    sha256 x86_64_linux:  "ea14ea82474ebc29426a280e43409ebce2a688ba2e4de3ef11aa82564841327a"
  end

  depends_on "python-setuptools" => :build
  depends_on "sphinx-doc" => :build
  depends_on "gcc" # for gfortran
  depends_on "open-mpi"
  depends_on "python@3.13"

  resource "six" do
    url "https://files.pythonhosted.org/packages/94/e7/b2c673351809dca68a0e064b6af791aa332cf192da575fd474ed7d6f16a2/six-1.17.0.tar.gz"
    sha256 "ff70335d468e7eb6ec65b95b99d3a2836546063f63acc5171de367e834932a81"
  end

  # Fix -flat_namespace being used on Big Sur and later.
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-big_sur.diff"
    sha256 "35acd6aebc19843f1a2b3a63e880baceb0f5278ab1ace661e57a502d9d78c93c"
    directory "build-frontend"
  end
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-big_sur.diff"
    sha256 "35acd6aebc19843f1a2b3a63e880baceb0f5278ab1ace661e57a502d9d78c93c"
    directory "build-backend"
  end

  def python3
    "python3.13"
  end

  def install
    resource("six").stage do
      system python3, "-m", "pip", "install", *std_pip_args(prefix: libexec), "."
    end

    ENV.prepend_path "PYTHONPATH", libexec/Language::Python.site_packages(python3)
    ENV["PYTHON"] = which(python3)
    ENV["SPHINX"] = Formula["sphinx-doc"].opt_bin/"sphinx-build"

    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make"
    system "make", "install"

    inreplace pkgshare/"otf2.summary", "#{Superenv.shims_path}/", ""
  end

  def caveats
    <<~EOS
      To use the Python bindings, you will need to have the six library.
      One option is to use the bundled copy through your PYTHONPATH, e.g.
        export PYTHONPATH=#{opt_libexec/Language::Python.site_packages(python3)}
    EOS
  end

  test do
    cp_r share/"doc/otf2/examples", testpath
    workdir = testpath/"examples"
    chdir "#{testpath}/examples" do
      # build serial tests
      system "make", "serial", "mpi", "pthread"
      %w[
        otf2_mpi_reader_example
        otf2_mpi_reader_example_cc
        otf2_mpi_writer_example
        otf2_pthread_writer_example
        otf2_reader_example
        otf2_writer_example
      ].each { |p| assert_path_exists workdir/p }
      system "./otf2_writer_example"
      assert_path_exists workdir/"ArchivePath/ArchiveName.otf2"
      system "./otf2_reader_example"
      rm_r("./ArchivePath")
      system Formula["open-mpi"].opt_bin/"mpirun", "-n", "2", "./otf2_mpi_writer_example"
      assert_path_exists workdir/"ArchivePath/ArchiveName.otf2"
      2.times do |n|
        assert_path_exists workdir/"ArchivePath/ArchiveName/#{n}.evt"
      end
      system Formula["open-mpi"].opt_bin/"mpirun", "-n", "2", "./otf2_mpi_reader_example"
      system "./otf2_reader_example"
      rm_r("./ArchivePath")
      system "./otf2_pthread_writer_example"
      assert_path_exists workdir/"ArchivePath/ArchiveName.otf2"
      system "./otf2_reader_example"
    end

    ENV.prepend_path "PYTHONPATH", libexec/Language::Python.site_packages(python3)
    system python3, "-c", "import otf2"
  end
end
