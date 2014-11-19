name             "postfix2redis"
maintainer       "Algirdas S"
maintainer_email "algirdas.s@gmail.com"
license          "Apache 2.0"
description      "Installs redis and sets postfix filter to forward emails to it."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0.1"

recipe "postfix2redis::default", "The default recipe which does all the stuff."
recipe "postfix2redis::postfix", "Only configures Postfix. Skips Redis setup."
recipe "postfix2redis::redis", "Only sets up Redis. Skips Postfix configuration."
recipe "postfix2redis::mailx", "Only install mailx package. For use of 'mail' command."

%w[ rhel centos ].each do |os|
  supports os
end

%w[ yum ].each do |cookbook|
  depends cookbook
end
