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

# import operator

require 'json'
require_relative 'mock_rimesync'
require 'bcrypt'
require 'base64'
require 'parsr'
require 'rest-client'

module Boolean; end   # workaround for making `''.is_a? Boolean` work
class TrueClass; include Boolean; end
class FalseClass; include Boolean; end

class TimeSync # :nodoc:
  def initialize(baseurl, token = nil, test = false)
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
      # single ruby dictionary. If successful, the dictionary will contain
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
                                  arg_error_list.join(", "))]
      end

      arg_error_list = nil

      @user = username
      @password = password
      @auth_type = auth_type

      # Create the auth block to send to the login endpoint
      @auth = Hash["auth" => auth()]   # not sure about this?

      # Construct the url with the login endpoint
      @url = "{}/login".format(baseurl)   # not sure about this?

      # Test mode, set token and return it from the mocked method
      if @test
          @token = "TESTTOKEN"
          return mock_rimesync.authenticate()
      end

      # Send the request, then convert the resonse to a ruby dictionary
      begin
          # Success!
          response = RestClient.post url auth.to_json  # not sure about this
          token_response = response_to_ruby(response)
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
      # ruby dictionary. The dictionary will contain a representation of that
      # JSON body if it was successful or error information if it was not.

      # ``time`` is a ruby dictionary containing the time information to send
      # to TimeSync.
      if time['duration'] < 0
          return Hash[error => "time object: duration cannot be negative"]
      end

      if not time['duration'].is_a? Integer
          duration = duration_to_seconds(time['duration'])
          time['duration'] = duration

          # Duration at this point contains an error_msg if it's not an int
          if not time['duration'].is_a? Integer
              return duration
          end
      end
      return create_or_update(time, nil, "time", "times")
  end

  def update_time(time, uuid)
      # update_time(time, uuid)

      # Send a time entry update to TimeSync via a POST request in a JSON body.
      # This method will return that body in the form of a list containing a
      # single ruby dictionary. The dictionary will contain a representation
      # of that updated time object if it was successful or error information
      # if it was not.

      # ``time`` is a ruby dictionary containing the time information to send
      # to TimeSync.
      # ``uuid`` contains the uuid for a time entry to update.
      if time.has_key?('duration')
          if time['duration'] < 0
              return Hash[error => "time object: duration cannot be negative"]
          end

          if not time['duration'].is_a? Integer
              duration = duration_to_seconds(time['duration'])
              time['duration'] = duration

              # Duration at this point contains an error_msg if not an int
              if not time['duration'].is_a? Integer
                  return duration
              end
          end
      end

      return create_or_update(time, uuid, "time", "times", false)
  end

  def create_project(project)
      # create_project(project)

      # Post a project to TimeSync via a POST request in a JSON body. This
      # method will return that body in the form of a list containing a single
      # ruby dictionary. The dictionary will contain a representation of that
      # JSON body if it was successful or error information if it was not.

      # ``project`` is a ruby dictionary containing the project information
      # to send to TimeSync.
      return create_or_update(project, nil, "project", "projects")
  end

  def update_project(project, slug)
      # update_project(project, slug)

      # Send a project update to TimeSync via a POST request in a JSON body.
      # This method will return that body in the form of a list containing a
      # single ruby dictionary. The dictionary will contain a representation
      # of that updated project object if it was successful or error
      # information if it was not.

      # ``project`` is a ruby dictionary containing the project information
      # to send to TimeSync.
      # ``slug`` contains the slug for a project entry to update.
      return create_or_update(project, slug, "project", "projects",
                                     false)
  end

  def create_activity(activity)
      # create_activity(activity, slug=nil)

      # Post an activity to TimeSync via a POST request in a JSON body. This
      # method will return that body in the form of a list containing a single
      # ruby dictionary. The dictionary will contain a representation of that
      # JSON body if it was successful or error information if it was not.

      # ``activity`` is a ruby dictionary containing the activity information
      # to send to TimeSync.
      return create_or_update(activity, nil,
                                     "activity", "activities")
  end

  def update_activity(activity, slug)
      # update_activity(activity, slug)

      # Send an activity update to TimeSync via a POST request in a JSON body.
      # This method will return that body in the form of a list containing a
      # single ruby dictionary. The dictionary will contain a representation
      # of that updated activity object if it was successful or error
      # information if it was not.

      # ``activity`` is a ruby dictionary containing the project information
      # to send to TimeSync.
      # ``slug`` contains the slug for an activity entry to update.
      return create_or_update(activity, slug,
                                     "activity", "activities",
                                     false)
  end

  def create_user(user)
      # create_user(user)

      # Post a user to TimeSync via a POST request in a JSON body. This
      # method will return that body in the form of a list containing a single
      # ruby dictionary. The dictionary will contain a representation of that
      # JSON body if it was successful or error information if it was not.

      # ``user`` is a ruby dictionary containing the user information to send
      # to TimeSync.
      for perm in ["site_admin", "site_manager", "site_spectator", "active"]
          if user.has_key?(perm) && !(user[perm].is_a? Boolean)
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
      return create_or_update(user, nil, "user", "users")
  end

  def update_user(user, username)
      # update_user(user, username)

      # Send a user update to TimeSync via a POST request in a JSON body.
      # This method will return that body in the form of a list containing a
      # single ruby dictionary. The dictionary will contain a representation
      # of that updated user object if it was successful or error
      # information if it was not.

      # ``user`` is a ruby dictionary containing the user information to send
      # to TimeSync.
      # ``username`` contains the username for a user to update.
      for perm in ["site_admin", "site_manager", "site_spectator", "active"]
          if user.has_key?(perm) && !(user[perm].is_a? Boolean)
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
      return create_or_update(user, username, "user", "users", false)
  end

  def get_times(query_parameters=nil)
      # get_times(query_parameters)

      # Request time entries filtered by parameters passed in
      # ``query_parameters``. Returns a list of ruby objects representing the
      # JSON time information returned by TimeSync or an error message if
      # unsuccessful.

      # ``query_parameters`` is a ruby dictionary containing the optional
      # query parameters described in the TimeSync documentation. If
      # ``query_parameters`` is empty or nil, ``get_times()`` will return all
      # times in the database. The syntax for each argument is
      # ``{"query": ["parameter"]}``.
      # Check that user has authenticated
      @local_auth_error = local_auth_error()
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
          query_string = construct_filter_query(@query_parameters)
      elsif
          query_string = "?"
      end

      # Construct query url, at this point query_string ends with a ?
      url = "{0}/times{1}token={2}".format(self.baseurl,
                                           query_string,
                                           self.token)

      # Test mode, return one or many objects depending on if uuid is passed
      if @test
          if @query_parameters && query_parameters.has_key?("uuid")
              return mock_rimesync.get_times(query_parameters["uuid"])
          elsif
              return mock_rimesync.get_times(nil)  # error
          end
      end

      # Attempt to GET times, then convert the response to a ruby
      # dictionary. Always returns a list.
      begin
          # Success!
          response = RestClient.get url
          res_dict = response_to_ruby(response)

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
      # ``query_parameters``. Returns a list of ruby objects representing the
      # JSON project information returned by TimeSync or an error message if
      # unsuccessful.

      # ``query_parameters`` is a ruby dict containing the optional query
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
      @local_auth_error = local_auth_error()
      if @local_auth_error
          return [Hash[error => local_auth_error]]
      end

      # Save for passing to test mode since format_endpoints deletes
      # kwargs["slug"] if it exists
      if @query_parameters && query_parameters.has_key?("slug")
          slug = query_parameters["slug"]
      elsif
          slug = nil
      end

      @query_string = ""

      # If kwargs exist, create a correct query string
      # Else, prepare query_string for the token
      if @query_parameters
          query_string = format_endpoints(query_parameters)
          # If format_endpoints returns nil, it was passed both slug and
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

      # Attempt to GET projects, then convert the response to a ruby
      # dictionary. Always returns a list.
      begin
          # Success!
          response = RestClient.get url
          res_dict = self.response_to_ruby(response)

          return  (res_dict.kind_of?(Array) ? res_dict : [res_dict])
      rescue Exception => e
          # Request Error
          return [Hash[error: e]]
      end
  end

  def get_activities(query_parameters=nil)
      # get_activities(query_parameters)

      # Request activity information filtered by parameters passed to
      # ``query_parameters``. Returns a list of ruby objects representing
      # the JSON activity information returned by TimeSync or an error message
      # if unsuccessful.

      # ``query_parameters`` is a dictionary containing the optional query
      # parameters described in the TimeSync documentation. If
      # ``query_parameters`` is empty or nil, ``get_activities()`` will
      # return all activities in the database. The syntax for each argument is
      # ``{"query": "parameter"}`` or ``{"bool_query": <boolean>}``.

      # Optional parameters:
      # "slug": "<slug>"
      # "include_deleted": <boolean>
      # "revisions": <boolean>

      # Does not accept a slug combined with include_deleted, but does accept
      # any other combination.
      # Check that user has authenticated
      @local_auth_error = local_auth_error()
      if @local_auth_error
          return [Hash[error => local_auth_error]]
      end

      # Save for passing to test mode since format_endpoints deletes
      # kwargs["slug"] if it exists
      if @query_parameters &&  query_parameters.has_key?("slug")
          slug = query_parameters["slug"]
      elsif
          slug = nil
      end

      @query_string = ""

      # If kwargs exist, create a correct query string
      # Else, prepare query_string for the token
      if @query_parameters
          query_string = format_endpoints(query_parameters)
          # If format_endpoints returns nil, it was passed both slug and
          # include_deleted, which is not allowed by the TimeSync API
          if query_string is nil
              error_message = "invalid combination: slug and include_deleted"
              return [Hash[error: error_message]]
          end
      elsif
          query_string = "?token={}".format(self.token)
      end

      # Construct query url - at this point query_string ends with
      # ?token=self.token
      url = "{0}/activities{1}".format(self.baseurl, query_string)

      # Test mode, return list of projects if slug is nil, or a list of
      # projects
      if test
          return mock_rimesync.get_activities(slug)
      end

      # Attempt to GET activities, then convert the response to a ruby
      # dictionary. Always returns a list.
      begin
          # Success!
          response = RestClient.get url
          res_dict = self.response_to_ruby(response)

          return  (res_dict.kind_of?(Array) ? res_dict : [res_dict])
      rescue Exception => e
          # Request Error
          return [Hash[error: e]]
      end
    end

  def get_users(username=nil)
      # get_users(username=nil)

      # Request user entities from the TimeSync instance specified by the
      # baseurl provided when instantiating the TimeSync object. Returns a list
      # of ruby dictionaries containing the user information returned by
      # TimeSync or an error message if unsuccessful.

      # ``username`` is an optional parameter containing a string of the
      # specific username to be retrieved. If ``username`` is not provided, a
      # list containing all users will be returned. Defaults to ``nil``.
      # Check that user has authenticated

      @local_auth_error = local_auth_error()
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

      # Attempt to GET users, then convert the response to a ruby
      # dictionary. Always returns a list.
      begin
          # Success!
          response = RestClient.get url
          res_dict = self.response_to_ruby(response)

                    return  (res_dict.kind_of?(Array) ? res_dict : [res_dict])
      rescue Exception => e
          # Request Error
          return [Hash[error => e]]
      end
  end

  def delete_time(uuid=nil)
      # delete_time(uuid=nil)

      # Allows the currently authenticated user to delete their own time entry
      # by uuid.

      # ``uuid`` is a string containing the uuid of the time entry to be
      # deleted.
      # Check that user has authenticated
      @local_auth_error = local_auth_error()
      if @local_auth_error
          return Hash[error => local_auth_error]
      end

      if not uuid
          return Hash[error => "missing uuid; please add to method call"]
      end

      return delete_object("times", uuid)
  end

  def delete_project(slug=nil)
      # delete_project(slug=nil)

      # Allows the currently authenticated admin user to delete a project
      # record by slug.

      # ``slug`` is a string containing the slug of the project to be deleted.
      # Check that user has authenticated
      @local_auth_error = local_auth_error()
      if @local_auth_error
          return Hash[error => local_auth_error]
      end

      if not @slug
          return Hash[error => "missing slug; please add to method call"]
      end

      return self.delete_object("projects", slug)
  end

  def delete_activity(slug=nil)
      # delete_activity(slug=nil)

      # Allows the currently authenticated admin user to delete an activity
      # record by slug.

      # ``slug`` is a string containing the slug of the activity to be deleted.
      # Check that user has authenticated
      local_auth_error = local_auth_error()
      if @local_auth_error
          return Hash[error => local_auth_error]
      end

      if not @slug
          return Hash[error: "missing slug; please add to method call"]
      end

      return delete_object("activities", slug)
  end

  def delete_user(username=nil)
      # delete_user(username=nil)

      # Allows the currently authenticated admin user to delete a user
      # record by username.

      # ``username`` is a string containing the username of the user to be
      # deleted.
      # Check that user has authenticated
      @local_auth_error = local_auth_error()
      if @local_auth_error
          return Hash[error => local_auth_error]
      end

      if not username
          return Hash[error =>
                  "missing username; please add to method call"]
      end

      return self.delete_object("users", username)
  end

  def token_expiration_time  # work on this
      # token_expiration_time()

      # Returns the expiration time of the JWT (JSON Web Token) associated with
      # this object.
      # Check that user has authenticated
      @local_auth_error = local_auth_error()
      if @local_auth_error
          return Hash[error => local_auth_error]
      end

      # Return valid date if in test mode
      if @test
          return mock_rimesync.token_expiration_time()
      end

      # Decode the token, then get the second dict (payload) from the
      # resulting string. The payload contains the expiration time.
      begin
          decoded_payload = Base64.decode64(token.split(".")[1])  # not sure about this
      rescue
          return Hash[error => "improperly encoded token"]
      end

      # literal_eval the string representation of a dict to convert it to a
      # dict, then get the value at 'exp'. The value at 'exp' is epoch time
      # in ms
      exp_int = Parsr.literal_eval(decoded_payload)['exp']  # not sure about this

      # Convert the epoch time from ms to s
      exp_int /= 1000

      # Convert and format the epoch time to ruby datetime.
      exp_datetime = Time.at(exp_int)

      return exp_datetime
  end

  def project_users(project=nil)
      # project_users(project)

      # Returns a dict of users for the specified project containing usernames
      # mapped to their list of permissions for the project.
      # Check that user has authenticated
      @local_auth_error = local_auth_error()
      if @local_auth_error
          return Hash[error => local_auth_error]
      end

      # Check that a project slug was passed
      if not project
          return Hash[error => "Missing project slug, please include in method call"]
      end

      # Construct query url
      url = "{0}/projects/{1}?token={2}".format(baseurl,
                                                project,token)
      # Return valid user object if in test mode
      if @test
          return mock_rimesync.project_users()
      end

      # Try to get the project object
      begin
          # Success!
          response = RestClient.get url
          project_object = response_to_ruby(response)
      rescue Exception => e
          # Request Error
          return Hash[error => e]
      end

      # Create the user dict to return
      # There was an error, don't do anything with it, return as a list
      if project_object.has_key?("error")
          return project_object
      end

      # Get the user object from the project
      users = project_object["users"]

      # Convert the nested permissions dict to a list containing only
      # relevant (true) permissions
      for user in users
          perm = Array[]
          for permission in users[user]
              if users[user][permission]
                  perm.push(permission)
          users[user] = perm
          end
      end

      return users
  end

