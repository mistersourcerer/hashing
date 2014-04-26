# Hasher

Permits you to say which instance variables of your objects should be used to
serialize it into a `Hash`. Gives you a nice way to inform this, and facilitates
to recreation of your serializable objects from hashes.

## Installation

Add this line to your application's Gemfile:

    gem 'hasher'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hasher

## Usage

Given a `File` class like this:

```ruby
class File
  def initialize(path, commit = nil, content = nil)
    @path, @commit, @content = path, commit, content
  end
end
```

And I want to turn instances of it in a `Hash` like the one below, so I can, for
example, turn this `Hash` into a `YAML` to save it in a file.

```ruby
{
  path: @path,
  commit: @commit,
  content: @content
}
```

I just need to include the `Hasher` module, and then indicates which
`instance vars` (`ivars`) should be used in the serialization using the class
method `hasherize`:

```ruby
class File
  include Hasher
  hasherize :path, :commit, :content
end
```

### #to_h

Then I will be able to call the `#to_h` method in any instance of `File` to
obtain the "hasherized®" version of it:

```ruby
file = File.new 'README.md', 'cfe9aacbc02528b', '#Hasher\n\nWow. Such code...'

file.to_h
# {
#   path: 'README.md',
#   commit: 'cfe9aacbc02528b',
#   content: '#Hasher\n\nWow. Such code...'
# }
```

### ::from_hash

And I can now tell `Hasher` how one can create an instance of `File` given a
valid `Hash` like the one created by a `#to_h` call:

```ruby
class File
  include Hasher
  hasherize :path, :commit, :content

  from_hash ->(hash) {
    new hash[:path], hash[:commit], hash[:content]
  }
end
```

### Hasherify
include Hasherify.new :path, :commit, :content

### Custom hasherifying and load strategies
hasherize :content,
  serialize: ->() {},
  load: ->() {}

### Nested Hasherized objects
annotation...

## Contributing

1. Fork it ( https://github.com/[my-github-username]/hasher/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
