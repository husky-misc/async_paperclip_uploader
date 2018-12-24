# AsyncPaperclipUploader

Save your attachments first to filesystem and then save async to your model

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'async_paperclip_uploader'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install async_paperclip_uploader

## Usage

First, call AsyncPaperclipUploader::Temporary.new passing the model object, the related attachment attribute, and the uploaded file. 
e.g.:

`AsyncPaperclipUploader::Temporary.new(@user, 'avatar', uploaded_file).call`

Next, create the sidekiq job class, which should follow the following name convention: object class name + UploadJob, e.g.:

`UserUploadJob`

In this class, you must receive the attributes object_id, attribute and filepath. e.g.:

`class UserUploadJob
  include Sidekiq::Worker

  def perform(user_id, attribute, filepath)
  end

end

`

Inside perform method, you will want to call AsyncPaperclipUploader::Permanent.new, which expects to receive the object class name, the object id, the attribute, and the filepath. e.g.:


`
def perform(user_id, attribute, filepath)
  AsyncPaperclipUploader::Permanent.new('User', user_id, attribute, filepath).call
end
`

If you want a callback to be ran, the call method accepts a block. e.g.:

`
AsyncPaperclipUploader::Permanent.new('User', user_id, attribute, filepath).call do
  # you callback here
end
`


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
