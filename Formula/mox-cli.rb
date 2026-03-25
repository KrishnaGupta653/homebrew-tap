class MoxCli < Formula
  desc "Terminal music CLI with web UI and extensive features"
  homepage "https://github.com/KrishnaGupta653/mox"
  url "https://github.com/KrishnaGupta653/mox/archive/v6.0.9.tar.gz"
  sha256 "64f62cb0a545535a38a728563a725ceb45bfad38b7d050fc173510298a21276d"
  license "MIT"
  head "https://github.com/KrishnaGupta653/mox.git", branch: "main"

  depends_on "mpv"
  depends_on "curl"
  depends_on "jq"
  depends_on "python@3.11"
  depends_on "yt-dlp" => :recommended
  depends_on "fzf" => :recommended
  depends_on "chafa" => :recommended
  depends_on "ffmpeg" => :recommended

  def install
    # Install source files to libexec/src
    (libexec/"src").install Dir["src/*"]
    
    # Install scripts
    libexec.install Dir["scripts/*"]
    
    # Install main executable to libexec
    libexec.install "mox"
    
    # Create wrapper script that points to the actual implementation
    (bin/"mox").write <<~EOS
      #!/bin/bash
      export MOX_LIBEXEC_DIR="#{libexec}"
      export MOX_PACKAGE_DIR="#{libexec}"
      exec "#{libexec}/src/mox.sh" "$@"
    EOS
    
    # Make sure it's executable
    chmod 0755, bin/"mox"
    
    # Make source files executable
    chmod 0755, libexec/"src/mox.sh"
    chmod 0755, libexec/"src/music_ui_server.py"
    
    # Install documentation
    doc.install "README.md"
    doc.install Dir["docs/*"] if Dir.exist?("docs")
    
    # Install man page if it exists
    man1.install "docs/mox.1" if File.exist?("docs/mox.1")
    
    # Install shell completions
    if Dir.exist?("completions")
      bash_completion.install "completions/mox.bash" if File.exist?("completions/mox.bash")
      zsh_completion.install "completions/_mox" if File.exist?("completions/_mox")
      fish_completion.install "completions/mox.fish" if File.exist?("completions/mox.fish")
    end
  end

  def post_install
    # Run installation script (skip if it doesn't exist or fails)
    system "#{libexec}/install.sh" if File.exist?("#{libexec}/install.sh") rescue nil
    
    puts <<~EOS
      🎵 mox has been installed!
      
      Quick start:
        mox help                    # Show help
        mox "lofi hip hop"          # Play music
        mox uxi                     # Open web interface
      
      Configuration:
        ~/music_system/config       # Edit configuration
        
      For more information:
        https://github.com/KrishnaGupta653/mox#readme
    EOS
  end

  test do
    # Test basic functionality
    system "#{bin}/mox", "help"
    
    # Test version
    output = shell_output("#{bin}/mox --version 2>&1", 0)
    assert_match "mox", output
    
    # Test configuration creation
    system "#{bin}/mox", "doctor"
  end

  def caveats
    <<~EOS
      To use all features of mox, you may want to install additional dependencies:
      
        brew install yt-dlp fzf chafa ffmpeg socat
      
      For YouTube support, consider setting up API keys:
        https://github.com/KrishnaGupta653/mox#configuration
    EOS
  end
end