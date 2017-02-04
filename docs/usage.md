rimesync - Ruby gem to communicate with a TimeSync API
======================================================


This gem provides an interface to communicate with an implementation of the
[OSU Open Source Lab's](http://www.osuosl.org) [TimeSync API](http://timesync.readthedocs.org/en/latest/). An implementation of the TimeSync API,
built in Node.js, can be found [here](https://github.com/osuosl/timesync-node).

Rimesync uses ruby version 2.2.1

This gem allows users to

* Authenticate a rimesync object with a TimeSync implementation
  (**authenticate**)
* Send times, projects, activities, and users to TimeSync (**create_time**,
  **create_project**, **create_activity**, **create_user**),
* Update times, projects, activities, and users (**update_time**,
  **update_project**, **update_activity**, **update_user**)
* Get one or a list of times projects, activities, and users (**get_times**,
  **get_projects**, **get_activities**, **get_users**)
* Delete an object in the TimeSync database (**delete_time**,
  **delete_project**, **delete_activity**, **delete_user**)

Rimesync currently supports the following TimeSync API versions:

* v1

All of these methods return a list of one or more ruby hashes (or an empty list if TimeSync has no records).

* **authenticate(username, password, auth_type)** - Authenticates a rimesync
  object with a TimeSync implementation

 <br /> 

* **create_time(time)** - Sends time to TimeSync baseurl set in
  constructor
* **create_project(project)** - Send new project to TimeSync
* **create_activity(activity)** - Send new activity to TimeSync
* **create_user(user)** - Send a new user to TimeSync

 <br /> 

* **update_time(time, uuid)** - Update time entry specified by uuid
* **update_project(project, slug)** - Update project specified by slug
* **update_activity(activity, slug)** - Update activity specified by slug
* **update_user(user, username)** - Update user specified by username

 <br /> 

* **get_times(query_parameters)** - Get times from TimeSync
* **get_projects(query_parameters)** - Get project information from TimeSync
* **get_activities(query_parameters)** - Get activity information from TimeSync
* **get_users(username=nil)** - Get user information from TimeSync

 <br /> 

* **delete_time(uuid)** - Delete time entry from TimeSync
* **delete_project(slug)** - Delete project record from TimeSync
* **delete_activity(slug)** - Delete activity record from TimeSync
* **delete_user(username)** - Delete user record from TimeSync

Install Rimesync
----------------

In future one could simply gem install rimesync, but as of now you'll need to do the following - 


`$ git clone https://github.com/osuosl/rimesync`
`$ cd rimesync`
`$ bundle install`
`$ gem build rimesync.gemspec`
`$ gem install ./rimesync-0.1.0.gem`

If you don't get any errors just open up an interactive ruby session and try - 

`$ irb`
`>> require 'rimesync'`
`=> true`

You should get `true`.

Initiate and Authenticate a TimeSync object
-------------------------------------------

To access rimesync's public methods you must first initiate a TimeSync object

```ruby

require `rimesync`

ts = TimeSync.new(baseurl = "http://ts.example.com/v1")
ts.authenticate(username = "user",password = "password",auth_type = "password")
```

Where

* `baseurl` is a string containing the url of the TimeSync instance you will
  communicate with. This must include the version endpoint (example
  `"http://ts.example.com/v1"`)
* `user` is a string containing the username of the user communicating with
  TimeSync
* `password` is a string containing the user's password
* `auth_type` is a string containing the type of authentication your TimeSync
  implementation uses for login, such as ``"password"``, or ``"ldap"``.

You can also optionally include a token in the constructor like so:

```ruby
require 'rimesync'

ts = TimeSync.new(baseurl="http://ts.example.com/v1", token="SOMETOKENYOUGOTEARLIER")
# ts.authenticate is not required
```

This is handy when state is not kept between different parts of your system, but you don't want to have to re-authenticate your TimeSync object for every section of code.


Note: If you attempt to get, create, or update objects before authenticating,
      rimesync will return this error:

```ruby
[{"
  rimesync error"=> "Not authenticated with TimeSync, call self.authenticate first"}]
```


Errors
------

Rimesync returns errors the same way it returns successes for whatever method
is in use. This means that most of the time errors are returned as a ruby
hash, except in the case of get methods. If the error is a local rimesync
error, the key for the error message will be `"rimesync error"`. If the error
is from TimeSync, the hash will contain the same keys described in the
[TimeSync error documentation](http://timesync.readthedocs.org/en/latest/draft_errors.html), but as a ruby hash.

If there is an error connecting with the TimeSync instance specified by the
baseurl passed to the rimesync constructor, the error will also contain the
status code of the response.

An example for a method that returns a hash within a list:

```ruby

    [{"
  rimesync error" => "connection to TimeSync failed at baseurl http://ts.example.com/v1 - response status was 502"}]
```

The same error returned from a method that returns a single hash:

```ruby

    {"
  rimesync error" => "connection to TimeSync failed at baseurl http://ts.example.com/v1 - response status was 502"}
```

Useful methods
--------------

These methods are available to general TimeSync users with applicable user roles on the projects they are submitting times to.

TimeSync.\ **authenticate(user, password, auth_type)**

Authenticate a rimesync object with a TimeSync implementation. The
authentication is subject to any time limits imposed by that implementation.

`user` is a string containing the username of the user communicating with
TimeSync

`password` is a string containing the user's password

`auth_type` is a string containing the type of authentication your
TimeSync implementation uses for login, such as `"password"`, or
`"ldap"`.

**authenticate** will return a ruby hash. If authentication was 
successful, the hash will look like this:

```ruby

[{"token" => "SOMELONGTOKEN"}]
```

If authentication was unsuccessful, the hash will contain an error message:

```ruby

[{"status" => 401, "error" => "Authentication failure", "text" => "Invalid username or password"}]
```

Example:

```ruby

>> ts.authenticate(username="example-user", password="example-password", auth_type="password")

[{'token' => 'eyJ0eXAi...XSnv0ghQ=='}]

>>
```

TimeSync.\ **token_expiration_time**

Returns a ruby datetime representing the expiration time of the current
authentication token.

Example:

```ruby

>> ts.authenticate(username="username", password="user-pass", auth_type=
   "password")
[{'token'=> 'eyJ0eXAiOiJKV1QiLCJhbGciOiJITUFDLVNIQTUxMiJ9.eyJpc3MiOiJvc3Vvc2wtdGltZXN5bmMtc3RhZ2luZyIsInN1YiI6InRlc3QiLCJleHAiOjE0NTI3MTQzMzQwODcsImlhdCI6MTQ1MjcxMjUzNDA4N30=.QP2FbiY3I6e2eN436hpdjoBFbW9NdrRUHbkJ+wr9GK9mMW7/oC/oKnutCwwzMCwjzEx6hlxnGo6/LiGyPBcm3w=='}]
>> ts.token_expiration_time
2016-08-23 22:16:52 +0530
>>
```

TimeSync.\ **create_time(time)**

Send a time entry to the TimeSync instance at the baseurl provided when
instantiating the TimeSync object. This method will return a list with a
single ruby hash containing the created entry if successful. The hash will
contain error information if `create_time` was unsuccessful.

`time` is a ruby hash containing the time information to send to
TimeSync. The syntax is `"string_key" => "string_value"` with the exception
of the key `"duration"` which takes an integer value, and the key
`"activities"`, which takes a list of strings containing activity slugs.
`create_time` accepts the following fields in `time`:

Required:

* `"duration"` - duration of time spent working on a project. May be
  entered as a positive integer (which will default to seconds) or a
  string. As a string duration, follow the format ``<val>h<val>m``. An
  internal method will convert the duration to seconds.
* `"project"` - slug of project worked on
* `"user"` - username of user that did the work, must match `user`
  specified in instantiation
* `"activities"` - list of slugs identifying the activies worked on for this time entry
* `"date_worked"` - date worked for this time entry in the form
  ``"yyyy-mm-dd"``

Optional:

* `"notes"` - optional notes about this time entry
* `"issue_uri"` - optional uri to issue worked on


Example usage:

```ruby

      >> time = {
      *      "duration" => 1200,
      *      "user" => "example-2",
      *      "project" => "ganeti_web_manager",
      *      "activities" => ["docs"],
      *      "notes" => "Worked on documentation toward settings.",
      *      "issue_uri" => "https://github.com/osuosl/ganeti_webmgr/issues",
      *      "date_worked" => "2014-04-17"
      * }
      >> ts.create_time(time=time)
      [{'activities': ['docs'], 'deleted_at': nil, 'date_worked': '2014-04-17', 'uuid': '838853e3-3635-4076-a26f-7efr4e60981f', 'notes': 'Worked on documentation toward settings configuration.', 'updated_at': nil, 'project': 'ganeti_web_manager', 'user': 'example-2', 'duration': 1200, 'issue_uri': 'https://github.com/osuosl/ganeti_webmgr/issues', 'created_at': '2015-05-23', 'revision': 1}]
      >>
```

```ruby

>> time = {
*      "duration" => "3h30m",
*      "user" => "example-2",
*      "project" => "ganeti_web_manager",
*      "activities" => ["docs"],
*      "notes" => "Worked on documentation toward settings.",
*      "issue_uri" => "https://github.com/osuosl/ganeti_webmgr/issues",
*      "date_worked" => "2014-04-17"
*    }
>> ts.create_time(time=time)
[{'activities': ['docs'], 'deleted_at': nil, 'date_worked': '2014-04-17', 'uuid': '838853e3-3635-4076-a26f-7efr4e60981f', 'notes': 'Worked on documentation toward settings configuration.', 'updated_at': nil, 'project': 'ganeti_web_manager', 'user': 'example-2', 'duration': 12600, 'issue_uri': 'https://github.com/osuosl/ganeti_webmgr/issues', 'created_at': '2015-05-23', 'revision': 1}]
>>
```


TimeSync.\ **update_time(time, uuid)**

Update a time entry by uuid on the TimeSync instance specified by the
baseurl provided when instantiating the TimeSync object. This method will
return a ruby hash containing the updated entry if successful. The
hash will contain error information if `update_time` was
unsuccessful.

`time` is a ruby hash containing the time information to send to
TimeSync. The syntax is `"string_key": "string_value"` with the exception
of the key `"duration"` which takes an integer value, and the key
`"activities"`, which takes a list of strings containing activity slugs.
You only need to send the fields that you want to update.

`uuid` is a string containing the uuid of the time to be updated.

`update_time` accepts the following fields in `time`:

* `"duration"` - duration of time spent working on a project. May be
  entered as a positive integer (which will default to seconds) or a
  string. As a string duration, follow the format `<val>h<val>m`. An
  internal method will convert the duration to seconds.
* `"project"` - slug of project worked on
* `"user"` - username of user that did the work, must match `user`
  specified in `authenticate`
* `"activities"` - list of slugs identifying the activies worked on for
  this time entry
* `"date_worked"` - date worked for this time entry in the form
  `"yyyy-mm-dd"`
* `"notes"` - optional notes about this time entry
* `"issue_uri"` - optional uri to issue worked on

Example usage:

```ruby

>> time = {
*    "duration" => 1900,
*    "user" => "red-leader",
*    "activities" => ["hello", "world"],
*  }
>> ts.update_time(time=time, uuid="some-uuid")
[{'activities': ['hello', 'world'], 'date_worked': '2015-08-07', 'updated_at': '2015-10-18', 'user': 'red-leader', 'duration': 1900, 'deleted_at': nil, 'uuid': 'some-uuid', 'notes': nil, 'project': ['ganeti'], 'issue_uri': 'https://github.com/osuosl/ganeti_webmgr/issues/56', 'created_at': '2014-06-12', 'revision': 2}]

>> time = {
*    "duration" => "3h35m",
*    "user" => "red-leader",
*    "activities" => ["hello", "world"],
*  }
>> ts.update_time(time=time, uuid="some-uuid")
[{'activities' => ['hello', 'world'], 'date_worked' => '2015-08-07', 'updated_at' => '2015-10-18', 'user' => 'red-leader', 'duration' => 12900, 'deleted_at' => nil, 'uuid' => 'some-uuid', 'notes' => nil, 'project' => ['ganeti'], 'issue_uri' => 'https://github.com/osuosl/ganeti_webmgr/issues/56', 'created_at' => '2014-06-12', 'revision' => 3}]
```

TimeSync.\ **get_times(query_parameters=nil)**

Request time entries from the TimeSync instance specified by the baseurl
provided when instantiating the TimeSync object. The time entries are
filtered by parameters passed in `query_parameters`. Returns a list of
ruby hashed containing the time information returned by TimeSync or
an error message if unsuccessful. This method always returns a list, even
if the list contains zero or one time object.

`query_parameters` is a ruby hash containing the optional query
parameters described in the [TimeSync documentation](http://timesync.readthedocs.org/en/latest/draft_api.html#get-endpoints). If
`query_parameters` is missing, it defaults to `nil`, in which case
`get_times` will return all times the current user is authorized to see.
The syntax for each argument is `{"query" => ["parameter1", "parameter2"]}`
except for the `uuid` parameter which is `{"uuid" => "uuid-as-string"}`
and the `include_deleted` and `include_revisions` parameters which
should be set to booleans.

Currently the valid queries allowed by rimesync are:

* `user` - filter time request by username

      - example: ``{"user" => ["username"]}``

* `project` - filter time request by project slug

      - example: `{"project" => ["slug"]}`

* `activity` - filter time request by activity slug

      - example: `{"activity" => ["slug"]}`

* `start` - filter time request by start date

      - example: `{"start" => ["2014-07-23"]}`

* `end` - filter time request by end date

      - example: `{"end" => ["2015-07-23"]}`

* `include_revisions` - either `true` or `false` to include
      revisions of times. Defaults to `false`

      - example: ``{"include_revisions" => true}``

* `include_deleted` - either `true` or `false` to include
      deleted times. Defaults to `false`

      - example: `{"include_deleted" => true}`

    * `uuid` - get specific time entry by time uuid

      - example: `{"uuid" => "someuuid"}`

      To get a deleted time by `uuid`, also add the `include_deleted`
      parameter.

Example usage:

```ruby

>> ts.get_times
[{'activities': ['docs', 'planning'], 'date_worked': '2014-04-17', 'updated_at': nil, 'user': 'userone', 'duration': 1200, 'deleted_at': nil, 'uuid': 'c3706e79-1c9a-4765-8d7f-89b4544cad56', 'notes': 'Worked on documentation.', 'project': ['ganeti-webmgr', 'gwm'], 'issue_uri': 'https://github.com/osuosl/ganeti_webmgr', 'created_at': '2014-04-17', 'revision': 1}, {'activities': ['code', 'planning'], 'date_worked': '2014-04-17', 'updated_at': nil, 'user': 'usertwo', 'duration': 1300, 'deleted_at': nil, 'uuid': '12345676-1c9a-rrrr-bbbb-89b4544cad56', 'notes': 'Worked on coding', 'project': ['ganeti-webmgr', 'gwm'], 'issue_uri': 'https://github.com/osuosl/ganeti_webmgr', 'created_at': '2014-04-17', 'revision': 1}, {'activities': ['code'], 'date_worked': '2014-04-17', 'updated_at': nil, 'user': 'userthree', 'duration': 1400, 'deleted_at': nil, 'uuid': '12345676-1c9a-ssss-cccc-89b4544cad56', 'notes': 'Worked on coding', 'project': ['timesync', 'ts'], 'issue_uri': 'https://github.com/osuosl/timesync', 'created_at': '2014-04-17', 'revision': 1}]
>> ts.get_times({"uuid": "c3706e79-1c9a-4765-8d7f-89b4544cad56"})
[{'activities': ['docs', 'planning'], 'date_worked': '2014-04-17', 'updated_at': nil, 'user': 'userone', 'duration': 1200, 'deleted_at': nil, 'uuid': 'c3706e79-1c9a-4765-8d7f-89b4544cad56', 'notes': 'Worked on documentation.', 'project': ['ganeti-webmgr', 'gwm'], 'issue_uri': 'https://github.com/osuosl/ganeti_webmgr', 'created_at': '2014-04-17', 'revision': 1}]
>>
```

Warning:
```
      If the `uuid` parameter is passed all other parameters will be ignored
      except for `include_deleted` and `include_revisions`. For example,
      `ts.get_times({"uuid" => "time-entry-uuid", "user" => ["bob", "rob"]})`` is
      equivalent to `ts.get_times({"uuid": "time-entry-uuid"})`.
```


TimeSync.\ **delete_time(uuid)**

Allows the currently authenticated user to delete their own time entry by
uuid.

`uuid` is a string containing the uuid of the time entry to be deleted.

**delete_time** returns a `[{"status": 200}]` if successful or an error
message if unsuccessful.

Example usage:

```ruby

  >> ts.delete_time(uuid="some-uuid")
  [{"status": 200}]
  >>
```


TimeSync.\ **get_projects(query_parameters=nil)**

Request project entries from the TimeSync instance specified by the baseurl
provided when instantiating the TimeSync object. The project entries are
filtered by parameters passed in `query_parameters`. Returns a list of
ruby hashes containing the project information returned by TimeSync
or an error message if unsuccessful. This method always returns a list,
even if the list contains one project object.

`query_parameters` is a dict containing the optional query parameters
described in the [TimeSync documentation](http://timesync.readthedocs.org/en/latest/draft_api.html#get-endpoints). If `query_parameters` is
empty, `get_projects` will return all projects in the database. The
syntax for each argument is `{"query" => "parameter"}` or
`{"bool_query" => <boolean>}`.

The optional parameters currently supported by the TimeSync API are:

* `slug` - filter project request by project slug

  - example: `{"slug" => "gwm"}`

* `include_deleted` - tell TimeSync whether to include deleted projects in
  request. Default is `false` and cannot be combined with a `slug`.

  - example: `{"include_deleted" => true}`

* `include_revisions` - tell TimeSync whether to include past revisions of
  projects in request. Default is `false`

  - example: `{"include_revisions" => true}`

Example usage:

```ruby

  >> ts.get_projects
  [{'users' => {'tschuy' => {'member' => true, 'spectator' => false, 'manager' => false}, 'mrsj' => {'member' => true, 'spectator' => false, 'manager' => true}, 'oz' => {'member' => false, 'spectator' => true, 'manager' => false}}, 'uuid' => 'a034806c-00db-4fe1-8de8-514575f31bfb', 'deleted_at' => nil, 'name' => 'Ganeti Web Manager', 'updated_at' => '2014-07-20', 'created_at' => '2014-07-17', 'revision' => 4, 'uri' => 'https://code.osuosl.org/projects/ganeti-webmgr', 'slugs' => ['gwm']}, {'users' => {'managers' => ['tschuy'], 'spectators' => ['tschuy', 'mrsj'], 'members' => ['patcht', 'tschuy', 'mrsj']}, 'uuid' => 'a034806c-rrrr-bbbb-8de8-514575f31bfb', 'deleted_at' => nil, 'name' => 'TimeSync', 'updated_at' => '2014-07-20', 'created_at' => '2014-07-17', 'revision' => 2, 'uri' => 'https://code.osuosl.org/projects/timesync', 'slugs' => ['timesync', 'ts']}, {'users' => {'managers' => ['mrsj'], 'spectators' => ['tschuy', 'mrsj'], 'members' => ['patcht', 'tschuy', 'mrsj', 'MaraJade', 'thai']}, 'uuid' => 'a034806c-ssss-cccc-8de8-514575f31bfb', 'deleted_at' => nil, 'name' => 'rimesync', 'updated_at' => '2014-07-20', 'created_at' => '2014-07-17', 'revision' => 1, 'uri' => 'https://code.osuosl.org/projects/
  rimesync', 'slugs' => ['rimesync', 'ps']}]
  >> ts.get_projects({"slug" => "gwm"})
  [{'users' => {'tschuy' => {'member' => true, 'spectator' => false, 'manager' => false}, 'mrsj' => {'member' => true, 'spectator' => false, 'manager' => true}, 'oz' => {'member' => false, 'spectator' => true, 'manager' => false}}, 'uuid' => 'a034806c-00db-4fe1-8de8-514575f31bfb', 'deleted_at' => nil, 'name' => 'Ganeti Web Manager', 'updated_at' => '2014-07-20', 'created_at' => '2014-07-17', 'revision' => 4, 'uri' => 'https://code.osuosl.org/projects/ganeti-webmgr', 'slugs' => ['gwm']}]
  >>
```

Warning:

Does not accept a `slug` combined with `include_deleted`, but does
accept any other combination.


TimeSync.\ **get_activities(query_parameters=nil)**

Request activity entries from the TimeSync instance specified by the baseurl
provided when instantiating the TimeSync object. The activity entries are
filtered by parameters passed in `query_parameters`. Returns a list of
ruby hashed containing the activity information returned by TimeSync
or an error message if unsuccessful. This method always returns a list, even
if the list contains one activity object.

`query_parameters` contains the optional query parameters described in the
[TimeSync documentation](http://timesync.readthedocs.org/en/latest/draft_api.html#get-endpoints). If `query_parameters` is empty,
`get_activities` will return all activities in the database. The syntax
for each argument is `{"query" => "parameter"}` or
`{"bool_query" => <boolean>}`.

The optional parameters currently supported by the TimeSync API are:

* `slug` - filter activity request by activity slug

  - example: `{"slug" => "code"}`

* `include_deleted` - tell TimeSync whether to include deleted activities
  in request. Default is `false` and cannot be combined with a `slug`.

  - example: `{"include_deleted" => true}`

* `include_revisions` - tell TimeSync whether to include past revisions of
  activities in request. Default is `false`

  - example: `{"include_revisions" => true}`

Example usage:

```ruby

>> ts.get_activities
[{'uuid': 'adf036f5-3d49-4a84-bef9-062b46380bbf', 'created_at': '2014-04-17', 'updated_at': nil, 'name': 'Documentation', 'deleted_at': nil, 'slug': 'docs', 'revision': 5}, {'uuid': 'adf036f5-3d49-bbbb-rrrr-062b46380bbf', 'created_at': '2014-04-17', 'updated_at': nil, 'name': 'Coding', 'deleted_at': nil, 'slug': 'dev', 'revision': 1}, {'uuid': 'adf036f5-3d49-cccc-ssss-062b46380bbf', 'created_at': '2014-04-17', 'updated_at': nil, 'name': 'Planning', 'deleted_at': nil, 'slug': 'plan', 'revision': 1}]
>> ts.get_activities({"slug" => "docs"})
[{'uuid': 'adf036f5-3d49-4a84-bef9-062b46380bbf', 'created_at': '2014-04-17', 'updated_at': nil, 'name': 'Documentation', 'deleted_at': nil, 'slug': 'docs', 'revision': 5}]
>>
```

Warning:

Does not accept a `slug` combined with ``include_deleted``, but does
accept any other combination.


TimeSync.\ **get_users(username=nil)**

Request user entities from the TimeSync instance specified by the baseurl
provided when instantiating the TimeSync object. Returns a list of ruby
hashed containing the user information returned by TimeSync or an
error message if unsuccessful. This method always returns a list, even if
the list contains one user object.

`username` is an optional parameter containing a string of the specific
username to be retrieved. If `username` is not provided, a list containing
all users will be returned. Defaults to `nil`.

Example usage:

```ruby

>> ts.get_users
[{'username': 'userone', 'display_name': 'One Is The Loneliest Number', 'site_admin': false, 'site_spectator': false, 'site_spectator': false, 'created_at': '2015-02-29', 'active': true, 'deleted_at': nil, 'email': 'exampleone@example.com'}, {'username': 'usertwo', 'display_name': 'Two Can Be As Bad As One', 'site_admin': false, 'site_spectator': false, 'site_manager': false, 'created_at': '2015-02-29', 'active': true, 'deleted_at': nil, 'email': 'exampletwo@example.com'}, {'username': 'userthree', 'display_name': 'Yes Its The Saddest Experience', 'site_admin': false, 'site_spectator': false, 'site_manager': false, 'created_at': '2015-02-29', 'active': true, 'deleted_at': nil, 'email': 'examplethree@example.com'}, {'username': 'userfour', 'display_name': 'Youll Ever Do', 'site_admin': false, 'site_manager': false, 'site_spectator': false, 'created_at': '2015-02-29', 'active': true, 'deleted_at': nil, 'email': 'examplefour@example.com'}]
>> ts.get_users(username="userone")
[{'username': 'userone', 'display_name': 'One Is The Loneliest Number', 'site_admin': false, 'site_spectator': false, 'site_spectator': false, 'created_at': '2015-02-29', 'active': true, 'deleted_at': nil, 'email': 'exampleone@example.com'}]
>>
```

Administrative methods
----------------------

These methods are available to TimeSync users with administrative permissions.

TimeSync.\ **create_project(project)**

Create a project on the TimeSync instance at the baseurl provided when
instantiating the TimeSync object. This method will return a single ruby
hash containing the created project if successful. The hash
will contain error information if `create_project` was unsuccessful.

`project` is a ruby hash containing the project information to
send to TimeSync. The syntax is `"key" => "value"` except for the
`"slugs"` field, which is `"slugs" => ["slug1", "slug2", "slug3"]`.
`project` requires the following fields:

* `"uri"`
* `"name"`
* `"slugs"` - this must be a list of strings

Optionally include a users field to add users to the project:

* ``"users"`` - this must be a ruby hash containing individual user
                permissions. See example below.

Example usage:

```ruby

  >> project = {
  *    "uri" => "https://code.osuosl.org/projects/timesync",
  *    "name" => "TimeSync API",
  *    "slugs" => ["timesync", "time"],
  *    "users" => {"tschuy" => {"member" => true, "spectator" => false, 
  *                "manager" => true}, "mrsj" => {"member" => true, "spectator"*                  => false, "manager" => false}, "patcht" => {"member" =>
  *                 true, "spectator" => false, "manager" => true}, "oz" => {
  *                 "member" => false, "spectator" => true, "manager" => false}
  *                }}
  >> ts.create_project(project=project)
  {'users' => {'tschuy' => {'member' => true, 'spectator' => false, 'manager' => true}, 'mrsj' => {'member' => true, 'spectator' => false, 'manager' => false}, 'patcht' => {'member' => true, 'spectator' => false, 'manager' => true}, 'oz' => {'member' => false, 'spectator' => true, 'manager' => false}}, 'deleted_at' => nil, 'uuid' => '309eae69-21dc-4538-9fdc-e6892a9c4dd4', 'updated_at' => nil, 'created_at' => '2015-05-23', 'uri' => 'https://code.osuosl.org/projects/timesync', 'name' => 'TimeSync API', 'revision' => 1, 'slugs' => ['timesync', 'time']}
  >>
```


TimeSync.\ **update_project(project, slug)**

Update an existing project by slug on the TimeSync instance specified by the
baseurl provided when instantiating the TimeSync object. This method will
return a ruby hash containing the updated project if successful.
The hash will contain error information if `update_project` was
unsuccessful.

`project` is a ruby hash containing the project information to
send to TimeSync. The syntax is `"key" => "value"` except for the
`"slugs"` field, which is `"slugs" => ["slug1", "slug2", "slug3"]`.

`slug` is a string containing the slug of the project to be updated.

If `"uri"`, `"name"`, or `"owner"` are set to `""` (empty string) or
``"slugs"`` is set to ``[]`` (empty array), the value will be set to the
empty string/array.

You only need to pass the fields you want to update in `project`.

`project` accepts the following fields:

* `"uri"`
* `"name"`
* `"slugs"` - this must be a list of strings
* `"user"`

Example usage:

```ruby

  >> project = {
  *    "uri" => "https://code.osuosl.org/projects/timesync",
  *    "name" => "rimesync",
  *  }
  >> ts.update_project(project=project, slug="ps")
  {'users' => {'tschuy' => {'member' => true, 'spectator' => true, 'manager' => true}, 'patcht' => {'member' => true, 'spectator' => false, 'manager' => false}}, 'uuid' => '309eae69-21dc-4538-9fdc-e6892a9c4dd4', 'name' => '
  rimesync', 'updated_at' => '2014-04-18', 'created_at' => '2014-04-16', 'deleted_at' => nil, 'revision' => 2, 'uri' => 'https://code.osuosl.org/projects/timesync', 'slugs' => ['ps']}
  >>
```

TimeSync.\ **delete_project(slug)**

Allows the currently authenticated admin user to delete a project record by
slug.

`slug` is a string containing the slug of the project to be deleted.

**delete_project** returns a `[{"status": 200}]` if successful or an
error message if unsuccessful.

Example usage:

```ruby

>> ts.delete_project(slug="some-slug")
[{'status' => 200}]
>>
```

TimeSync.\ **create_activity(activity)**

Create an activity on the TimeSync instance at the baseurl provided when
instantiating the TimeSync object. This method will return a ruby
hash containing the created activity if successful. The hash
will contain error information if `create_activity` was unsuccessful.

`activity` is a ruby hash containing the activity information to
send to TimeSync. The syntax is `"key" => "value"`. `activity` requires
the following fields:

* `"name"`
* `"slug"`

Example usage:

```ruby

>> activity = {
*    "name" => "Quality Assurance/Testing",
*    "slug" => "qa"
*}
>> ts.create_activity(activity=activity)
{'uuid' => 'cfa07a4f-d446-4078-8d73-2f77560c35c0', 'created_at' => '2013-07-27', 'updated_at' => nil, 'deleted_at' => nil, 'revision' => 1, 'slug' => 'qa', 'name' => 'Quality Assurance/Testing'}
>>
```

TimeSync.\ **update_activity(activity, slug)**

Update an existing activity by slug on the TimeSync instance specified by
the baseurl provided when instantiating the TimeSync object. This method
will return a ruby hash containing the updated activity if
successful. The hash will contain error information if
`update_activity` was unsuccessful.

`activity` is a ruby hash containing the activity information to
send to TimeSync. The syntax is `"key" => "value"`.

`slug` is a string containing the slug of the activity to be updated.

If `"name"` or `"slug"` in `activity` are set to `""` (empty
string), the value will be set to the empty string.

You only need to pass the fields you want to update in `activity`.

`activity` accepts the following fields to update an activity:

* `"name"`
* `"slug"`

Example usage:

```ruby

>> activity = {"name" => "Code in the wild"}
>> ts.update_activity(activity=activity, slug="ciw")
{'uuid' => '3cf78d25-411c-4d1f-80c8-a09e5e12cae3', 'created_at' => '2014-04-16', 'updated_at' => '2014-04-17', 'deleted_at' => nil, 'revision' => 2, 'slug' => 'ciw', 'name' => 'Code in the wild'}
>>
```

TimeSync.\ **delete_activity(slug)**

Allows the currently authenticated admin user to delete an activity record
by slug.

`slug` is a string containing the slug of the activity to be deleted.

**delete_activity** returns a `[{"status" => 200}]` if successful or an
error message if unsuccessful.

Example usage:

```ruby

>> ts.delete_activity(slug="some-slug")
[{'status': 200}]
>>
```

------------------------------------------

TimeSync.\ **create_user(user)**

Create a user on the TimeSync instance at the baseurl provided when
instantiating the TimeSync object. This method will return a ruby
hash containing the created user if successful. The hash will
contain error information if `create_user` was unsuccessful.

`user` is a ruby hash containing the user information to send to
TimeSync. The syntax is `"key" => "value"`. `user` requires the following
fields:

* `"username"`
* `"password"`

Additionally, the following parameters may be optionally included:

* `"display_name"`
* `"email"`
* `"site_admin"` - sitewide permission, must be a boolean
* `"site_spectator"` - sitewide permission , must be a boolean
* `"site_manager"` - sitewide permission, must be a boolean
* `"active"` - user status, usually set internally, must be a boolean

Example usage:

```ruby

  >> user = {
  *    "username" => "example",
  *    "password" => "password",
  *    "display_name" => "X. Ample User",
  *    "email" => "example@example.com"
  *  }
  >> ts.create_user(user=user)
  {'username' => 'example', 'deleted_at' => nil, 'display_name' => 'X. Ample User', 'site_admin' => false, 'site_manager' => false, 'site_spectator' => false, 'created_at' => '2015-05-23', 'active' => true, 'email' => 'example@example.com'}
  >>
```

TimeSync.\ **update_user(user, username)**

Update an existing user by `username` on the TimeSync instance specified
by the baseurl provided when instantiating the TimeSync object. This method
will return a ruby hash containing the updated user if successful.
The hash will contain error information if `update_user` was
unsuccessful.

`user` is a ruby hash containing the user information to send to
TimeSync. The syntax is `"key" => "value"`.

`username` is a string containing the username of the user to be updated.

You only need to pass the fields you want to update in `user`.

`user` accepts the following fields to update a user object:

* `"username"`
* `"password"`
* `"display_name"`
* `"email"`
* `"site_admin"`
* `"site_manager"`
* `"site_spectator"`

Example usage:

```ruby

>> user = {
*    "username" => "red-leader",
*    "email" => "red-leader@yavin.com"
*  }
>> ts.update_user(user=user, username="example")
{'username' => 'red-leader', 'display_name' => 'Mr. Example', 'site_admin' => false, 'site_spectator' => false, 'site_manager' => false, 'created_at' => '2015-02-29', 'active' => true, 'deleted_at' => nil, 'email' => 'red-leader@yavin.com'}
>>
```

TimeSync.\ **delete_user(username)**

Allows the currently authenticated admin user to delete a user record by
username.

`username` is a string containing the username of the user to be deleted.

**delete_user** returns a `[{"status": 200}]` if successful or an error
message if unsuccessful.

Example usage:

```ruby

>> ts.delete_user(username="username")
[{"status" => 200}]
>>
```