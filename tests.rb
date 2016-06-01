require 'test/unit'
require 'http'
require_relative 'rimesync'
require 'json'

class Resp
  def initialize
    @text = nil
    @status_code = nil
  end
end


class TestRimeSync < Test::Unit::TestCase
  def setup
    baseurl = 'http://ts.example.com/v1'
    @ts = TimeSync.new(baseurl) # not working
    @ts.user = 'example-user'
    @ts.password = 'password'
    @ts.auth_type = 'password'
    @ts.token = 'TESTTOKEN'
  end

  def teardown
    remove_instance_variable(:@ts)
    @post = actual_post   # fix this and next two lines
    @delete = actual_delete
    @get = actual_get
  end

  def test_instantiate_with_token
    # Test that instantiating rimesync with a token sets the token variable
    ts = rimesync.TimeSync('baseurl', token='TOKENTOCHECK')  # not working
    assert_equal(ts.token, 'TOKENTOCHECK')
  end

  def test_instantiate_without_token
    # Test that instantiating rimesync without a token does not sets the token variable
    ts = rimesync.TimeSync('baseurl')
    assert_nil(ts.token)
  end

  def test_create_or_update_create_time_valid   # work on this
    # Tests TimeSync._TimeSync__create_or_update for create time with valid data

    # Parameters to be sent to TimeSync

    time = Hash[
        'duration' => 12,
        'project' => 'ganeti-web-manager',
        'user' => 'example-user',
        'activities' => ['documenting'],
        'notes' => 'Worked on docs',
        'issue_uri' => 'https://github.com/',
        'date_worked' => '2014-04-17',
    ]

    # Format content for assert_called_with test
    content = Hash[
        'auth' => ts._TimeSync__token_auth(),
        'object' => time,
    ]

    # Mock requests.post so it doesn't actually post to TimeSync
    requests.post = mock.create_autospec(requests.post)

    # Send it
    ts._TimeSync__create_or_update(time, nil, "time", "times")

    # Test it
    requests.post.assert_called_with("http://ts.example.com/v1/times",
                                     json=content)
  end

  def test_create_or_update_update_time_valid  # work on this
    # Tests TimeSync._TimeSync__create_or_update for update time with valid data

    # Parameters to be sent to TimeSync

    time = Hash[
        'duration' => 12,
        'project' => 'ganeti-web-manager',
        'user' => 'example-user',
        'activities' => ['documenting'],
        'notes' => 'Worked on docs',
        'issue_uri' => 'https://github.com/',
        'date_worked' => '2014-04-17',
    ]

    # Test baseurl and uuid
    uuid = '1234-5678-90abc-d'

    # Format content for assert_called_with test
    content = Hash[
        'auth' => self.ts._TimeSync__token_auth(),
        'object' => time,
    ]

    # Mock requests.post so it doesn't actually post to TimeSync
    requests.post = mock.create_autospec(requests.post)

    # Send it
    self.ts._TimeSync__create_or_update(time, uuid, 'time', 'times')

    # Test it
    requests.post.assert_called_with(
        'http://ts.example.com/v1/times/{}'.format(uuid),
        json=content)
  end

  def test_create_or_update_update_time_valid_less_fields  # work on this
    # Tests TimeSync._TimeSync__create_or_update for update time with one valid parameter

    # Parameters to be sent to TimeSync
    time = Hash[
        'duration' => 12,
    ]

    # Test baseurl and uuid
    uuid = '1234-5678-90abc-d'

    # Format content for assert_called_with test
    content = Hash[
        'auth' => ts._TimeSync__token_auth(),
        'object' => time,
    ]

    # Mock requests.post so it doesn't actually post to TimeSync
    requests.post = mock.create_autospec(requests.post)

    # Send it
    self.ts._TimeSync__create_or_update(time, uuid, 'time', 'times', false)

    # Test it
    requests.post.assert_called_with(
        'http://ts.example.com/v1/times/{}'.format(uuid),
        json=content)
  end

  def test_create_or_update_create_time_invalid
  # Tests TimeSync._TimeSync__create_or_update for create time with invalid field

  # Parameters to be sent to TimeSync
    time = Hash[
        'duration' => 12,
        'project' => 'ganeti-web-manager',
        'user' => 'example-user',
        'activities' => ['documenting'],
        'notes' => 'Worked on docs',
        'issue_uri' => 'https://github.com/',
        'date_worked' => '2014-04-17',
        'bad' => 'field'
    ]


    assert_equal(ts._TimeSync__create_or_update(time, nil,
                                                          'time', 'times'),
                      [{ts.error =>
                        'time object: invalid field: bad'}])
  end

  def test_create_or_update_create_time_two_required_missing
    # Parameters to be sent to TimeSync
    time = Hash[
        'duration' => 12,
        'user' => 'example-user',
        'notes' => 'Worked on docs',
        'issue_uri' => 'https://github.com/',
        'date_worked' => '2014-04-17'
    ]

    assert_equal(ts._TimeSync__create_or_update(time, nil,
                                                          'time', 'times'),
                      [Hash[ts.error =>
                        'time object: missing required field(s): project, activities']])
  end

  def test_create_or_update_create_time_each_required_missing
    # Tests TimeSync._TimeSync__create_or_update to create time with missing required fields
    # Parameters to be sent to TimeSync
    time = Hash[
        'duration' => 12,
        'project' => 'ganeti-web-manager',
        'user' => 'example-user',
        'activities' => ['documenting'],
        'date_worked' => '2014-04-17'
    ]

    time_to_test = Hash[time]

    for key, value in time
        del(time_to_test[key])  # will ot work
        assert_equal(ts._TimeSync__create_or_update(
                          time_to_test, nil, 'time', 'times'),
                          [Hash[ts.error => 'time object: missing required field(s): {}'.format(key)]])
        time_to_test = Hash[time]
    end
  end

  def test_create_or_update_create_time_type_error
    # Tests TimeSync._TimeSync__create_or_update for create time with incorrect parameter types

    # Parameters to be sent to TimeSync
    param_list = Array[1, 'hello', [1, 2, 3], nil, true, false, 1.234]

    for param in param_list
        assert_equal(ts._TimeSync__create_or_update(param, nil,'time','times'),
                            [Hash[ts.error =>'time object: must be python dictionary']])
    end
  end

  def test_create_or_update_create_user_valid  # work on this
    # Tests TimeSync._TimeSync__create_or_update for create user with valid data
    # Parameters to be sent to TimeSync
    user = Hash[
        'username' => 'example-user',
        'password' => 'password',
        'display_name' => 'Example User',
        'email' => 'example.user@example.com',
    ]

    # Format content for assert_called_with test
    content = Hash[
        'auth' => ts._TimeSync__token_auth(),
        'object' => user,
    ]

    # Mock requests.post so it doesn't actually post to TimeSync
    requests.post = mock.create_autospec(requests.post)

    # Send it
    self.ts._TimeSync__create_or_update(user, nil, 'user', 'users')

    # Test it
    requests.post.assert_called_with('http://ts.example.com/v1/users',
                                     json=content)
  end

  def test_create_or_update_update_user_valid   # work on this
    # Tests TimeSync._TimeSync__create_or_update for update user with valid data
    # Parameters to be sent to TimeSync
    user = Hash[
        'username' => 'example-user',
        'password' => 'password',
        'display_name' => 'Example User',
        'email' => 'example.user@example.com',
    ]

    # Test baseurl and uuid
    username = 'example-user'

    # Format content for assert_called_with test
    content = Hash[
        'auth' => ts._TimeSync__token_auth(),
        'object' => user,
    ]

    # Mock requests.post so it doesn't actually post to TimeSync
    requests.post = mock.create_autospec(requests.post)

    # Send it
    ts._TimeSync__create_or_update(user, username, 'user',
                                        'users', false)

    # Test it
    requests.post.assert_called_with(
        'http://ts.example.com/v1/users/{}'.format(username),
        json=content)
  end

  def test_create_or_update_update_user_valid_less_fields   # work on this
      """Tests TimeSync._TimeSync__create_or_update for update user with one
      valid parameter"""
      # Parameters to be sent to TimeSync
      user = {
          "display_name": "Example User",
      }

      # Test baseurl and uuid
      username = "example-user"

      # Format content for assert_called_with test
      content = {
          'auth': self.ts._TimeSync__token_auth(),
          'object': user,
      }

      # Mock requests.post so it doesn't actually post to TimeSync
      requests.post = mock.create_autospec(requests.post)

      # Send it
      self.ts._TimeSync__create_or_update(user, username, "user",
                                          "users", false)

      # Test it
      requests.post.assert_called_with(
          "http://ts.example.com/v1/users/{}".format(username),
          json=content)


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
                                                          'user', 'users'),
                      [Hash[ts.error =>
                        'user object: invalid field: bad']])
  end

  def test_create_or_update_create_user_two_required_missing
      # Tests TimeSync._TimeSync__create_or_update for create user with missing required fields

    # Parameters to be sent to TimeSync
    user = Hash[
        'displayname' => 'Example User',
        'email'=> 'example.user@example.com'
    ]

    assert_equal(ts._TimeSync__create_or_update(user, nil,
                                                          'user', 'users'),
                      [Hash[ts.error =>
                        'user object: missing required field(s): username, password']])
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
                          user_to_test, nil, 'user', 'users'),
                          [Hash[ts.error => 'user object: missing required field(s): {}'.format(key)]])
        user_to_test = Hash[user]
    end
  end

  def test_create_or_update_create_user_type_error
        #Tests TimeSync._TimeSync__create_or_update for create user with incorrect parameter types

    # Parameters to be sent to TimeSync
    param_list = [1, 'hello', [1, 2, 3], nil, true, false, 1.234]

    for param in param_list
        assert_equal(ts._TimeSync__create_or_update(param,nil,'user','users'),
                          [Hash[ts.error =>
                            'user object: must be python dictionary']])
    end
  end

  def test_create_or_update_create_project_valid  # work on this
    # Tests TimeSync._TimeSync__create_or_update for create project with valid data

    # Parameters to be sent to TimeSync

    project = Hash[
        'uri' => 'https://code.osuosl.org/projects/timesync',
        'name' => 'TimeSync API',
        'slugs' => ['timesync', 'time'],
        'users' => Hash[
            'mrsj' => Hash['member' => true, 'spectator' => true, 'manager' => true],
            'thai' => Hash['member' => true, 'spectator' => false, 'manager' => false]
        ]
    ]

    # Format content for assert_called_with test
    content = Hash[
        'auth' => ts._TimeSync__token_auth(),
        'object' => project,
    ]

    # Mock requests.post so it doesn't actually post to TimeSync
    requests.post = mock.create_autospec(requests.post)

    # Send it
    self.ts._TimeSync__create_or_update(project, nil,
                                        'project', 'projects')

    # Test it
    requests.post.assert_called_with('http://ts.example.com/v1/projects',
                                     json=content)
  end


  def test_create_or_update_update_project_valid  # work on this
    # Tests TimeSync._TimeSync__create_or_update for update project with valid parameters
    # Parameters to be sent to TimeSync
    project = Hash[
        'uri' => 'https://code.osuosl.org/projects/timesync',
        'name' => 'TimeSync API',
        'slugs' => ['timesync', 'time'],
        'users' => Hash[
            'mrsj' => Hash['member' => true, 'spectator' => true, 'manager' => true],
            'thai' => Hash['member' => true, 'spectator' => false, 'manager' => false]
        ]
    ]

    # Format content for assert_called_with test
    content = Hash[
        'auth' => ts._TimeSync__token_auth(),
        'object' => project,
    ]

    # Mock requests.post so it doesn't actually post to TimeSync
    requests.post = mock.create_autospec(requests.post)

    # Send it
    self.ts._TimeSync__create_or_update(project, 'slug',
                                        'project', 'projects')

    # Test it
    requests.post.assert_called_with(
        'http://ts.example.com/v1/projects/slug',
        json=content)
  end

  def test_create_or_update_update_project_valid_less_fields  # work on this
    # Tests TimeSync._TimeSync__create_or_update for update project with one valid parameter
    # Parameters to be sent to TimeSync
    project = Hash[
        'slugs' => ['timesync', 'time'],
    ]

    # Format content for assert_called_with test
    content = Hash[
        'auth' => ts._TimeSync__token_auth(),
        'object' => project,
    ]

    # Mock requests.post so it doesn't actually post to TimeSync
    requests.post = mock.create_autospec(requests.post)

    # Send it
    ts._TimeSync__create_or_update(project, 'slug', 'project',
                                        'projects', false)

    # Test it
    requests.post.assert_called_with(
        'http://ts.example.com/v1/projects/slug',
        json=content)
  end

  def test_create_or_update_create_project_invalid
    # Tests TimeSync._TimeSync__create_or_update for create project with invalid field

    # Parameters to be sent to TimeSync
    project = Hash[
        'uri' => 'https://code.osuosl.org/projects/timesync',
        'name' => 'TimeSync API',
        'slugs' => ['timesync', 'time'],
        'users' => Hash[
            'mrsj' => Hash['member' => true, 'spectator' => true, 'manager' => true],
            'thai' => Hash['member' => true, 'spectator' => false, 'manager' => false]
        ],
        'bad' => 'field'
    ]

    assert_equal(ts._TimeSync__create_or_update(project,nil,
                                                          'project',
                                                          'projects'),
                      [Hash[ts.error =>
                        'project object: invalid field: bad']])
  end


  def test_create_or_update_create_project_required_missing
    # Tests TimeSync._TimeSync__create_or_update for create project with missing required fields

    # Parameters to be sent to TimeSync
    project = Hash[
        'slugs' => ['timesync', 'time'],
    ]

    assert_equal(ts._TimeSync__create_or_update(project,nil,
                                                          'project',
                                                          'project'),
                      [Hash[ts.error => 'project object: missing required field(s): name']])
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
                          project_to_test, nil, 'project', 'projects'),
                          [Hash[ts.error => 'project object: missing required field(s): {}'.format(key)]])
        project_to_test = Hash[project]
    end
  end

  def test_create_or_update_create_project_type_error
    # Tests TimeSync._TimeSync__create_or_update for create project with incorrect parameter types

    # Parameters to be sent to TimeSync
    param_list = Array[1, 'hello', [1, 2, 3], nil, true, false, 1.234]

    for param in param_list
        assert_equal(ts._TimeSync__create_or_update(param,nil,
                                                    'project','projects'),
                          [Hash[ts.error =>
                            'project object: must be python dictionary']])
    end
  end

  def test_create_or_update_create_activity_valid  # work on this
    # Tests TimeSync._TimeSync__create_or_update for create activity with valid data
    # Parameters to be sent to TimeSync
    project = Hash[
        'name' => 'Quality Assurance/Testing',
        'slug' => 'qa',
    ]

    # Format content for assert_called_with test
    content = Hash[
        'auth' => ts._TimeSync__token_auth(),
        'object' => project,
    ]

    # Mock requests.post so it doesn't actually post to TimeSync
    requests.post = mock.create_autospec(requests.post)

    # Send it
    ts._TimeSync__create_or_update(project, nil,
                                        'activity', 'activities')

    # Test it
    requests.post.assert_called_with('http://ts.example.com/v1/activities',
                                     json=content)
  end

  def test_create_or_update_update_activity_valid   # work on this
    # Tests TimeSync._TimeSync__create_or_update for update activity with valid parameters
    # Parameters to be sent to TimeSync
    activity = Hash[
        'name' => 'Quality Assurance/Testing',
        'slug' => 'qa',
    ]

    # Format content for assert_called_with test
    content = {
        'auth' => ts._TimeSync__token_auth(),
        'object' => activity,
    }

    # Mock requests.post so it doesn't actually post to TimeSync
    requests.post = mock.create_autospec(requests.post)

    # Send it
    ts._TimeSync__create_or_update(activity, 'slug',
                                        'activity', 'activities')

    # Test it
    requests.post.assert_called_with(
        'http://ts.example.com/v1/activities/slug',
        json=content)
  end

  def test_create_or_update_update_activity_valid_less_fields  # work in this
    # Tests TimeSync._TimeSync__create_or_update for update activity with one valid parameter
      # Parameters to be sent to TimeSync
      activity = Hash[
          'slug' => 'qa',
      ]

      # Format content for assert_called_with test
      content = Hash[
          'auth' => ts._TimeSync__token_auth(),
          'object' => activity,
      ]

      # Mock requests.post so it doesn't actually post to TimeSync
      requests.post = mock.create_autospec(requests.post)

      # Send it
      ts._TimeSync__create_or_update(activity, 'slug', 'activity',
                                          'activities', false)

      # Test it
      requests.post.assert_called_with(
          'http://ts.example.com/v1/activities/slug',
          json=content)

  end

  def test_create_or_update_create_activity_invalid
    # Tests TimeSync._TimeSync__create_or_update for create activity with invalid field
    # Parameters to be sent to TimeSync
    activity = Hash[
        'name' => 'Quality Assurance/Testing',
        'slug' => 'qa',
        'bad' => 'field'
    ]

    assert_equal(ts._TimeSync__create_or_update(activity,nil,
                                                          'activity',
                                                          'activites'),
                      [Hash[ts.error =>
                        'activity object: invalid field: bad']])
  end

  def test_create_or_update_create_activity_required_missing
    # Tests TimeSync._TimeSync__create_or_update for create activity with missing required fields
    # Parameters to be sent to TimeSync
    activity = Hash[
        'name' => 'Quality Assurance/Testing',
    ]

    assert_equal(ts._TimeSync__create_or_update(activity,nil,
                                                          'activity',
                                                          'activities'),
                      [Hash[ts.error => 'activity object: missing required field(s): slug']])
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
                          'activity', 'activities'),
                          [Hash[ts.error => 'activity object: missing required field(s): {}'.format(key)]])
        activity_to_test = Hash[activity]
    end
  end

  def test_create_or_update_create_activity_type_error
    # Tests TimeSync._TimeSync__create_or_update for create activity with incorrect parameter types

    # Parameters to be sent to TimeSync
    param_list = [1, 'hello', [1, 2, 3], nil, true, false, 1.234]

    for param in param_list
      assert_equal(ts._TimeSync__create_or_update(param,
                          nil, 'activity', 'activities'),
                          [Hash[ts.error => 'activity object: must be python dictionary']])

    end
  end

  # @patch('rimesync.TimeSync._TimeSync__response_to_python')
  # def test_create_or_update_create_time_no_auth(self, m_resp_python):
  # end

  # @patch('rimesync.TimeSync._TimeSync__response_to_python')
  # def test_create_or_update_create_project_no_auth(self, m_resp_python):
  # end

  # @patch('rimesync.TimeSync._TimeSync__response_to_python')
  # def test_create_or_update_create_activity_no_auth(self, m_resp_python):
  # end

  # @patch('rimesync.TimeSync._TimeSync__response_to_python')
  # def test_create_or_update_update_time_no_auth(self, m_resp_python):
  # end

  # @patch('rimesync.TimeSync._TimeSync__response_to_python')
  # def test_create_or_update_update_project_no_auth(self, m_resp_python):
  # end

  # @patch('rimesync.TimeSync._TimeSync__response_to_python')
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

    assert_equal(ts._TimeSync__auth, auth)
  end

  def test_get_time_for_user  # work on this
    # Tests TimeSync.get_times with username query parameter
    response = resp()
    response.text = json.dump(Hash['this' => 'should be in a list'])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = '{0}/times?user=example-user&token={1}'.format(ts.baseurl,
                                                         ts.token)

    # Test that requests.get was called with baseurl and correct parameter
    assertEqual(self.ts.get_times(Hash['user' => [self.ts.user]]),
                     [Hash['this' => 'should be in a list']])
    requests.get.assert_called_with(url)
  end

  def test_get_time_for_proj  # work on this
    # Tests TimeSync.get_times with project query parameter
    response = resp()
    response.text = json.dump(Hash['this' => 'should be in a list'])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = '{0}/times?project=gwm&token={1}'.format(ts.baseurl,
                                                   ts.token)

    # Test that requests.get was called with baseurl and correct parameter
    assertEqual(self.ts.get_times(Hash['project' => ['gwm']]),
                     [Hash['this' => 'should be in a list']])
    requests.get.assert_called_with(url)
  end


  def test_get_time_for_activity  # work on this
    # Tests TimeSync.get_times with activity query parameter
    response = resp()
    response.text = json.dump(Hash['this' => 'should be in a list'])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = '{0}/times?activity=dev&token={1}'.format(ts.baseurl,
                                                    ts.token)

    # Test that requests.get was called with baseurl and correct parameter
    self.assertEqual(ts.get_times(Hash['activity' => ['dev']]),
                     [Hash['this' => 'should be in a list']])
    requests.get.assert_called_with(url)
  end

  def test_get_time_for_start_date  # wokr on this
    # Tests TimeSync.get_times with start date query parameter
    response = resp()
    response.text = json.dump(Hash['this' => 'should be in a list'])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = '{0}/times?start=2015-07-23&token={1}'.format(ts.baseurl,
                                                        ts.token)

    # Test that requests.get was called with baseurl and correct parameter
    self.assertEqual(ts.get_times(Hash['start' => ['2015-07-23']]),
                     [Hash['this' => 'should be in a list']])
    requests.get.assert_called_with(url)
  end

  def test_get_time_for_end_date # work on this
    # Tests TimeSync.get_times with end date query parameter
    response = resp()
    response.text = json.dump(Hash['this' => 'should be in a list'])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = '{0}/times?end=2015-07-23&token={1}'.format(ts.baseurl,
                                                      ts.token)

    # Test that requests.get was called with baseurl and correct parameter
    assertEqual(self.ts.get_times(Hash['end' => ['2015-07-23']]),
                     [Hash['this' => 'should be in a list']])
    requests.get.assert_called_with(url)
  end

  def test_get_time_for_include_revisions  # wok on this
    # Tests TimeSync.get_times with include_revisions query parameter
    response = resp()
    response.text = json.dump(Hash['this' => 'should be in a list'])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = '{0}/times?include_revisions=true&token={1}'.format(
        self.ts.baseurl, self.ts.token)

    # Test that requests.get was called with baseurl and correct parameter
    self.assertEqual(self.ts.get_times(Hash['include_revisions' => true]),
                     [Hash['this' => 'should be in a list']])
    requests.get.assert_called_with(url)
  end

  def test_get_time_for_include_revisions_false # work on this
    # Tests TimeSync.get_times with include_revisions false query parameter
    response = resp()
    response.text = json.dump(Hash['this' => 'should be in a list'])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = '{0}/times?include_revisions=false&token={1}'.format(
        ts.baseurl, ts.token)

    # Test that requests.get was called with baseurl and correct parameter
    assertEqual(ts.get_times(Hash['include_revisions' => false]),
                     [Hash['this' => 'should be in a list']])
    requests.get.assert_called_with(url)

  end


  def test_get_time_for_include_deleted # wokr on this
    # Tests TimeSync.get_times with include_deleted query parameter
    response = resp()
    response.text = json.dump(Hash['this' => 'should be in a list'])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = '{0}/times?include_deleted=true&token={1}'.format(
        ts.baseurl, ts.token)

    # Test that requests.get was called with baseurl and correct parameter
    assertEqual(ts.get_times(Hash['include_deleted' => true]),
                     [Hash['this' => 'should be in a list']])
    requests.get.assert_called_with(url)

  end

  def test_get_time_for_include_deleted_false  # work on this
    # Tests TimeSync.get_times with include_revisions false query parameter
    response = resp()
    response.text = json.dump(Hash['this' => 'should be in a list'})

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = '{0}/times?include_deleted=false&token={1}'.format(
        ts.baseurl, ts.token)

    # Test that requests.get was called with baseurl and correct parameter
    assertEqual(ts.get_times(Hash['include_deleted' => false}),
                     [Hash['this' => 'should be in a list'}])
    requests.get.assert_called_with(url)
  end

  def test_get_time_for_proj_and_activity  # work on this
      """Tests TimeSync.get_times with project and activity query
      parameters"""
    response = resp()
    response.text = json.dump(Hash['this' => 'should be in a list'])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = '{0}/times?activity=dev&project=gwm&token={1}'.format(
        ts.baseurl, ts.token)

    # Test that requests.get was called with baseurl and correct parameters
    # Multiple parameters are sorted alphabetically
    assertEqual(ts.get_times(Hash['project' => ['gwm'],
                                        'activity' => ['dev']]),
                     [Hash['this' => 'should be in a list']])
    requests.get.assert_called_with(url)
  end

  def test_get_time_for_activity_x3   # work on this
    # Tests TimeSync.get_times with project and activity query parameters
    response = resp()
    response.text = json.dump(Hash['this' => 'should be in a list'])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    token_string = '&token={}'.format(ts.token)

    url = '{0}/times?activity=dev&activity=rev&activity=hd{1}'.format(
        ts.baseurl, token_string)

    # Test that requests.get was called with baseurl and correct parameters
    # Multiple parameters are sorted alphabetically
    assert_equal(ts.get_times(Hash['activity' => Array['dev',
                                                      'rev',
                                                      'hd']]),
                      [Hash['this' => 'should be in a list']])
    requests.get.assert_called_with(url)
  end

  def test_get_time_with_uuid  # work on this
    # Tests TimeSync.get_times with uuid query parameter
    response = resp()
    response.text = json.dump(Hash['this' => 'should be in a list'])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = '{0}/times/sadfasdg432?token={1}'.format(ts.baseurl,
                                                   ts.token)

    # Test that requests.get was called with baseurl and correct parameter
    assert_equal(ts.get_times(Hash['uuid' => 'sadfasdg432']),
                      [Hash['this' => 'should be in a list']])
    requests.get.assert_called_with(url)
  end

  def test_get_time_with_uuid_and_activity   # work on this
    # Tests TimeSync.get_times with uuid and activity query parameters
    response = resp()
    response.text = json.dump(Hash['this' => 'should be in a list'])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = '{0}/times/sadfasdg432?token={1}'.format(ts.baseurl,
                                                   ts.token)

    # Test that requests.get was called with baseurl and correct parameter
    assert_equal(ts.get_times(Hash['uuid' => 'sadfasdg432',
                                         'activity' => ['dev']]),
                      [Hash['this' => 'should be in a list']])
    requests.get.assert_called_with(url)
  end

  def test_get_time_with_uuid_and_include_revisions  # work on this
    # Tests TimeSync.get_times with uuid and include_revisions query parameters
    response = resp()
    response.text = json.dump(Hash['this' => 'should be in a list'])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = '{0}/times/sadfasdg432?include_revisions=true&token={1}'.format(
        ts.baseurl, ts.token)

    # Test that requests.get was called with baseurl and correct parameter
    assert_equal(ts.get_times(Hash['uuid' => 'sadfasdg432',
                                         'include_revisions' => true]),
                      [Hash['this' => 'should be in a list']])
    requests.get.assert_called_with(url)
  end

  def test_get_time_with_uuid_and_include_deleted # Work on this
    # Tests TimeSync.get_times with uuid and include_deleted query parameters
    response = resp()
    response.text = json.dump(Hash['this' => 'should be in a list'])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = '{0}/times/sadfasdg432?include_deleted=true&token={1}'.format(
        ts.baseurl, ts.token)

    # Test that requests.get was called with baseurl and correct parameter
    assert_equal(ts.get_times(Hash['uuid' => 'sadfasdg432',
                                         'include_deleted' => true]),
                      [Hash['this' => 'should be in a list']])
    requests.get.assert_called_with(url)
  end

  def test_get_time_with_uuid_include_deleted_and_revisions   # work on this
    # Tests TimeSync.get_times with uuid and include_deleted query parameters
    response = resp()
    response.text = json.dump(Hash["this": "should be in a list"])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    # Please forgive me for this. I blame the PEP8 line length rule
    endpoint = "times"
    uuid = "sadfasdg432"
    token = "token={}".format(self.ts.token)
    queries = "include_deleted=true&include_revisions=true"
    url = "{0}/{1}/{2}?{3}&{4}".format(self.ts.baseurl, endpoint, uuid,
                                       queries, token)

    # Test that requests.get was called with baseurl and correct parameter
    self.assert_equal(self.ts.get_times(Hash["uuid": "sadfasdg432",
                                         "include_revisions": true,
                                         "include_deleted": true]),
                      [Hash["this": "should be in a list"]])
    requests.get.assert_called_with(url)
  end

  def test_get_all_times  # work on this
    # Tests TimeSync.get_times with no parameters
    response = resp()
    response.text = json.dump([Hash["this" => "should be in a list"]])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = "{0}/times?token={1}".format(ts.baseurl,
                                       ts.token)

    # Test that requests.get was called with baseurl and correct parameter
    assert_equal(ts.get_times(),
                      [Hash["this" => "should be in a list"]])
    requests.get.assert_called_with(url)
  end


  def test_get_times_bad_query
    # Tests TimeSync.get_times with an invalid query parameter

    # Should return the error
    assert_equal(ts.get_times({'bad' => ['query']}),
                      [{ts.error => 'invalid query: bad'}])
  end

  def test_get_projects  # work on this
    # Tests TimeSync.get_projects
    response = resp()
    response.text = json.dump([Hash["this" => "should be in a list"]])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = "{0}/projects?token={1}".format(ts.baseurl,
                                          ts.token)

    # Test that requests.get was called correctly
    assert_equal(ts.get_projects(),
                      [Hash["this" => "should be in a list"]]])
    requests.get.assert_called_with(url)
  end

  def test_get_projects_slug  # work on this
    # Tests TimeSync.get_projects with slug
    response = resp()
    response.text = json.dump(Hash["this" => "should be in a list"]])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = "{0}/projects/gwm?token={1}".format(ts.baseurl,
                                              ts.token)

    # Test that requests.get was called correctly
    assert_equal(ts.get_projects(Hash["slug" => "gwm"]]),
                      [Hash["this": "should be in a list"]]])
    requests.get.assert_called_with(url)
  end

  def test_get_projects_include_revisions # work on this
    # Tests TimeSync.get_projects with include_revisions query
    response = resp()
    response.text = json.dump(Hash["this" => "should be in a list"]])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = "{0}/projects?include_revisions=true&token={1}".format(
        ts.baseurl, ts.token)

    # Test that requests.get was called correctly
    assert_equal(ts.get_projects(Hash["include_revisions" => true]]),
                      [Hash["this": "should be in a list"]]])
    requests.get.assert_called_with(url)

  end

  def test_get_projects_slug_include_revisions  # work on this
    # Tests TimeSync.get_projects with include_revisions query and slug
    response = resp()
    response.text = json.dump(Hash["this" => "should be in a list"]])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = "{0}/projects/gwm?include_revisions=true&token={1}".format(
        ts.baseurl, ts.token)

    # Send it

    # Test that requests.get was called correctly
    assert_equal(ts.get_projects(Hash["slug" => "gwm",
                                            "include_revisions": true]]),
                      [Hash["this": "should be in a list"]]])
    requests.get.assert_called_with(url)
  end

  def test_get_projects_include_deleted # work on this
    # Tests TimeSync.get_projects with include_deleted query
    response = resp()
    response.text = json.dump(Hash["this" => "should be in a list"]])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = "{0}/projects?include_deleted=true&token={1}".format(
        ts.baseurl, ts.token)

    # Test that requests.get was called correctly
    assert_equal(ts.get_projects(Hash["include_deleted" => true]]),
                      [Hash["this" => "should be in a list"]]])
    requests.get.assert_called_with(url)
  end


