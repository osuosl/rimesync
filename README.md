# rimesync

A Ruby Gem equivalent in functionality to [Pymesync](https://github.com/osuosl/pymesync).

## Build Instructions

```shell
$ git clone https://github.com/osuosl/rimesync
$ cd rimesync
$ gem build rimesync.gemspec
$ gem install rimesync-0.1.0.gem
```

### Build docs

```shell
$ rake doc
```

### Running Tests and Linter

```shell
$ rake
```

#### Running Tests Separately
```shell
$ rake test
```

#### Running Rubocop Separately
```shell
$ rake rubocop
```
