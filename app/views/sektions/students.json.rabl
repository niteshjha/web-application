
object false

node(:students) { 
  @students.map{ |m| 
    { :name => m.name, :id => m.id } 
  }
}

node(:sektion) { @sektion.id } 
node(:context) { @context.blank? ? "unknown" : @context }
