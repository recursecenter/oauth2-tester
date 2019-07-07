# OAuth2 Tester

A small web app that lets you test an API protected by OAuth 2.0 using an authorization code grant type.

## Getting started

Create an OAuth app on the authorization server. If you're running OAuth2 Tester locally, the redirect URI should be `http://localhost:4567`. If you need to use a different port, you can set `PORT` in your `.env` file (see below)

Create a `.env` file in the project root with the following contents:

```sh
CLIENT_ID=...
CLIENT_SECRET=...
AUTHORIZATION_SERVER=http://www.example.com
TEST_RESOURCE=/api/v1/some_resource.json # this will be loaded and displayed after you are successfully authenticated.
```

Then run the following:

```
$ bundle install
$ ruby app.rb
```

## License

OAuth2 Tester is copyright 2019 Recurse Center and is available under the terms of the GNU GPLv3 or later. See COPYING for more info.
