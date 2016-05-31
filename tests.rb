require "test/unit"
require "http"
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

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_create_time_valid(self, m_resp_python)
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_update_time_valid(self, m_resp_python)
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
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
                            [{ts.error =>"time object: must be python dictionary"}])
    end
  end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_create_time_catch_request_error(self, m)
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_create_user_valid(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_update_user_valid(self, m_resp_python)
  # end

  #   @patch("rimesync.TimeSync._TimeSync__response_to_python")
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

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_create_user_catch_request_error(self, m):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_create_project_valid(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_update_project_valid(self, m_resp_python):
  # end

  #   @patch("rimesync.TimeSync._TimeSync__response_to_python")
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
      param_list = Array[1, "hello", [1, 2, 3], nil, true, false, 1.234]

      for param in param_list
          assert_equal(ts._TimeSync__create_or_update(param,nil,
                                                      "project","projects"),
                            [{ts.error =>
                              "project object: must be python dictionary"}])
      end
  end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_create_activity_valid(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_update_activity_valid(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_update_activity_valid_less_fields(self,
  #                                                             m_resp_python):
  # end


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
                        [{ts.error =>
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
                        [{ts.error => "activity object: missing required field(s): slug"}])
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

    # @patch("rimesync.TimeSync._TimeSync__response_to_python")
    # def test_create_or_update_create_time_no_auth(self, m_resp_python):
    # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_create_project_no_auth(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_create_activity_no_auth(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_update_time_no_auth(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_update_project_no_auth(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_create_or_update_update_activity_no_auth(self, m_resp_python):
  # end

  def test_auth
    # Tests TimeSync._TimeSync__auth function

      # Create auth block to test _auth
      auth = Hash[
              'type' => 'password',
              'username' => 'example-user',
              'password' => 'password'
            ]

      assert_equal(ts._TimeSync__auth(), auth)
  end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_time_for_user(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_time_for_proj(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_time_for_activity(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_time_for_start_date(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_time_for_end_date(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_time_for_include_revisions(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_time_for_include_revisions_false(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_time_for_include_deleted(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_time_for_include_deleted_false(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_time_for_proj_and_activity(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_time_for_activity_x3(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_time_with_uuid(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_time_with_uuid_and_activity(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_time_with_uuid_and_include_revisions(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_time_with_uuid_and_include_deleted(self, m_resp_python):
  # end

  #   @patch("rimesync.TimeSync._TimeSync__response_to_python")
  #   def test_get_time_with_uuid_include_deleted_and_revisions(self,
  #                                                             m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_all_times(self, m_resp_python):
  # end

  def test_get_times_bad_query
    # Tests TimeSync.get_times with an invalid query parameter

      # Should return the error
      assert_equal(ts.get_times({"bad" => ["query"]}),
                        [{self.ts.error => "invalid query: bad"}])
  end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_projects(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_projects_slug(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_projects_include_revisions(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_projects_slug_include_revisions(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_projects_include_deleted(self, m_resp_python):
  # end

def test_get_projects_include_deleted_with_slug
    # Tests TimeSync.get_projects with include_deleted query and slug, which is not allowed

    # Mock requests.get
    requests.get = mock.Mock("requests.get")  # won't work

    # Test that error message is returned, can't combine slug and include_deleted
    assert_equal(ts.get_projects({'slug'=> 'gwm',
                                            'include_deleted'=> true}),
                      [{ts.error =>
                       "invalid combination: slug and include_deleted"}])
  end

  #   @patch("rimesync.TimeSync._TimeSync__response_to_python")
  #   def test_get_projects_include_deleted_include_revisions(self,
  #                                                           m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_activities(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_activities_slug(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_activities_include_revisions(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_activities_slug_include_revisions(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_activities_include_deleted(self, m_resp_python):
  #   end

  def test_get_activities_include_deleted_with_slug
    # Tests TimeSync.get_activities with include_deleted query and slug, which is not allowed

      # Mock requests.get
      # requests.get = mock.Mock("requests.get") # won't work

      # # Test that error message is returned, can't combine slug and
      # # include_deleted
      # assert_equal(ts.get_activities({'slug'=> 'code',
      #                                           'include_deleted': True}),
      #                   [{ts.error => "invalid combination: slug and include_deleted"}])
  end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_activities_include_deleted_include_revisions(self,
  #                                                           m_resp_python):
  # end

  def test_get_times_no_auth
    # Test that get_times() returns error message when auth not set
      ts.token = nil
      assertEquals(ts.get_times(),
                        [{ts.error =>
                          "Not authenticated with TimeSync, call self.authenticate() first"}])
  end

  def test_get_projects_no_auth
    # Test that get_projects() returns error message when auth not set
      ts.token = nil
      assert_equal(ts.get_projects(),
                        [{ts.error =>
                          "Not authenticated with TimeSync, call self.authenticate() first"}])
  end

  def test_get_activities_no_auth
    # Test that get_activities() returns error message when auth not set
      ts.token = nil
      self.assert_equal(ts.get_activities(),
                        [{ts.error =>
                          "Not authenticated with TimeSync, call self.authenticate() first"}])

  end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_users(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_get_users_username(self, m_resp_python):
  # end

  def test_get_users_no_auth
      # Test that get_users() returns error message when auth not set
      ts.token = None
      assert_equal(ts.get_users(),
                        [{ts.error =>
                          "Not authenticated with TimeSync, call self.authenticate() first"}])
  end

  # def test_response_to_python_single_object(self):
  # end

  # def test_response_to_python_list_of_object(self):
  # end

  # def test_response_to_python_empty_response(self):
  #   end

  # @patch("rimesync.TimeSync._TimeSync__create_or_update")
  # def test_create_time(self, mock_create_or_update):
  # end

  # @patch("rimesync.TimeSync._TimeSync__create_or_update")
  # def test_update_time(self, mock_create_or_update):
  # end

  def test_create_time_with_negative_duration
    # Tests that TimeSync.create_time will return an error if a negative duration is passed
      time = Hash[
          'duration' => -12600,
          'project' => 'ganeti-web-manager',
          'user' => 'example-user',
          'activities' => ['documenting'],
          'notes' => 'Worked on docs',
          'issue_uri' => 'https://github.com/',
          'date_worked'=> "2014-04-17"
      ]

      assert_equal(ts.create_time(time),
                        [{ts.error =>
                          "time object: duration cannot be negative"}])
    end

  def test_update_time_with_negative_duration
    # Tests that TimeSync.update_time will return an error if a negative duration is passed
      time = Hash[
          'duration'=> -12600,
          'project'=> 'ganeti-web-manager',
          'user'=> 'example-user',
          'activities'=> ['documenting'],
          'notes'=> 'Worked on docs',
          'issue_uri'=> 'https://github.com/',
          'date_worked'=> "2014-04-17"
      ]

      assert_equal(ts.update_time(time, "uuid"),
                        [{ts.error =>
                          "time object: duration cannot be negative"}])
    end


    # @patch("rimesync.TimeSync._TimeSync__create_or_update")
    # def test_create_time_with_string_duration(self, mock_create_or_update):
    # end

    # @patch("rimesync.TimeSync._TimeSync__create_or_update")
    # def test_update_time_with_string_duration(self, mock_create_or_update):
    # end



    def test_create_time_with_junk_string_duration
        # Tests that TimeSync.create_time will fail if a string containing no hours/minutes is entered
        time = Hash[
            'duration'=> 'junktime',
            'project'=> 'ganeti-web-manager',
            'user'=> 'example-user',
            'activities'=> ['documenting'],
            'notes'=> "Worked on docs",
            'issue_uri'=> "https://github.com/",
            'date_worked'=> "2014-04-17",
        ]

        assert_equal(ts.create_time(time),
                          [{ts.error =>
                            "time object: invalid duration string"}])
      end

    def test_update_time_with_junk_string_duration
        # Tests that TimeSync.update_time will fail if a string containing no hours/minutes is entered
        time = Hash[
            'duration'=> 'junktime',
            'project'=> 'ganeti-web-manager',
            'user'=> 'example-user',
            'activities'=> ['documenting'],
            'notes'=> 'Worked on docs',
            'issue_uri'=> "https://github.com/",
            'date_worked'=> "2014-04-17",
        ]

        assert_equal(ts.update_time(time, "uuid"),
                          [{ts.error =>
                            "time object: invalid duration string"}])
      end

    def test_create_time_with_invalid_string_duration
        # Tests that TimeSync.create_time will fail if a string containing multiple hours/minutes is entered
        time = Hash[
            'duration'=> '3h30m15h',
            'project'=> 'ganeti-web-manager',
            'user'=> 'example-user',
            'activities'=> ['documenting'],
            'notes'=> 'Worked on docs',
            'issue_uri'=> "https://github.com/",
            'date_worked'=> '2014-04-17',
        ]

        assert_equal(ts.create_time(time),
                          [{ts.error =>
                            "time object: invalid duration string"}])
      end

    def test_update_time_with_invalid_string_duration
      # Tests that TimeSync.update_time will fail if a string containing multiple hours/minutes is entered
        time = Hash[
            'duration'=> '3h30m15h',
            'project'=> 'ganeti-web-manager',
            'user'=> 'example-user',
            'activities'=> ['documenting'],
            'notes'=> 'Worked on docs',
            'issue_uri'=> "https://github.com/",
            'date_worked'=> '2014-04-17',
        ]

        assert_equal(ts.update_time(time, "uuid"),
                          [{ts.error =>
                            "time object: invalid duration string"}])
    end

  # @patch("rimesync.TimeSync._TimeSync__create_or_update")
  # def test_create_project(self, mock_create_or_update):
  # end

  # @patch("rimesync.TimeSync._TimeSync__create_or_update")
  # def test_update_project(self, mock_create_or_update):
  # end

  # @patch("rimesync.TimeSync._TimeSync__create_or_update")
  # def test_create_activity(self, mock_create_or_update):
  # end

  # @patch("rimesync.TimeSync._TimeSync__create_or_update")
  # def test_update_activity(self, mock_create_or_update):
  # end

  # @patch("rimesync.TimeSync._TimeSync__create_or_update")
  # def test_create_user(self, mock_create_or_update):
  # end

  # @patch("rimesync.TimeSync._TimeSync__create_or_update")
  # def test_create_user_valid_perms(self, mock_create_or_update):
  # end

  def test_create_user_invalid_admin
      # Tests that TimeSync.create_user returns error with invalid perm field
      user = Hash[
          'username'=> 'example-user',
          'password'=> 'password',
          'displayname'=> 'Example User',
          'email'=> 'example.user@example.com',
          'admin'=> True,
          'spectator'=> False,
          'manager'=> True,
          'active'=> True,
      ]

      user_to_test = Hash[user]
      for perm in ["admin", "spectator", "manager", "active"]
          user_to_test = Hash[user]
          user_to_test[perm] = 'invalid'
          assert_equal(ts.create_user(user_to_test),
                            [{ts.error => "user object: {} must be True or False".format(perm)}])
        end
    end

  # @patch("rimesync.TimeSync._TimeSync__create_or_update")
  # def test_update_user(self, mock_create_or_update):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_authentication(self, mock_response_to_python):
  # end

  # def test_authentication_return_success(self):
  # end

  # def test_authentication_return_error(self):
  # end

  def test_authentication_no_username
    # Tests authenticate method with no username in call
      assert_equal(ts.authenticate(password="password",
                                             auth_type="password"),
                        [{ts.error => "Missing username; please add to method call"}])
    end

  def test_authentication_no_password
  # Tests authenticate method with no password in call
    assert_equal(ts.authenticate(username="username",
                                           auth_type="password"),
                      [{ts.error => "Missing password; please add to method call"}])
  end

  def test_authentication_no_auth_type
      # Tests authenticate method with no auth_type in call
      assert_equal(ts.authenticate(password="password",
                                             username="username"),
                        [{ts.error => "Missing auth_type; please add to method call"}])
    end

  def test_authentication_no_username_or_password
    # Tests authenticate method with no username or password in call
      assert_equal(ts.authenticate(auth_type="password"),
                        [{ts.error => "Missing username, password; please add to method call"}])
    end

  def test_authentication_no_username_or_auth_type
      # Tests authenticate method with no username or auth_type in call
      assert_equal(ts.authenticate(password="password"),
                        [{ts.error => "Missing username, auth_type; please add to method call"}])
    end

  def test_authentication_no_password_or_auth_type
      # Tests authenticate method with no username or auth_type in call
      assert_equal(ts.authenticate(username="username"),
                        [{ts.error => "Missing password, auth_type; please add to method call"}])
    end

  def test_authentication_no_arguments
      # Tests authenticate method with no arguments in call
      assert_equal(ts.authenticate(),
                        [{ts.error => "Missing username, password, auth_type; please add to method call"}])
    end

  # def test_authentication_no_token_in_response(self):
  # end

  def test_local_auth_error_with_token
      # Test internal local_auth_error method with token
      assert_nil(ts._TimeSync__local_auth_error())
    end

  def test_local_auth_error_no_token
    # Test internal local_auth_error method with no token
      ts.token = nil
      assert_equal(ts._TimeSync__local_auth_error(),
                        "Not authenticated with TimeSync, call self.authenticate() first")
    end

  # def test_handle_other_connection_response(self):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_delete_object_time(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_delete_object_project(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_delete_object_activity(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__response_to_python")
  # def test_delete_object_user(self, m_resp_python):
  # end

  # @patch("rimesync.TimeSync._TimeSync__delete_object")
  # def test_delete_time(self, m_delete_object):
  # end

  def test_delete_time_no_auth
    # Test that delete_time returns proper error on authentication failure
      ts.token = nil
      assert_equal(ts.delete_time("abcd-3453-3de3-99sh"),
                        [{"rimesync error" =>
                          "Not authenticated with TimeSync, call self.authenticate() first"}])
    end

  def test_delete_time_no_uuid
    # Test that delete_time returns proper error when uuid not provided
      assert_equal(ts.delete_time(),
                        [{"rimesync error" =>
                          "missing uuid; please add to method call"}])
    end

  # @patch("rimesync.TimeSync._TimeSync__delete_object")
  # def test_delete_project(self, m_delete_object):
  # end

  def test_delete_project_no_auth
  # Test that delete_project returns proper error on authentication failure
    ts.token = nil
    assert_equal(ts.delete_project("ts"),
                      [{"rimesync error" =>
                        "Not authenticated with TimeSync, call self.authenticate() first"}])
  end

  def test_delete_project_no_slug
      # Test that delete_project returns proper error when slug not provided
      assert_equal(ts.delete_project(),
                        [{"rimesync error" =>
                          "missing slug; please add to method call"}])
    end

  # @patch("rimesync.TimeSync._TimeSync__delete_object")
  # def test_delete_activity(self, m_delete_object):
  # end

  def test_delete_activity_no_auth
    # Test that delete_activity returns proper error on authentication failure
      ts.token = nil
      assert_equal(ts.delete_activity("code"),
                        [{"rimesync error" =>
                          "Not authenticated with TimeSync, call self.authenticate() first"}])
  end

  def test_delete_activity_no_slug
    # Test that delete_activity returns proper error when slug not provided
      assert_equal(ts.delete_activity(),
                        [{"rimesync error" =>
                          "missing slug; please add to method call"}])
  end

  # @patch("rimesync.TimeSync._TimeSync__delete_object")
  # def test_delete_user(self, m_delete_object):
  # end

  def test_delete_user_no_auth
    # Test that delete_user returns proper error on authentication failure
      ts.token = nil
      assert_equal(ts.delete_user("example-user"),
                        [{"rimesync error" =>
                          "Not authenticated with TimeSync, call self.authenticate() first"}])
    end

  def test_delete_user_no_username
      # Test that delete_user returns proper error when username not provided
      assert_equal(ts.delete_user(),
                        [{"rimesync error" =>
                          "missing username; please add to method call"}])
    end

  # def test_token_expiration_valid(self):
  #   end

  def test_token_expiration_invalid
    # Test that token_expiration_time returns correct from an invalid token
      assert_equal(ts.token_expiration_time(),
                        [{ts.error => "improperly encoded token"}])
  end

  def test_token_expiration_no_auth
    # Test that token_expiration_time returns correct error when user is not authenticated
      ts.token = nil
      assert_equal(ts.token_expiration_time(),
                        [{ts.error => "Not authenticated with TimeSync, call self.authenticate() first"}])
  end

  def test_duration_to_seconds
    # Tests that when a string duration is entered, it is converted to an integer
      time = Hash[
          'duration'=> '3h30m',
          'project'=> 'ganeti-web-manager',
          'user'=> 'example-user',
          'activities'=> ['documenting'],
          'notes'=> 'Worked on docs',
          'issue_uri'=> "https://github.com/",
          'date_worked'=> '2014-04-17',
      ]

      assert_equal(ts._TimeSync__duration_to_seconds(time['duration']), 12600)
    end

  def test_duration_to_seconds_with_invalid_str
    # Tests that when an invalid string duration is entered, an error message is returned
      time = Hash[
          'duration'=> '3hh30m',
          'project'=> 'ganeti-web-manager',
          'user'=> 'example-user',
          'activities'=> ['documenting'],
          'notes'=> 'Worked on docs',
          'issue_uri'=> "https://github.com/",
          'date_worked'=> '2014-04-17',
      ]

      assert_equal(ts._TimeSync__duration_to_seconds(time['duration']),
                        [{ts.error =>
                          "time object: invalid duration string"}])
    end


  # def test_project_users_valid
  #   # Test project_users method with a valid project object returned from TimeSync
  # end

  # def test_project_users_error_response(self):
  # end
end
