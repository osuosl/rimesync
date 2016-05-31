require_relative "rimesync"
require "test/unit"

class TestMockRimeSync < Test::Unit::TestCase

  def setUp
      baseurl = "http://ts.example.com/v1"
      @ts = pymesync.TimeSync(baseurl, test=true)
      @ts.authenticate("testuser", "testpassword", "password")
  end

  def tearDown
      del(@ts)
  end

  def test_mock_authenticate
      @ts.token = nil
      assert_equal(ts.authenticate("example", "ex", "password"),
                        {"token"=> "TESTTOKEN"})
      assert_equal(ts.token, "TESTTOKEN")
  end

  def test_mock_token_expiration_time
      assert_equal(ts.token_expiration_time(),
                        Time.new(2016, 1, 13, 11, 45, 34))
  end

  def test_mock_create_time
      parameter_dict = Hash[
          'duration' => 12,
          'user' => 'example-2',
          'project' => 'ganeti_web_manager',
          'activities' => ['docs'],
          'notes' => 'Worked on documentation toward settings configuration.',
          'issue_uri' => "https://github.com/osuosl/ganeti_webmgr/issues",
          'date_worked' => '2014-04-17'
      ]

      expected_result = Hash[
          'duration' => 12,
          'user' => 'example-2',
          'project' => 'ganeti_web_manager',
          'activities' => ['docs'],
          'notes' => 'Worked on documentation toward settings configuration.',
          'issue_uri' => "https://github.com/osuosl/ganeti_webmgr/issues",
          'date_worked' => '2014-04-17',
          'created_at' => '2015-05-23',
          'updated_at' => None,
          'deleted_at' => None,
          'uuid' => '838853e3-3635-4076-a26f-7efr4e60981f',
          'revision' => 1
      ]
      assert_equal(ts.create_time(parameter_dict), expected_result)
   end

  def test_mock_update_time(self):
       parameter_dict = {
           'duration' => 19,
           'user' => 'red-leader',
           'activities' => Array['hello', 'world'],
       }
       updated_param = {
           'duration' => 19,
           'user' => 'red-leader',
           'activities' => Array['hello', 'world'],
           'project' => Array['ganeti'],
           'notes' => None,
           'issue_uri' => "https://github.com/osuosl/ganeti_webmgr/issues/56",
           'date_worked' => '2015-08-07',
           'created_at' => '2014-06-12',
           'updated_at' => '2015-10-18',
           'deleted_at' => None,
           'uuid' => 'fake-uuid',
           'revision' => 2
       }
       assert_equal(ts.update_time(parameter_dict, "fake-uuid"),
                         updated_param)
  end


  def test_mock_create_time_with_string_duration
      parameter_dict = Hash[
          'duration' => '3h30m',
          'user' => 'example-2',
          'project' => 'ganeti_web_manager',
          'activities' => Array['docs'],
          'notes' => 'Worked on documentation toward settings configuration.',
          'issue_uri' => "https://github.com/osuosl/ganeti_webmgr/issues",
          'date_worked' => '2014-04-17'
      ]

      expected_result = Hash[
          'duration' => 12600,
          'user' => 'example-2',
          'project' => 'ganeti_web_manager',
          'activities' => ['docs'],
          'notes' => 'Worked on documentation toward settings configuration.',
          'issue_uri' => "https://github.com/osuosl/ganeti_webmgr/issues",
          'date_worked' => '2014-04-17',
          'created_at' => '2015-05-23',
          'updated_at' => None,
          'deleted_at' => None,
          'uuid' => '838853e3-3635-4076-a26f-7efr4e60981f',
          'revision' => 1
      ]

      assert_equal(ts.create_time(parameter_dict), expected_result)
  end

  def test_mock_update_time_with_string_duration
      parameter_dict = Hash[
          'duration' => '3h35m',
          'user' => 'red-leader',
          'activities' => Array['hello', 'world'],
      ]

      updated_param = Hash[
          'duration' => 12900,
          'user' => 'red-leader',
          'activities' => ['hello', 'world'],
          'project' => ['ganeti'],
          'notes' => None,
          'issue_uri' => "https://github.com/osuosl/ganeti_webmgr/issues/56",
          'date_worked' => '2015-08-07',
          'created_at' => '2014-06-12',
          'updated_at' => '2015-10-18',
          'deleted_at' => None,
          'uuid' => 'fake-uuid',
          'revision' => 2
      ]

      assert_equal(ts.update_time(parameter_dict, "fake-uuid"),
                        updated_param)

  end

end