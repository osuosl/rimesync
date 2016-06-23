# rimesync - Ruby Port of rimesync

# Allows for interactions with the TimeSync API

# - authenticate(username, password, auth_type) - Authorizes user with TimeSync
# - token_expiration_time - Returns datetime expiration of user authentication
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
# v0

require 'json'
require_relative 'mock_rimesync'
require 'bcrypt'
require 'base64'
require 'rest-client'

# workaround for making `''.is_a? Boolean` work
module Boolean
end
class TrueClass;
  include Boolean;
end
class FalseClass;
  include Boolean;
end

# rubocop:disable ClassLength
class TimeSync # :nodoc:
  # rubocop:disable MethodLength
  def initialize(baseurl, token = nil, test = false)
    if baseurl.end_with? "/"
      @baseurl = baseurl.chop
    else
      @baseurl = baseurl
    end
    @user = nil
    @password = nil
    @auth_type = nil
    @token = token
    @error = 'rimesync error'
    @test = test

    @valid_get_queries = Array['user', 'project', 'activity',
                              'start', 'end', 'include_revisions',
                              'include_deleted', 'uuid']
    @required_params = Hash[
        'time' => %w(duration project user date_worked),
        'project' => %w(name slugs),
        'activity' => %w(name slug),
        'user' => %w(username password)
    ]
    @optional_params = Hash[
        'time' => %w(notes issue_uri activities),
        'project' => %w(uri users default_activity),
        'activity' => [],
        'user' => %w(display_name email site_admin site_spectator
        site_manager meta active)
    ]
  end

  # rubocop:disable MethodLength
  def authenticate(username = nil, password = nil, auth_type = nil)
    # authenticate(username, password, auth_type)

    # Authenticate a username and password with TimeSync via a POST request
    # to the login endpoint. This method will return a list containing a
    # single ruby hash. If successful, the hash will contain
    # the token in the form [{'token': 'SOMETOKEN'}]. If an error is returned
    # the hash will contain the error information.

    # ``username`` is a string containing the username of the TimeSync user
    # ``password`` is a string containing the user's password
    # ``auth_type`` is a string containing the authentication method used by
    # TimeSync

    # Check for correct arguments in method call
    arg_error_list = Array[]

    if username.nil?
      arg_error_list.push('username')
    end

    if password.nil?
      arg_error_list.push('password')
    end

    if auth_type.nil?
      arg_error_list.push('auth_type')
    end

    if !arg_error_list.empty?
      return Hash[@error => 'Missing %s; please add to method call' % Array[arg_error_list.join(', ')]]
    end

    arg_error_list.clear

    @user = username
    @password = password
    @auth_type = auth_type

    # Create the auth block to send to the login endpoint
    auth_hash = Hash['auth' => auth].to_json

    # Construct the url with the login endpoint
    url = '%s/login' % Array[@baseurl]


    # Test mode, set token and return it from the mocked method
    if @test
      @token = "TESTTOKEN"
      return mock_rimesync.authenticate
    end

    # Send the request, then convert the resonse to a ruby hash
    begin
      # Success!
      response = RestClient.post(url, auth_hash, :content_type => :json, :accept => :json)
      token_response = response_to_ruby(response.body, response.code)
    rescue => e
      # Request error
      return Hash[@error => e]
    end

    # If TimeSync returns an error, return the error without setting the
    # token.
    # Else set the token to the returned token and return the dict.
    if token_response.key?('error') || !token_response.key?('token')
      return token_response
    else
      @token = token_response['token']
      return token_response
    end
  end

  def create_time(time)
    # create_time

    # Send a time entry to TimeSync via a POST request in a JSON body. This
    # method will return that body in the form of a list containing a single
    # ruby hash. The hash will contain a representation of that
    # JSON body if it was successful or error information if it was not.

    # ``time`` is a ruby hash containing the time information to send
    # to TimeSync.

    unless time['duration'].is_a? Integer
      duration = duration_to_seconds(time['duration'])
      time['duration'] = duration

      # Duration at this point contains an error_msg if it's not an int
      unless time['duration'].is_a? Integer
        return duration
      end
    end

    if time['duration'] < 0
      return Hash[@error => 'time object: duration cannot be negative']
    end

    return create_or_update(time, nil, 'time', 'times')
  end

  def update_time(time, uuid)
    # update_time(time, uuid)

    # Send a time entry update to TimeSync via a POST request in a JSON body.
    # This method will return that body in the form of a list containing a
    # single ruby hash. The hash will contain a representation
    # of that updated time object if it was successful or error information
    # if it was not.

    # ``time`` is a ruby hash containing the time information to send
    # to TimeSync.
    # ``uuid`` contains the uuid for a time entry to update.
    if time.key?('duration')
      unless time['duration'].is_a? Integer
        duration = duration_to_seconds(time['duration'])
        time['duration'] = duration

        # Duration at this point contains an error_msg if not an int
        unless time['duration'].is_a? Integer
          return duration
        end
      end

      if time['duration'] < 0
        return Hash[@error => 'time object: duration cannot be negative']
      end

    end
    return create_or_update(time, uuid, 'time', 'times', false)
  end

  def create_project(project)
    # create_project(project)

    # Post a project to TimeSync via a POST request in a JSON body. This
    # method will return that body in the form of a list containing a single
    # ruby hash. The hash will contain a representation of that
    # JSON body if it was successful or error information if it was not.

    # ``project`` is a ruby hash containing the project information
    # to send to TimeSync.
    return create_or_update(project, nil, 'project', 'projects')
  end

  def update_project(project, slug)
    # update_project(project, slug)

    # Send a project update to TimeSync via a POST request in a JSON body.
    # This method will return that body in the form of a list containing a
    # single ruby hash. The hash will contain a representation
    # of that updated project object if it was successful or error
    # information if it was not.

    # ``project`` is a ruby hash containing the project information
    # to send to TimeSync.
    # ``slug`` contains the slug for a project entry to update.
    return create_or_update(project, slug, 'project', 'projects',
                            false)
  end

  def create_activity(activity)
    # create_activity(activity, slug=nil)

    # Post an activity to TimeSync via a POST request in a JSON body. This
    # method will return that body in the form of a list containing a single
    # ruby hash. The hash will contain a representation of that
    # JSON body if it was successful or error information if it was not.

    # ``activity`` is a ruby hash containing the activity information
    # to send to TimeSync.
    return create_or_update(activity, nil,
                            'activity', 'activities')
  end

  def update_activity(activity, slug)
    # update_activity(activity, slug)

    # Send an activity update to TimeSync via a POST request in a JSON body.
    # This method will return that body in the form of a list containing a
    # single ruby hash. The hash will contain a representation
    # of that updated activity object if it was successful or error
    # information if it was not.

    # ``activity`` is a ruby hash containing the project information
    # to send to TimeSync.
    # ``slug`` contains the slug for an activity entry to update.
    return create_or_update(activity, slug,
                            'activity', 'activities',
                            false)
  end

  def create_user(user)
    # create_user(user)

    # Post a user to TimeSync via a POST request in a JSON body. This
    # method will return that body in the form of a list containing a single
    # ruby hash. The hash will contain a representation of that
    # JSON body if it was successful or error information if it was not.

    # ``user`` is a ruby hash containing the user information to send
    # to TimeSync.
    ary = %w(site_admin site_manager site_spectator active)
    ary.each do |perm|
      if user.key?(perm) && !(user[perm].is_a? Boolean)
        return Hash[@error => 'user object: %s must be True or False' % perm]
      end
    end

    hash_user_password(user)
    return create_or_update(user, nil, 'user', 'users')
  end

  def update_user(user, username)
    # update_user(user, username)

    # Send a user update to TimeSync via a POST request in a JSON body.
    # This method will return that body in the form of a list containing a
    # single ruby hash. The hash will contain a representation
    # of that updated user object if it was successful or error
    # information if it was not.

    # ``user`` is a ruby hash containing the user information to send
    # to TimeSync.
    # ``username`` contains the username for a user to update.

    ary = %w(site_admin site_manager site_spectator active)
    ary.each do |perm|
      if user.key?(perm) && !(user[perm].is_a? Boolean)
        return Hash[@error => 'user object: %s must be True or False' % perm]
      end
    end

    hash_user_password(user)
    return create_or_update(user, username, 'user', 'users', false)
  end

  def get_times(query_parameters = nil)
    # get_times(query_parameters)

    # Request time entries filtered by parameters passed in
    # ``query_parameters``. Returns a list of ruby objects representing the
    # JSON time information returned by TimeSync or an error message if
    # unsuccessful.

    # ``query_parameters`` is a ruby hash containing the optional
    # query parameters described in the TimeSync documentation. If
    # ``query_parameters`` is empty or nil, ``get_times`` will return all
    # times in the database. The syntax for each argument is
    # ``{'query': ['parameter']}``.
    # Check that user has authenticated

    @local_auth_error = local_auth_error
    if @local_auth_error
      return [Hash[@error => @local_auth_error]]
    end

    # Check for key error
    if !query_parameters.nil?
      for key, value in query_parameters
        unless @valid_get_queries.include?(key)
          return [Hash[@error => 'invalid query: %s' % key]]
        end
      end
    end

    # Initialize the query string
    query_string = ''

    # If there are filtering parameters, construct them correctly.
    # Else reinitialize the query string to a ? so we can add the token.
    if !query_parameters.nil?
      query_string = construct_filter_query(query_parameters)
    else
      query_string = '?'
    end

    # Construct query url, at this point query_string ends with a ?
    url = '%s/times%stoken=%s' % Array[@baseurl, query_string, @token]

    # Test mode, return one or many objects depending on if uuid is passed
    if @test
      if !query_parameters.nil? && query_parameters.key?('uuid')
        return mock_rimesync.get_times(query_parameters['uuid'])
      else
        return mock_rimesync.get_times(nil)
      end
    end

    # Attempt to GET times, then convert the response to a ruby
    # hash. Always returns a list.
    begin
      # Success!
      response = RestClient.get url
      res_dict = response_to_ruby(response.body, response.code)
      return (res_dict.is_a?(Array) ? res_dict : [res_dict])
    rescue => e
      # Request Error
      return [Hash[@error => e]]
    end
  end

  def get_projects(query_parameters = nil)
    # get_projects(query_parameters)

    # Request project information filtered by parameters passed to
    # ``query_parameters``. Returns a list of ruby objects representing the
    # JSON project information returned by TimeSync or an error message if
    # unsuccessful.

    # ``query_parameters`` is a ruby dict containing the optional query
    # parameters described in the TimeSync documentation. If
    # ``query_parameters`` is empty or nil, ``get_projects`` will return
    # all projects in the database. The syntax for each argument is
    # ``{'query': 'parameter'}`` or ``{'bool_query': <boolean>}``.

    # Optional parameters:
    # 'slug': '<slug>'
    # 'include_deleted': <boolean>
    # 'revisions': <boolean>

    # Does not accept a slug combined with include_deleted, but does accept
    # any other combination.
    # Check that user has authenticated

    @local_auth_error = local_auth_error
    if @local_auth_error
      return [Hash[@error => @local_auth_error]]
    end

    # Save for passing to test mode since format_endpoints deletes
    # kwargs['slug'] if it exists
    if !query_parameters.to_s.empty? && query_parameters.key?('slug')
      slug = query_parameters['slug']
    else
      slug = nil
    end

    query_string = ''

    # If kwargs exist, create a correct query string
    # Else, prepare query_string for the token
    if !query_parameters.to_s.empty?
      query_string = format_endpoints(query_parameters)
      # If format_endpoints returns nil, it was passed both slug and
      # include_deleted, which is not allowed by the TimeSync API
      if query_string.nil?
        error_message = 'invalid combination: slug and include_deleted'
        return [Hash[@error => error_message]]
      end
    else
      query_string = '?token=%s' % @token
    end

    # Construct query url - at this point query_string ends with
    # ?token=token
    url = '%s/projects%s' % Array[@baseurl, query_string]

    # Test mode, return list of projects if slug is nil, or a single
    # project
    if @test
      return mock_rimesync.get_projects(slug)
    end

    # Attempt to GET projects, then convert the response to a ruby
    # hash. Always returns a list.
    begin
      # Success!
      response = RestClient.get url
      res_dict = response_to_ruby(response.body, response.code)
      return (res_dict.is_a?(Array) ? res_dict : [res_dict])
    rescue => e
      # Request Error
      return [Hash[@error => e]]
    end
  end

  def get_activities(query_parameters = nil)
    # get_activities(query_parameters)

    # Request activity information filtered by parameters passed to
    # ``query_parameters``. Returns a list of ruby objects representing
    # the JSON activity information returned by TimeSync or an error message
    # if unsuccessful.

    # ``query_parameters`` is a hash containing the optional query
    # parameters described in the TimeSync documentation. If
    # ``query_parameters`` is empty or nil, ``get_activities`` will
    # return all activities in the database. The syntax for each argument is
    # ``{'query': 'parameter'}`` or ``{'bool_query': <boolean>}``.

    # Optional parameters:
    # 'slug': '<slug>'
    # 'include_deleted': <boolean>
    # 'revisions': <boolean>

    # Does not accept a slug combined with include_deleted, but does accept
    # any other combination.
    # Check that user has authenticated
    @local_auth_error = local_auth_error
    if @local_auth_error
      return [Hash[@error => @local_auth_error]]
    end

    # Save for passing to test mode since format_endpoints deletes
    # kwargs['slug'] if it exists
    if !query_parameters.to_s.empty? && query_parameters.key?('slug')
      slug = query_parameters['slug']
    else
      slug = nil
    end

    query_string = ''

    # If kwargs exist, create a correct query string
    # Else, prepare query_string for the token
    if !query_parameters.to_s.empty?
      query_string = format_endpoints(query_parameters)
      # If format_endpoints returns nil, it was passed both slug and
      # include_deleted, which is not allowed by the TimeSync API
      if query_string.nil?
        error_message = 'invalid combination: slug and include_deleted'
        return [Hash[@error => error_message]]
      end
    else
      query_string = '?token=%s' % @token
    end

    # Construct query url - at this point query_string ends with
    # ?token=token
    url = '%s/activities%s' % Array[@baseurl, query_string]

    # Test mode, return list of projects if slug is nil, or a list of
    # projects
    if @test
      return mock_rimesync.get_activities(slug)
    end

    # Attempt to GET activities, then convert the response to a ruby
    # hash. Always returns a list.
    begin
      # Success!
      response = RestClient.get url
      res_dict = response_to_ruby(response.body, response.code)
      return (res_dict.is_a?(Array) ? res_dict : [res_dict])
    rescue => e
      # Request Error
      return [Hash[@error => e]]
    end
  end

  def get_users(username = nil)
    # get_users(username=nil)

    # Request user entities from the TimeSync instance specified by the
    # baseurl provided when instantiating the TimeSync object. Returns a list
    # of ruby dictionaries containing the user information returned by
    # TimeSync or an error message if unsuccessful.

    # ``username`` is an optional parameter containing a string of the
    # specific username to be retrieved. If ``username`` is not provided, a
    # list containing all users will be returned. Defaults to ``nil``.
    # Check that user has authenticated

    @local_auth_error = local_auth_error
    if @local_auth_error
      return [Hash[@error => @local_auth_error]]
    end

    # url should end with /users if no username is passed else
    # /users/username
    url = username ? '%s/users/%s' % [@baseurl, username] : '%s/users' % @baseurl

    # The url should always end with a token
    url += '?token=%s' % @token

    # Test mode, return one user object if username is passed else return
    # several user objects
    if @test
      return mock_rimesync.get_users(username)
    end

    # Attempt to GET users, then convert the response to a ruby
    # hash. Always returns a list.

    begin
      # Success!
      response = RestClient.get url
      res_dict = response_to_ruby(response.body, response.code)
      return (res_dict.is_a?(Array) ? res_dict : [res_dict])
    rescue => e
      # Request Error
      return [Hash[@error => e]]
    end
  end

  def delete_time(uuid = nil)
    # delete_time(uuid=nil)

    # Allows the currently authenticated user to delete their own time entry
    # by uuid.

    # ``uuid`` is a string containing the uuid of the time entry to be
    # deleted.
    # Check that user has authenticated
    @local_auth_error = local_auth_error
    if @local_auth_error
      return Hash[@error => @local_auth_error]
    end

    unless uuid
      return Hash[@error => 'missing uuid; please add to method call']
    end

    return delete_object('times', uuid)
  end

  def delete_project(slug = nil)
    # delete_project(slug=nil)

    # Allows the currently authenticated admin user to delete a project
    # record by slug.

    # ``slug`` is a string containing the slug of the project to be deleted.
    # Check that user has authenticated
    @local_auth_error = local_auth_error
    if @local_auth_error
      return Hash[@error => @local_auth_error]
    end

    unless slug
      return Hash[@error => 'missing slug; please add to method call']
    end

    return delete_object('projects', slug)
  end

  def delete_activity(slug = nil)
    # delete_activity(slug=nil)

    # Allows the currently authenticated admin user to delete an activity
    # record by slug.

    # ``slug`` is a string containing the slug of the activity to be deleted.
    # Check that user has authenticated
    @local_auth_error = local_auth_error
    if @local_auth_error
      return Hash[@error => @local_auth_error]
    end

    unless slug
      return Hash[@error => 'missing slug; please add to method call']
    end

    return delete_object('activities', slug)
  end

  def delete_user(username = nil)
    # delete_user(username=nil)

    # Allows the currently authenticated admin user to delete a user
    # record by username.

    # ``username`` is a string containing the username of the user to be
    # deleted.
    # Check that user has authenticated
    @local_auth_error = local_auth_error
    if @local_auth_error
      return Hash[@error => @local_auth_error]
    end

    unless username
      return Hash[@error =>
                      'missing username; please add to method call']
    end

    return delete_object('users', username)
  end

  def token_expiration_time
    # token_expiration_time
    # Returns the expiration time of the JWT (JSON Web Token) associated with
    # this object.
    # Check that user has authenticated
    @local_auth_error = local_auth_error
    if @local_auth_error
      return Hash[@error => @local_auth_error]
    end

    # Return valid date if in test mode
    if @test
      return mock_rimesync.token_expiration_time
    end

    # Decode the token, then get the second dict (payload) from the
    # resulting string. The payload contains the expiration time.
    begin
      decoded_payload = Base64.decode64(@token.split('.')[1])
    rescue
      return Hash[@error => 'improperly encoded token']
    end

    # literal_eval the string representation of a dict to convert it to a
    # dict, then get the value at 'exp'. The value at 'exp' is epoch time
    # in ms
    exp_int = JSON.load(decoded_payload)['exp'] # not sure about this

    # Convert the epoch time from ms to s
    exp_int /= 1000

    # Convert and format the epoch time to ruby datetime.
    exp_datetime = Time.at(exp_int)

    return exp_datetime
  end

  def project_users(project = nil)
    # project_users(project)

    # Returns a dict of users for the specified project containing usernames
    # mapped to their list of permissions for the project.
    # Check that user has authenticated
    @local_auth_error = local_auth_error
    if @local_auth_error
      return Hash[@error => @local_auth_error]
    end

    # Check that a project slug was passed
    unless project
      return Hash[@error => 'Missing project slug, please include in method call']
    end

    # Construct query url
    url = '%s/projects/%s?token=%s' % Array[@baseurl, project, @token]
    # Return valid user object if in test mode
    if @test
      return mock_rimesync.project_users
    end
    # Try to get the project object
    begin
      # Success!
      response = RestClient.get(url)
      project_object = response_to_ruby(response.body, response.code)
    rescue => e
      # Request Error
      return Hash[@error => e]
    end

    # Create the user dict to return
    # There was an error, don't do anything with it, return as a list
    if project_object.key?('error')
      return project_object
    end

    # Get the user object from the project
    users = project_object['users']

    # Convert the nested permissions dict to a list containing only
    # relevant (true) permissions

    rv = Hash.new

    for user, permissions in users
      rv_perms = Array[]
      for perm, value in permissions
        if value
          rv_perms.push(perm)
        end
      end
      rv[user] = rv_perms
    end

    rv
  end

  ################################################
  # Internal methods
  ################################################

  # private

  def auth
    # Returns auth object to log in to TimeSync
    Hash['type' => @auth_type,
         'username' => @user,
         'password' => @password]
  end

  def token_auth
    # Returns auth object with a token to send to TimeSync endpoints
    Hash['type' => 'token',
         'token' => @token,]
  end

  def local_auth_error
    # Checks that token is set.
    # Returns error if not set, otherwise returns nil
    return (@token ? nil : ('Not authenticated with TimeSync, call authenticate first'))
  end

  # Hashes the password field in a user object.
  # If the password is Unicode, encode it to UTF-8 first
  def hash_user_password(user)
    # Only hash password if it is present
    # Don't error out here so that internal methods can catch all missing
    # fields later on and return a more meaningful error if necessary.
    if user.key?(:password)
      password = user[:password]

      # Hash the password
      hashed = BCrypt::Password.create(:password)

      user[:password] = hashed
    end
  end

  def response_to_ruby(body, code)
    # Body should always be a string

    # Convert response to native ruby list of objects
    # DELETE returns an empty body if successful
    if body.empty? && code == 200
      return Hash['status' => 200]
    end
    # If body is valid JSON, it came from TimeSync. If it isn't
    # and we got a ValueError, we know we are having trouble connecting to
    # TimeSync because we are not getting a return from TimeSync.
    begin
      ruby_object = JSON.load(body)
    rescue => e
      # If we get a ValueError, body isn't a JSON object, and
      # therefore didn't come from a TimeSync connection.
      err_msg = 'connection to TimeSync failed at baseurl %s - ' % @baseurl
      err_msg += 'response status was %s' % code
      return Hash[@error => err_msg]
    end
    return ruby_object
  end

  # Format endpoints for GET projects and activities requests.
  # Returns nil if invalid combination of slug and include_deleted
  def format_endpoints(queries)
    query_string = '?'
    query_list = Array[]

    # The following combination is not allowed
    if queries.key?('slug') && queries.key?('include_deleted')
      return nil
      # slug goes first, then delete it so it doesn't show up after the ?
    elsif queries.key?('slug')
      # query_string = '/%s?' % queries['slug']
      query_string = format('/%s?', queries['slug'])
      queries.delete('slug')
    end

    # Convert true and false booleans to TimeSync compatible strings
    for k, v in queries.to_a
      queries[k] = v ? "true" : "false"
      query_list.push("%s=%s" % Array[k, queries[k]])
    end

    query_list = query_list.sort

    # Check for items in query_list after slug was removed, create
    # query string
    if query_list
      # query_string += '%s&' % query_list.join('&')
      query_string += format('%s&', query_list.join('&'))
    end
    # Authenticate and return
    # query_string += 'token=%s' % @token
    query_string += format('token=%s', @token)
    query_string
  end

  def construct_filter_query(queries)
    # Construct the query string for filtering GET queries, such as get_times
    query_string = '?'
    query_list = Array[]

    # Format the include_* queries similarly to other queries for easier
    # processing
    if queries.key?('include_deleted')
      queries['include_deleted'] = queries['include_deleted'] ?
                                    ['true'] : ['false']
    end

    if queries.key?('include_revisions')
      queries['include_revisions'] = (queries['include_revisions'] ? ['true'] : ['false'])
    end

    # If uuid is included, the only other accepted queries are the
    # include_*s
    if queries.key?('uuid')
      query_string = '/%s?' % queries['uuid']
      if queries.key?('include_deleted')
        # query_string += 'include_deleted=%s&' % queries['include_deleted'][0]
        query_string += format('include_deleted=%s&',
                               queries['include_deleted'][0])
      end

      if queries.key?('include_revisions')
        # query_string += 'include_revisions=%s&' % queries['include_revisions'][0]
        query_string += format('include_revisions=%s&',
                               queries['include_revisions'][0])
      end

      # Everthing is a list now, so iterate through and push
    else
      # Sort them into an alphabetized list for easier testing
      # sorted_qs = sorted(queries.to_a, key = operator.itemgetter(0))
      sorted_qs = queries.to_a.sort
      for query, param in sorted_qs
        for slug in param
          # Format each query in the list
          # query_list.push('%s=%s' % Array[query, slug])
          query_list.push(format('%s=%s', query, slug))
        end
      end

      # Construct the query_string using the list.
      # Last character will be an & so we can push the token
      for string in query_list
        query_string += '%s&' % string
      end
    end
    query_string
  end

  def get_field_errors(actual, object_name, create_object)
    # Checks that ``actual`` parameter passed to POST method contains
    # items in required or optional lists for that ``object_name``.
    # Returns nil if no errors found or error string if error found. If
    # ``create_object`` then ``actual`` gets checked for required fields
    # Check that actual is a ruby dict
    unless actual.is_a? (Hash)
      return '%s object: must be ruby hash' % object_name
    end

    # missing_list contains a list of all the required parameters that were
    # not passed. It is initialized to all required parameters.
    missing_list = @required_params[object_name].clone

    # For each key, if it is not required or optional, it is not allowed
    # If it is requried, remove that parameter from the missing_list, since
    # it is no longer missing
    # actual.each do |key, value|

    for key, value in actual
      if !@required_params[object_name].include?key.to_s and !@optional_params[object_name].include?key.to_s
        return '%s object: invalid field: %s' % Array[object_name, key]
      end

      # Remove field from copied list if the field is in required
      if @required_params[object_name].include? key.to_s
        # missing_list.delete(key.to_s)
        missing_list.delete_at(missing_list.index(key.to_s))
      end
    end

    # If there is anything in missing_list, it is an absent required field
    # This only needs to be checked if the create_object flag is passed
    if create_object && !missing_list.empty?
      return '%s object: missing required field(s): %s' % Array[
          object_name, missing_list.join(', ')]
    end
    # No errors if we made it this far
    nil
  end

  def create_or_update(object_fields, identifier,
                       object_name, endpoint, create_object = true)
    # Create or update an object ``object_name`` at specified ``endpoint``.
    # This method will return that object in the form of a list containing a
    # single ruby hash. The hash will contain a representation
    # of the JSON body returned by TimeSync if it was successful or error
    # information if it was not. If ``create_object``, then ``parameters``
    # gets checked for required fields.

    # Check that user has authenticated
    @local_auth_error = local_auth_error

    if @local_auth_error
      return Hash[@error => @local_auth_error]
    end

    # Check that object contains required fields and no bad fields
    field_error = get_field_errors(object_fields, object_name, create_object)

    if field_error
      return Hash[@error => field_error]
    end

    # Since this is a POST request, we need an auth and object objects
    values = Hash['auth' => token_auth, 'object' => object_fields].to_json


    # Reformat the identifier with the leading '/' so it can be added to
    # the url. Do this here instead of the url assignment below so we can
    # set it to ' if it wasn't passed.
    identifier = identifier ? '/%s' % identifier : ''

    # Construct url to post to
    url = '%s/%s%s' % Array[@baseurl, endpoint, identifier]

    # Test mode, remove leading '/' from identifier
    if @test
      return test_handler(object_fields, identifier.drop(1), object_name, create_object)
    end

    # Attempt to POST to TimeSync, then convert the response to a ruby
    # hash
    begin
      # Success!
      response = RestClient.post(url, values, :content_type => :json, :accept => :json)
      return response_to_ruby(response.body, response.code)
    rescue => e
      # Request error
      return Hash[@error => e]
    end
  end

  def duration_to_seconds(duration)
    # When a time_entry is created, a user will enter a time duration as
    # one of the parameters of the object. This method will convert that
    # entry (if it's entered as a string) into the appropriate integer
    # equivalent (in seconds).

    begin
      t = Time.strptime(duration, '%Hh%Mm')
      hours_spent = t.hour
      minutes_spent = t.min

      temp = "%sh%sm" % [hours_spent, minutes_spent]

      if temp != duration
          error_msg = [Hash[@error => "time object: invalid duration string"]]
          return error_msg
      end

      # Convert duration to seconds
      return (hours_spent * 3600) + (minutes_spent * 60)
    rescue
      error_msg = [Hash[@error => 'time object: invalid duration string']]
      return error_msg
    end
  end

  # Deletes object at ``endpoint`` identified by ``identifier``
  def delete_object(endpoint, identifier)
    # Construct url
    url = '%s/%s/%s?token=%s' % Array[@baseurl, endpoint, identifier, @token]

    # Test mode
    if @test
      return mock_rimesync.delete_object
    end

    # Attempt to DELETE object
    begin
      # Success!
      response = RestClient.delete url
      return response_to_ruby(response.body, response.code)
    rescue => e
      # Request error
      return Hash[@error => e]
    end
  end

  # Handle test methods in test mode for creating or updating an object
  def test_handler(parameters, identifier, obj_name, create_object)
    case obj_name

    when 'time'
      if create_object
        return mock_rimesync.create_time(parameters)
      else
        return mock_rimesync.update_time(parameters, identifier)
      end
    when 'project'
      if create_object
        return mock_rimesync.create_project(parameters)
      else
        return mock_rimesync.update_project(parameters, identifier)
      end
    when 'activity'
      if create_object
        return mock_rimesync.create_activity(parameters)
      else
        return mock_rimesync.update_activity(parameters, identifier)
      end
    when 'user'
      if create_object
        return mock_rimesync.create_user(parameters)
      else
        return mock_rimesync.update_user(parameters, identifier)
      end
    end
  end
end
