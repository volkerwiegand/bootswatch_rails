# BootswatchRails

This gem helps to bootstrap a project using bootswatch.com assets.

Bootswatch.com is a derivative work based on Twitter Bootstrap version 3
that comes with a bunch of precompiled stylesheets. In my projects I use
bootstrap-sass as the gem providing the Bootstrap javascripts, while I
access the precompiled stylesheets (including fonts) via Bootswatch.

Bootswatch_rails uses simple_form and currently this is hard coded. The
installer configures simple_form to prefer horizontal forms.

## Installation

Add this line to your application's Gemfile:

    gem 'bootswatch_rails'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bootswatch_rails

## Usage

Basically just run 'rails generate bootswatch_rails:install`

TODO: include more information!

## Testing

Since I have no experience with test driven development (yet), this is
still an empty spot. Any help is highly appreciated.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/bootswatch_rails/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
