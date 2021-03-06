require "buildr/xmlbeans"
#require "buildr/cobertura"

# Keep this structure to allow the build system to update version numbers.
VERSION_NUMBER = "1.0.0-SNAPSHOT"

require "dependencies.rb"
require "repositories.rb"

ODE_VERSION = "apache-ode-war-1.3.2-SNAPSHOT"
ODE_URI = "http://www.intalio.org/public/ode/#{ODE_VERSION}.zip"

#ODE_VERSION = "apache-ode-war-1.3.2-SNAPSHOT"
#ODE_URI = "file:///ode/1.x/distro/target/#{ODE_VERSION}.zip"

desc "ODE Extension"
define "ode-ext" do
  project.version = VERSION_NUMBER
  project.group = "org.intalio.ode-ext"
  
  compile.options.target = "1.5"

  desc "Deployment Extension"
  define "deploy" do
    import_ode = lambda do |target|
      file(target) do |task|
        Buildr.ant("download ode and unzip") do |ant|
          ant.get :src=>ODE_URI, :dest=>_("target/ode.zip")
          ant.unzip :src=>_("target/ode.zip"), :dest=>_("target/ode/unzipped")
          ant.unjar :src=>_("target/ode/unzipped/#{ODE_VERSION}/ode.war"), :dest=>_("target/ode")
        end
        Dir[_("target/ode/WEB-INF/lib/*.jar")].each {|f| compile.with f}
      end
#      Dir[_("target/ode/WEB-INF/lib/*.jar")].map {|f| file(f)}
    end
    build import_ode[_("target/ode/WEB-INF/lib")]
    compile.with DEPLOY_SERVICE, APACHE_COMMONS[:logging], _("target/ode/WEB-INF/lib")

    package(:zip).include(package(:jar)).include(artifacts(DEPLOY_SERVICE)).include(artifacts(DEPLOY_REGISTRY)).include(artifacts(SLF4J))
  end
end
