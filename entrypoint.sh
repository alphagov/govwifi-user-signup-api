#!/bin/sh

echo "Migrating database."
bundle exec rake db:migrate
echo "Done migrating database. Starting Server"
exec "$@"
