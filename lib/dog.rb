require 'pry'

class Dog

    attr_accessor :name, :breed, :id

    def initialize(id: nil, name: name, breed: breed)
        @id = id
        @name = name 
        @breed = breed 
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end
    end

    def self.create(hash)
        dog = Dog.new(hash)
        dog.save
        dog
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        self.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * 
            FROM dogs 
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQl
        SELECT * FROM dogs WHERE name = ?  AND breed = ?
        SQl
    
        dog = DB[:conn].execute(sql, name, breed).first
        if dog
            new_dog = self.new_from_db(dog)
        else
            new_dog = self.create({name: name, breed: breed})
        end
        new_dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        SQL
        DB[:conn].execute(sql, name). map do |row|
            Dog.new_from_db(row)
        end.first
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end