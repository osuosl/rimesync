def authenticate
  Hash['token' => 'TESTTOKEN'] # rcop
end

def token_expiration_time
  Time.new(2016, 1, 13, 11, 45, 34) # rcop
end

# Sends time to baseurl (TimeSync)
def create_time(p_dict)
  p_dict['created_at'] = '2015-05-23'
  p_dict['updated_at'] = nil
  p_dict['deleted_at'] = nil
  p_dict['uuid'] = '838853e3-3635-4076-a26f-7efr4e60981f'
  p_dict['revision'] = 1
  p_dict['notes'] = p_dict['notes'] ? p_dict['notes'] : nil
  p_dict['issue_uri'] = p_dict['issue_uri'] ? p_dict['issue_uri'] : nil
  p_dict # rcop
end

# Updates time by uuid
# rubocop:disable MethodLength
# rubocop:disable Metrics/AbcSize
def update_time(p_dict, uuid)
  updated_param = Hash[
    'duration' => p_dict.key?('duration') ? p_dict['duration'] : 18,
    'user' => p_dict.key?('user') ? p_dict['user'] : 'example-user',
    'activities' => p_dict.key?('activities') ? p_dict['activities'] : ['qa'],
    'project' => p_dict.key?('project') ? p_dict['project'] : ['ganeti'],
    'notes' => p_dict.key?('notes') ? p_dict['notes'] : nil,
    'issue_uri' => p_dict.key?('issue_uri') ? p_dict['issue_uri'] : 'https://github.com/osuosl/ganeti_webmgr/issues/56',
    'date_worked' => p_dict.key?('date_worked') ? p_dict['date_worked'] : '2015-08-07',
    'created_at' => '2014-06-12',
    'updated_at' => '2015-10-18',
    'deleted_at' => nil,
    'uuid' => uuid,
    'revision' => 2
  ]
  updated_param
end

# Creates project
def create_project(p_dict)
  p_dict['users'] = p_dict.key?('users') ? p_dict['users'] : Hash[
        'mrsj' => Hash['member' => true, 'spectator' => true,
                       'manager' => true],
        'tschuy' => Hash['member' => true, 'spectator' => false,
                         'manager' => false]
  ]
  p_dict['uuid'] = '309eae69-21dc-4538-9fdc-e6892a9c4dd4'
  p_dict['revision'] = 1
  p_dict['created_at'] = '2015-05-23'
  p_dict['updated_at'] = nil
  p_dict['deleted_at'] = nil
  p_dict['uri'] = p_dict.key?('uri') ? p_dict['uri'] : nil
  p_dict
end

# Updates project by slug
def update_project(p_dict, slug)
  updated_param = Hash[
    'uri' => p_dict.key?('uri') ? p_dict['uri'] : nil,
    'name' => p_dict.key?('name') ? p_dict['name'] : 'TimeSync API',
    'slugs' => p_dict.key?('slugs') ? p_dict['slugs'] : [slug],
    'created_at' => '2014-04-16',
    'updated_at' => '2014-04-18',
    'deleted_at' => nil,
    'uuid' => '309eae69-21dc-4538-9fdc-e6892a9c4dd4',
    'revision' => 2,
    'users' => Hash[
        'members' => %w(patcht tschuy),
        'spectators' => [
          'tschuy'
        ],
        'managers' => [
          'tschuy'
        ]
    ]
  ]
  updated_param
end

# Creates activity
def create_activity(p_dict)
  p_dict['uuid'] = 'cfa07a4f-d446-4078-8d73-2f77560c35c0'
  p_dict['created_at'] = '2013-07-27'
  p_dict['updated_at'] = nil
  p_dict['deleted_at'] = nil
  p_dict['revision'] = 1
  p_dict
end

# Updates activity by slug
def update_activity(p_dict, slug)
  updated_param = Hash[
    'name' => p_dict.key?('name') ? p_dict['name'] : 'Testing Infra',
    'slug' => p_dict.key?('slug') ? p_dict['slug'] : slug,
    'uuid' => '3cf78d25-411c-4d1f-80c8-a09e5e12cae3',
    'created_at' => '2014-04-16',
    'updated_at' => '2014-04-17',
    'deleted_at' => nil,
    'revision' => 2
  ]
  updated_param
end

