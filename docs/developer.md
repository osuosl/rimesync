Developer Documentation for rimesync
====================================

Introduction
------------

When developing for rimesync, there are several things that need to be
considered, including communication with TimeSync, return formats, error
messages, testing, internal vs. external methods, test mode, and documenting
changes.

Communicating with TimeSync
---------------------------

Rimesync communicates with a user-defined TimeSync implementation using the
ruby [rest-client library](https://github.com/rest-client/rest-client/). All POST requests to TimeSync must be in proper JSON by passing the data to the json variable in the POST request.

TimeSync returns either a single JSON object or a list of several JSON objects.
These must be converted to a ruby hash or list of hash as
described in the next section.

Return Format
-------------

Rimesync usually returns a hash or a list of zero or more ruby
hashes (in the case of get methods). The return format is decided by the
information that will be returned by TimeSync. If TimeSync could return
multiple objects, rimesync returns the dicts in a list, even if zero or one
object is returned.

Following this format, the user can use the same logic and syntax to process a
`get_<endpoint>` method that returns one object as they do for a
`get_<endpoint>` method that returns many objects. This is important because
filtering parameters can be passed to those methods that will get an unknown
number of objects from TimeSync.

The exception to this rule is for simple data returns like
``token_expiration_time``, which returns a ruby datetime. 

Error Messages
--------------

As mentioned above, local rimesync error messages should be returned as a ruby hash within a list. The key for the error message is set as a class variable in the rimesync.TimeSync class constructor. This class variable is called error and sets the key name throughout the module, including in the tests. The value stored at the key location must be descriptive enough to help the user debug their issue.

The TimeSync API also returns its own errors in a different format, like so:

```ruby

  [{"status" => 401, "error" => "Authentication failure", "text" => "Invalid username or password"}]
```

Testing
-------

Rimesync makes some very expensive API calls to the TimeSync API. These calls
can tie up TimeSync resources or even change the state of the TimeSync database.

To test any method that makes an API call or uses an external resource, you
should mock it. Mocking in ruby involves a somewhat steep learning curve, for mocking requests we used the [webmock library](https://github.com/bblimke/webmock/).

Test Mode
---------

Rimesync provides a `testing` mode so users can test their code without
having to mock rimesync. It just returns what the TimeSync API says it should
return on proper inputs.

If you write a new public method for rimesync, make sure you add it to the
``mock_rimesync.rb`` file with a proper return. In the method you write,
include this logic so the test mode method is called instead when test mode is
on:

```ruby

  if @test
      # your test mode method
  end
```

Make sure you are returning your test mode method *after* all error checking is
complete.

Documenting Changes
-------------------

When you add a public method, please document it in the usage docs and the test
mode docs. Follow the format for already-existing methods.

Uploading to rubygems
---------------------

Currently, we have not packaged rimesync as a gem so one cannot `gem install` it, however the future goal is to publish rimesync on [rubygems](https://rubygems.org/) and allow user to be able to install it easily.