require 'rubygems'
require 'sinatra'
require 'sqlite3'

def is_barber_exists? db, name
	db.execute('select * from Barbers where name=?', [name]).length > 0
end

def seed_db db, barbers
	barbers.each do |barber|
		if !is_barber_exists? db, barber
			db.execute 'insert into Barbers(name) values(?)', [barber]
		end
	end
end

def get_db
	db = SQLite3::Database.new 'barbershop.sqlite'
	db.results_as_hash = true

	return db
end

before do
	db = get_db
	@barbers = db.execute 'select * from Barbers'
end

configure do
	 db = get_db

	db.execute 'CREATE TABLE IF NOT EXISTS
		"Us"
		(
			"id" INTEGER PRIMARY KEY AUTOINCREMENT,
			"username" TEXT,
			"phone" TEXT,
			"datestamp" TEXT,
			"barber" TEXT,
			"color" TEXT
		)'

	db.execute 'CREATE TABLE IF NOT EXISTS
		"Barbers"
		(
			"id" INTEGER PRIMARY KEY AUTOINCREMENT,
			"name" TEXT
			
		)'	
	seed_db db, ['Secator ninzja', 'Boroda naxer', 'Wizapd', 'All Clean', 'Under Walt', 'Second Changer']
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a>
	 pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	erb :about
end

get '/visit' do
	erb :visit
end

post '/visit' do
	@username = params[:username]
	@phone = params[:phone]
	@datetime = params[:datetime]
	@barber = params[:barber]
	@color = params[:color]

	hh = {

		:username => 'Введите имя',
		:phone => 'Введите номер телефона',
		:datetime => 'Введите дату посещения'
	}

	@error = hh.select{|key| params[key] == ''}.values.join(', ')

	if @error != ''
		return erb :visit
	end
	db = get_db
	db.execute 'insert into
		Us
		(
			username,
			phone,
			datestamp,
			barber,
			color
		)
		values (?, ?, ?, ?, ?)', [@username, @phone, @datetime, @barber, @color]
	

	 @message = "Hello #{@username} you phone #{@phone} we waiting you at #{@datetime},
		you color is #{@color} and Wizard: #{@barber}"

	erb :checkout
end

get '/admin' do
	erb :admin
end

post '/admin' do

	@login = params[:login]
	@password = params[:password]


	if @login == 'admin' && @password == '12345'

		db = get_db
		@results = db.execute 'select * from Us order by id desc'

		erb :vizitlist
	else
		@message = "Hello, access denied!"
		erb :admin
	end
end

get '/contacts' do
	erb :contacts
end
 get '/input' do
 	erb :input
 end

 