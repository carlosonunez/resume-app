[![Build Status](https://travis-ci.org/carlosonunez/resume-app.svg?branch=master)](https://travis-ci.org/carlosonunez/resume-app)

Important Stuff!
================

**Want to submit a feature?** [Go here.](https://github.com/carlosonunez/resume-app/issues/new?labels=feature&title=[Feature]&template=.github/feature_request_template.md)

**Want to submit an issue?** [Go here.](https://github.com/carlosonunez/resume-app/issues/new?labels=bug&title=[Bug]&template=.github/issue_template.md)

What is this?
=============

This is a simple web app that renders resumes posted onto S3 buckets.
By default, `resume-app` looks for an S3 object called
`latest` and expects your S3 bucket to be private.

How do I use it?
===============

**NOTE**: You will need an AWS IAM account with enough access to read S3 objects.
That account also needs to have a valid `AWS_ACCESS_KEY_ID` and 
`AWS_SECRET_ACCESS_KEY`.

1. Clone this repository and `cd` into it.
2. Create your own environment: `cp .env.example .env.local`
3. Open `.env.local` in your favorite editor and substitute the values provided.
4. Build the gem and Docker image: `make build`
5. Run the Docker image: `docker run -p $PORT:4567 resume_app:$(cat version)`
6. Upload your Markdown-formatted resume to the `S3_BUCKET_NAME` provided in `.env.local`
7. See it live at https://localhost:`$PORT`.

How do I deploy this onto actual hardware?
===========================================

**NOTE**: You will need a Docker Hub account to push your Docker image into.
Go to [hub.docker.com](https://hub.docker.com) to create one.

##AWS

1. Follow steps 1-3 above. Be sure to substitute the values under the "AWS Hosting" section.
2. Test your configuration: `make integration_tests`. This will take about six minutes to become ready.
3. Deploy your environment: `make deploy`. This will take about six minutes to become ready.

If you need to debug the "integration" environment, run this instead: `DEBUG=true make integration_tests`

If you'd like to delete the environment that was created, run this: `make destroy`


Additional Features
===================

Run Tests on Push
------------------

For those looking to fork or continue development on this codebase, you can have your local repository
run tests before pushing your changes. This makes for faster and easier PR merges.

To set this up:

1. Add the `pre-push` hook to your `.git` directory: `ln -s ../../.githooks/pre-push .git/hooks/pre-push`
2. Give it executable permissions: `chmod +x .git/hooks/pre-push`

Need help?
==========

[Email me!](mailto:dev@carlosnunez.me)
