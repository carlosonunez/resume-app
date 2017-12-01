What is this?
=============

This is a simple web app that renders resumes posted onto S3 buckets.
By default, `resume-markdown-renderer` looks for an S3 object called
`resume.latest` and expects your S3 bucket to be private.

How do I use it?
===============

1. Create your `.env`: `cp .env.example .env`
2. Replace the dummy values in the `.env` with real values.
3. Create your resume, name it `resume.latest` and save it into the bucket provided in `.env`.

   **NOTE**: At the moment, this application simply takes Markdown and renders it as provided.
   Future releases will provide a domain specific language to make creating resumes easier.

4. Run `rake deploy`. Your resume should be shown at http://localhost:5000.

Need help?
==========

[Email me!](mailto:dev@carlosnunez.me)
