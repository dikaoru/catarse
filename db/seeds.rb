# coding: utf-8

puts 'Seeding the database...'

[
  { pt: 'Arte', en: 'Art', fr: 'Art'},
  { pt: 'Artes plásticas', en: 'Visual Arts', fr: 'Art plastique' },
  { pt: 'Circo', en: 'Circus', fr: 'Cirque' },
  { pt: 'Comunidade', en: 'Community', fr: 'Comunauté' },
  { pt: 'Humor', en: 'Humor', fr: 'Humour' },
  { pt: 'Quadrinhos', en: 'Comicbooks', fr: 'bd' },
  { pt: 'Dança', en: 'Dance', fr: 'Dance' },
  { pt: 'Design', en: 'Design', fr: 'Design' },
  { pt: 'Eventos', en: 'Events', fr: 'Événementiel' },
  { pt: 'Moda', en: 'Fashion', fr: 'Mode' },
  { pt: 'Gastronomia', en: 'Gastronomy', fr: 'Gastronomie' },
  { pt: 'Cinema e Vídeo', en: 'Film & Video', fr: 'Cinéma' },
  { pt: 'Jogos', en: 'Games', fr: 'Jeux' },
  { pt: 'Jornalismo', en: 'Journalism', fr: 'Journalisme' },
  { pt: 'Música', en: 'Music', fr: 'Musique' },
  { pt: 'Fotografia', en: 'Photography', fr: 'Photographie' },
  { pt: 'Ciência e Tecnologia', en: 'Science & Technology', fr: 'Sciences et technologies' },
  { pt: 'Teatro', en: 'Theatre', fr: 'Théatre' },
  { pt: 'Esporte', en: 'Sport', fr: 'Sport' },
  { pt: 'Web', en: 'Web', fr: 'Web' },
  { pt: 'Carnaval', en: 'Carnival', fr: 'Carnaval' },
  { pt: 'Arquitetura e Urbanismo', en: 'Architecture & Urbanism', fr: 'Architecture et Urbanisme' },
  { pt: 'Literatura', en: 'Literature', fr: 'Literature' },
  { pt: 'Mobilidade e Transporte', en: 'Mobility & Transportation', fr: 'Transport et Mobilité' },
  { pt: 'Meio Ambiente', en: 'Environment', fr: 'Environement' },
  { pt: 'Negócios Sociais', en: 'Social Business', fr: 'Social' },
  { pt: 'Educação', en: 'Education', fr: 'Éducation' },
  { pt: 'Filmes de Ficção', en: 'Fiction Films' , fr: 'Films de fiction'},
  { pt: 'Filmes Documentários', en: 'Documentary Films', fr: 'Films documentaire' },
  { pt: 'Filmes Universitários', en: 'Experimental Films' },
  { pt: 'Saúde', en: 'Health', fr: 'Santé' }
].each do |name|
   category = Category.find_or_initialize_by(name_pt: name[:pt])
   category.update_attributes({
     name_en: name[:en]
   })
   category.update_attributes({
     name_fr: name[:fr]
   })
 end


{
  company_name: 'Nobleza Obliga',
  company_logo: 'https://nobleza-obliga-upgrade.herokuapp.com/assets/catarse_bootstrap/logo_icon_catarse.png',
  host: 'nobleza-obliga-upgrade.herokuapp.com',
  base_url: "https://nobleza-obliga-upgrade.herokuapp.com",
  jwt_secret: "b26ed3cb-9666-4eca-9182-3a87fb2c5c6d",
  api_hos: "https://nobleza-obliga-upgrade.herokuapp.com",
  email_contact: 'info@NoblezaObliga.com',
  email_payments: 'pagos@NoblezaObliga.com',
  email_projects: 'causas@NoblezaObliga.com',
  email_system: 'info@NoblezaObliga.com',
  email_no_reply: 'no-reply@NoblezaObliga.com',
  facebook_url: "https://www.facebook.com/NoblezaO",
  facebook_app_id: '',
  twitter_url: 'https://twitter.com/NoblezaObliga_',
  twitter_username: "NoblezaObliga_",
  mailchimp_url: "",
  catarse_fee: '0.13',
  support_forum: 'https://nobleza-obliga-upgrade.herokuapp.com',
  base_domain: 'nobleza-obliga-upgrade.herokuapp.com',
  uservoice_secret_gadget: 'change_this',
  uservoice_key: 'uservoice_key',
  faq_url: 'https://nobleza-obliga-upgrade.herokuapp.com',
  feedback_url: 'https://nobleza-obliga-upgrade.herokuapp.com',
  terms_url: 'https://nobleza-obliga-upgrade.herokuapp.com',
  privacy_url: 'https://nobleza-obliga-upgrade.herokuapp.com',
  about_channel_url: 'https://nobleza-obliga-upgrade.herokuapp.com',
  instagram_url: '',
  blog_url: "https://nobleza-obliga-upgrade.herokuapp.com",
  github_url: 'https://github.com/dikaoru/nobleza',
  contato_url: 'https://nobleza-obliga-upgrade.herokuapp.com'
}.each do |name, value|
   conf = CatarseSettings.find_or_initialize_by(name: name)
   conf.update_attributes({
     value: value
   }) if conf.new_record?
end

OauthProvider.find_or_create_by!(name: 'facebook') do |o|
  o.key = 'your_facebook_app_key'
  o.secret = 'your_facebook_app_secret'
  o.path = 'facebook'
end

puts
puts '============================================='
puts ' Showing all Authentication Providers'
puts '---------------------------------------------'

OauthProvider.all.each do |conf|
  a = conf.attributes
  puts "  name #{a['name']}"
  puts "     key: #{a['key']}"
  puts "     secret: #{a['secret']}"
  puts "     path: #{a['path']}"
  puts
end


puts
puts '============================================='
puts ' Showing all entries in Configuration Table...'
puts '---------------------------------------------'

CatarseSettings.all.each do |conf|
  a = conf.attributes
  puts "  #{a['name']}: #{a['value']}"
end

puts "Adding Admin user..."

  User.find_or_create_by!(name: "Admin") do |u|
    u.nickname = "Admin"
    u.email = "admin@admin.com"
    u.password = "password"
    u.password_confirmation = "password"
    u.remember_me = false
    u.admin = true
  end

puts "Adding Funder user..."

  User.find_or_create_by!(name: "Funder") do |u|
    u.nickname = "Funder"
    u.email = "funder@funder.com"
    u.nickname = "Funder"
    u.password = "password"
    u.password_confirmation = "password"
    u.remember_me = false
  end

puts "Adding Test user..."

  User.find_or_create_by!(name: "Test") do |u|
    u.nickname = "Test"
    u.email = "test@test.com"
    u.nickname = "Test"
    u.password = "password"
    u.password_confirmation = "password"
    u.remember_me = false
  end

puts "Done!"

Rails.cache.clear

puts '---------------------------------------------'
puts 'Done!'
