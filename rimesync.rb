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

require 'json'
require_relative 'mock_rimesync'

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
      return __create_or_update(time, None, "time", "times")
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
end

