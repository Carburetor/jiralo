# Jiralo

A nice utility to extract JIRA worklogs so that can be combined and exported.

## Installation

Run the following command

```bash
gem install jiralo
```

## Usage

You must export the following env variables:

```bash
export JIRA_USERNAME='youruser'
export JIRA_PASSWORD='jirapass'
```

Then you can run:

```bash
jiralo project user from_date to_date
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/jiralo.

