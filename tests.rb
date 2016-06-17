require 'test/unit'
require_relative 'rimesync'
require 'json'
require 'bcrypt'
require 'base64'
require 'rest-client'
require 'webmock/test_unit'

class Resp # :nodoc:
  def initialize
    @body = nil
    @code = nil
  end
end

# rubocop:disable ClassLength
class TestRimeSync < Test::Unit::TestCase # :nodoc:
  def setup
    baseurl = 'http://ts.example.com/v0'
    @ts = TimeSync.new(baseurl)
    @ts.instance_variable_set(:@user, 'example-user')
    @ts.instance_variable_set(:@password, 'password')
    @ts.instance_variable_set(:@auth_type, 'password')
    @ts.instance_variable_set(:@token, 'TESTTOKEN')
  end

  # Test that instantiating rimesync with a token sets the token variable
  def test_instantiate_with_token
    @ts = TimeSync.new('baseurl', token = 'TOKENTOCHECK') # not sure about "@"ts
    assert_equal(@ts.instance_variable_get(:@token), 'TOKENTOCHECK')
  end

  # Test that instantiating rimesync without a token
  # does not sets the token variable
  def test_instantiate_without_token
    @ts = TimeSync.new('baseurl') # not sure about "@"ts
    assert_nil(@ts.instance_variable_get(:@token))
  end

  # rubocop:disable MethodLength
  # Tests TimeSync._TimeSync.create_or_update for create time with valid data
  def test_create_or_update_create_time_valid
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

    content = Hash[
        'auth' => @ts.token_auth,
        'object' => time,
    ].to_json

    url = 'http://ts.example.com/v0/times'

    stub_request(:post, url).with(body: content)

    @ts.create_or_update(time, nil, 'time', 'times')
  end

  # Tests TimeSync._TimeSync.create_or_update for update time with valid data
  def test_create_or_update_update_time_valid
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
        'auth' => @ts.token_auth,
        'object' => time,
    ].to_json

    # Test baseurl and uuid
    uuid = '1234-5678-90abc-d'

    url = 'http://ts.example.com/v0/times/%s' % uuid

    stub_request(:post, url).with(body: content)

    # Send it
    @ts.create_or_update(time, uuid, 'time', 'times')
  end

  # Tests TimeSync.create_or_update
  # for update time with one valid parameter
  def test_create_or_update_update_time_valid_less_fields
    # Parameters to be sent to TimeSync
    time = Hash[
        'duration' => 12,
    ]

    # Test baseurl and uuid
    uuid = '1234-5678-90abc-d'

    # Format content for assert_called_with test
    content = Hash[
        'auth' => @ts.token_auth,
        'object' => time,
    ].to_json

    url = 'http://ts.example.com/v0/times/%s' % uuid

    stub_request(:post, url).with(body: content)

    # Send it
    @ts.create_or_update(time, uuid, 'time', 'times', false)
  end

  # Tests TimeSync.create_or_update
  # for create time with invalid field
  def test_create_or_update_create_time_invalid
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

    assert_equal(@ts.create_or_update(time, nil, 'time', 'times'),
                 Hash[@ts.instance_variable_get(:@error) => 'time object: invalid field: bad'])
  end

  # Tests TimeSync._TimeSync__create_or_update for
  # create time with missing required fields
  def test_create_or_update_create_time_two_required_missing
    # Parameters to be sent to TimeSync
    time = Hash[
        'user' => 'example-user',
        'notes' => 'Worked on docs',
        'issue_uri' => 'https://github.com/',
        'date_worked' => '2014-04-17'
    ]

    assert_equal(@ts.create_or_update(time, nil, 'time', 'times'),
                 Hash[@ts.instance_variable_get(:@error) =>
                       'time object: missing required field(s): duration, project'])
  end

  # Tests TimeSync.create_or_update
  # to create time with missing required fields
  def test_create_or_update_create_time_each_required_missing # NOT WORKING
    # Parameters to be sent to TimeSync
    time = Hash[
        'duration' => 12,
        'project' => 'ganeti-web-manager',
        'user' => 'example-user',
        'date_worked' => '2014-04-17'
    ]

    time_to_test = Hash[time]

    for key, value in time
      time_to_test.delete(key)
      assert_equal(@ts.create_or_update(
                     time_to_test, nil, 'time', 'times'),
                   Hash[@ts.instance_variable_get(:@error) => 'time object: missing required field(s): %s' % key])
      time_to_test = Hash[time]
    end
  end

  # Tests TimeSync.create_or_update
  # for create time with incorrect parameter types
  def test_create_or_update_create_time_type_error
    # Parameters to be sent to TimeSync
    param_list = Array[1, 'hello', [1, 2, 3], nil, true, false, 1.234]

    param_list.each do |param|
      assert_equal(@ts.create_or_update(param, nil, 'time', 'times'),
                   Hash[@ts.instance_variable_get(:@error) => 'time object: must be ruby hash'])
    end
  end

  # Tests TimeSync.create_or_update for create user with valid data
  def test_create_or_update_create_user_valid
    # Parameters to be sent to TimeSync
    user = Hash[
        'username' => 'example-user',
        'password' => 'password',
        'display_name' => 'Example User',
        'email' => 'example.user@example.com',
    ]

    # Format content for assert_called_with test
    content = Hash[
        'auth' => @ts.token_auth,
        'object' => user,
    ].to_json

    url = 'http://ts.example.com/v0/users'

    stub_request(:post, url).with(body: content)

    # Send it
    @ts.create_or_update(user, nil, 'user', 'users')

  end

  # Tests TimeSync.create_or_update for update user with valid data
  def test_create_or_update_update_user_valid
    # Parameters to be sent to TimeSync
    user = Hash[
        'username' => 'example-user',
        'password' => 'password',
        'display_name' => 'Example User',
        'email' => 'example.user@example.com',
    ]

    # Test baseurl and uuid
    username = 'example-user'

    content = Hash[
        'auth' => @ts.token_auth,
        'object' => user,
    ].to_json

    url = 'http://ts.example.com/v0/users/%s' % username

    stub_request(:post, url).with(body: content)

    # Send it
    @ts.create_or_update(user, username, 'user',
                                   'users', false)

  end

  # Tests TimeSync.create_or_update
  # for update user with one valid parameter
  def test_create_or_update_update_user_valid_less_fields
    # Parameters to be sent to TimeSync
    user = Hash[
        'display_name' => 'Example User',
    ]

    # Test baseurl and uuid
    username = 'example-user'

    content = Hash[
        'auth' => @ts.token_auth,
        'object' => user,
    ].to_json

    url = 'http://ts.example.com/v0/users/%s' % username

    stub_request(:post, url).with(body: content)

    # Send it
    @ts.create_or_update(user, username, 'user',
                                   'users', false)
  end

  # Tests TimeSync.create_or_update
  # for create user with invalid field
  def test_create_or_update_create_user_invalid
    # Parameters to be sent to TimeSync
    user = Hash[
        'username' => 'example-user',
        'password' => 'password',
        'display_name' => 'Example User',
        'email' => 'example.user@example.com',
        'bad' => 'field'
    ]

    assert_equal(@ts.create_or_update(user, nil,
                                                'user',
                                                'users'),
                 Hash[@ts.instance_variable_get(:@error) =>
                        'user object: invalid field: bad'])
  end

  # Tests TimeSync.create_or_update
  # for create user with missing required fields
  def test_create_or_update_create_user_two_required_missing
    # Parameters to be sent to TimeSync
    user = Hash[
        'display_name' => 'Example User',
        'email' => 'example.user@example.com'
    ]

    assert_equal(@ts.create_or_update(user, nil,
                                                'user',
                                                'users'),
                 Hash[@ts.instance_variable_get(:@error) => 'user object: missing required field(s): username, password'])
  end

  # Tests TimeSync.create_or_update
  # to create user with missing required fields
  def test_create_or_update_create_user_each_required_missing
    # Parameters to be sent to TimeSync
    user = Hash[
        'username' => 'example-user',
        'password' => 'password',
    ]

    user_to_test = user

    for key, value in user
      user_to_test.delete(key)  # delete mutates the hash
      assert_equal(@ts.create_or_update(
                   user_to_test, nil, 'user', 'users'),
                   Hash[@ts.instance_variable_get(:@error) => 'user object: missing required field(s): %s' % key])
      user_to_test = user
      puts user_to_test
    end
  end

  # Tests TimeSync.create_or_update
  # for create user with incorrect parameter types
  def test_create_or_update_create_user_type_error
    # Parameters to be sent to TimeSync
    param_list = [1, 'hello', [1, 2, 3], nil, true, false, 1.234]

    param_list.each do |param|
      assert_equal(@ts.create_or_update(param, nil, 'user', 'users'),
                   Hash[@ts.instance_variable_get(:@error) =>
                        'user object: must be ruby hash'])
    end
  end

  # Tests TimeSync.create_or_update
  # for create project with valid data
  def test_create_or_update_create_project_valid
    # Parameters to be sent to TimeSync
    project = Hash[
      'uri' => 'https://code.osuosl.org/projects/timesync',
      'name' => 'TimeSync API',
      'slugs' => %w(timesync time),
      'users' => Hash[
          'mrsj' => Hash['member' => true, 'spectator' => true,
                         'manager' => true],
          'thai' => Hash['member' => true, 'spectator' => false,
                         'manager' => false]
      ]
    ]

    # Format content for assert_called_with test
    content = Hash[
      'auth' => @ts.token_auth,
      'object' => project,
    ].to_json

    url = 'http://ts.example.com/v0/projects'

    stub_request(:post, url).with(body: content)

    # Send it
    @ts.create_or_update(project, nil,
                         'project', 'projects')

  end

  # Tests TimeSync.create_or_update for
  # update project with valid parameters
  def test_create_or_update_update_project_valid
    # Parameters to be sent to TimeSync
    project = Hash[
        'uri' => 'https://code.osuosl.org/projects/timesync',
        'name' => 'TimeSync API',
        'slugs' => %w(timesync time),
        'users' => Hash[
            'mrsj' => Hash['member' => true, 'spectator' => true,
                           'manager' => true],
            'thai' => Hash['member' => true, 'spectator' => false,
                           'manager' => false]
        ]
    ]

    # Format content for assert_called_with test
    content = Hash[
        'auth' => @ts.token_auth,
        'object' => project,
    ].to_json

    url = 'http://ts.example.com/v0/projects/slug'

    stub_request(:post, url).with(body: content)

    # Send it
    @ts.create_or_update(project, 'slug',
                                   'project', 'projects')

  end

  # Tests TimeSync.create_or_update for
  # update project with one valid parameter
  def test_create_or_update_update_project_valid_less_fields
    # Parameters to be sent to TimeSync
    project = Hash[
        'slugs' => %w(timesync time),
    ]

    # Format content for assert_called_with test
    content = Hash[
        'auth' => @ts.token_auth,
        'object' => project,
    ].to_json

    url = 'http://ts.example.com/v0/projects/slug'

    stub_request(:post, url).with(body: content)

    # Send it
    @ts.create_or_update(project, 'slug', 'project',
                         'projects', false)
  end

  # Tests TimeSync.create_or_update for
  # create project with invalid field
  def test_create_or_update_create_project_invalid
    # Parameters to be sent to TimeSync
    project = Hash[
        'uri' => 'https://code.osuosl.org/projects/timesync',
        'name' => 'TimeSync API',
        'slugs' => %w(timesync time),
        'users' => Hash[
            'mrsj' => Hash['member' => true, 'spectator' => true,
                           'manager' => true],
            'thai' => Hash['member' => true, 'spectator' => false,
                           'manager' => false]
        ],
        'bad' => 'field'
    ]

    assert_equal(@ts.create_or_update(project, nil,
                                                'project',
                                                'projects'),
                 Hash[@ts.instance_variable_get(:@error) =>
                       'project object: invalid field: bad'])
  end

  # Tests TimeSync.create_or_update for
  # create project with missing required fields
  def test_create_or_update_create_project_required_missing
    # Parameters to be sent to TimeSync
    project = Hash[
      'slugs' => %w(timesync time),
    ]

    assert_equal(@ts.create_or_update(project, nil,
                                      'project',
                                      'project'),
                 Hash[@ts.instance_variable_get(:@error) => 'project object: missing required field(s): name'])
  end

  # Tests TimeSync.create_or_update for
  # create project with missing required fields
  def test_create_or_update_create_project_each_required_missing
    # Parameters to be sent to TimeSync
    project = Hash[
      'name' => 'TimeSync API',
      'slugs' => %w(timesync time),
    ]

    project_to_test = Hash[project]

    for key, value in project
      project_to_test.delete(key)
      assert_equal(@ts.create_or_update(
                        project_to_test, nil, 'project', 'projects'),
                        Hash[@ts.instance_variable_get(:@error) => 'project object: missing required field(s): %s' % key])
      project_to_test = Hash[project]
    end
  end

  # Tests TimeSync.create_or_update for
  # create project with incorrect parameter types
  def test_create_or_update_create_project_type_error
    # Parameters to be sent to TimeSync
    param_list = Array[1, 'hello', [1, 2, 3], nil, true, false, 1.234]

    param_list.each do |param|
      assert_equal(@ts.create_or_update(param, nil,
                                                  'project', 'projects'),
                   Hash[@ts.instance_variable_get(:@error) =>
                          'project object: must be ruby hash'])
    end
  end

  # Tests TimeSync.create_or_update for
  # create activity with valid data
  def test_create_or_update_create_activity_valid
    # Parameters to be sent to TimeSync
    project = Hash[
      'name' => 'Quality Assurance/Testing',
      'slug' => 'qa'
    ]

    # Format content for assert_called_with test
    content = Hash[
      'auth' => @ts.token_auth,
      'object' => project
    ].to_json

    url = 'http://ts.example.com/v0/activities'

    stub_request(:post, url).with(body: content)

    # Send it
    @ts.create_or_update(project, nil,
                         'activity', 'activities')
  end

  # Tests TimeSync.create_or_update
  # for update activity with valid parameters
  def test_create_or_update_update_activity_valid
    # Parameters to be sent to TimeSync
    activity = Hash[
      'name' => 'Quality Assurance/Testing',
      'slug' => 'qa',
    ]

    # Format content for assert_called_with test
    content = Hash[
      'auth' => @ts.token_auth,
      'object' => activity
    ].to_json

    url = 'http://ts.example.com/v0/activities/slug'

    stub_request(:post, url).with(body: content)

    # Send it
    @ts.create_or_update(activity, 'slug',
                         'activity', 'activities')
  end

  # Tests TimeSync.create_or_update
  # for update activity with one valid parameter
  def test_create_or_update_update_activity_valid_less_fields
    # Parameters to be sent to TimeSync
    activity = Hash[
        'slug' => 'qa',
    ]

    # Format content for assert_called_with test
    content = Hash[
        'auth' => @ts.token_auth,
        'object' => activity,
    ].to_json

    url = 'http://ts.example.com/v0/activities/slug'

    stub_request(:post, url).with(body: content)

    # Send it
    @ts.create_or_update(activity, 'slug', 'activity',
                         'activities', false)
  end

  # Tests TimeSync.create_or_update
  # for create activity with invalid field
  def test_create_or_update_create_activity_invalid
    # Parameters to be sent to TimeSync
    activity = Hash[
        'name' => 'Quality Assurance/Testing',
        'slug' => 'qa',
        'bad' => 'field'
    ]

    assert_equal(@ts.create_or_update(activity, nil,
                                                'activity',
                                                'activites'),
                 Hash[@ts.instance_variable_get(:@error) =>
                        'activity object: invalid field: bad'])
  end

  # Tests TimeSync.create_or_update
  # for create activity with missing required fields
  def test_create_or_update_create_activity_required_missing
    # Parameters to be sent to TimeSync
    activity = Hash[
        'name' => 'Quality Assurance/Testing',
    ]

    assert_equal(@ts.create_or_update(activity, nil,
                                                'activity',
                                                'activities'),
                 Hash[@ts.instance_variable_get(:@error) => 'activity object: missing required field(s): slug'])
  end

  # Tests TimeSync.create_or_update
  # for create activity with missing required fields
  def test_create_or_update_create_activity_each_required_missing
    # Parameters to be sent to TimeSync
    activity = Hash[
        'name' => 'Quality Assurance/Testing',
        'slug' => 'qa'
    ]

    activity_to_test = Hash[activity]

    for key, value in activity
      activity_to_test.delete(key)
      assert_equal(@ts.create_or_update(
                   activity_to_test, nil, 'activity', 'activities'),
                   Hash[@ts.instance_variable_get(:@error) => 'activity object: missing required field(s): %s' % key])
      activity_to_test = Hash[activity]
    end
  end

  # Tests TimeSync.create_or_update for
  # create activity with incorrect parameter types
  def test_create_or_update_create_activity_type_error
    # Parameters to be sent to TimeSync
    param_list = [1, 'hello', [1, 2, 3], nil, true, false, 1.234]

    param_list.each do |param|
      assert_equal(@ts.create_or_update(param, nil,
                                        'activity',
                                        'activities'),
                   Hash[@ts.instance_variable_get(:@error) => 'activity object: must be ruby hash'])

    end
  end

  # Tests TimeSync.create_or_update for create time with no auth
  def test_create_or_update_create_time_no_auth
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

    @ts.instance_variable_set(:@token, nil)

    # Send it
    assert_equal(@ts.create_or_update(time, nil, "time", "times"),
                 Hash[@ts.instance_variable_get(:@error) => "Not authenticated with ""TimeSync, call authenticate first"])
  end


  def test_create_or_update_create_project_no_auth
  # Tests TimeSync.create_or_update for create project with no auth
  # Parameters to be sent to TimeSync
  project = Hash[
      'uri' => 'https://code.osuosl.org/projects/timesync',
      'name' => 'TimeSync API',
      'slugs' => %w(timesync time),
  ]

  @ts.instance_variable_set(:@token, nil)

  # Send it
  assert_equal(@ts.create_or_update(project, nil, 'project', 'projects'),
    Hash[@ts.instance_variable_get(:@error), 'Not authenticated with TimeSync, call authenticate first'])
  end


  # Tests TimeSync.create_or_update for create activity with no auth
  def test_create_or_update_create_activity_no_auth
    # Parameters to be sent to TimeSync
    activity = Hash[
        'name' => 'Quality Assurance/Testing',
        'slug' => 'qa',
    ]

    @ts.instance_variable_set(:@token, nil)

    # Send it
    assert_equal(@ts.create_or_update(activity, nil, "activity", "activities"),
                      Hash[@ts.instance_variable_get(:@error) => "Not authenticated with ""TimeSync, call authenticate first"])

  end


  # Tests TimeSync._TimeSync__create_or_update for update time with no auth
  def test_create_or_update_update_time_no_auth
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

    @ts.instance_variable_set(:@token, nil)

    # Send it
    assert_equal(@ts.create_or_update(time, nil, "time", "times",
                                      false),
                      Hash[@ts.instance_variable_get(:@error) => "Not authenticated with ""TimeSync, call authenticate first"])
  end


  # Tests TimeSync._TimeSync__create_or_update for update project with no auth
  def test_create_or_update_update_project_no_auth
    # Parameters to be sent to TimeSync
    project = Hash[
        'uri' => 'https://code.osuosl.org/projects/timesync',
        'name' => 'TimeSync API',
        'slugs' => ['timesync', 'time'],
    ]

    @ts.instance_variable_set(:@token, nil)

    # Send it
    assert_equal(@ts.create_or_update(project, nil, "project", "project",
                                      false),
                Hash[@ts.instance_variable_get(:@error) => "Not authenticated with ""TimeSync, call authenticate first"])
  end


  # Tests TimeSync._TimeSync__create_or_update for update activity with no auth
  def test_create_or_update_update_activity_no_auth
    # Parameters to be sent to TimeSync
    activity = Hash[
        'name' => 'Quality Assurance/Testing',
        'slug' => 'qa',
    ]

    @ts.instance_variable_set(:@token, nil)

    # Send it
    assert_equal(@ts.create_or_update(activity, nil, "activity", "activities",
                                     false),
                Hash[@ts.instance_variable_get(:@error) => "Not authenticated with ""TimeSync, call authenticate first"])
  end


  # Tests TimeSync.auth function
  def test_auth
    # Create auth block to test auth
    auth = Hash[
          'type' => 'password',
          'username' => 'example-user',
          'password' => 'password'
          ]

    assert_equal(@ts.auth, auth)
  end

  # Tests TimeSync.get_times with username query parameter
  def test_get_time_for_user
    url = '%s/times?user=example-user&token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                        @ts.instance_variable_get(:@token)]

    stub_request(:get, /.*times.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))


    assert_equal(@ts.get_times(Hash['user' => [@ts.instance_variable_get(:@user)]]),
                [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_times with project query parameter
  def test_get_time_for_proj
    url = '%s/times?project=gwm&token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                        @ts.instance_variable_get(:@token)]

    stub_request(:get, /.*times.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_times(Hash['project' => ['gwm']]),
                [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_times with activity query parameter
  def test_get_time_for_activity
    url = '%s/times?activity=dev&token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                     @ts.instance_variable_get(:@token)]

    stub_request(:get, /.*times.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_times(Hash['activity' => ['dev']]),
                [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_times with start date query parameter
  def test_get_time_for_start_date
    url = '%s/times?start=2015-07-23&token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                       @ts.instance_variable_get(:@token)]

    stub_request(:get, /.*times.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_times(Hash['start' => ['2015-07-23']]),
                [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_times with end date query parameter
  def test_get_time_for_end_date
    url = '%s/times?end=2015-07-23&token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                     @ts.instance_variable_get(:@token)]

    stub_request(:get, /.*times.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_times(Hash['end' => ['2015-07-23']]),
                [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_times with include_revisions query parameter
  def test_get_time_for_include_revisions
    url = '%s/times?include_revisions=true&token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                             @ts.instance_variable_get(:@token)]

    stub_request(:get, /.*times.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_times(Hash['include_revisions' => true]),
                [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_times with include_revisions false query parameter
  def test_get_time_for_include_revisions_false
    url = '%s/times?include_revisions=false&token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                              @ts.instance_variable_get(:@token)]

    stub_request(:get, /.*times.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_times(Hash['include_revisions' => false]),
                [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_times with include_deleted query parameter
  def test_get_time_for_include_deleted
    url = '%s/times?include_deleted=true&token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                           @ts.instance_variable_get(:@token)]
    stub_request(:get, /.*times.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_times(Hash['include_deleted' => true]),
                [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_times with include_revisions false query parameter
  def test_get_time_for_include_deleted_false
    url = '%s/times?include_deleted=false&token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                            @ts.instance_variable_get(:@token)]
    stub_request(:get, /.*times.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_times(Hash['include_deleted' => false]),
                [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_times with project and activity query parameters
  def test_get_time_for_proj_and_activity
    url = '%s/times?activity=dev&project=gwm&token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                               @ts.instance_variable_get(:@token)]

    stub_request(:get, /.*times.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_times(Hash['project' => ['gwm'],
                                    'activity' => ['dev']]),
                [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_times with project and activity query parameters
  def test_get_time_for_activity_x3
    token_string = '&token=%s' % @ts.instance_variable_get(:@token)
    url = '%s/times?activity=dev&activity=rev&activity=hd%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                                     token_string]
    stub_request(:get, /.*times.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_times(Hash['activity' =>
                                    Array['dev', 'rev', 'hd']]),
                 [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_times with uuid query parameter
  def test_get_time_with_uuid
    url = '%s/times/sadfasdg432?token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                  @ts.instance_variable_get(:@token)]

    stub_request(:get, /.*times.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_times(Hash['uuid' => 'sadfasdg432']),
                 [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_times with uuid and activity query parameters
  def test_get_time_with_uuid_and_activity
    url = '%s/times/sadfasdg432?token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                    @ts.instance_variable_get(:@token)]

    stub_request(:get, /.*times.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_times(Hash['uuid' => 'sadfasdg432',
                                   'activity' => ['dev']]),
                 [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_times with uuid and include_revisions query parameters
  def test_get_time_with_uuid_and_include_revisions
    url = '{0}/times/sadfasdg432?include_revisions=true&token={1}' % Array[@ts.instance_variable_get(:@baseurl),
                                                                           @ts.instance_variable_get(:@token)]
    stub_request(:get, /.*times.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_times(Hash['uuid' => 'sadfasdg432',
                                   'include_revisions' => true]),
                 [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_times with uuid and include_deleted query parameters
  def test_get_time_with_uuid_and_include_deleted
    url = '%s/times/sadfasdg432?include_deleted=true&token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                                       @ts.instance_variable_get(:@token)]

    stub_request(:get, /.*times.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_times(Hash['uuid' => 'sadfasdg432',
                                   'include_deleted' => true]),
                 [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_times with uuid and include_deleted query parameters
  def test_get_time_with_uuid_include_deleted_and_revisions
    endpoint = 'times'
    uuid = 'sadfasdg432'
    token = 'token=%s' % @ts.instance_variable_get(:@token)
    queries = 'include_deleted=true&include_revisions=true'
    url = '%s/%s/%s?%s&%s' % Array[@ts.instance_variable_get(:@baseurl), endpoint, uuid,
                                   queries, token]

    stub_request(:get, /.*times.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_times(Hash['uuid' => 'sadfasdg432',
                                    'include_revisions' => true,
                                    'include_deleted' => true]),
                 [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_times with no parameters
  def test_get_all_times
    url = '%s/times?token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                        @ts.instance_variable_get(:@token)]

    stub_request(:get, /.*times.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_times,
                 [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_times with an invalid query parameter
  def test_get_times_bad_query
    # Should return the error
    assert_equal(@ts.get_times(Hash['bad' => ['query']]),
                 [Hash[@ts.instance_variable_get(:@error) => 'invalid query: bad']])
  end

  # Tests TimeSync.get_projects
  def test_get_projects
    url = '%s/projects?token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                           @ts.instance_variable_get(:@token)]
    stub_request(:get, /.*projects.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_projects,
                 [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_projects with slug
  def test_get_projects_slug
    url = '{0}/projects/gwm?token={1}' % Array[@ts.instance_variable_get(:@baseurl),
                                               @ts.instance_variable_get(:@token)]

    stub_request(:get, /.*projects.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_projects(Hash['slug' => 'gwm']),
                 [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_projects with include_revisions query
  def test_get_projects_include_revisions
    url = '%s/projects?include_revisions=true&token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                                  @ts.instance_variable_get(:@token)]

    stub_request(:get, /.*projects.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_projects(Hash['include_revisions' => true]),
                 [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_projects with include_revisions query and slug
  def test_get_projects_slug_include_revisions
    url = '%s/projects/gwm?include_revisions=true&token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                                      @ts.instance_variable_get(:@token)]

    stub_request(:get, /.*projects.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_projects(Hash['slug' => 'gwm',
                                      'include_revisions' => true]),
                 [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_projects with include_deleted query
  def test_get_projects_include_deleted
    # response = resp
    # response.body = json.dump(Hash['this' => 'should be in a list'])
    url = '%s/projects?include_deleted=true&token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                                @ts.instance_variable_get(:@token)]

    stub_request(:get, /.*projects.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_projects(Hash['include_deleted' => true]),
                 [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_projects with include_deleted
  # query and slug, which is not allowed
  def test_get_projects_include_deleted_with_slug
    # Mock requests.get
    # requests.get = mock.Mock('requests.get') # won't work
    stub_request(:get, /.*/)

    # Test that error message is returned,
    # can't combine slug and include_deleted
    assert_equal(@ts.get_projects(Hash['slug' => 'gwm',
                                      'include_deleted' => true]),
                 [Hash[@ts.instance_variable_get(:@error) =>
                       'invalid combination: slug and include_deleted']])
  end

  # Tests TimeSync.get_projects with
  # include_revisions and include_deleted queries
  def test_get_projects_include_deleted_include_revisions
    # response = resp
    # response.body = json.dump(Hash['this' => 'should be in a list'])
    token_string = '&token=%s' % @ts.instance_variable_get(:@token)
    endpoint = '/projects'
    url = '%s%s?include_deleted=true&include_revisions=true%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                                       endpoint, token_string]

    stub_request(:get, /.*projects.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_projects(Hash['include_revisions' => true,
                                      'include_deleted' => true]),
                 [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_activities
  def test_get_activities
    url = '%s/activities?token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                           @ts.instance_variable_get(:@token)]

    stub_request(:get, url)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_activities,
                 [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_activities with slug
  def test_get_activities_slug
    url = '%s/activities/code?token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                @ts.instance_variable_get(:@token)]

    stub_request(:get, /.*activities.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    assert_equal(@ts.get_activities(Hash['slug' => 'code']),
                 [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_activities with include_revisions query
  def test_get_activities_include_revisions
    url = '%s/activities?include_revisions=true&token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                                  @ts.instance_variable_get(:@token)]
    stub_request(:get, /.*activities.*/)
    .to_return(:body => JSON.dump(Hash['this' => 'should be in a list']))

    assert_equal(@ts.get_activities(Hash['include_revisions' => true]),
                 [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_projects with include_revisions query and slug
  def test_get_activities_slug_include_revisions
    url = '{%s/activities/code?include_revisions=true&token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                                        @ts.instance_variable_get(:@token)]
    stub_request(:get, /.*activities.*/)
    .to_return(:body => JSON.dump(Hash['this' => 'should be in a list']))


    assert_equal(@ts.get_activities(Hash['slug' => 'code',
                                        'include_revisions' => true]),
                 [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_activities with include_deleted query
  def test_get_activities_include_deleted
    url = '%s/activities?include_deleted=true&token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                                @ts.instance_variable_get(:@token)]

    stub_request(:get, /.*activities.*/)
    .to_return(:body => JSON.dump(Hash['this' => 'should be in a list']))

    assert_equal(@ts.get_activities(Hash['include_deleted' => true]),
                      [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_activities with
  # include_deleted query and slug, which is not allowed
  def test_get_activities_include_deleted_with_slug
    # Mock requests.get
    # requests.get = mock.Mock('requests.get')

    stub_request(:get, /.*/)
    # .to_return(:body => JSON.dump(Hash['this' => 'should be in a list']))

    # Test that error message is returned, can't combine slug and
    # include_deleted
    assert_equal(@ts.get_activities(Hash['slug' => 'code',
                                        'include_deleted' => true]),
                 [Hash[@ts.instance_variable_get(:@error) =>
                       'invalid combination: slug and include_deleted']])
  end

  # Tests TimeSync.get_activities with
  # include_revisions and include_deleted queries
  def test_get_activities_include_deleted_include_revisions
    token_string = '&token=%s' % @ts.instance_variable_get(:@token)
    endpoint = '/activities'
    url = '%s%s?include_deleted=true&include_revisions=true%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                                       endpoint, token_string]

    stub_request(:get, /.*activities.*/)
    .to_return(:body => JSON.dump(Hash['this' => 'should be in a list']))

    # Send it
    assert_equal(@ts.get_activities(Hash['include_revisions' => true,
                                        'include_deleted' => true]),
                 [Hash['this' => 'should be in a list']])

  end

  # Test that get_times returns error message when auth not set
  def test_get_times_no_auth
    @ts.instance_variable_set(:@token, nil)
    assert_equal(@ts.get_times,
                 [Hash[@ts.instance_variable_get(:@error) => 'Not authenticated with TimeSync, call authenticate first']])
  end

  # Test that get_projects returns error message when auth not set
  def test_get_projects_no_auth
    @ts.instance_variable_set(:@token, nil)
    assert_equal(@ts.get_projects,
                 [Hash[@ts.instance_variable_get(:@error) => 'Not authenticated with TimeSync, call authenticate first']])
  end

  # Test that get_activities returns error message when auth not set
  def test_get_activities_no_auth
    @ts.instance_variable_set(:@token, nil)
    assert_equal(@ts.get_activities,
                 [Hash[@ts.instance_variable_get(:@error) => 'Not authenticated with TimeSync, call authenticate first']])
  end

  # Tests TimeSync.get_users
  def test_get_users
    # response = resp
    # response.body = json.dump(Hash['this' => 'should be in a list'])
    url = '%s/users?token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                      @ts.instance_variable_get(:@token)]
    stub_request(:get, url)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    # Send it
    assert_equal(@ts.get_users,
                 [Hash['this' => 'should be in a list']])
  end

  # Tests TimeSync.get_users with username
  def test_get_users_username
    url = '%s/users/%s?token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                         'example-user', @ts.instance_variable_get(:@token)]
    stub_request(:get, /.*users.*/)
    .to_return(:body => JSON.dump([Hash['this' => 'should be in a list']]))

    # Send it
    assert_equal(@ts.get_users('example-user'),
                 [Hash['this' => 'should be in a list']])
  end

  # Test that get_users returns error message when auth not set
  def test_get_users_no_auth # ERROR
    @ts.instance_variable_set(:@token, 'nil')
    assert_equal(@ts.get_users,
                 [Hash[@ts.instance_variable_get(:@error) => 'Not authenticated with TimeSync, \
                                    call authenticate first']])
  end

  # Test that TimeSync.response_to_ruby
  # converts a json object to a  list of object
  def test_response_to_ruby_single_object
    json_object = Hash[
      'uri' => 'https://code.osuosl.org/projects/ganeti-webmgr',
      'name' => 'Ganeti Web Manager',
      'slugs' => %w(ganeti gwm),
      'owner' => 'example-user',
      'uuid' => 'a034806c-00db-4fe1-8de8-514575f31bfb',
      'revision' => 4,
      'created_at' => '2014-07-17',
      'deleted_at' => nil,
      'updated_at' => '2014-07-20'
    ]

    ruby_object = Hash[
      'uuid' => 'a034806c-00db-4fe1-8de8-514575f31bfb',
      'updated_at' => '2014-07-20',
      'created_at' => '2014-07-17',
      'uri' => 'https://code.osuosl.org/projects/ganeti-webmgr',
      'name' => 'Ganeti Web Manager',
      'owner' => 'example-user',
      'deleted_at' => nil,
      'slugs' => %w(ganeti gwm),
      'revision' => 4
    ]

    response = Resp.new
    response.instance_variable_set(:@body, json_object)

    assert_equal(@ts.response_to_ruby(response), ruby_object)
  end

  # Test that TimeSync.response_to_ruby
  # converts a json list of objects to a ruby list of objects
  def test_response_to_ruby_list_of_object
    json_object = Array[
        Hash[
          'name' => 'Documentation',
          'slugs' => %w(docs doc),
          'uuid' => 'adf036f5-3d49-4a84-bef9-0sdb46380bbf',
          'revision' => 1,
          'created_at' => '2014-04-17',
          'deleted_at' => nil,
          'updated_at' => nil
        ],
        Hash[
          'name' => 'Coding',
          'slugs' => %w(coding code prog),
          'uuid' => 'adf036f5-3d79-4a84-bef9-062b46320bbf',
          'revision' => 1,
          'created_at' => '2014-04-17',
          'deleted_at' => nil,
          'updated_at' => nil
        ],
        Hash[
          'name' => 'Research',
          'slugs' => %w(research res),
          'uuid' => 'adf036s5-3d49-4a84-bef9-062b46380bbf',
          'revision' => 1,
          'created_at' => '2014-04-17',
          'deleted_at' => nil,
          'updated_at' => nil
        ]
    ]

    ruby_object = Array[
        Hash[
            'uuid' => 'adf036f5-3d49-4a84-bef9-0sdb46380bbf',
            'created_at' => '2014-04-17',
            'updated_at' => nil,
            'name' => 'Documentation',
            'deleted_at' => nil,
            'slugs' => %w(docs doc),
            'revision' => 1
        ],
        Hash[
            'uuid' => 'adf036f5-3d79-4a84-bef9-062b46320bbf',
            'created_at' => '2014-04-17',
            'updated_at' => nil,
            'name' => 'Coding',
            'deleted_at' => nil,
            'slugs' => %w(coding code prog),
            'revision' => 1
        ],
        Hash[
            'uuid' => 'adf036s5-3d49-4a84-bef9-062b46380bbf',
            'created_at' => '2014-04-17',
            'updated_at' => nil,
            'name' => 'Research',
            'deleted_at' => nil,
            'slugs' => %w(research res),
            'revision' => 1
        ]
    ]

    response = Resp.new
    response.instance_variable_set(:@body, json_object)

    assert_equal(@ts.response_to_ruby(response), ruby_object)
  end

  # Check that response_to_ruby returns correctly for delete_*G methods
  def test_response_to_ruby_empty_response
    response = Resp.new
    response.instance_variable_set(:@body, '')
    response.instance_variable_set(:@code, 200)
    assert_equal(@ts.response_to_ruby(response),
                 Hash['status' => 200])
  end


  # Tests that TimeSync.create_time calls _create_or_update with correct parameters
  # @patch("pymesync.TimeSync._TimeSync__create_or_update")
  # def test_create_time
  #   time = Hash[
  #       'duration': 12,
  #       'project': 'ganeti-web-manager',
  #       'user': 'example-user',
  #       'activities': ['documenting'],
  #       'notes': 'Worked on docs',
  #       'issue_uri': 'https://github.com/',
  #       'date_worked': '2014-04-17',
  #   ]

  #   @ts.create_time(time)

  #   mock_create_or_update.assert_called_with(time, None, "time", "times")
  # end


  # @patch('rimesync.TimeSync.create_or_update')
  # def test_update_time(self, mock_create_or_update):
  # end

  # Tests that TimeSync.create_time will return an error
  # if a negative duration is passed
  def test_create_time_with_negative_duration
    time = Hash[
        'duration' => -12_600,
        'project' => 'ganeti-web-manager',
        'user' => 'example-user',
        'activities' => ['documenting'],
        'notes' => 'Worked on docs',
        'issue_uri' => 'https://github.com/',
        'date_worked' => '2014-04-17'
    ]

    assert_equal(@ts.create_time(time),
                 Hash[@ts.instance_variable_get(:@error) =>
                       'time object: duration cannot be negative'])
  end

  # Tests that TimeSync.update_time will return an error
  # if a negative duration is passed
  def test_update_time_with_negative_duration
    time = Hash[
        'duration' => -12_600,
        'project' => 'ganeti-web-manager',
        'user' => 'example-user',
        'activities' => ['documenting'],
        'notes' => 'Worked on docs',
        'issue_uri' => 'https://github.com/',
        'date_worked' => '2014-04-17'
    ]

    assert_equal(@ts.update_time(time, 'uuid'),
                 Hash[@ts.instance_variable_get(:@error) =>
                       'time object: duration cannot be negative'])
  end

  # @patch('rimesync.TimeSync.create_or_update')
  # def test_create_time_with_string_duration(self, mock_create_or_update):
  # end

  # @patch('rimesync.TimeSync.create_or_update')
  # def test_update_time_with_string_duration(self, mock_create_or_update):
  # end

  # Tests that TimeSync.create_time will fail
  # if a string containing no hours/minutes is entered
  def test_create_time_with_junk_string_duration
    time = Hash[
        'duration' => 'junktime',
        'project' => 'ganeti-web-manager',
        'user' => 'example-user',
        'activities' => ['documenting'],
        'notes' => 'Worked on docs',
        'issue_uri' => 'https://github.com/',
        'date_worked' => '2014-04-17',
    ]

    assert_equal(@ts.create_time(time),
                 [Hash[@ts.instance_variable_get(:@error) =>
                       'time object: invalid duration string']])
  end

  # Tests that TimeSync.update_time will fail
  # if a string containing no hours/minutes is entered
  def test_update_time_with_junk_string_duration
    time = Hash[
        'duration' => 'junktime',
        'project' => 'ganeti-web-manager',
        'user' => 'example-user',
        'activities' => ['documenting'],
        'notes' => 'Worked on docs',
        'issue_uri' => 'https://github.com/',
        'date_worked' => '2014-04-17',
    ]

    assert_equal(@ts.update_time(time, 'uuid'),
                 [Hash[@ts.instance_variable_get(:@error) => 'time object: invalid duration string']])
  end

  # Tests that TimeSync.create_time will fail
  # if a string containing multiple hours/minutes is entered
  def test_create_time_with_invalid_string_duration
    time = Hash[
        'duration' => '3h30m15h',
        'project' => 'ganeti-web-manager',
        'user' => 'example-user',
        'activities' => ['documenting'],
        'notes' => 'Worked on docs',
        'issue_uri' => 'https://github.com/',
        'date_worked' => '2014-04-17',
    ]

    assert_equal(@ts.create_time(time),
                 [Hash[@ts.instance_variable_get(:@error) => 'time object: invalid duration string']])
  end

  # Tests that TimeSync.update_time will fail
  # if a string containing multiple hours/minutes is entered
  def test_update_time_with_invalid_string_duration
    time = Hash[
        'duration' => '3h30m15h',
        'project' => 'ganeti-web-manager',
        'user' => 'example-user',
        'activities' => ['documenting'],
        'notes' => 'Worked on docs',
        'issue_uri' => 'https://github.com/',
        'date_worked' => '2014-04-17',
    ]

    assert_equal(@ts.update_time(time, 'uuid'),
                 [Hash[@ts.instance_variable_get(:@error) => 'time object: invalid duration string']])
  end

  # @patch('rimesync.TimeSync.create_or_update')
  # def test_create_project(self, mock_create_or_update):
  # end

  # @patch('rimesync.TimeSync.create_or_update')
  # def test_update_project(self, mock_create_or_update):
  # end

  # @patch('rimesync.TimeSync.create_or_update')
  # def test_create_activity(self, mock_create_or_update):
  # end

  # @patch('rimesync.TimeSync.create_or_update')
  # def test_update_activity(self, mock_create_or_update):
  # end

  # @patch('rimesync.TimeSync.create_or_update')
  # def test_create_user(self, mock_create_or_update):
  # end

  # @patch('rimesync.TimeSync.create_or_update')
  # def test_create_user_valid_perms(self, mock_create_or_update):
  # end

  # rubocop:disable MethodLength
  # Tests that TimeSync.create_user returns error with invalid perm field
  def test_create_user_invalid_admin
    user = Hash[
        'username' => 'example-user',
        'password' => 'password',
        'display_name' => 'Example User',
        'email' => 'example.user@example.com',
        'site_admin' => true,
        'site_spectator' => false,
        'site_manager' => true,
        'active' => true,
    ]

    user_to_test = Hash[user]
    ary = %w(site_admin site_spectator site_manager active)
    ary.each do |perm|
      user_to_test = Hash[user]
      user_to_test[perm] = 'invalid'
      assert_equal(@ts.create_user(user_to_test),
                   Hash[@ts.instance_variable_get(:@error) => 'user object: %s must be True or False' % perm])
    end
  end

  # Tests that unicode password objects get
  # encoded to UTF-8 before being hashed
  def test_create_user_unicode_password
    user = Hash[
        'username': 'example-user',
        'password': 'password',
        'display_name': 'Example User',
        'email': 'example.user@example.com',
        'site_admin': true,
        'site_spectator': false,
        'site_manager': true,
        'active': true,
    ]

    @ts.create_user(user)

    assert_equal(BCrypt.hashpw(user['password'], user['password']),  # research this
                      user['password'])
  end

  # Tests that unicode password objects get encoded to UTF-8 before being hashed
  def test_update_user_unicode_password
    user = Hash[
        'username': 'example-user',
        'password': 'password',
        'display_name': 'Example User',
        'email': 'example.user@example.com',
        'site_admin': true,
        'site_spectator': false,
        'site_manager': true,
        'active': true,
    ]

    @ts.update_user(user, user[:username])

    assert_equal(BCrypt::Password.create(user[:password]), user[:password])
  end

  def test_hash_user_password
    # Tests that passwords are hashed correctly
    user = Hash[
        'username': 'user',
        'password': 'pass'
    ]

    @ts.hash_user_password(user)

    assert_equal(BCrypt::Password.create(user[:password]), user[:password])
  end


  # @patch('rimesync.TimeSync.create_or_update')
  # def test_update_user(self, mock_create_or_update):
  # end

  # Tests authenticate method for url and data construction
  def test_authentication
    auth = Hash[
      'auth' => Hash[
          'type' => 'password',
          'username' => 'example-user',
          'password' => 'password'
      ]
    ].to_json

    url = 'http://ts.example.com/v0/login'

    stub_request(:post, url).with(body: auth)

    @ts.authenticate(username: 'example-user', password: 'password', auth_type: 'password')
  end

  # Tests authenticate method with a token return
  def test_authentication_return_success
    stub_request(:post, /.*/)
    .to_return(:body => JSON.dump([Hash['token' => 'sometoken']]))

    auth_block = @ts.authenticate(username: 'example-user', password: 'password', auth_type: 'password')

    assert_equal(auth_block['token'], @ts.instance_variable_get(:@token), 'sometoken')
    assert_equal(auth_block, Hash['token' => 'sometoken'])
  end

  # Tests authenticate method with an error return
  def test_authentication_return_error
    stub_request(:post, /.*/)
    .to_return(:body => JSON.dump([Hash['status' => 401,
                                   'error' => 'Authentication failure',
                                   'text' => 'Invalid username or password']]))

    auth_block = @ts.authenticate(username: 'example-user', password: 'password', auth_type: 'password')

    assert_equal(auth_block,
                 Hash['status' => 401,
                      'error' => 'Authentication failure',
                      'text' => 'Invalid username or password'])
  end

  # Tests authenticate method with no username in call
  def test_authentication_no_username
    assert_equal(@ts.authenticate(password: 'password', auth_type: 'password'),
                 Hash[@ts.instance_variable_get(:@error) =>
                  'Missing username; please add to method call'])
  end

  # Tests authenticate method with no password in call
  def test_authentication_no_password
    assert_equal(@ts.authenticate(username: 'username', auth_type: 'password'),
                 Hash[@ts.instance_variable_get(:@error) =>
                  'Missing password; please add to method call'])
  end

  # Tests authenticate method with no auth_type in call
  def test_authentication_no_auth_type
    assert_equal(@ts.authenticate(username: 'username', password: 'password'),
                 Hash[@ts.instance_variable_get(:@error) =>
                  'Missing auth_type; please add to method call'])
  end

  # Tests authenticate method with no username or password in call
  def test_authentication_no_username_or_password
    assert_equal(@ts.authenticate(auth_type: 'password'),
                 Hash[@ts.instance_variable_get(:@error) =>
                  'Missing username, password; please add to method call'])
  end

  # Tests authenticate method with no username or auth_type in call
  def test_authentication_no_username_or_auth_type
    assert_equal(@ts.authenticate(password: 'password'),
                 Hash[@ts.instance_variable_get(:@error) =>
                  'Missing username, auth_type; please add to method call'])
  end

  # Tests authenticate method with no username or auth_type in call
  def test_authentication_no_password_or_auth_type
    assert_equal(@ts.authenticate(username: 'username'),
                 Hash[@ts.instance_variable_get(:@error) =>
                  'Missing password, auth_type; please add to method call'])
  end

  # Tests authenticate method with no arguments in call
  def test_authentication_no_arguments
    assert_equal(@ts.authenticate,
                 Hash[@ts.instance_variable_get(:@error) =>
                  'Missing username, password, auth_type; please add to method call'])
  end

  # Tests authenticate method with no token in response
  def test_authentication_no_token_in_response
    response = Resp.new
    response.instance_variable_set(:@status_code, 502)

    # stub_request(:post, /.*/).to_return(:status => 502)
    stub_request(:post, /.*/).to_return(response)

    assert_equal(@ts.authenticate(username: 'username', password: 'password',
                                 auth_type: 'password'),
                 Hash[@ts.instance_variable_get(:@error) => 'connection to TimeSync failed at baseurl http://ts.example.com/v0 - response status was 502'])
  end

  # Test internal local_auth_error method with token
  def test_local_auth_error_with_token
    assert_nil(@ts.local_auth_error)
  end

  # Test internal local_auth_error method with no token
  def test_local_auth_error_no_token
    @ts.instance_variable_set(:@token, nil)
    assert_equal(@ts.local_auth_error,
                 'Not authenticated with TimeSync, call authenticate first')
  end

  # Test that pymesync doesn't break when
  # getting a response that is not a JSON object
  def test_handle_other_connection_response
    response = Resp.new
    response.instance_variable_set(:@code, 502)

    assert_equal(@ts.response_to_ruby(response),
                 Hash[@ts.instance_variable_get(:@error) => 'connection to TimeSync failed at baseurl http://ts.example.com/v0 - response status was 502'])
  end

  # Test that _delete_object calls requests.delete with the correct url
  def test_delete_object_time
    url = '%s/times/abcd-3453-3de3-99sh?token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                          @ts.instance_variable_get(:@token)]
    stub_request(:delete, url)
    @ts.delete_object('times', 'abcd-3453-3de3-99sh')
  end

  # Test that _delete_object calls requests.delete with the correct url
  def test_delete_object_project
    url = '%s/projects/ts?token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                              @ts.instance_variable_get(:@token)]
    stub_request(:delete, url)
    @ts.delete_object('projects', 'ts')
  end

  # Test that _delete_object calls requests.delete with the correct url
  def test_delete_object_activity
    url = '%s/activities/code?token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                  @ts.instance_variable_get(:@token)]
    stub_request(:delete, url)
    @ts.delete_object('activities', 'code')
  end

  # Test that _delete_object calls requests.delete with the correct url
  def test_delete_object_user
    url = '%s/users/example-user?token=%s' % Array[@ts.instance_variable_get(:@baseurl),
                                                     @ts.instance_variable_get(:@token)]
    stub_request(:delete, url)
    @ts.delete_object('users', 'example-user')
  end

  # @patch('rimesync.TimeSync.delete_object')
  # def test_delete_time(self, m_delete_object):
  # end

  # Test that delete_time returns proper error on authentication failure
  def test_delete_time_no_auth
    @ts.instance_variable_set(:@token, nil)
    assert_equal(@ts.delete_time(uuid: 'abcd-3453-3de3-99sh'),
                 Hash['rimesync error' => 'Not authenticated with TimeSync, call authenticate first'])
  end

  # Test that delete_time returns proper error when uuid not provided
  def test_delete_time_no_uuid
    assert_equal(@ts.delete_time,
                 Hash['rimesync error' =>
                      'missing uuid; please add to method call'])
  end

  # @patch('rimesync.TimeSync.delete_object')
  # def test_delete_project(self, m_delete_object):
  # end

  # Test that delete_project returns proper error on authentication failure
  def test_delete_project_no_auth
    @ts.instance_variable_set(:@token, nil)
    assert_equal(@ts.delete_project('ts'),
                 Hash['rimesync error' => 'Not authenticated with TimeSync, call authenticate first'])
  end

  # Test that delete_project returns proper error when slug not provided
  def test_delete_project_no_slug
    assert_equal(@ts.delete_project,
                 Hash['rimesync error' =>
                      'missing slug; please add to method call'])
  end

  # @patch('rimesync.TimeSync.delete_object')
  # def test_delete_activity(self, m_delete_object):
  # end

  # Test that delete_activity returns proper error on authentication failure
  def test_delete_activity_no_auth
    @ts.instance_variable_set(:@token, nil)
    assert_equal(@ts.delete_activity('code'),
                 Hash['rimesync error' => 'Not authenticated with TimeSync, call authenticate first'])
  end

  # Test that delete_activity returns proper error when slug not provided
  def test_delete_activity_no_slug
    assert_equal(@ts.delete_activity,
                 Hash['rimesync error' =>
                       'missing slug; please add to method call'])
  end

  # @patch('rimesync.TimeSync.delete_object')
  # def test_delete_user(self, m_delete_object):
  # end

  # Test that delete_user returns proper error on authentication failure
  def test_delete_user_no_auth
    @ts.instance_variable_set(:@token, nil)
    assert_equal(@ts.delete_user('example-user'),
                 Hash['rimesync error' => 'Not authenticated with TimeSync, call authenticate first'])
  end

  # Test that delete_user returns proper error when username not provided
  def test_delete_user_no_username
    assert_equal(@ts.delete_user,
                 Hash['rimesync error' =>
                       'missing username; please add to method call'])
  end

  # Test that token_expiration_time returns valid date from a valid token
  def test_token_expiration_valid
    @ts.instance_variable_set(:@token, 'eyJ0eXAiOiJKV1QiLCJhbGciO\
                              iJITUFDLVNIQTUxMiJ9.eyJpc3MiOiJvc3Vv\
                              c2wtdGltZXN5bmMtc3RhZ2luZyIsInN1YiI6\
                              InRlc3QiLCJleHAiOjE0NTI3MTQzMzQwODcsI\
                              mlhdCI6MTQ1MjcxMjUzNDA4N30=.QP2FbiY3I6\
                              e2eN436hpdjoBFbW9NdrRUHbkJ+wr9GK9mMW7/oC/oK\
                              nutCwwzMCwjzEx6hlxnGo6/LiGyPBcm3w==')

    decoded_payload = Base64.decode64(@ts.instance_variable_get(:@token)
                                      .split('.')[1])
    exp_int = JSON.load(decoded_payload)['exp'] / 1000
    exp_datetime = Time.at(exp_int)

    assert_equal(@ts.token_expiration_time, exp_datetime)
  end

  # Test that token_expiration_time returns correct from an invalid token
  def test_token_expiration_invalid
    assert_equal(@ts.token_expiration_time,
                 Hash[@ts.instance_variable_get(:@error) => 'improperly encoded token'])
  end

  # Test that token_expiration_time returns correct error
  # when user is not authenticated
  def test_token_expiration_no_auth
    @ts.instance_variable_set(:@token, nil)
    assert_equal(@ts.token_expiration_time,
                 Hash[@ts.instance_variable_get(:@error) => 'Not authenticated with TimeSync, call authenticate first'])
  end

  # Tests that when a string duration is entered, it is converted to an integer
  def test_duration_to_seconds
    time = Hash[
        'duration' => '3h30m',
        'project' => 'ganeti-web-manager',
        'user' => 'example-user',
        'activities' => ['documenting'],
        'notes' => 'Worked on docs',
        'issue_uri' => 'https://github.com/',
        'date_worked' => '2014-04-17',
    ]

    assert_equal(@ts.duration_to_seconds(time['duration']), 12_600)
  end

  # Tests for duration validity - if the duration given
  # is a negative int, an error message is returned
  def test_duration_invalid
    time = Hash[
        'duration': -12600,
        'project': 'ganeti-web-manager',
        'user': 'example-user',
        'activities': ['documenting'],
        'notes': 'Worked on docs',
        'issue_uri': 'https://github.com/',
        'date_worked': '2014-04-17',
    ]
    assert_equal(@ts.create_time(time),
                 Hash[@ts.instance_variable_get(:@error) =>'time object: duration cannot be negative'])
  end

  # rubocop:disable MethodLength
  # Tests that when an invalid string duration is entered,
  # an error message is returned
  def test_duration_to_seconds_with_invalid_str
    time = Hash[
        'duration' => '3hh30m',
        'project' => 'ganeti-web-manager',
        'user' => 'example-user',
        'activities' => ['documenting'],
        'notes' => 'Worked on docs',
        'issue_uri' => 'https://github.com/',
        'date_worked' => '2014-04-17',
    ]

    assert_equal(@ts.duration_to_seconds(time['duration']),
                 [Hash[@ts.instance_variable_get(:@error) => 'time object: invalid duration string']])
  end


  # Test project_users method with a valid project object returned from TimeSync
  def test_project_users_valid
      project = "rime"
      response = Resp.new
      response.instance_variable_set(:@code, 200)

      response.instance_variable_set(:@body, JSON.dump(Hash[
          "uri" => "https://github.com/osuosl/pymesync",
          "name" => "pymesync",
          "slugs" => ["pyme", "ps", "pymesync"],
          "uuid" => "a034806c-00db-4fe1-8de8-514575f31bfb",
          "revision" => 4,
          "created_at" => "2014-07-17",
          "deleted_at" => nil,
          "updated_at" => "2014-07-20",
          "users" => Hash[
              "malcolm" => Hash["member" => true,
                          "manager" => true,
                          "spectator" => true],
              "jayne" =>   Hash["member" => true,
                          "manager" => false,
                          "spectator" => false],
              "kaylee" =>  Hash["member" => true,
                          "manager" => false,
                          "spectator" => false],
              "zoe" =>     Hash["member" => true,
                          "manager" => false,
                          "spectator" => false],
              "hoban" =>   Hash["member" => true,
                          "manager" => false,
                          "spectator" => false],
              "simon" =>   Hash["member" => false,
                          "manager" => false,
                          "spectator" => true],
              "river" =>   Hash["member" => false,
                          "manager" => false,
                          "spectator" => true],
              "derrial" => Hash["member" => false,
                          "manager" => false,
                          "spectator" => true],
              "inara" =>   Hash["member" => false,
                          "manager" => false,
                          "spectator" => true]
          ]
      ]))

      expected_result = Hash[
          'malcolm' => ['member', 'manager', 'spectator'],
          'jayne' =>   ['member'],
          'kaylee' =>  ['member'],
          'zoe' =>     ['member'],
          'hoban' =>   ['member'],
          'simon' =>   ['spectator'],
          'river' =>   ['spectator'],
          'derrial' => ['spectator'],
          'inara' =>   ['spectator']
      ]

      stub_request(:get, /.*/).to_return(:body)

      assert_equal(@ts.project_users(project=project), expected_result)
    end


  # Test project_users method with an error object returned from TimeSync
  def test_project_users_error_response
    proj = 'rimes'
    response = Resp.new
    response.instance_variable_set(:@code, 404)

    response.instance_variable_set(:@body, JSON.dump([Hash['error' => 'Object not found', 'text' => 'nilxistent project']]))

    stub_request(:get, /.*/).to_return(response)

    assert_equal(@ts.project_users(project = proj),
                 Hash['error' => 'Object not found',
                      'text' => 'nilxistent project'])
  end

  # Test project_users method with no project object
  # passed as a parameter, should return an error
  def test_project_users_no_project_parameter
    assert_equal(@ts.project_users,
                 Hash[@ts.instance_variable_get(:@error) =>
                      'Missing project slug, please include in method call'])
  end

  # Test that the trailing slash in the baseurl is removed
  def test_baseurl_with_trailing_slash
    @ts = TimeSync.new('http://ts.example.com/v0/')
    assert_equal(@ts.instance_variable_get(:@baseurl), 'http://ts.example.com/v0')
  end

  # Test that the trailing slash in the baseurl is removed
  def test_baseurl_without_trailing_slash
    @ts = TimeSync.new('http://ts.example.com/v0')
    assert_equal(@ts.instance_variable_get(:@baseurl), 'http://ts.example.com/v0')
  end
end
