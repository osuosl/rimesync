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
          'updated_at' => nil,
          'deleted_at' => nil,
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
           'notes' => nil,
           'issue_uri' => "https://github.com/osuosl/ganeti_webmgr/issues/56",
           'date_worked' => '2015-08-07',
           'created_at' => '2014-06-12',
           'updated_at' => '2015-10-18',
           'deleted_at' => nil,
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
          'updated_at' => nil,
          'deleted_at' => nil,
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
          'notes' => nil,
          'issue_uri' => "https://github.com/osuosl/ganeti_webmgr/issues/56",
          'date_worked' => '2015-08-07',
          'created_at' => '2014-06-12',
          'updated_at' => '2015-10-18',
          'deleted_at' => nil,
          'uuid' => 'fake-uuid',
          'revision' => 2
      ]

      assert_equal(ts.update_time(parameter_dict, "fake-uuid"),
                        updated_param)

  end

  def test_mock_create_project
      parameter_dict = Hash[
          'uri' => "https://code.osuosl.org/projects/timesync",
          'name' => 'TimeSync API',
          'slugs' => ['timesync', 'time'],
          'users' => {
              'mrsj' => {'member' => true, 'spectator' => true, 'manager' => true},
              'thai' => {'member' => true, 'spectator' => false, 'manager' => false}
          }
      ]

      expected_result = Hash[
          'uri' => "https://code.osuosl.org/projects/timesync",
          'name' => 'TimeSync API',
          'slugs' => ['timesync', 'time'],
          'uuid' => '309eae69-21dc-4538-9fdc-e6892a9c4dd4',
          'created_at' => '2015-05-23',
          'updated_at' => nil,
          'deleted_at' => nil,
          'revision' => 1,
          'users' => Hash[
              'mrsj' => Hash['member' => true, 'spectator' => true, 'manager' => true],
              'thai' => Hash['member' => true, 'spectator' => false, 'manager' => false]
          ]
      ]

      assert_equal(ts.create_project(parameter_dict), expected_result)
  end

  def test_mock_update_project
      parameter_dict = Hash[
          "uri": "https://code.osuosl.org/projects/timesync",
          "name": "pymesync",
      ]

      expected_result = Hash[
          'uri' => "https://code.osuosl.org/projects/timesync",
          'name' => 'pymesync',
          'slugs' => ['ps'],
          'created_at' => '2014-04-16',
          'updated_at' => '2014-04-18',
          'deleted_at' => nil,
          'uuid' => '309eae69-21dc-4538-9fdc-e6892a9c4dd4',
          'revision' => 2,
          'users' => Hash[
              'members' => Array[
                  'patcht',
                  'tschuy'
              ],
              'spectators' => Array[
                  'tschuy'
              ],
              'managers' => Array[
                  'tschuy'
              ]
          ]
      ]

      assert_equal(ts.update_project(parameter_dict, "ps"),
                        expected_result)

  end

  def test_mock_create_activity
      parameter_dict = Hash[
          'name' => 'Quality Assurance/Testing',
          'slug' => 'qa'
      ]

      expected_result = Hash[
          'name' => 'Quality Assurance/Testing',
          'slug' => 'qa',
          'uuid' => 'cfa07a4f-d446-4078-8d73-2f77560c35c0',
          'created_at' => '2013-07-27',
          'updated_at' => nil,
          'deleted_at' => nil,
          'revision' => 1
      ]

      assert_equal(ts.create_activity(parameter_dict),
                        expected_result)

  end

  def test_mock_update_activity
      parameter_dict = Hash['name' => 'Code in the wild']

      expected_result = Hash[
          'name' => 'Code in the wild',
          'slug' => 'ciw',
          'uuid' => '3cf78d25-411c-4d1f-80c8-a09e5e12cae3',
          'created_at' => '2014-04-16',
          'updated_at' => '2014-04-17',
          'deleted_at' => nil,
          'revision' => 2
      ]

      assert_equal(ts.update_activity(parameter_dict, "ciw"),
                        expected_result)
  end

  def test_mock_create_user
      parameter_dict = Hash[
          'username': 'example',
          'password': 'password',
          'display_name': 'X. Ample User',
          'email': 'example@example.com'
      ]

      expected_result = Hash[
          'username' => 'example',
          'display_name' => 'X. Ample User',
          'email' => 'example@example.com',
          'active' => true,
          'site_admin' => false,
          'site_manager' => false,
          'site_spectator' => false,
          'created_at' => '2015-05-23',
          'deleted_at' => nil
      ]

      assert_equal(ts.create_user(parameter_dict), expected_result)
  end

  def test_mock_update_user
      parameter_dict = Hash[
          'username' => 'red-leader',
          'email' => 'red-leader@yavin.com',
          'site_spectator' => true
      ]

      expected_result = Hash[
          'username' => 'red-leader',
          'display_name' => 'Mr. Example',
          'email' => 'red-leader@yavin.com',
          'active' => true,
          'site_admin' => false,
          'site_manager' => false,
          'site_spectator' => true,
          'created_at' => '2015-02-29',
          'deleted_at' => nil
      ]

      self.assertEquals(self.ts.update_user(parameter_dict, "example"),
                        expected_result)
  end

  def test_mock_get_times_with_uuid
      expected_result = Array[
      	Hash[
          'duration' => 12,
          'user' => 'userone',
          'project' => Array['ganeti-webmgr', 'gwm'],
          'activities' => Array['docs', 'planning'],
          'notes' => 'Worked on documentation.',
          'issue_uri' => "https://github.com/osuosl/ganeti_webmgr",
          'date_worked' => '2014-04-17',
          'revision' => 1,
          'created_at' => '2014-04-17',
          'updated_at' => nil,
          'deleted_at' => nil,
          'uuid' => 'example-uuid'
        ]
      ]

      assert_equal(ts.get_times({"uuid": "example-uuid"}),
                        expected_result)
  end

  def test_mock_get_times_no_uuid
      expected_result = Array[
          Hash[
              'duration' => 12,
              'user' => 'userone',
              'project' => Array['ganeti-webmgr', 'gwm'],
              'activities' => Array['docs', 'planning'],
              'notes' => 'Worked on documentation.',
              'issue_uri' => "https://github.com/osuosl/ganeti_webmgr",
              'date_worked' => '2014-04-17',
              'revision' => 1,
              'created_at' => '2014-04-17',
              'updated_at' => nil,
              'deleted_at' => nil,
              'uuid' => 'c3706e79-1c9a-4765-8d7f-89b4544cad56'
          ],
          Hash[
              'duration' => 13,
              'user' => 'usertwo',
              'project' => Array['ganeti-webmgr', 'gwm'],
              'activities' => Array['code', 'planning'],
              'notes' => 'Worked on coding',
              'issue_uri' => "https://github.com/osuosl/ganeti_webmgr",
              'date_worked' => '2014-04-17',
              'revision' => 1,
              'created_at' => '2014-04-17',
              'updated_at' => nil,
              'deleted_at' => nil,
              'uuid' => '12345676-1c9a-rrrr-bbbb-89b4544cad56'
          ],
          Hash[
              'duration' => 14,
              'user' => 'userthree',
              'project' => Array['timesync', 'ts'],
              'activities' => Array['code'],
              'notes' => 'Worked on coding',
              'issue_uri' => "https://github.com/osuosl/timesync",
              'date_worked' => '2014-04-17',
              'revision' => 1,
              'created_at' => '2014-04-17',
              'updated_at' => nil,
              'deleted_at' => nil,
              'uuid' => '12345676-1c9a-ssss-cccc-89b4544cad56'
          ]
      ]

      assert_equal(ts.get_times(), expected_result)
  end

  def test_mock_get_projects_with_slug
        expected_result = Array[
        	Hash[
            'uri' => "https://code.osuosl.org/projects/ganeti-webmgr",
            'name' => 'Ganeti Web Manager',
            'slugs' => ['ganeti'],
            'uuid' => 'a034806c-00db-4fe1-8de8-514575f31bfb',
            'revision' => 4,
            'created_at' => '2014-07-17',
            'deleted_at' => nil,
            'updated_at' => '2014-07-20',
            'users' => Hash[
                'members' => Array[
                    'patcht',
                    'tschuy'
                ],
                'spectators' => Array[
                    'tschuy'
                ],
                'managers' => Array[
                    'tschuy'
                ]
            ]
            ]
        ]

        assert_equal(ts.get_projects({"slug" => "ganeti"}),expected_result)
  end

    def test_mock_get_projects_no_slug
        expected_result = Array[
            Hash[
                'uri' => "https://code.osuosl.org/projects/ganeti-webmgr",
                'name' => 'Ganeti Web Manager',
                'slugs' => ['gwm'],
                'uuid' => 'a034806c-00db-4fe1-8de8-514575f31bfb',
                'revision' => 4,
                'created_at' => '2014-07-17',
                'deleted_at' => nil,
                'updated_at' => '2014-07-20',
                'users' => Hash[
                    'members' => Array[
                        'patcht',
                        'tschuy'
                    ],
                    'spectators' => Array[
                        'tschuy'
                    ],
                    'managers' => Array[
                        'tschuy'
                    ]
                ]
            ],
            Hash[
                'uri' => "https://code.osuosl.org/projects/timesync",
                'name' => 'TimeSync',
                'slugs' => ['timesync', 'ts'],
                'uuid' => 'a034806c-rrrr-bbbb-8de8-514575f31bfb',
                'revision' => 2,
                'created_at' => '2014-07-17',
                'deleted_at' => nil,
                'updated_at' => '2014-07-20',
                'users' => Hash[
                    'members' => Array[
                        'patcht',
                        'tschuy',
                        'mrsj'
                    ],
                    'spectators' => Array[
                        'tschuy',
                        'mrsj'
                    ],
                    'managers' => Array[
                        'tschuy'
                    ]
                ]
            ],
            Hash[
                'uri' => "https://code.osuosl.org/projects/pymesync",
                'name' => 'pymesync',
                'slugs' => ['pymesync', 'ps'],
                'uuid' => 'a034806c-ssss-cccc-8de8-514575f31bfb',
                'revision' => 1,
                'created_at' => '2014-07-17',
                'deleted_at' => nil,
                'updated_at' => '2014-07-20',
                'users' => Hash[
                    'members' => Array[
                        'patcht',
                        'tschuy',
                        'mrsj',
                        'MaraJade',
                        'thai'
                    ],
                    'spectators' => Array[
                        'tschuy',
                        'mrsj'
                    ],
                    'managers' => Array[
                        'mrsj'
                    ]
                ]
            ]
        ]

        assert_equal(ts.get_projects(), expected_result)

  end
end