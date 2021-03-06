name "sensu-msi"

source :path => File.expand_path("files/msi", Omnibus.root)

build do
  block do
    src_dir = self.project_dir

    shell = Mixlib::ShellOut.new("heat.exe dir \"C:\\opt\\sensu\" -nologo -srd -gg -cg SensuDir -dr SENSULOCATION -var var.SensuSourceDir -out Sensu-Files.wxs", :cwd => src_dir)
    shell.run_command
    shell.error!
  end

  block do
    require 'erb'

    File.open("#{project_dir}\\templates\\Sensu-Config.wxi.erb") { |file|
      versions = build_version.split("-").first.split(".")
      @major_version = versions[0]
      @minor_version = versions[1]
      @micro_version = versions[2]
      @build_version = self.project.build_iteration

      @guid = "D607A85C-BDFA-4F08-83ED-2ECB4DCD6BC5"

      erb = ERB.new(file.read)
      File.open("#{project_dir}\\Sensu-Config.wxi", "w") { |out|
        out.write(erb.result(binding))
      }
    }

  end

  command "xcopy Sensu-en-us.wxl C:\\opt\\sensu\\msi-tmp /Y", :cwd => source[:path]

  command "xcopy assets C:\\opt\\sensu\\msi-tmp\\assets /I /Y", :cwd => source[:path]

  block do
    src_dir = self.project_dir

    shell = Mixlib::ShellOut.new("candle.exe -nologo -out C:\\opt\\sensu\\msi-tmp\\ -dSensuSourceDir=\"C:\\opt\\sensu\" Sensu-Files.wxs Sensu.wxs", :cwd => src_dir)
    shell.run_command
    shell.error!
  end
end
