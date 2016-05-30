require "test/unit"
require "http"    # not working
require_relative "rimesync"

class Resp
	def initialize
		@text = nil
		@status_code = nil
	end
end


class TestRimeSync < Test::Unit::TestCase
  def setup
  	baseurl = "http://ts.example.com/v1"
  	@ts = rimesync.TimeSync(baseurl) # not working
  	@ts.user = "example-user"
  	@ts.password = "password"
  	@ts.auth_type = "password"
  	@ts.token = "TESTTOKEN"
  end

  def teardown
  	del(@ts)  # does not works in ruby
  	@post = actual_post   # fix this and next two lines
  	@delete = actual_delete
  	@get = actual_get
  end

  def test_instantiate_with_token
    # Test that instantiating rimesync with a token sets the token variable
    ts = rimesync.TimeSync("baseurl", token="TOKENTOCHECK")  # not working
    assert_equal(ts.token, "TOKENTOCHECK")
  end

  def test_instantiate_without_token
    # Test that instantiating rimesync without a token does not sets the token variable
    ts = rimesync.TimeSync("baseurl")
    assert_nil(ts.token)
  end

  # @patch("pymesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_create_time_valid(self, m_resp_python)
  # end

  # @patch("pymesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_update_time_valid(self, m_resp_python)
  # end

  # @patch("pymesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_update_time_valid_less_fields(self,
  #                                                           m_resp_python)
  # end

  def test_create_or_update_create_time_invalid
  # Tests TimeSync._TimeSync__create_or_update for create time with invalid field

  # Parameters to be sent to TimeSync
  time = Hash[
      'duration' => 12,
      'project' => 'ganeti-web-manager',
      'user' => 'example-user',
      'activities' => ['documenting'],
      'notes' => 'Worked on docs',
      'issue_uri' => "https://github.com/",
      'date_worked' => '2014-04-17',
      'bad' => 'field'
  ]


  assert_equal(ts._TimeSync__create_or_update(time, nil,
                                                        "time", "times"),
                    [{ts.error =>
                      "time object: invalid field: bad"}])
  end

  def test_create_or_update_create_time_two_required_missing
    # Parameters to be sent to TimeSync
    time = Hash[
        'duration' => 12,
        'user' => 'example-user',
        'notes' => 'Worked on docs',
        'issue_uri' => "https://github.com/",
        'date_worked' => "2014-04-17"
    ]

    assert_equal(ts._TimeSync__create_or_update(time, nil,
                                                          "time", "times"),
                      [{ts.error =>
                        "time object: missing required field(s): project, activities"}])
  end

    def test_create_or_update_create_time_each_required_missing
      # Tests TimeSync._TimeSync__create_or_update to create time with missing required fields
      # Parameters to be sent to TimeSync
        time = Hash[
            'duration' => 12,
            'project' => 'ganeti-web-manager',
            'user' => 'example-user',
            'activities' => ['documenting'],
            'date_worked' => "2014-04-17"
        ]

        time_to_test = Hash[time]

        for key, value in time
            del(time_to_test[key])  # will ot work
            assert_equal(ts._TimeSync__create_or_update(
                              time_to_test, nil, "time", "times"),
                              [{ts.error => "time object: missing required field(s): {}".format(key)}])
            time_to_test = Hash[time]
        end
      end

      def test_create_or_update_create_time_type_error
        # Tests TimeSync._TimeSync__create_or_update for create time with incorrect parameter types

        # Parameters to be sent to TimeSync
        param_list = Array[1, "hello", [1, 2, 3], nil, true, false, 1.234]

        for param in param_list
            assert_equal(ts._TimeSync__create_or_update(param, nil,"time","times"),
                                [{ts.error=>"time object: must be python dictionary"}])
        end
      end

    # @patch("pymesync.TimeSync._TimeSync__response_to_python")
    # def test_create_or_update_create_time_catch_request_error(self, m)
    # end

    # @patch("pymesync.TimeSync._TimeSync__response_to_python")
    # def test_create_or_update_create_user_valid(self, m_resp_python):
    # end

    # @patch("pymesync.TimeSync._TimeSync__response_to_python")
    # def test_create_or_update_update_user_valid(self, m_resp_python)
    # end

  #   @patch("pymesync.TimeSync._TimeSync__response_to_python")
  #   def test_create_or_update_update_user_valid_less_fields(self,
  #                                                           m_resp_python):
  # end

  def test_create_or_update_create_user_invalid
    #Tests TimeSync._TimeSync__create_or_update for create user with invalid field

      # Parameters to be sent to TimeSync
      user = Hash[
          'username' => 'example-user',
          'password' => 'password',
          'displayname' => 'Example User',
          'email' => 'example.user@example.com',
          'bad'=> 'field'
      ]

      assert_equal(ts._TimeSync__create_or_update(user, nil,
                                                            "user", "users"),
                        [{ts.error =>
                          "user object: invalid field: bad"}])
    end

  def test_create_or_update_create_user_two_required_missing
      # Tests TimeSync._TimeSync__create_or_update for create user with missing required fields

        # Parameters to be sent to TimeSync
        user = Hash[
            'displayname' => 'Example User',
            'email'=> 'example.user@example.com'
        ]

        assert_equal(ts._TimeSync__create_or_update(user, nil,
                                                              "user", "users"),
                          [{ts.error =>
                            "user object: missing required field(s): username, password"}])
    end

  def test_create_or_update_create_user_each_required_missing
    # Tests TimeSync._TimeSync__create_or_update to create user with missing required fields
      # Parameters to be sent to TimeSync
      user = Hash[
          'username' => 'example-user',
          'password' => 'password',
      ]

      user_to_test = Hash[user]

      for key,value in user
          del(user_to_test[key])
          assert_equal(ts._TimeSync__create_or_update(
                            user_to_test, None, "user", "users"),
                            [{ts.error => "user object: missing required field(s): {}".format(key)}])
          user_to_test = Hash[user]
      end
    end
    def test_create_or_update_create_user_type_error
        #Tests TimeSync._TimeSync__create_or_update for create user with incorrect parameter types

        # Parameters to be sent to TimeSync
        param_list = [1, "hello", [1, 2, 3], nil, true, false, 1.234]

        for param in param_list
            assert_equal(ts._TimeSync__create_or_update(param,nil,"user","users"),
                              [{ts.error =>
                                "user object: must be python dictionary"}])
        end
    end

    # @patch("pymesync.TimeSync._TimeSync__response_to_python")
    # def test_create_or_update_create_user_catch_request_error(self, m):
    # end

    # @patch("pymesync.TimeSync._TimeSync__response_to_python")
    # def test_create_or_update_create_project_valid(self, m_resp_python):
    # end

    # @patch("pymesync.TimeSync._TimeSync__response_to_python")
    # def test_create_or_update_update_project_valid(self, m_resp_python):
    # end

  #   @patch("pymesync.TimeSync._TimeSync__response_to_python")
  #   def test_create_or_update_update_project_valid_less_fields(self,
  #                                                              m_resp_python):
  # end

  def test_create_or_update_create_project_invalid
    # Tests TimeSync._TimeSync__create_or_update for create project with invalid field

    # Parameters to be sent to TimeSync
    project = Hash[
        'uri' => "https://code.osuosl.org/projects/timesync",
        'name' => 'TimeSync API',
        'slugs' => ['timesync', 'time'],
        'users' => Hash[
            'mrsj' => Hash['member' => true, 'spectator' => true, 'manager' => true],
            'thai' => Hash['member' => true, 'spectator' => false, "manager" => false]
        ],
        'bad' => 'field'
    ]

    assert_equal(ts._TimeSync__create_or_update(project,nil,
                                                          "project",
                                                          "projects"),
                      [{ts.error =>
                        "project object: invalid field: bad"}])
  end


