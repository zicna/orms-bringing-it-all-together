class Dog
    attr_accessor :name, :breed, :id

    def initialize(id: nil, name: , breed:)
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
        if !self.id
            sql = <<-SQL
                INSERT INTO dogs(name, breed)
                VALUES (?, ?)
            SQL
            #binding.pry
            DB[:conn].execute(sql, self.name, self.breed)
            id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self.class.find_by_id(id)
            # d = Dog.new
            # d
        end
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
        d = Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * 
            FROM dogs
            WHERE dogs.id = ?
        SQL
        
        dog = DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE dogs.name = ? 
            AND dogs.breed = ?
            LIMIT 1
        SQL

        dog = DB[:conn].execute(sql, name, breed)
        #binding.pry
        if dog.empty?
            dog_data = dog[0]
            dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
            #dog.save
        elsif !dog.empty?
            # binding.pry
            # dog = self.create(name: name, breed: breed)
            #dog = self.find_by_name(name)
            dog = self.find_by_id(dog[0])
        end
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * 
            FROM dogs
            WHERE dogs.name = ?
        SQL
#binding.pry
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET dogs.name = ?, dogs.breed = ?
            WHERE dogs.id = ?
        SQL
#binding.pry
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end



    
    
end