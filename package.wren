import "wren-package" for WrenPackage, Dependency

class Package is WrenPackage {
  construct new() {}
  name { "agents" }
  dependencies {
    return [
      Dependency.new("wren-assert", "v1.1.2", "https://github.com/RobLoach/wren-assert.git"),
      Dependency.new("wren-vector", "v1.0.0", "https://github.com/chances/wren-vector.git")
    ]
  }
}

Package.new().default()
