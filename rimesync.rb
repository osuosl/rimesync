# rimesync - Ruby Port of Pymesync

# Allows for interactions with the TimeSync API

# - authenticate(username, password, auth_type) - Authorizes user with TimeSync
# - token_expiration_time() - Returns datetime expiration of user authentication
# - create_time(time) - Sends time to baseurl (TimeSync)
# - update_time(time, uuid) - Updates time by uuid
# - create_project(project) - Creates project
# - update_project(project, slug) - Updates project by slug
# - create_activity(activity) - Creates activity
# - update_activity(activity, slug) - Updates activity by slug
# - create_user(user) - Creates a user
# - update_user(user, username) - Updates user by username
# - get_times(query_parameters) - Get times from TimeSync
# - get_projects(query_parameters) - Get project information from TimeSync
# - get_activities(query_parameters) - Get activity information from TimeSync
# - get_users(username) - Get user information from TimeSync

# Supported TimeSync versions:
# v1

class Rimesync # :nodoc:
  def initialize(baseurl, token = None, test = False)
    @baseurl = baseurl # passing val. of local var. to instance var.
    @user = None
    @password = None
    @auth_type = None
    @token = token
    @error = 'rimesync error'
    @test = test

    valid_get_queries = Array['user', 'project', 'activity',
                              'start', 'end', 'include_revisions',
                              'include_deleted', 'uuid']
    required_params = Hash[
            'time' => %w(['duration', 'project', 'user',
                     'activities', 'date_worked']),
            'project' => %w(['name', 'slugs']),
            'activity' => %w(['name', 'slug']),
            'user' => %w(['username', 'password'])
        ]
    optional_params = Hash[
            'time' => %w(['notes', 'issue_uri']),
            'project' => %w(['uri', 'users']),
            'activity' => [],
            'user' => %w(['displayname', 'email', 'admin','spectator',
                          'manager', 'admin', 'meta', 'active'])
        ]
  end
end