# Creates a user
def create_user(p_dict)
  p_dict['active'] = true
  p_dict['site_admin'] = p_dict.key?('site_admin') ? p_dict['site_admin'] : false
  p_dict['site_manager'] = p_dict.key?('site_manager') ? p_dict['site_manager'] : false
  p_dict['site_spectator'] = p_dict.key?('site_spectator') ? p_dict['site_spectator'] : false
  p_dict['created_at'] = '2015-05-23'
  p_dict['deleted_at'] = nil
  del(p_dict['password'])
  p_dict
end

# Updates user by username
def update_user(p_dict, username)
  updated_param = Hash[
    'username' => p_dict.key?('username') ? p_dict['username'] : username,
    'display_name' => p_dict.key?('display_name') ? p_dict['display_name'] : 'Mr. Example',
    'email' => p_dict.key?('email') ? p_dict['email'] : 'examplej@example.com',
    'active' => true,
    'site_admin' => p_dict.key?('site_admin') ? p_dict['site_admin'] : false,
    'site_manager' => p_dict.key?('site_manager') ? p_dict['site_manager'] : false,
    'site_spectator' => p_dict.key?('site_spectator') ? (p_dict['site_spectator']) : false,
    'created_at' => '2015-02-29',
    'deleted_at' => nil
  ]
  updated_param
end

# Get times from TimeSync
def get_times(uuid)
  p_list = Array[
    Hash[
        'duration' => 12,
        'user' => 'userone',
        'project' => %w(ganeti-webmgr gwm),
        'activities' => %w(docs planning),
        'notes' => 'Worked on documentation.',
        'issue_uri' => 'https://github.com/osuosl/ganeti_webmgr',
        'date_worked' => '2014-04-17',
        'revision' => 1,
        'created_at' => '2014-04-17',
        'updated_at' => nil,
        'deleted_at' => nil,
        'uuid' => uuid ? uuid : 'c3706e79-1c9a-4765-8d7f-89b4544cad56'
    ]
  ]
  unless uuid
    p_list.push(
      Hash[
        'duration' => 13,
        'user' => 'usertwo',
        'project' => %w(ganeti-webmgr gwm),
        'activities' => %w(code planning),
        'notes' => 'Worked on coding',
        'issue_uri' => 'https://github.com/osuosl/ganeti_webmgr',
        'date_worked' => '2014-04-17',
        'revision' => 1,
        'created_at' => '2014-04-17',
        'updated_at' => nil,
        'deleted_at' => nil,
        'uuid' => '12345676-1c9a-rrrr-bbbb-89b4544cad56'
      ]
    )

    p_list.push(
      Hash[
        'duration' => 14,
        'user' => 'userthree',
        'project' => %w(timesync ts),
        'activities' => ['code'],
        'notes' => 'Worked on coding',
        'issue_uri' => 'https://github.com/osuosl/timesync',
        'date_worked' => '2014-04-17',
        'revision' => 1,
        'created_at' => '2014-04-17',
        'updated_at' => nil,
        'deleted_at' => nil,
        'uuid' => '12345676-1c9a-ssss-cccc-89b4544cad56'
      ]
    )
  end
  p_list
end

# Get project information from TimeSync
def get_projects(slug)
  p_list = Array[
    Hash[
        'uri' => 'https://code.osuosl.org/projects/ganeti-webmgr',
        'name' => 'Ganeti Web Manager',
        'slugs' => [slug ? slug : 'gwm'],
        'uuid' => 'a034806c-00db-4fe1-8de8-514575f31bfb',
        'revision' => 4,
        'created_at' => '2014-07-17',
        'deleted_at' => nil,
        'updated_at' => '2014-07-20',
        'users' => Hash[
            'members' => %w(patcht tschuy),
            'spectators' => [
              'tschuy'
            ],
            'managers' => [
              'tschuy'
            ]
        ]
    ]
  ]
  unless slug
    p_list.push(
      Hash[
        'uri' => 'https://code.osuosl.org/projects/timesync',
        'name' => 'TimeSync',
        'slugs' => %w(timesync ts),
        'uuid' => 'a034806c-rrrr-bbbb-8de8-514575f31bfb',
        'revision' => 2,
        'created_at' => '2014-07-17',
        'deleted_at' => nil,
        'updated_at' => '2014-07-20',
        'users' => Hash[
            'members' => %w(patcht tschuy mrsj),
            'spectators' => %w(tschuy mrsj),
            'managers' => [
              'tschuy'
            ]
        ]
      ]
    )

    p_list.push(
      Hash[
        'uri' => 'https://code.osuosl.org/projects/pymesync',
        'name' => 'pymesync',
        'slugs' => %w(pymesync ps),
        'uuid' => 'a034806c-ssss-cccc-8de8-514575f31bfb',
        'revision' => 1,
        'created_at' => '2014-07-17',
        'deleted_at' => nil,
        'updated_at' => '2014-07-20',
        'users' => Hash[
            'members' => %w(patcht tschuy mrsj MaraJade thai),
            'spectators' => %w(tschuy mrsj),
            'managers' => [
              'mrsj'
            ]
        ]
      ]
    )
  end
  p_list
