class Person
  attr_accessor: :name, :age, :birthday

  def initialize(name, age, birthday)
    @name = name
    @age = age
    @birthday = birthday
  end
end

frank = Person.new('Frank', 24, 'September 25, 1991')

p frank.name