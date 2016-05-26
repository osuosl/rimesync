require "test/unit"
require "./rimesync.rb"

class Resp
	def initialize
		@text = None
		@status_code = None
	end
end


class TestRimeSync < Test::Unit::TestCase
  def setup
  	baseurl = "http://ts.example.com/v1"
  	@ts = rimesync.TimeSync(baseurl)
  	@ts.user = "example-user"
  	@ts.password = "password"
  	@ts.auth_type = "password"
  	@ts.token = "TESTTOKEN"
  end

  def teardown
  	del(@ts)
  	@post = actual_post
  	@delete = actual_delete
  	@get = actual_get
  end
end

