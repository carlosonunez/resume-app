Contributing!
=============

Thanks for contributing! I really appreciate your help and interest in this project.
This doc will show you the ropes.

I always aim to make the contribution process as simple and hassle-free as possible.
If you have *any* feedback, [create a GitHub issue!](https://github.com/carlosonunez/resume-app/issues/new).

Building `resume-app`
===================

If you'd like to build the Docker image for `resume-app` that contains the 
app's Ruby gem, do this: `BUILD_ENVIRONMENT=local make build`

If you'd like to build the gem directly, do the following:

1. Install the prereqs: `bundle install`
2. Build the gem: `gem build resume-app.gemspec`. This will drop a `resume-app.gem` into your working directory.
3. Optionally, install it: `gem install resume-app.gem`

Contributing to `resume-app`
============================

Pull requests are always welcome.

1. [Fork the project](https://github.com/carlosonunez/resume-app#fork-destination-box)
2. Make your changes.
3. Run unit tests: `BUILD_ENVIRONMENT=local make unit_tests`
4. If you've made changes to Terraform infrastructure code, run integration
   tests: `BUILD_ENVIRONMENT=local make integration_tests`
   **NOTE**: This *will* cost you money!
5. Submit a pull request.

As directed by Make, you'll need to create a `.env` for your `local` and `integration`
environments.
