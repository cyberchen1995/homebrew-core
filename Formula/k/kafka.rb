class Kafka < Formula
  desc "Open-source distributed event streaming platform"
  homepage "https://kafka.apache.org/"
  url "https://www.apache.org/dyn/closer.lua?path=kafka/3.9.0/kafka_2.13-3.9.0.tgz"
  mirror "https://archive.apache.org/dist/kafka/3.9.0/kafka_2.13-3.9.0.tgz"
  sha256 "abc44402ddf103e38f19b0e4b44e65da9a831ba9e58fd7725041b1aa168ee8d1"
  license "Apache-2.0"

  livecheck do
    url "https://kafka.apache.org/downloads"
    regex(/href=.*?kafka[._-]v?\d+(?:\.\d+)+-(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0d5693294afbccfda699c56b8a15c6fcc71bdc357dff246b9bf24b23862fcef8"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "0d5693294afbccfda699c56b8a15c6fcc71bdc357dff246b9bf24b23862fcef8"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "0d5693294afbccfda699c56b8a15c6fcc71bdc357dff246b9bf24b23862fcef8"
    sha256 cellar: :any_skip_relocation, sonoma:        "5fe61e9a6222ad4275cdc96c03776d660bca0aed2c7816f90fbea90777db38c4"
    sha256 cellar: :any_skip_relocation, ventura:       "5fe61e9a6222ad4275cdc96c03776d660bca0aed2c7816f90fbea90777db38c4"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "d36d3e630e1070fdcd4433b15973d197c9d868d57707b8d2398cbd774bfc301d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "0d5693294afbccfda699c56b8a15c6fcc71bdc357dff246b9bf24b23862fcef8"
  end

  depends_on "openjdk"
  depends_on "zookeeper"

  def install
    data = var/"lib"
    inreplace "config/server.properties",
      "log.dirs=/tmp/kafka-logs", "log.dirs=#{data}/kafka-logs"

    inreplace "config/kraft/server.properties",
      "log.dirs=/tmp/kraft-combined-logs", "log.dirs=#{data}/kraft-combined-logs"

    inreplace "config/kraft/controller.properties",
      "log.dirs=/tmp/kraft-controller-logs", "log.dirs=#{data}/kraft-controller-logs"

    inreplace "config/kraft/broker.properties",
      "log.dirs=/tmp/kraft-broker-logs", "log.dirs=#{data}/kraft-broker-logs"

    inreplace "config/zookeeper.properties",
      "dataDir=/tmp/zookeeper", "dataDir=#{data}/zookeeper"

    # remove Windows scripts
    rm_r("bin/windows")

    libexec.install "libs"

    prefix.install "bin"
    bin.env_script_all_files(libexec/"bin", Language::Java.overridable_java_home_env)
    Dir["#{bin}/*.sh"].each { |f| mv f, f.to_s.gsub(/.sh$/, "") }

    mv "config", "kafka"
    etc.install "kafka"
    libexec.install_symlink etc/"kafka" => "config"

    # create directory for kafka stdout+stderr output logs when run by launchd
    (var+"log/kafka").mkpath
  end

  service do
    run [opt_bin/"kafka-server-start", etc/"kafka/server.properties"]
    keep_alive true
    working_dir HOMEBREW_PREFIX
    log_path var/"log/kafka/kafka_output.log"
    error_log_path var/"log/kafka/kafka_output.log"
  end

  test do
    ENV["LOG_DIR"] = "#{testpath}/kafkalog"

    # Workaround for https://issues.apache.org/jira/browse/KAFKA-15413
    # See https://github.com/Homebrew/homebrew-core/pull/133887#issuecomment-1679907729
    ENV.delete "COLUMNS"

    (testpath/"kafka").mkpath
    cp "#{etc}/kafka/zookeeper.properties", testpath/"kafka"
    cp "#{etc}/kafka/server.properties", testpath/"kafka"
    inreplace "#{testpath}/kafka/zookeeper.properties", "#{var}/lib", testpath
    inreplace "#{testpath}/kafka/server.properties", "#{var}/lib", testpath

    zk_port = free_port
    kafka_port = free_port
    inreplace "#{testpath}/kafka/zookeeper.properties", "clientPort=2181", "clientPort=#{zk_port}"
    inreplace "#{testpath}/kafka/server.properties" do |s|
      s.gsub! "zookeeper.connect=localhost:2181", "zookeeper.connect=localhost:#{zk_port}"
      s.gsub! "#listeners=PLAINTEXT://:9092", "listeners=PLAINTEXT://:#{kafka_port}"
    end

    begin
      fork do
        exec "#{bin}/zookeeper-server-start #{testpath}/kafka/zookeeper.properties " \
             "> #{testpath}/test.zookeeper-server-start.log 2>&1"
      end

      sleep 15

      fork do
        exec "#{bin}/kafka-server-start #{testpath}/kafka/server.properties " \
             "> #{testpath}/test.kafka-server-start.log 2>&1"
      end

      sleep 30

      system "#{bin}/kafka-topics --bootstrap-server localhost:#{kafka_port} --create --if-not-exists " \
             "--replication-factor 1 --partitions 1 --topic test > #{testpath}/kafka/demo.out " \
             "2>/dev/null"
      pipe_output "#{bin}/kafka-console-producer --bootstrap-server localhost:#{kafka_port} --topic test 2>/dev/null",
                  "test message"
      system "#{bin}/kafka-console-consumer --bootstrap-server localhost:#{kafka_port} --topic test " \
             "--from-beginning --max-messages 1 >> #{testpath}/kafka/demo.out 2>/dev/null"
      system "#{bin}/kafka-topics --bootstrap-server localhost:#{kafka_port} --delete --topic test " \
             ">> #{testpath}/kafka/demo.out 2>/dev/null"
    ensure
      system bin/"kafka-server-stop"
      system bin/"zookeeper-server-stop"
      sleep 10
    end

    assert_match(/test message/, File.read("#{testpath}/kafka/demo.out"))
  end
end
