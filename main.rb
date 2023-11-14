require "google_drive"

# Creates a session. This will prompt the credential via command line for the
# first time and save it to config.json file for later usages.
# See this document to learn how to create config.json:
# https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md
session = GoogleDrive::Session.from_config("config.json")

# uzimam sve fajlove koji se nalaze unutar google drive-a
# session.files.each do |file|
#   p file.title
# end

ws = session.spreadsheet_by_key("1ZwnNhN4Uj96DklpoDbJylT8tNVakcjoJK3m9cghfoqQ").worksheets[0]
p ws[2, 1]