def test_get_projects_include_deleted_with_slug
  # Tests TimeSync.get_projects with include_deleted query and slug, which is not allowed

  # Mock requests.get
  requests.get = mock.Mock('requests.get') # won't work

  # Test that error message is returned, can't combine slug and include_deleted
  assert_equal(ts.get_projects(Hash['slug' => 'gwm',
                                          'include_deleted' => true]),
                    [Hash[ts.error =>
                     'invalid combination: slug and include_deleted']])
  end

  def test_get_projects_include_deleted_include_revisions  # work on this
    # Tests TimeSync.get_projects with include_revisions and include_deleted queries
      response = resp()
      response.text = json.dump(Hash["this" => "should be in a list"])

      # Mock requests.get
      requests.get = mock.create_autospec(requests.get,
                                          return_value=response)

      token_string = "&token={}".format(ts.token)
      endpoint = "/projects"
      url = "{0}{1}?include_deleted=true&include_revisions=true{2}".format(
          ts.baseurl, endpoint, token_string)

      # Test that requests.get was called with correct parameters
      assert_equal(ts.get_projects(Hash["include_revisions" => true,
                                              "include_deleted" => true]),
                        [Hash["this" => "should be in a list"]])
      requests.get.assert_called_with(url)
  end

  def test_get_activities  # work on this
    # Tests TimeSync.get_activities
    response = resp()
    response.text = json.dump([Hash["this" => "should be in a list"}])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = "{0}/activities?token={1}".format(ts.baseurl, ts.token)

    # Test that requests.get was called correctly
    assert_equal(ts.get_activities(),
                      [Hash["this" => "should be in a list"}])
    requests.get.assert_called_with(url)
  end

  def test_get_activities_slug  # work on this
    # Tests TimeSync.get_activities with slug
    response = resp()
    response.text = json.dump(Hash["this" => "should be in a list"})

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = "{0}/activities/code?token={1}".format(ts.baseurl,
                                                 ts.token)

    # Test that requests.get was called correctly
    assert_equal(ts.get_activities(Hash["slug" => "code"}),
                      [Hash["this" => "should be in a list"}])
    requests.get.assert_called_with(url)
  end

  def test_get_activities_include_revisions  # work on this
    # Tests TimeSync.get_activities with include_revisions query
    response = resp()
    response.text = json.dump(Hash["this" => "should be in a list"})

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = "{0}/activities?include_revisions=true&token={1}".format(
        ts.baseurl, ts.token)

    # Test that requests.get was called correctly
    assert_equal(ts.get_activities(Hash["include_revisions" => true}),
                      [Hash["this" => "should be in a list"}])
    requests.get.assert_called_with(url)
  end

  def test_get_activities_slug_include_revisions   # work on this
    # Tests TimeSync.get_projects with include_revisions query and slug
    response = resp()
    response.text = json.dump(Hash["this" => "should be in a list"})

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = "{0}/activities/code?include_revisions=true&token={1}".format(
        self.ts.baseurl, self.ts.token)

    # Test that requests.get was called correctly
    self.assert_equal(self.ts.get_activities(Hash["slug" => "code",
                                              "include_revisions" => true}),
                      [Hash["this" => "should be in a list"}])
    requests.get.assert_called_with(url)
  end

  def test_get_activities_include_deleted  # work on this
    # Tests TimeSync.get_activities with include_deleted query
    response = resp()
    response.text = json.dump(Hash["this" => "should be in a list"})

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = "{0}/activities?include_deleted=true&token={1}".format(
        ts.baseurl, ts.token)

    # Send it

    # Test that requests.get was called correctly
    assert_equal(ts.get_activities(Hash["include_deleted" => true}),
                      [{"this" => "should be in a list"}])
    requests.get.assert_called_with(url)
  end

  def test_get_activities_include_deleted_with_slug
    # Tests TimeSync.get_activities with include_deleted query and slug, which is not allowed
    # Mock requests.get
    requests.get = mock.Mock("requests.get")

    # Test that error message is returned, can't combine slug and
    # include_deleted
    assert_equal(ts.get_activities(Hash['slug' => 'code',
                                              'include_deleted' => true]),
                      [Hash[ts.error =>
                       'invalid combination => slug and include_deleted']])
  end

  def test_get_activities_include_deleted_include_revisions # work on this
    # Tests TimeSync.get_activities with include_revisions and include_deleted queries
    response = resp()
    response.text = json.dump(Hash["this" => "should be in a list"])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    token_string = "&token={}".format(ts.token)
    endpoint = "/activities"
    url = "{0}{1}?include_deleted=true&include_revisions=true{2}".format(
        ts.baseurl, endpoint, token_string)

    # Send it
    assert_equal(ts.get_activities({"include_revisions" => true,
                                             "include_deleted" => true]),
                      [{"this" => "should be in a list"]])

    # Test that requests.get was called with correct parameters
    requests.get.assert_called_with(url)
  end


  def test_get_times_no_auth
    # Test that get_times returns error message when auth not set
    ts.token = nil
    assert_equal(ts.get_times,
                      [Hash[ts.error =>
                        'Not authenticated with TimeSync, call self.authenticate first']])
  end

  def test_get_projects_no_auth
    # Test that get_projects returns error message when auth not set
    ts.token = nil
    assert_equal(ts.get_projects,
                      [Hash[ts.error =>
                        'Not authenticated with TimeSync, call self.authenticate first']])
  end

  def test_get_activities_no_auth
    # Test that get_activities returns error message when auth not set
    ts.token = nil
    self.assert_equal(ts.get_activities,
                      [Hash[ts.error =>
                        'Not authenticated with TimeSync, call self.authenticate first']])
  end

  def test_get_users  # work on this
    # Tests TimeSync.get_users
    response = resp()
    response.text = json.dump([Hash["this" => "should be in a list"])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = "{0}/users?token={1}".format(ts.baseurl, ts.token)

    # Send it
    assert_equal(ts.get_users(),
                      [Hash["this" => "should be in a list"]])

    # Test that requests.get was called correctly
    requests.get.assert_called_with(url)
  end

  def test_get_users_username  # work on this
    # Tests TimeSync.get_users with username
    response = resp()
    response.text = json.dump(Hash["this" => "should be in a list"])

    # Mock requests.get
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    url = "{0}/users/{1}?token={2}".format(ts.baseurl,
                                           "example-user",
                                           ts.token)

    # Send it
    assert_equal(ts.get_users("example-user"),
                      [Hash["this" => "should be in a list"]])

    # Test that requests.get was called correctly
    requests.get.assert_called_with(url)
  end


  def test_get_users_no_auth
      # Test that get_users returns error message when auth not set
    ts.token = nil
    assert_equal(ts.get_users,
                      [Hash[ts.error =>
                        'Not authenticated with TimeSync, call self.authenticate first']])
  end

  def test_response_to_python_single_object   # work on this
    # Test that TimeSync._TimeSync__response_to_ruby converts a json object to a  list of object
      json_object = '{\
          "uri" => "https://code.osuosl.org/projects/ganeti-webmgr",\
          "name" => "Ganeti Web Manager",\
          "slugs" => ["ganeti", "gwm"],\
          "owner" => "example-user",\
          "uuid" => "a034806c-00db-4fe1-8de8-514575f31bfb",\
          "revision" => 4,\
          "created_at" => "2014-07-17",\
          "deleted_at" => null,\
          "updated_at" => "2014-07-20"\
      }'

      python_object = {
          u"uuid" => u"a034806c-00db-4fe1-8de8-514575f31bfb",
          u"updated_at" => u"2014-07-20",
          u"created_at" => u"2014-07-17",
          u"uri" => u"https://code.osuosl.org/projects/ganeti-webmgr",
          u"name" => u"Ganeti Web Manager",
          u"owner" => u"example-user",
          u"deleted_at" => nil,
          u"slugs" => [u"ganeti", u"gwm"],
          u"revision" => 4
      }

      response = resp()
      response.text = json_object

      assert_equal(self.ts._TimeSync__response_to_ruby(response),
                        ruby_object)
  end

  def test_response_to_python_list_of_object  # work on this
    # Test that TimeSync._TimeSync__response_to_ruby converts a json list of objects to a ruby list of objects
    json_object = '[\
        {\
            "name" => "Documentation",\
            "slugs" => ["docs", "doc"],\
            "uuid" => "adf036f5-3d49-4a84-bef9-0sdb46380bbf",\
            "revision" => 1,\
            "created_at" => "2014-04-17",\
            "deleted_at" => null,\
            "updated_at" => null\
        },\
        {\
            "name" => "Coding",\
            "slugs" => ["coding", "code", "prog"],\
            "uuid" => "adf036f5-3d79-4a84-bef9-062b46320bbf",\
            "revision" => 1,\
            "created_at" => "2014-04-17",\
            "deleted_at" => null,\
            "updated_at" => null\
        },\
        {\
            "name" => "Research",\
            "slugs" => ["research", "res"],\
            "uuid" => "adf036s5-3d49-4a84-bef9-062b46380bbf",\
            "revision" => 1,\
            "created_at" => "2014-04-17",\
            "deleted_at" => null,\
            "updated_at" => null\
        }\
    ]'

    python_object = [
        {
            u"uuid" => u"adf036f5-3d49-4a84-bef9-0sdb46380bbf",
            u"created_at" => u"2014-04-17",
            u"updated_at" => nil,
            u"name" => u"Documentation",
            u"deleted_at" => nil,
            u"slugs" => [u"docs", u"doc"],
            u"revision" => 1
        },
        {
            u"uuid" => u"adf036f5-3d79-4a84-bef9-062b46320bbf",
            u"created_at" => u"2014-04-17",
            u"updated_at" => nil,
            u"name" => u"Coding",
            u"deleted_at" => nil,
            u"slugs" => [u"coding", u"code", u"prog"],
            u"revision" => 1
        },
        {
            u"uuid" => u"adf036s5-3d49-4a84-bef9-062b46380bbf",
            u"created_at" => u"2014-04-17",
            u"updated_at" => nil,
            u"name" => u"Research",
            u"deleted_at" => nil,
            u"slugs" => [u"research", u"res"],
            u"revision" => 1
        }
    ]

    response = resp()
    response.text = json_object

    self.assert_equal(ts._TimeSync__response_to_python(response),
                      python_object)
  end

  def test_response_to_ruby_empty_response # work on this
    # Check that __response_to_ruby returns correctly for delete_*G methods
    response = resp()
    response.text = ""
    response.status_code = 200
    assert_equal(ts._TimeSync__response_to_python(response),
                      {"status": 200})
  end


  # @patch('rimesync.TimeSync._TimeSync__create_or_update')
  # def test_create_time(self, mock_create_or_update):
  # end

  # @patch('rimesync.TimeSync._TimeSync__create_or_update')
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
          'date_worked' => '2014-04-17'
      ]

      assert_equal(ts.create_time(time),
                        [Hash[ts.error =>
                          'time object: duration cannot be negative']])
  end

  def test_update_time_with_negative_duration
    # Tests that TimeSync.update_time will return an error if a negative duration is passed
    time = Hash[
        'duration' => -12600,
        'project' => 'ganeti-web-manager',
        'user' => 'example-user',
        'activities' => ['documenting'],
        'notes' => 'Worked on docs',
        'issue_uri' => 'https://github.com/',
        'date_worked' => '2014-04-17'
    ]

    assert_equal(ts.update_time(time, 'uuid'),
                      [Hash[ts.error =>
                        'time object: duration cannot be negative']])
    end


  # @patch('rimesync.TimeSync._TimeSync__create_or_update')
  # def test_create_time_with_string_duration(self, mock_create_or_update):
  # end

  # @patch('rimesync.TimeSync._TimeSync__create_or_update')
  # def test_update_time_with_string_duration(self, mock_create_or_update):
  # end



  def test_create_time_with_junk_string_duration
    # Tests that TimeSync.create_time will fail if a string containing no hours/minutes is entered
    time = Hash[
        'duration' => 'junktime',
        'project' => 'ganeti-web-manager',
        'user' => 'example-user',
        'activities' => ['documenting'],
        'notes' => 'Worked on docs',
        'issue_uri' => 'https://github.com/',
        'date_worked' => '2014-04-17',
    ]

    assert_equal(ts.create_time(time),
                      [Hash[ts.error =>
                        'time object: invalid duration string']])
  end

  def test_update_time_with_junk_string_duration
      # Tests that TimeSync.update_time will fail if a string containing no hours/minutes is entered
    time = Hash[
        'duration' => 'junktime',
        'project' => 'ganeti-web-manager',
        'user' => 'example-user',
        'activities' => ['documenting'],
        'notes' => 'Worked on docs',
        'issue_uri' => 'https://github.com/',
        'date_worked' => '2014-04-17',
    ]

    assert_equal(ts.update_time(time, 'uuid'),
                      [Hash[ts.error =>
                        'time object: invalid duration string']])
  end

  def test_create_time_with_invalid_string_duration
    # Tests that TimeSync.create_time will fail if a string containing multiple hours/minutes is entered
    time = Hash[
        'duration' => '3h30m15h',
        'project' => 'ganeti-web-manager',
        'user' => 'example-user',
        'activities' => ['documenting'],
        'notes' => 'Worked on docs',
        'issue_uri' => 'https://github.com/',
        'date_worked' => '2014-04-17',
    ]

    assert_equal(ts.create_time(time),
                      [Hash[ts.error =>
                        'time object: invalid duration string']])
  end

  def test_update_time_with_invalid_string_duration
    # Tests that TimeSync.update_time will fail if a string containing multiple hours/minutes is entered
      time = Hash[
          'duration' => '3h30m15h',
          'project' => 'ganeti-web-manager',
          'user' => 'example-user',
          'activities' => ['documenting'],
          'notes' => 'Worked on docs',
          'issue_uri' => 'https://github.com/',
          'date_worked' => '2014-04-17',
      ]

      assert_equal(ts.update_time(time, 'uuid'),
                        [Hash[ts.error =>
                          'time object: invalid duration string']])
  end

  # @patch('rimesync.TimeSync._TimeSync__create_or_update')
  # def test_create_project(self, mock_create_or_update):
  # end

  # @patch('rimesync.TimeSync._TimeSync__create_or_update')
  # def test_update_project(self, mock_create_or_update):
  # end

  # @patch('rimesync.TimeSync._TimeSync__create_or_update')
  # def test_create_activity(self, mock_create_or_update):
  # end

  # @patch('rimesync.TimeSync._TimeSync__create_or_update')
  # def test_update_activity(self, mock_create_or_update):
  # end

  # @patch('rimesync.TimeSync._TimeSync__create_or_update')
  # def test_create_user(self, mock_create_or_update):
  # end

  # @patch('rimesync.TimeSync._TimeSync__create_or_update')
  # def test_create_user_valid_perms(self, mock_create_or_update):
  # end

  def test_create_user_invalid_admin
    # Tests that TimeSync.create_user returns error with invalid perm field
    user = Hash[
        'username' => 'example-user',
        'password' => 'password',
        'displayname' => 'Example User',
        'email' => 'example.user@example.com',
        'admin' => true,
        'spectator' => false,
        'manager' => true,
        'active' => true,
    ]

    user_to_test = Hash[user]
    for perm in ['admin', 'spectator', 'manager', 'active']
        user_to_test = Hash[user]
        user_to_test[perm] = 'invalid'
        assert_equal(ts.create_user(user_to_test),
                          [Hash[ts.error => 'user object: {} must be true or false'.format(perm)]])
      end
  end

  # @patch('rimesync.TimeSync._TimeSync__create_or_update')
  # def test_update_user(self, mock_create_or_update):
  # end

  def test_authentication  # work on this
    # Tests authenticate method for url and data construction
    auth = Hash[
        'auth': Hash[
            'type' => 'password',
            'username' => 'example-user',
            'password' => 'password'
        ]
    ]

    # Mock requests.post so it doesn't actually post to TimeSync
    requests.post = mock.create_autospec(requests.post)

    ts.authenticate('example-user', 'password', 'password')

    requests.post.assert_called_with('http://ts.example.com/v1/login',
                                     json=auth)
  end

  def test_authentication_return_success  # work in this
    # Tests authenticate method with a token return

    # Use this fake response object for mocking requests.post
    response = resp()
    response.text = json.dump(Hash['token' => 'sometoken'])

    # Mock requests.post so it doesn't actually post to TimeSync
    requests.post = mock.create_autospec(requests.post,
                                         return_value=response)

    auth_block = self.ts.authenticate('example-user',
                                      'password',
                                      'password')

    self.assert_equal(auth_block['token'], self.ts.token, 'sometoken')
    self.assert_equal(auth_block, Hash['token' => 'sometoken'])
  end

  def test_authentication_return_error  # work on this
    # Tests authenticate method with an error return
    # Use this fake response object for mocking requests.post
    response = resp()
    response.text = json.dump(Hash['status' => 401,
                                'error' => 'Authentication failure',
                                'text' => 'Invalid username or password'])

    # Mock requests.post so it doesn't actually post to TimeSync
    requests.post = mock.create_autospec(requests.post,
                                         return_value=response)

    auth_block = ts.authenticate('example-user',
                                      'password',
                                      'password')

    assert_equal(auth_block, Hash['status' => 401,
                                   'error' => 'Authentication failure',
                                   'text' => 'Invalid username or '
                                   'password'])
  end

  def test_authentication_no_username
    # Tests authenticate method with no username in call
    assert_equal(ts.authenticate(password = 'password',
                                           auth_type = 'password'),
                      [Hash[ts.error => 'Missing username; please add to method call']])
  end

  def test_authentication_no_password
  # Tests authenticate method with no password in call
    assert_equal(ts.authenticate(username = 'username',
                                           auth_type = 'password'),
                      [Hash[ts.error => 'Missing password; please add to method call']])
  end

  def test_authentication_no_auth_type
      # Tests authenticate method with no auth_type in call
    assert_equal(ts.authenticate(password = 'password',
                                           username = 'username'),
                      [Hash[ts.error => 'Missing auth_type; please add to method call']])
  end

  def test_authentication_no_username_or_password
    # Tests authenticate method with no username or password in call
    assert_equal(ts.authenticate(auth_type = 'password'),
                      [Hash[ts.error => 'Missing username, password; please add to method call']])
  end

  def test_authentication_no_username_or_auth_type
    # Tests authenticate method with no username or auth_type in call
    assert_equal(ts.authenticate(password = 'password'),
                      [Hash[ts.error => 'Missing username, auth_type; please add to method call']])
  end

  def test_authentication_no_password_or_auth_type
    # Tests authenticate method with no username or auth_type in call
    assert_equal(ts.authenticate(username = 'username'),
                      [Hash[ts.error => 'Missing password, auth_type; please add to method call']])
  end

  def test_authentication_no_arguments
    # Tests authenticate method with no arguments in call
    assert_equal(ts.authenticate,
                      [Hash[ts.error => 'Missing username, password, auth_type; please add to method call']])
  end

  def test_authentication_no_token_in_response  # work ont this
    # Tests authenticate method with no token in response
    response = resp()
    response.status_code = 502

    # Mock requests.post so it doesn't actually post to TimeSync
    requests.post = mock.create_autospec(requests.post,
                                         return_value=response)

    assert_equal(ts.authenticate(username='username',
                                           password='password',
                                           auth_type='password'),
                      Hash[ts.error =>
                       "connection to TimeSync failed at baseurl http://ts.example.com/v1 - response status was 502"])
  end

  def test_local_auth_error_with_token
    # Test internal local_auth_error method with token
    assert_nil(ts._TimeSync__local_auth_error)
  end

  def test_local_auth_error_no_token
  # Test internal local_auth_error method with no token
    ts.token = nil
    assert_equal(ts._TimeSync__local_auth_error,
                      'Not authenticated with TimeSync, call self.authenticate first')
  end

  def test_handle_other_connection_response(self):
    # Test that pymesync doesn't break when getting a response that is not a JSON object
    response = resp()
    response.status_code = 502

    assert_equal(ts._TimeSync__response_to_python(response),
                      Hash[ts.error =>
                       "connection to TimeSync failed at baseurl "
                       "http://ts.example.com/v1 - "
                       "response status was 502"])
  end

  def test_delete_object_time # work on this
    # Test that _delete_object calls requests.delete with the correct url
    requests.delete = mock.create_autospec(requests.delete)
    url = "{0}/times/abcd-3453-3de3-99sh?token={1}".format(ts.baseurl,
                                                           ts.token)
    ts._TimeSync__delete_object("times", "abcd-3453-3de3-99sh")
    requests.delete.assert_called_with(url)
  end

  def test_delete_object_project  # work on this
    # Test that _delete_object calls requests.delete with the correct url
    requests.delete = mock.create_autospec(requests.delete)
    url = "{0}/projects/ts?token={1}".format(ts.baseurl,
                                             ts.token)
    ts._TimeSync__delete_object("projects", "ts")
    requests.delete.assert_called_with(url)
  end

  def test_delete_object_activity   # work on this
    #Test that _delete_object calls requests.delete with the correct url
      requests.delete = mock.create_autospec(requests.delete)
      url = "{0}/activities/code?token={1}".format(ts.baseurl,
                                                   ts.token)
      ts._TimeSync__delete_object("activities", "code")
      requests.delete.assert_called_with(url)
  end

  def test_delete_object_user  # work on this
    # Test that _delete_object calls requests.delete with the correct
    url
    requests.delete = mock.create_autospec(requests.delete)
    url = "{0}/users/example-user?token={1}".format(ts.baseurl,
                                                    ts.token)
    ts._TimeSync__delete_object("users", "example-user")
    requests.delete.assert_called_with(url)
  end


  # @patch('rimesync.TimeSync._TimeSync__delete_object')
  # def test_delete_time(self, m_delete_object):
  # end

  def test_delete_time_no_auth
    # Test that delete_time returns proper error on authentication failure
    ts.token = nil
    assert_equal(ts.delete_time('abcd-3453-3de3-99sh'),
                      [Hash['rimesync error' =>
                        'Not authenticated with TimeSync, call self.authenticate first']])
  end

  def test_delete_time_no_uuid
    # Test that delete_time returns proper error when uuid not provided
    assert_equal(ts.delete_time,
                      [Hash['rimesync error' =>
                        'missing uuid; please add to method call']])
  end

  # @patch('rimesync.TimeSync._TimeSync__delete_object')
  # def test_delete_project(self, m_delete_object):
  # end

  def test_delete_project_no_auth
  # Test that delete_project returns proper error on authentication failure
    ts.token = nil
    assert_equal(ts.delete_project('ts'),
                      [Hash['rimesync error' =>
                        'Not authenticated with TimeSync, call self.authenticate first']])
  end

  def test_delete_project_no_slug
    # Test that delete_project returns proper error when slug not provided
    assert_equal(ts.delete_project,
                      [Hash['rimesync error' =>
                        'missing slug; please add to method call']])
  end

  # @patch('rimesync.TimeSync._TimeSync__delete_object')
  # def test_delete_activity(self, m_delete_object):
  # end

  def test_delete_activity_no_auth
    # Test that delete_activity returns proper error on authentication failure
    ts.token = nil
    assert_equal(ts.delete_activity('code'),
                      [Hash['rimesync error' =>
                        'Not authenticated with TimeSync, call self.authenticate first']])
  end

  def test_delete_activity_no_slug
    # Test that delete_activity returns proper error when slug not provided
    assert_equal(ts.delete_activity,
                      [Hash['rimesync error' =>
                        'missing slug; please add to method call']])
  end

  # @patch('rimesync.TimeSync._TimeSync__delete_object')
  # def test_delete_user(self, m_delete_object):
  # end

  def test_delete_user_no_auth
    # Test that delete_user returns proper error on authentication failure
    ts.token = nil
    assert_equal(ts.delete_user('example-user'),
                      [Hash['rimesync error' =>
                        'Not authenticated with TimeSync, call self.authenticate first']])
  end

  def test_delete_user_no_username
      # Test that delete_user returns proper error when username not provided
    assert_equal(ts.delete_user,
                      [Hash['rimesync error' =>
                        'missing username; please add to method call']])
  end

  def test_token_expiration_valid  # work on this
    #Test that token_expiration_time returns valid date from a valid token
    ts.token = ("eyJ0eXAiOiJKV1QiLCJhbGciOiJITUFDLVNIQTUxMiJ9.eyJpc3M"
                     "iOiJvc3Vvc2wtdGltZXN5bmMtc3RhZ2luZyIsInN1YiI6InRlc3Q"
                     "iLCJleHAiOjE0NTI3MTQzMzQwODcsImlhdCI6MTQ1MjcxMjUzNDA"
                     "4N30=.QP2FbiY3I6e2eN436hpdjoBFbW9NdrRUHbkJ+wr9GK9mMW"
                     "7/oC/oKnutCwwzMCwjzEx6hlxnGo6/LiGyPBcm3w==")

    decoded_payload = base64.b64decode(self.ts.token.split(".")[1])
    exp_int = ast.literal_eval(decoded_payload)['exp'] / 1000
    exp_datetime = datetime.datetime.fromtimestamp(exp_int)

    assert_equal(ts.token_expiration_time(),
                      exp_datetime)
  end


  def test_token_expiration_invalid
    # Test that token_expiration_time returns correct from an invalid token
    assert_equal(ts.token_expiration_time,
                      [Hash[ts.error => 'improperly encoded token']])
  end

  def test_token_expiration_no_auth
    # Test that token_expiration_time returns correct error when user is not authenticated
    ts.token = nil
    assert_equal(ts.token_expiration_time,
                      [Hash[ts.error => 'Not authenticated with TimeSync, call self.authenticate first']])
  end

  def test_duration_to_seconds
    # Tests that when a string duration is entered, it is converted to an integer
    time = Hash[
        'duration' => '3h30m',
        'project' => 'ganeti-web-manager',
        'user' => 'example-user',
        'activities' => ['documenting'],
        'notes' => 'Worked on docs',
        'issue_uri' => 'https://github.com/',
        'date_worked' => '2014-04-17',
    ]

    assert_equal(ts._TimeSync__duration_to_seconds(time['duration']), 12600)
  end

  def test_duration_to_seconds_with_invalid_str
    # Tests that when an invalid string duration is entered, an error message is returned
    time = Hash[
        'duration' => '3hh30m',
        'project' => 'ganeti-web-manager',
        'user' => 'example-user',
        'activities' => ['documenting'],
        'notes' => 'Worked on docs',
        'issue_uri' => 'https://github.com/',
        'date_worked' => '2014-04-17',
    ]

    assert_equal(ts._TimeSync__duration_to_seconds(time['duration']),
                      [Hash[ts.error =>
                        'time object: invalid duration string']])
  end

  def test_project_users_valid
    # Test project_users method with a valid project object returned from TimeSync
    project = "rime"
    response = resp()
    response.status_code = 200
    response.text = json.dump(Hash[
        'uri' => 'https://github.com/osuosl/rimesync',
        'name' => 'pymesync',
        'slugs' => Array['rime', 'ps', 'rimesync'],
        'uuid' => 'a034806c-00db-4fe1-8de8-514575f31bfb',
        'revision' => 4,
        'created_at' => '2014-07-17',
        'deleted_at' => nil,
        'updated_at' => '2014-07-20',
        'users' => Hash[
            'malcolm' => Hash['member' => true,
                        'manager' => true,
                        'spectator' => true],
            'jayne' =>   Hash['member' => true,
                        'manager' => false,
                        'spectator' => false],
            'kaylee' =>  Hash['member' => true,
                        'manager' => false,
                        'spectator' => false],
            'zoe' =>     Hash['member' => true,
                        'manager' => false,
                        'spectator' => false],
            'hoban' =>   Hash['member' => true,
                        'manager' => false,
                        'spectator' => false],
            'simon' =>   Hash['member' => false,
                        'manager' => false,
                        'spectator' => true],
            'river' =>   Hash['member' => false,
                        'manager' => false,
                        'spectator' => true],
            'derrial' => Hash['member' => false,
                        'manager' => false,
                        'spectator' => true],
            'inara' =>   Hash['member' => false,
                        'manager' => false,
                        'spectator' => true]
        ]
    ])

    expected_result = Hash[
        u'malcolm' => Array[u'member', u'manager', u'spectator'],
        u'jayne' =>   Array[u'member'],
        u'kaylee' =>  Array[u'member'],
        u'zoe' =>     Array[u'member'],
        u'hoban' =>   Array[u'member'],
        u'simon' =>   Array[u'spectator'],
        u'river' =>   Array[u'spectator'],
        u'derrial' => Array[u'spectator'],
        u'inara' =>   Array[u'spectator']
    ]

    # Mock requests.get so it doesn't actually post to TimeSync
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    assert_equal(self.ts.project_users(project=project),
                      expected_result)
  end

  def test_project_users_error_response  # work on this
    # Test project_users method with an error object returned from TimeSync
    proj = "rimes"
    response = resp()
    response.status_code = 404
    response.text = json.dump(Hash[
        'error' => 'Object not found',
        'text' => 'nilxistent project'
    ])

    # Mock requests.get so it doesn't actually post to TimeSync
    requests.get = mock.create_autospec(requests.get,
                                        return_value=response)

    assert_equal(ts.project_users(project=proj),
                      Hash[u"error" => u"Object not found",
                       u"text" => u"nilxistent project"])
  end

  def test_project_users_no_project_parameter  # work on this
    # Test project_users method with no project object passed as a parameter, should return an error
    assert_equal(ts.project_users(),
                      Hash[ts.error => "Missing project slug, please "
                                      "include in method call"])
  end

  def test_baseurl_with_trailing_slash  # work on this
    # Test that the trailing slash in the baseurl is removed
    ts = TimeSync.new("http://ts.example.com/v1/")
    assert_equal(ts.baseurl, "http://ts.example.com/v1")
  end

  def test_baseurl_without_trailing_slash  # work on this
    # Test that the trailing slash in the baseurl is removed
    ts = TimeSync.new("http://ts.example.com/v1")
    assert_equal(self.ts.baseurl, "http://ts.example.com/v1")

end


# main