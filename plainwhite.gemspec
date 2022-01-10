Gem::Specification.new do |spec|
  spec.name          = "plainwhite"
  spec.version       = "0.13"
  spec.authors       = ["nandangSec"]
  spec.email         = ["contact.nandang@gmail.com"]
  spec.summary       = "A portfolio style jekyll theme for writers"
  spec.homepage      = ""
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").select { |f| f.match(%r!^(assets|_layouts|_includes|_sass|LICENSE|README|404.html|atom.xml|search.json)!i) }
  spec.add_runtime_dependency "jekyll", ">= 3.7.3"
  spec.add_runtime_dependency "jekyll-seo-tag", ">= 2.1.0"
  spec.add_runtime_dependency "jekyll-feed", ">= 0.12"
  spec.add_development_dependency "bundler", "> 1.16"
  spec.add_development_dependency "rake", "~> 12.0"
end
