require 'minitest/autorun'
require 'json'
require 'timeout'

describe 'job DSL support' do
  describe 'when directed to install jobs using the jobs DSL plugin' do
    it 'creates a runnable seed job that creates other jobs when executed' do
      delete_job('autogenerated_job')
      refute find_job('autogenerated_job')
      assert find_job('dummy_seed'), "Couldn't find the dummy seed"
      run_job('dummy_seed')
      Timeout.timeout(60) do
        loop do
          break if find_job('autogenerated_job')
          sleep 1
        end
      end
      assert find_job('autogenerated_job'), "Seed didn't run, or failed to generate job"
    end
  end
end

def curl(command)
  `curl --silent #{command}`
end

def delete_job(job_name)
  curl "-X POST http://127.0.0.1:8080/job/#{job_name}/doDelete"
end

def find_job(job_name)
  json = curl "http://127.0.0.1:8080/api/json"
  jobs = JSON.parse(json).fetch('jobs')
  jobs.detect { |job| job.fetch('name') == job_name }
end

def run_job(job_name)
  curl "-X POST http://127.0.0.1:8080/job/#{job_name}/build"
end
