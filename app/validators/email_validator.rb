class EmailValidator < ActiveModel::EachValidator
  def validate_each( record, attribute, value )
    email_regexp = /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z/
    record.errors.add( attribute, :invalid ) unless value =~ email_regexp
  end
end
