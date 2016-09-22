# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

ScraperQueue.create(domain: "fanfiction.net", last_access: Time.now)
ScraperQueue.create(domain: "fictionpress.com", last_access: Time.now)
ScraperQueue.create(domain: "forums.sufficientvelocity.com", last_access: Time.now)
ScraperQueue.create(domain: "forums.spacebattles.com", last_access: Time.now)
ScraperQueue.create(domain: "forum.questionablequesting.com", last_access: Time.now)