#here pop


  def test_create_or_update_create_project_required_missing
    # Tests TimeSync._TimeSync__create_or_update for create project with missing required fields

      # Parameters to be sent to TimeSync
      project = Hash[
          'slugs' => ['timesync', 'time'],
      ]

      assert_equal(ts._TimeSync__create_or_update(project,nil,
                                                            "project",
                                                            "project"),
                        [{ts.error => "project object: missing required field(s): name"}])
    end

  def test_create_or_update_create_project_each_required_missing
    #Tests TimeSync._TimeSync__create_or_update for create project with missing required fields

      # Parameters to be sent to TimeSync
      project = Hash[
          'name' => 'TimeSync API',
          'slugs' => ['timesync', 'time'],
      ]

      project_to_test = Hash[project]

      for key, value in project
          del(project_to_test[key])
          assert_equal(ts._TimeSync__create_or_update(
                            project_to_test, nil, "project", "projects"),
                            [{ts.error => "project object: missing required field(s): {}".format(key)}])
          project_to_test = Hash[project]
      end
    end

  def test_create_or_update_create_project_type_error
    # Tests TimeSync._TimeSync__create_or_update for create project with incorrect parameter types

      # Parameters to be sent to TimeSync
      param_list = [1, "hello", [1, 2, 3], nil, true, false, 1.234]

      for param in param_list
          assert_equal(ts._TimeSync__create_or_update(param,nil,
                                                      "project","projects"),
                            [{ts.error =>
                              "project object: must be python dictionary"}])
      end
  end

  # @patch("pymesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_create_activity_valid(self, m_resp_python):
  # end

  # @patch("pymesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_update_activity_valid(self, m_resp_python):
  # end

  # @patch("pymesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_update_activity_valid_less_fields(self,
  #                                                             m_resp_python):
  # end


  # here love

  def test_create_or_update_create_activity_invalid
    # Tests TimeSync._TimeSync__create_or_update for create activity with invalid field
      # Parameters to be sent to TimeSync
      activity = Hash[
          'name' => 'Quality Assurance/Testing',
          'slug' => 'qa',
          'bad' => 'field'
      ]

      assert_equal(ts._TimeSync__create_or_update(activity,nil,
                                                            "activity",
                                                            "activites"),
                        [{ts.error=>
                          "activity object: invalid field: bad"}])
    end

  def test_create_or_update_create_activity_required_missing
    # Tests TimeSync._TimeSync__create_or_update for create activity with missing required fields
      # Parameters to be sent to TimeSync
      activity = Hash[
          'name' => 'Quality Assurance/Testing',
      ]

      assert_equal(ts._TimeSync__create_or_update(activity,nil,
                                                            "activity",
                                                            "activities"),
                        [{ts.error=> "activity object: missing required field(s): slug"}])
    end

  def test_create_or_update_create_activity_each_required_missing
      # Tests TimeSync._TimeSync__create_or_update for create activity with missing required fields
      # Parameters to be sent to TimeSync
      activity = Hash[
          'name' => 'Quality Assurance/Testing',
          'slug'=> 'qa'
      ]


      activity_to_test = Hash[activity]

      for key,value in activity
          del(activity_to_test[key])
          assert_equal(ts._TimeSync__create_or_update(
                            activity_to_test, nil,
                            "activity", "activities"),
                            [{ts.error => "activity object: missing required field(s): {}".format(key)}])
          activity_to_test = Hash[activity]
        end
      end

  def test_create_or_update_create_activity_type_error
      # Tests TimeSync._TimeSync__create_or_update for create activity with incorrect parameter types

      # Parameters to be sent to TimeSync
      param_list = [1, "hello", [1, 2, 3], nil, true, false, 1.234]

      for param in param_list
        assertEquals(ts._TimeSync__create_or_update(param,
                            nil, "activity", "activities"),
                            [{ts.error => "activity object: must be python dictionary"}])

      end
    end

end
