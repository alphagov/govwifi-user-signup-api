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

## Performance Platform

This application sends statistics to the [Performance Platform](https://www.gov.uk/performance/govwifi) for volumetrics and completion rates via a Rake task.  This Rake task is triggered by an ECS scheduled task.

### Send statistics manually

You can trigger statistics to be sent manually by running the command below locally.
Ensure that your ~/.aws/credentials is set up correctly.
Populate the date argument to the Rake task with the date that you want to send the statistics for.

#### Volumetrics

```shell
aws ecs run-task --cluster api-cluster --task-definition user-signup-api-task --count 1 --overrides "{ \"containerOverrides\": [{ \"name\": \"user-signup\", \"command\": [\"bundle\", \"exec\", \"rake\", \"publish_daily_statistics['2018-05-03']\"] }] }" --region eu-west-2
```

#### Completion Rate

```shell
aws ecs run-task --cluster api-cluster --task-definition user-signup-api-task --count 1 --overrides "{ \"containerOverrides\": [{ \"name\": \"user-signup\", \"command\": [\"bundle\", \"exec\", \"rake\", \"publish_weekly_statistics['2018-05-03']\"] }] }" --region eu-west-2
```

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

