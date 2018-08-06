# GovWifi User Signup API

End user signup journeys for GovWifi.

## Overview

### Journeys

With each journey, we generate a unique username and password for GovWifi.
These get stored and sent to the user.

* SMS signup - Users text a phone number and get a set of credentials
* SMS help routes - Users can also ask for help from the same phone number and
  are sent some guides based on their selected operating system
* Email signup - Users with a government domain email send a blank email to
  signup@wifi.service.gov.uk
* Sponsor signup - Users with a government domain email address send through a
  list of email addresses and/or phone numbers to sponsor@wifi.service.gov.uk

### Sinatra routes

* `GET /healthcheck` - AWS ELB target group health checking
* `POST /user-signup/email-notification` - AWS SES incoming email notifications
* `POST /user-signup/sms-notification` - Firetext incoming SMS notifications

### Dependencies

* [GOV.UK Notify](https://www.notifications.service.gov.uk/) - used to send outgoing emails and SMS replies
* MySQL database - used to store generated credentials

## Developing

### Running the tests

You can run the tests and linter with the following commands:

```shell
make test
make lint
```

### Serving the app locally

```shell
make serve
```

Then access the site at [http://localhost:8080/healthcheck](http://localhost:8080/healthcheck)

### Deploying changes

Once you have merged your changes into master branch.  Deploying is made up of
two steps.  Pushing a built image to the docker registry from Jenkins, and
restarting the running tasks so it picks up the latest image.

