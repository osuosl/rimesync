def authenticate
    return Hash["token" => "TESTTOKEN"]
end

def token_expiration_time
    return Time.new(2016, 1, 13, 11, 45, 34)
end


def create_time(p_dict)
    #Sends time to baseurl (TimeSync)
    p_dict["created_at"] = "2015-05-23"
    p_dict["updated_at"] = nil
    p_dict["deleted_at"] = nil
    p_dict["uuid"] = "838853e3-3635-4076-a26f-7efr4e60981f"
    p_dict["revision"] = 1
    p_dict["notes"] = p_dict["notes"] ? p_dict["notes"] : nil
    p_dict["issue_uri"] = p_dict["issue_uri"] ? p_dict["issue_uri"] : nil
    return p_dict
end


def update_time(p_dict, uuid)
   # Updates time by uuid
    updated_param = Hash[
        "duration" => p_dict.has_key?("duration") ? p_dict["duration"] : 18,
        "user" => p_dict.has_key?("user") ? p_dict["user"] : "example-user",
        "activities" => p_dict.has_key?("activities") ? p_dict["activities"] : ["qa"],
        "project" => p_dict.has_key?("project") ? p_dict["project"] : ["ganeti"],
        "notes" => p_dict.has_key?("notes") ? p_dict["notes"] : nil,
        "issue_uri" => p_dict.has_key?("issue_uri") ? p_dict["issue_uri"] : ("https://github.com/osuosl/ganeti_webmgr/issues/56"),
        "date_worked" => p_dict.has_key?("date_worked") ? p_dict["date_worked"] : ("2015-08-07"),
        "created_at" => "2014-06-12",
        "updated_at" => "2015-10-18",
        "deleted_at" => nil,
        "uuid" => nil,
        "revision" => 2
    ]
    return updated_param
end


def create_project(p_dict)
    # Creates project
    p_dict["users"] = p_dict.has_key?("users") ? p_dict["users"] : Hash[
        "mrsj" => Hash["member" => true, "spectator" => true, "manager" => true],
        "tschuy" => Hash["member" => true, "spectator" => false, "manager" => false]
    ]
    p_dict["uuid"] = "309eae69-21dc-4538-9fdc-e6892a9c4dd4"
    p_dict["revision"] = 1
    p_dict["created_at"] = "2015-05-23"
    p_dict["updated_at"] = nil
    p_dict["deleted_at"] = nil
    p_dict["uri"] = p_dict.has_key?("uri") ? p_dict["uri"] : nil
    return p_dict
end


def update_project(p_dict, slug)
    # Updates project by slug
    updated_param = Hash[
        "uri" => p_dict.has_key?("uri") ? p_dict["uri"] : nil,
        "name" => p_dict.has_key?("name") ? p_dict["name"] : "TimeSync API",
        "slugs" => p_dict.has_key?("slugs") ? p_dict["slugs"] : [slug],
        "created_at" => "2014-04-16",
        "updated_at" => "2014-04-18",
        "deleted_at" => nil,
        "uuid" => "309eae69-21dc-4538-9fdc-e6892a9c4dd4",
        "revision" => 2,
        "users" => Hash[
            "members" => [
                "patcht",
                "tschuy"
            ],
            "spectators" => [
                "tschuy"
            ],
            "managers" => [
                "tschuy"
            ]
        ]
    ]
    return updated_param
end


def create_activity(p_dict)
    # Creates activity
    p_dict["uuid"] = "cfa07a4f-d446-4078-8d73-2f77560c35c0"
    p_dict["created_at"] = "2013-07-27"
    p_dict["updated_at"] = nil
    p_dict["deleted_at"] = nil
    p_dict["revision"] = 1
    return p_dict
end


def update_activity(p_dict, slug)
    # Updates activity by slug
    updated_param = Hash[
        "name" => p_dict.has_key?("name") ? p_dict["name"] : "Testing Infra",
        "slug" => p_dict.has_key?("slug") ? p_dict["slug"] : slug,
        "uuid" => "3cf78d25-411c-4d1f-80c8-a09e5e12cae3",
        "created_at" => "2014-04-16",
        "updated_at" => "2014-04-17",
        "deleted_at" => nil,
        "revision" => 2
    ]
    return updated_param
end


