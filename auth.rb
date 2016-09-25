require "google_drive"

session = GoogleDrive::Session.from_config("config.json")
puts session

