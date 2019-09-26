# frozen_string_literal: true

require 'bundler/setup'

require 'benchmark'

require 'ten34/client'

db_name = "test-#{Time.now.to_i}.db"
client = Ten34::Client.new("route53://#{db_name}")
client.create_db

client.put('foo', 'bar')

puts Benchmark.measure { 1000.times { client.get('foo') } }

client.del('foo')
client.delete_db
