# rimesync - Ruby Port of rimesync

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

require 'json'
require_relative 'mock_rimesync'
require 'bcrypt'

module Boolean; end   # workaround for making `''.is_a? Boolean` work
class TrueClass; include Boolean; end
class FalseClass; include Boolean; end

class TimeSync # :nodoc:
  def initialize(baseurl, token = nil, test = False)
    @baseurl = baseurl # passing val. of local var. to instance var.
    @user = nil
    @password = nil
    @auth_type = nil
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

  def authenticate(username = nil, password = nil, auth_type = nil)
      # authenticate(username, password, auth_type)

      # Authenticate a username and password with TimeSync via a POST request
      # to the login endpoint. This method will return a list containing a
      # single python dictionary. If successful, the dictionary will contain
      # the token in the form [{"token": "SOMETOKEN"}]. If an error is returned
      # the dictionary will contain the error information.

      # ``username`` is a string containing the username of the TimeSync user
      # ``password`` is a string containing the user's password
      # ``auth_type`` is a string containing the authentication method used by
      # TimeSync

      # Check for correct arguments in method call
      arg_error_list = Array[]

      if not @username
          arg_error_list.push("username")
      end

      if not @password
          arg_error_list.push("password")
      end

      if not @auth_type
          arg_error_list.push("auth_type")
      end

      if @arg_error_list
          return Hash[error => "Missing {}; please add to method call".format(
                                  ", ".join(arg_error_list))]
      end

      arg_error_list = nil

      @user = username
      @password = password
      @auth_type = auth_type

      # Create the auth block to send to the login endpoint
      @auth = Hash["auth" => __auth()]   # not sure about this?

      # Construct the url with the login endpoint
      @url = "{}/login".format(baseurl)   # not sure about this?

      # Test mode, set token and return it from the mocked method
      if @test
          @token = "TESTTOKEN"
          return mock_rimesync.authenticate()
      end

      # Send the request, then convert the resonse to a python dictionary
      begin
          # Success!
          response = requests.post(url, json=auth)
          token_response = self.__response_to_python(response)
      rescue Exception => e
          # Request error
          return Hash[error => e]
      end

      # If TimeSync returns an error, return the error without setting the
      # token.
      # Else set the token to the returned token and return the dict.
      if token_response.has_key?("error") or !(token_response.has_key?("token"))
          return token_response
      else
          token = token_response["token"]
          return token_response
      end
  end
  def create_time(time)
      # create_time

      # Send a time entry to TimeSync via a POST request in a JSON body. This
      # method will return that body in the form of a list containing a single
      # python dictionary. The dictionary will contain a representation of that
      # JSON body if it was successful or error information if it was not.

      # ``time`` is a python dictionary containing the time information to send
      # to TimeSync.
      if time['duration'] < 0
          return Hash[error => "time object: duration cannot be negative"]
      end

      if not time['duration'].is_a? Integer
          duration = __duration_to_seconds(time['duration'])
          time['duration'] = duration

          # Duration at this point contains an error_msg if it's not an int
          if not time['duration'].is_a? Integer
              return duration
          end
      end
      return __create_or_update(time, nil, "time", "times")
  end
  def update_time(time, uuid)
      # update_time(time, uuid)

      # Send a time entry update to TimeSync via a POST request in a JSON body.
      # This method will return that body in the form of a list containing a
      # single python dictionary. The dictionary will contain a representation
      # of that updated time object if it was successful or error information
      # if it was not.

      # ``time`` is a python dictionary containing the time information to send
      # to TimeSync.
      # ``uuid`` contains the uuid for a time entry to update.
      if time.has_key?('duration')
          if time['duration'] < 0
              return Hash[error => "time object: duration cannot be negative"]
          end

          if not time['duration'].is_a? Integer
              duration = __duration_to_seconds(time['duration'])
              time['duration'] = duration

              # Duration at this point contains an error_msg if not an int
              if not time['duration'].is_a? Integer
                  return duration
              end
          end
      end

      return __create_or_update(time, uuid, "time", "times", False)
  end
  def create_project(project)
      # create_project(project)

      # Post a project to TimeSync via a POST request in a JSON body. This
      # method will return that body in the form of a list containing a single
      # python dictionary. The dictionary will contain a representation of that
      # JSON body if it was successful or error information if it was not.

      # ``project`` is a python dictionary containing the project information
      # to send to TimeSync.
      return __create_or_update(project, nil, "project", "projects")
  end
  def update_project(project, slug)
      # update_project(project, slug)

      # Send a project update to TimeSync via a POST request in a JSON body.
      # This method will return that body in the form of a list containing a
      # single python dictionary. The dictionary will contain a representation
      # of that updated project object if it was successful or error
      # information if it was not.

      # ``project`` is a python dictionary containing the project information
      # to send to TimeSync.
      # ``slug`` contains the slug for a project entry to update.
      return __create_or_update(project, slug, "project", "projects",
                                     False)
  end
  def create_activity(activity)
      # create_activity(activity, slug=nil)

      # Post an activity to TimeSync via a POST request in a JSON body. This
      # method will return that body in the form of a list containing a single
      # python dictionary. The dictionary will contain a representation of that
      # JSON body if it was successful or error information if it was not.

      # ``activity`` is a python dictionary containing the activity information
      # to send to TimeSync.
      return __create_or_update(activity, nil,
                                     "activity", "activities")
  end

  def update_activity(activity, slug)
      # update_activity(activity, slug)

      # Send an activity update to TimeSync via a POST request in a JSON body.
      # This method will return that body in the form of a list containing a
      # single python dictionary. The dictionary will contain a representation
      # of that updated activity object if it was successful or error
      # information if it was not.

      # ``activity`` is a python dictionary containing the project information
      # to send to TimeSync.
      # ``slug`` contains the slug for an activity entry to update.
      return __create_or_update(activity, slug,
                                     "activity", "activities",
                                     False)
  end
  def create_user(user)
      # create_user(user)

      # Post a user to TimeSync via a POST request in a JSON body. This
      # method will return that body in the form of a list containing a single
      # python dictionary. The dictionary will contain a representation of that
      # JSON body if it was successful or error information if it was not.

      # ``user`` is a python dictionary containing the user information to send
      # to TimeSync.
      for perm in ["site_admin", "site_manager", "site_spectator", "active"]
          if user.has_key?(perm) and !(user[perm].is_a? Boolean)
              return Hash[error => "user object: {} must be True or False".format(perm)]
          end
      end

      # Only hash password if it is present
      # Don't error out here so that internal methods can catch all missing
      # fields later on and return a more meaningful error if necessary.
      if user.has_key?("password")
          # Hash the password
          password = user["password"]
          hashed = BCrypt::Password.create(password)
          user["password"] = hashed
      end
      return __create_or_update(user, nil, "user", "users")
  end
  def update_user(user, username)
      # update_user(user, username)

      # Send a user update to TimeSync via a POST request in a JSON body.
      # This method will return that body in the form of a list containing a
      # single python dictionary. The dictionary will contain a representation
      # of that updated user object if it was successful or error
      # information if it was not.

      # ``user`` is a python dictionary containing the user information to send
      # to TimeSync.
      # ``username`` contains the username for a user to update.
      for perm in ["site_admin", "site_manager", "site_spectator", "active"]
          if user.has_key?(perm) and !(user[perm].is_a? Boolean)
              return Hash[error => "user object: {} must be True or False".format(perm)]
          end
      end

      # Only hash password if it is present
      # Don't error out here so that internal methods can catch all missing
      # fields later on and return a more meaningful error if necessary.
      if user.has_key?("password")
          # Hash the password
          password = user["password"]
          hashed = BCrypt::Password.create(password)
          user["password"] = hashed
      end
      return __create_or_update(user, username, "user", "users", False)
  end
  def get_times(query_parameters=nil)
      # get_times(query_parameters)

      # Request time entries filtered by parameters passed in
      # ``query_parameters``. Returns a list of python objects representing the
      # JSON time information returned by TimeSync or an error message if
      # unsuccessful.

      # ``query_parameters`` is a python dictionary containing the optional
      # query parameters described in the TimeSync documentation. If
      # ``query_parameters`` is empty or nil, ``get_times()`` will return all
      # times in the database. The syntax for each argument is
      # ``{"query": ["parameter"]}``.
      # Check that user has authenticated
      @local_auth_error = __local_auth_error()
      if @local_auth_error
          return [Hash[error => local_auth_error]]
      end

      # Check for key error
      if @query_parameters
          for key, value in query_parameters
              if !(valid_get_queries.include?(key))
                  return [Hash[error => "invalid query: {}".format(key)]]
              end
          end
      end

      # Initialize the query string
      query_string = ""

      # If there are filtering parameters, construct them correctly.
      # Else reinitialize the query string to a ? so we can add the token.
      if @query_parameters
          query_string = __construct_filter_query(@query_parameters)
      elsif
          query_string = "?"
      end

      # Construct query url, at this point query_string ends with a ?
      url = "{0}/times{1}token={2}".format(self.baseurl,
                                           query_string,
                                           self.token)

      # Test mode, return one or many objects depending on if uuid is passed
      if @test
          if @query_parameters and query_parameters.has_key?("uuid")
              return mock_rimesync.get_times(query_parameters["uuid"])
          elsif
              return mock_rimesync.get_times(nil)  # something wrong here
          end
      end

      # Attempt to GET times, then convert the response to a python
      # dictionary. Always returns a list.
      begin
          # Success!
          response = requests.get(url)
          res_dict = self.__response_to_python(response)

          # return [res_dict] if type(res_dict) is not list else res_dict
          return  (res_dict.kind_of?(Array) ? res_dict : [res_dict])
      rescue Exception => e
          # Request Error
          return [Hash[error => e]]
      end
  end
  def get_projects(query_parameters=nil)
      # get_projects(query_parameters)

      # Request project information filtered by parameters passed to
      # ``query_parameters``. Returns a list of python objects representing the
      # JSON project information returned by TimeSync or an error message if
      # unsuccessful.

      # ``query_parameters`` is a python dict containing the optional query
      # parameters described in the TimeSync documentation. If
      # ``query_parameters`` is empty or nil, ``get_projects()`` will return
      # all projects in the database. The syntax for each argument is
      # ``{"query": "parameter"}`` or ``{"bool_query": <boolean>}``.

      # Optional parameters:
      # "slug": "<slug>"
      # "include_deleted": <boolean>
      # "revisions": <boolean>

      # Does not accept a slug combined with include_deleted, but does accept
      # any other combination.
      # Check that user has authenticated
      @local_auth_error = __local_auth_error()
      if @local_auth_error
          return [Hash[error => local_auth_error]]
      end

      # Save for passing to test mode since __format_endpoints deletes
      # kwargs["slug"] if it exists
      if @query_parameters and query_parameters.has_key?("slug")
          slug = query_parameters["slug"]
      elsif
          slug = nil
      end

      @query_string = ""

      # If kwargs exist, create a correct query string
      # Else, prepare query_string for the token
      if @query_parameters
          query_string = __format_endpoints(query_parameters)
          # If __format_endpoints returns nil, it was passed both slug and
          # include_deleted, which is not allowed by the TimeSync API
          if query_string is nil
              error_message = "invalid combination: slug and include_deleted"
              return [Hash[error: error_message]]
      elsif
          query_string = "?token={}".format(self.token)
      end

      # Construct query url - at this point query_string ends with
      # ?token=self.token
      url = "{0}/projects{1}".format(baseurl, query_string)

      # Test mode, return list of projects if slug is nil, or a single
      # project
      if @test
          return mock_rimesync.get_projects(slug)
      end

      # Attempt to GET projects, then convert the response to a python
      # dictionary. Always returns a list.
      begin
          # Success!
          response = requests.get(url)
          res_dict = self.__response_to_python(response)

          return  (res_dict.kind_of?(Array) ? res_dict : [res_dict])
      rescue Exception => e
          # Request Error
          return [Hash[error: e]]
      end
  end
  def get_activities(query_parameters=None)
      # get_activities(query_parameters)

      # Request activity information filtered by parameters passed to
      # ``query_parameters``. Returns a list of python objects representing
      # the JSON activity information returned by TimeSync or an error message
      # if unsuccessful.

      # ``query_parameters`` is a dictionary containing the optional query
      # parameters described in the TimeSync documentation. If
      # ``query_parameters`` is empty or None, ``get_activities()`` will
      # return all activities in the database. The syntax for each argument is
      # ``{"query": "parameter"}`` or ``{"bool_query": <boolean>}``.

      # Optional parameters:
      # "slug": "<slug>"
      # "include_deleted": <boolean>
      # "revisions": <boolean>

      # Does not accept a slug combined with include_deleted, but does accept
      # any other combination.
      # Check that user has authenticated
      @local_auth_error = __local_auth_error()
      if @local_auth_error
          return [Hash[error => local_auth_error]]
      end

      # Save for passing to test mode since __format_endpoints deletes
      # kwargs["slug"] if it exists
      if @query_parameters and  query_parameters.has_key?("slug")
          slug = query_parameters["slug"]
      elsif
          slug = None
      end

      @query_string = ""

      # If kwargs exist, create a correct query string
      # Else, prepare query_string for the token
      if @query_parameters
          query_string = __format_endpoints(query_parameters)
          # If __format_endpoints returns None, it was passed both slug and
          # include_deleted, which is not allowed by the TimeSync API
          if query_string is nil
              error_message = "invalid combination: slug and include_deleted"
              return [Hash[error: error_message]]
      elsif
          query_string = "?token={}".format(self.token)
      end

      # Construct query url - at this point query_string ends with
      # ?token=self.token
      url = "{0}/activities{1}".format(self.baseurl, query_string)

      # Test mode, return list of projects if slug is None, or a list of
      # projects
      if test
          return mock_rimesync.get_activities(slug)
      end

      # Attempt to GET activities, then convert the response to a python
      # dictionary. Always returns a list.
      begin
          # Success!
          response = requests.get(url)
          res_dict = self.__response_to_python(response)

          return  (res_dict.kind_of?(Array) ? res_dict : [res_dict])
      rescue Exception => e
          # Request Error
          return [Hash[error: e]]
      end
  def get_users(username=None)
      # get_users(username=None)

      # Request user entities from the TimeSync instance specified by the
      # baseurl provided when instantiating the TimeSync object. Returns a list
      # of python dictionaries containing the user information returned by
      # TimeSync or an error message if unsuccessful.

      # ``username`` is an optional parameter containing a string of the
      # specific username to be retrieved. If ``username`` is not provided, a
      # list containing all users will be returned. Defaults to ``None``.
      # Check that user has authenticated

      @local_auth_error = __local_auth_error()
      if @local_auth_error
          return [Hash[error => local_auth_error]]
      end

      # url should end with /users if no username is passed else
      # /users/username
      url = username ? "{0}/users/{1}".format(self.baseurl, username) : ("{}/users".format(self.baseurl))

      # The url should always end with a token
      url += "?token={}".format(self.token)

      # Test mode, return one user object if username is passed else return
      # several user objects
      if @test
          return mock_rimesync.get_users(username)
      end

      # Attempt to GET users, then convert the response to a python
      # dictionary. Always returns a list.
      begin
          # Success!
          response = requests.get(url)
          res_dict = self.__response_to_python(response)

                    return  (res_dict.kind_of?(Array) ? res_dict : [res_dict])
      rescue Exception => e
          # Request Error
          return [Hash[error => e]]
      end
  end
  def delete_time(uuid=None)
      # delete_time(uuid=None)

      # Allows the currently authenticated user to delete their own time entry
      # by uuid.

      # ``uuid`` is a string containing the uuid of the time entry to be
      # deleted.
      # Check that user has authenticated
      @local_auth_error = __local_auth_error()
      if @local_auth_error
          return Hash[error => local_auth_error]
      end

      if not uuid
          return Hash[error => "missing uuid; please add to method call"]
      end

      return __delete_object("times", uuid)
  end

  def delete_project(slug=None)
      # delete_project(slug=None)

      # Allows the currently authenticated admin user to delete a project
      # record by slug.

      # ``slug`` is a string containing the slug of the project to be deleted.
      # Check that user has authenticated
      @local_auth_error = __local_auth_error()
      if @local_auth_error
          return Hash[error => local_auth_error]
      end

      if not @slug
          return Hash[error => "missing slug; please add to method call"]
      end

      return self.__delete_object("projects", slug)
  end

  def delete_activity(slug=None)
      # delete_activity(slug=None)

      # Allows the currently authenticated admin user to delete an activity
      # record by slug.

      # ``slug`` is a string containing the slug of the activity to be deleted.
      # Check that user has authenticated
      local_auth_error = __local_auth_error()
      if @local_auth_error
          return Hash[error => local_auth_error]
      end

      if not @slug
          return Hash[error: "missing slug; please add to method call"]
      end

      return __delete_object("activities", slug)
  end

  def delete_user(username=None)
      # delete_user(username=None)

      # Allows the currently authenticated admin user to delete a user
      # record by username.

      # ``username`` is a string containing the username of the user to be
      # deleted.
      # Check that user has authenticated
      @local_auth_error = __local_auth_error()
      if @local_auth_error
          return Hash[error => local_auth_error]
      end

      if not username
          return Hash[error =>
                  "missing username; please add to method call"]
      end

      return self.__delete_object("users", username)
  end
end