end

# Get activity information from TimeSync
def get_activities(slug)
  p_list = Array[
    Hash[
        'name' => 'Documentation',
        'slug' => slug ? slug : 'docs',
        'uuid' => 'adf036f5-3d49-4a84-bef9-062b46380bbf',
        'revision' => 5,
        'created_at' => '2014-04-17',
        'deleted_at' => nil,
        'updated_at' => nil
    ]
  ]
  unless slug
    p_list.push(
      Hash[
        'name' => 'Coding',
        'slug' => 'dev',
        'uuid' => 'adf036f5-3d49-bbbb-rrrr-062b46380bbf',
        'revision' => 1,
        'created_at' => '2014-04-17',
        'deleted_at' => nil,
        'updated_at' => nil
      ]
    )

    p_list.push(
      Hash[
        'name' => 'Planning',
        'slug' => 'plan',
        'uuid' => 'adf036f5-3d49-cccc-ssss-062b46380bbf',
        'revision' => 1,
        'created_at' => '2014-04-17',
        'deleted_at' => nil,
        'updated_at' => nil
      ]
    )
  end
  p_list
end

# Get user information from TimeSync
def get_users(username)
  if username
    p_dict = Array[
      Hash[
        'username' => username,
        'display_name' => 'X. Ample User',
        'email' => 'example@example.com',
        'active' => true,
        'site_admin' => false,
        'site_spectator' => false,
        'site_manager' => false,
        'created_at' => '2015-02-29',
        'deleted_at' => nil
        ]
    ]
  else
    p_dict = Array[
      Hash[
        'username' => 'userone',
        'display_name' => 'One Is The Loneliest Number',
        'email' => 'exampleone@example.com',
        'active' => true,
        'site_admin' => false,
        'site_manager' => false,
        'site_spectator' => false,
        'created_at' => '2015-02-29',
        'deleted_at' => nil
      ],
      Hash[
        'username' => 'usertwo',
        'display_name' => 'Two Can Be As Bad As One',
        'email' => 'exampletwo@example.com',
        'active' => true,
        'site_admin' => false,
        'site_manager' => false,
        'site_spectator' => false,
        'created_at' => '2015-02-29',
        'deleted_at' => nil
      ],
      Hash[
        'username' => 'userthree',
        'display_name' => 'Yes It is The Saddest Experience',
        'email' => 'examplethree@example.com',
        'active' => true,
        'site_admin' => false,
        'site_manager' => false,
        'site_spectator' => false,
        'created_at' => '2015-02-29',
        'deleted_at' => nil
      ],
      Hash[
        'username' => 'userfour',
        'display_name' => 'You will Ever Do',
        'email' => 'examplefour@example.com',
        'active' => true,
        'site_admin' => false,
        'site_manager' => false,
        'site_spectator' => false,
        'created_at' => '2015-02-29',
        'deleted_at' => nil
      ]
    ]
  end
  p_dict
end

# Delete an object from TimeSync
def delete_object
  Array[Hash['status' => 200]]
end

# Return list of users and permissions from TimeSync
def project_users
  users = Hash[
    'malcolm' => %w(member manager),
    'jayne' =>   ['member'],
    'kaylee' =>  ['member'],
    'zoe' =>     ['member'],
    'hoban' =>   ['member'],
    'simon' =>   ['spectator'],
    'river' =>   ['spectator'],
    'derrial' => ['spectator'],
    'inara' =>   ['spectator']
  ]
  users
end