def create_user(p_dict)
    # Creates a user
    p_dict["active"] = true
    p_dict["site_admin"] =  p_dict.has_key?("site_admin") ? p_dict["site_admin"] : false
    p_dict["site_manager"] =  p_dict.has_key?("site_manager") ? p_dict["site_manager"] : false
    p_dict["site_spectator"] =  p_dict.has_key?("site_spectator") ? p_dict["site_spectator"] : false
    p_dict["created_at"] = "2015-05-23"
    p_dict["deleted_at"] = nil
    del(p_dict["password"])  # not works
    return p_dict
end


def update_user(p_dict, username)
    # Updates user by username
    updated_param = Hash[
        "username" => p_dict.has_key?("username") ? p_dict["username"] : username,
        "display_name" => p_dict.has_key?("display_name") ? p_dict["display_name"]  : "Mr. Example",
        "email" => p_dict.has_key?("email") ? p_dict["email"] : "examplej@example.com",
        "active" => true,
        "site_admin" => p_dict.has_key?("site_admin") ? p_dict["site_admin"] : false,
        "site_manager" => p_dict.has_key?("site_manager") ? p_dict["site_manager"] : false,
        "site_spectator" => p_dict.has_key?("site_spectator") ? (p_dict["site_spectator"]) : false,
        "created_at" => "2015-02-29",
        "deleted_at" => nil
    ]
    return updated_param
end


def get_times(uuid)
    # Get times from TimeSync
    p_list = Array[
        Hash[
            'duration' => 12,
            'user' => 'userone',
            'project' => ['ganeti-webmgr', 'gwm'],
            'activities' => ['docs', 'planning'],
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
    if not uuid
        p_list.push(
            Hash[
                'duration' => 13,
                'user' => 'usertwo',
                'project' => ['ganeti-webmgr', 'gwm'],
                'activities' => ['code', 'planning'],
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
                'project' => ['timesync', 'ts'],
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
    return p_list
end


def get_projects(slug)
    # Get project information from TimeSync
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
                'members' => [
                    'patcht',
                    'tschuy'
                ],
                'spectators' => [
                    'tschuy'
                ],
                'managers' => [
                    'tschuy'
                ]
            ]
        ]
    ]
    if not slug
        p_list.push(
            Hash[
                'uri' => 'https://code.osuosl.org/projects/timesync',
                'name' => 'TimeSync',
                'slugs' => ['timesync', 'ts'],
                'uuid' => 'a034806c-rrrr-bbbb-8de8-514575f31bfb',
                'revision' => 2,
                'created_at' => '2014-07-17',
                'deleted_at' => nil,
                'updated_at' => '2014-07-20',
                'users' => Hash[
                    'members' => [
                        'patcht',
                        'tschuy',
                        'mrsj'
                    ],
                    'spectators' => [
                        'tschuy',
                        'mrsj'
                    ],
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
                'slugs' => ['pymesync', 'ps'],
                'uuid' => 'a034806c-ssss-cccc-8de8-514575f31bfb',
                'revision' => 1,
                'created_at' => '2014-07-17',
                'deleted_at' => nil,
                'updated_at' => '2014-07-20',
                'users' => Hash[
                    'members' => [
                        'patcht',
                        'tschuy',
                        'mrsj',
                        'MaraJade',
                        'thai'
                    ],
                    'spectators' => [
                        'tschuy',
                        'mrsj'
                    ],
                    'managers' => [
                        'mrsj'
                    ]
                ]
            ]
        )
    end
    return p_list
end


def get_activities(slug)
    # Get activity information from TimeSync
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
    if not slug
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
    return p_list
end


def get_users(username)
    # Get user information from TimeSync
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
                'display_name' => 'Yes It''s The Saddest Experience',
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
                'display_name' => 'You''ll Ever Do',
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
    return p_dict
end


def delete_object
    # Delete an object from TimeSync
    return Array[Hash['status' => 200]]
end


def project_users
    # Return list of users and permissions from TimeSync
    users = Hash[
        'malcolm' => ['member', 'manager'],
        'jayne' =>   ['member'],
        'kaylee' =>  ['member'],
        'zoe' =>     ['member'],
        'hoban' =>   ['member'],
        'simon' =>   ['spectator'],
        'river' =>   ['spectator'],
        'derrial' => ['spectator'],
        'inara' =>   ['spectator']
    ]

    return users
end
