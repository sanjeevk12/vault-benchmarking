-- Script that writes and reads secrets from k/v engine in Vault

local counter = 1
local threads = {}

function setup(thread)
   thread:set("id", counter)
   table.insert(threads, thread)
   counter = counter + 1
end

function init(args)
   requests  = 0
   reads = 0
   writes = 0
   responses = 0
   -- give each thread different random seed
   math.randomseed(os.time() + id*1000)
   method = "POST"
   local msg = "thread %d created"
   print(msg:format(id))
end

function request()
   writes = writes + 1
   -- cycle through paths from 1 to N in order
   -- path = "/v1/secret/benchmark-" .. (writes % 100) + 1
   -- randomize path to secret
   path = "/v1/secret/benchmark-" .. math.random(10000)
   -- minimal secret giving thread id and # of write
   -- body = '{"foo-' .. id .. '" : "bar-' .. writes ..'"}'
   -- add extra key with 100 bytes
   body = '{"thread-' .. id .. '" : "write-' .. writes ..'","extra" : "1xxxxxxxxx2xxxxxxxxx3xxxxxxxxx4xxxxxxxxx5xxxxxxxxx6xxxxxxxxx7xxxxxxxxx8xxxxxxxxx9xxxxxxxxx0xxxxxxxxx"}'
   requests = requests + 1
   return wrk.format(method, path, nil, body)
end

function response(status, headers, body)
   responses = responses + 1
end

function done(summary, latency, requests)
   for index, thread in ipairs(threads) do
      local id        = thread:get("id")
      local requests  = thread:get("requests")
      local reads     = thread:get("reads")
      local writes    = thread:get("writes")
      local responses = thread:get("responses")
      local msg = "thread %d made %d requests including %d reads and %d writes, and got %d responses"
      print(msg:format(id, requests, reads, writes, responses))
   end
end