###############################################################################
# Internal methods
###############################################################################

private

    def auth
      # Returns auth object to log in to TimeSync
      return Hash['type' => auth_type,
              'username' => user,
              'password' => password ]
    end


    def token_auth
      # Returns auth object with a token to send to TimeSync endpoints
      return Hash['type' => 'token',
              'token' => token, ]
    end

    def local_auth_error
      # Checks that self.token is set. Returns error if not set, otherwise returns nil
      return  (token ? nil : ("Not authenticated with TimeSync, call self.authenticate() first"))
    end

    def response_to_ruby(response)
      # Convert response to native ruby list of objects
      # DELETE returns an empty body if successful
        if not response.text && response.status_code == 200
            return Hash['status' => 200]
        end

        # If response.text is valid JSON, it came from TimeSync. If it isn't
        # and we got a ValueError, we know we are having trouble connecting to
        # TimeSync because we are not getting a return from TimeSync.
        begin
            ruby_object = json.load(unicode(response.text))
        rescue Exception => e
            # If we get a ValueError, response.text isn't a JSON object, and
            # therefore didn't come from a TimeSync connection.
            err_msg = "connection to TimeSync failed at baseurl {} - ".format(
                self.baseurl)
            err_msg += "response status was {}".format(response.status_code)
            return Hash[error => err_msg]
        end
        return ruby_object
    end

    def format_endpoints(queries)
        """Format endpoints for GET projects and activities requests. Returns
        nil if invalid combination of slug and include_deleted"""
        query_string = "?"
        query_list = Array[]

        # The following combination is not allowed
        if queries.has_key?("slug") && queries.has_key?("include_deleted")
            return nil
        # slug goes first, then delete it so it doesn't show up after the ?
        elsif queries.has_key?("slug")
            query_string = "/{}?".format(queries["slug"])
            queries["slug"] = nil
        end

        # Convert True and False booleans to TimeSync compatible strings
        for k, v in sorted(queries.items(), key=operator.itemgetter(0))   # will not work, research
            queries[k] = v ? "true" : "false"
            query_list.push("{0}={1}".format(k, queries[k]))
        end
        # Check for items in query_list after slug was removed, create
        # query string
        if query_list
            query_string += "{}&".format(query_list.join("&"))
        end
        # Authenticate and return
        query_string += "token={}".format(token)

        return query_string
    end

    def construct_filter_query(queries)  # work on this
      # Construct the query string for filtering GET queries, such as get_times()
      query_string = "?"
      query_list = Array[]

      # Format the include_* queries similarly to other queries for easier
      # processing
      if queries.has_key?("include_deleted")
          queries["include_deleted"] = queries["include_deleted"] ? ["true"] : ["false"]
      end

      if queries.has_key?("include_revisions")
          queries["include_revisions"] = (queries["include_revisions"] ? ["true"] : ["false"])
      end

      # If uuid is included, the only other accepted queries are the
      # include_*s
      if queries.has_key?("uuid")
          query_string = "/{}?".format(queries["uuid"])
          if queries.has_key?("include_deleted")
              query_string += "include_deleted={}&".format(
                  queries["include_deleted"][0])
          if queries.has_key?("include_revisions")
              query_string += "include_revisions={}&".format(
                  queries["include_revisions"][0])

      # Everthing is a list now, so iterate through and append
      else
          # Sort them into an alphabetized list for easier testing
          sorted_qs = sorted(queries.items(), key=operator.itemgetter(0))
          for query, param in sorted_qs
              for slug in param
                  # Format each query in the list
                  query_list.append("{0}={1}".format(query, slug))

          # Construct the query_string using the list.
          # Last character will be an & so we can append the token
          for string in query_list
              query_string += "{}&".format(string)

      return query_string

    def get_field_errors(actual, object_name, create_object)
        # Checks that ``actual`` parameter passed to POST method contains
        # items in required or optional lists for that ``object_name``.
        # Returns nil if no errors found or error string if error found. If
        # ``create_object`` then ``actual`` gets checked for required fields
        # Check that actual is a ruby dict
        if not actual.is_a? (Hash)
            return "{} object: must be ruby dictionary".format(object_name)
        end

        # missing_list contains a list of all the required parameters that were
        # not passed. It is initialized to all required parameters.
        missing_list = Array[required_params[object_name]]

        # For each key, if it is not required or optional, it is not allowed
        # If it is requried, remove that parameter from the missing_list, since
        # it is no longer missing
        for key, value in actual
            if !(required_params[object_name].include? (key))
                    && !(optional_params[object_name].include? (key))  # error
                return "{0} object: invalid field: {1}".format(object_name,
                                                               key)
            end
            # Remove field from copied list if the field is in required
            if self.required_params[object_name].include? (key)
                missing_list[missing_list.index(key)] = nil
            end
        end

        # If there is anything in missing_list, it is an absent required field
        # This only needs to be checked if the create_object flag is passed
        if create_object && missing_list
            return "{0} object: missing required field(s): {1}".format(
                object_name, missing_list.join(", "))
        end

        # No errors if we made it this far
        return nil
    end

    def create_or_update(object_fields, identifier,
                           object_name, endpoint, create_object=true)
        # Create or update an object ``object_name`` at specified ``endpoint``.
        # This method will return that object in the form of a list containing a
        # single ruby dictionary. The dictionary will contain a representation
        # of the JSON body returned by TimeSync if it was successful or error
        # information if it was not. If ``create_object``, then ``parameters``
        # gets checked for required fields.

        # Check that user has authenticated
        @local_auth_error = local_auth_error()
        if @local_auth_error
            return Hash[error => local_auth_error]
        end

        # Check that object contains required fields and no bad fields
        @field_error = get_field_errors(object_fields,
                                              object_name,
                                              create_object)
        if @field_error
            return Hash[error => field_error]
        end

        # Since this is a POST request, we need an auth and object objects
        @values = Hash['auth' => token_auth(), 'object' => object_fields]

        # Reformat the identifier with the leading '/' so it can be added to
        # the url. Do this here instead of the url assignment below so we can
        # set it to "" if it wasn't passed.
        @identifier = identifier ? "/{}".format(identifier) : ""

        # Construct url to post to
        @url = "{0}/{1}{2}".format(self.baseurl, endpoint, identifier)

        # Test mode, remove leading '/' from identifier
        if test
            return test_handler(object_fields, identifier.drop(1),
                                       object_name, create_object)
        end

        # Attempt to POST to TimeSync, then convert the response to a ruby
        # dictionary
        begin
            # Success!
            response = RestClient.post url value.to_json
            return self.response_to_ruby(response)
        rescue Exception => e
            # Request error
            return Hash[error => e]
        end
    end

    def duration_to_seconds(duration)
        """When a time_entry is created, a user will enter a time duration as
           one of the parameters of the object. This method will convert that
           entry (if it's entered as a string) into the appropriate integer
           equivalent (in seconds).
        """
        begin
            t = Time.strptime(duration, "%Hh%Mm")
            hours_spent = t.hour
            minutes_spent = t.min

            # Convert duration to seconds
            return (hours_spent * 3600) + (minutes_spent * 60)
        rescue
            error_msg = [Hash[error => "time object: invalid duration string"]]
            return error_msg
        end
    end

    def delete_object(endpoint, identifier)
      # Deletes object at ``endpoint`` identified by ``identifier``

        # Construct url
        url = "{0}/{1}/{2}?token={3}".format(baseurl,
                                             endpoint,
                                             identifier,
                                             token)

        # Test mode
        if @test
            return mock_rimesync.delete_object()
        end

        # Attempt to DELETE object
        begin
            # Success!
            response = RestClient.delete url
            return response_to_ruby(response)
        except Exception e
            # Request error
            return Hash[error => e]
        end
    end

    def test_handler(parameters, identifier, obj_name, create_object)
      #Handle test methods in test mode for creating or updating an object

        case obj_name

        when "time"
            if create_object
                return mock_rimesync.create_time(parameters)
            else
                return mock_rimesync.update_time(parameters, identifier)
            end
        when "project"
            if create_object
                return mock_rimesync.create_project(parameters)
            else
                return mock_rimesync.update_project(parameters, identifier)
            end
        when "activity"
            if create_object
                return mock_rimesync.create_activity(parameters)
            else
                return mock_rimesync.update_activity(parameters, identifier)
            end
        when "user"
            if create_object
                return mock_rimesync.create_user(parameters)
            else
                return mock_rimesync.update_user(parameters, identifier)
            end
        end
    end
  end

