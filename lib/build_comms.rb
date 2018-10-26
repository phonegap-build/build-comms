# stdlib
require 'rexml/document'
require 'net/smtp'
require 'logger'

# external dependencies
begin
  require 'bundler/setup'
rescue LoadError
  require 'rubygems'
  require 'bundler/setup'
end

require 'aws-sdk'
require 'json'

# internal dependencies
require 'build_comms/base'
require 'build_comms/version'
require 'build_comms/utils'
require 'build_comms/sns'

require 'build_comms/message'
require 'build_comms/store'
require 'build_comms/queue'
require 'build_comms/watcher'
require 'build_comms/kms'
require 'build_comms/alert'

# set AWS region
Aws.config.update({region: 'us-east-1'})
