class PostalCode < ActiveRecord::Base
  has_and_belongs_to_many :mps
  validates_format_of :postal_code, :with => /[ABCEGHJKLMNPRSTVXY]\d[A-Z]\d[A-Z]\d/i
  
  def self.mps_for(postal_code)
    pc = PostalCode.find_or_create_by_postal_code(postal_code.gsub(/ /, '').downcase)
    
    unless pc.mps.size > 0
      res = `wget -O - "http://www2.parl.gc.ca/Parlinfo/Compilations/HouseOfCommons/MemberByPostalCode.aspx?Language=E&PostalCode=#{pc.postal_code}"`
      emails = res.scan(/mailto:(.*\..+@parl\.gc\.ca)"/).flatten
      pc.mps << Mp.find_all_by_email(emails)
    end
    pc.mps
  end
end
