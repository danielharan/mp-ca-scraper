require 'hpricot'

class Mp < ActiveRecord::Base
  has_and_belongs_to_many :postal_codes
  
  def self.get_list
    list = open("http://webinfo.parl.gc.ca/MembersOfParliament/MainMPsCompleteList.aspx?TimePeriod=Current&Language=E")
    list.each_line do |line|
      m = line.match(/ProfileMP\.aspx\?Key=(\d+)/)
      Mp.create(:parl_gc_id => m[1]) if m && !Mp.find_by_parl_gc_id(m[1])
    end
  end
  
  def self.cache_all
    (Mp.find :all).each do |mp|
      mp.download
      puts "downloaded: " + mp.id.to_s
      sleep 15
    end
  end

  def download
    wget = "wget -O tmp/mps/mp_#{parl_gc_id} -q http://webinfo.parl.gc.ca/MembersOfParliament/ProfileMP.aspx?Key=#{parl_gc_id}&Language=E"
    `#{wget}` unless File.exists?("tmp/mps/mp_#{parl_gc_id}")
  end

  def scrape_summary_info
    doc = Hpricot(File.read("tmp/mps/mp_#{parl_gc_id}"))
    self.parl_gc_constituency_id = doc.search('//*[@id="MasterPage_MasterPage_BodyContent_PageContent_Content_TombstoneContent_TombstoneContent_ucHeaderMP_hlConstituencyProfile"]')[0].attributes['href'].match(/Key=(\d+)/)[1]
    self.constituency_name = doc.search('//*[@id="MasterPage_MasterPage_BodyContent_PageContent_Content_TombstoneContent_TombstoneContent_ucHeaderMP_hlConstituencyProfile"]').innerHTML
    self.party = doc.search('//*[@id="MasterPage_MasterPage_BodyContent_PageContent_Content_TombstoneContent_TombstoneContent_ucHeaderMP_hlCaucusWebSite"]').innerHTML
    self.name = doc.search('//*[@id="MasterPage_MasterPage_BodyContent_PageContent_Content_TombstoneContent_TombstoneContent_ucHeaderMP_lblMPNameData"]').innerHTML
    self.email = doc.search('//*[@id="MasterPage_MasterPage_BodyContent_PageContent_Content_DetailsContent_DetailsContent__ctl0_hlEMail"]').innerHTML
    website = doc.search('//*[@id="MasterPage_MasterPage_BodyContent_PageContent_Content_DetailsContent_DetailsContent__ctl0_hlWebSite"]')
    self.website = website[0].attributes['href'] if website[0]
    self.parliamentary_phone = doc.search('//*[@id="MasterPage_MasterPage_BodyContent_PageContent_Content_DetailsContent_DetailsContent__ctl0_lblTelephoneData"]').innerHTML
    self.parliamentary_fax = doc.search('//*[@id="MasterPage_MasterPage_BodyContent_PageContent_Content_DetailsContent_DetailsContent__ctl0_lblFaxData"]').innerHTML
    self.preferred_language = doc.search('//*[@id="MasterPage_MasterPage_BodyContent_PageContent_Content_DetailsContent_DetailsContent__ctl0_lblPrefLanguageData"]').innerHTML

    const_info = doc.search('//*[@id="MasterPage_MasterPage_BodyContent_PageContent_Content_DetailsContent_DetailsContent__ctl0_divConstituencyOffices"]/table/tr/td')
    self.constituency_address = const_info[0].innerHTML.gsub(/, *$/, '')
    self.constituency_city, self.constituency_province = const_info[1].innerHTML.split(', ')
    self.constituency_postal_code = const_info[2].innerHTML
    self.constituency_phone = const_info[4].innerHTML.gsub(/Telephone: /, '')
    self.constituency_fax = const_info[5].innerHTML.gsub(/Fax: /, '')

    self.update
  end
  
  def scrape
    download
    scrape_summary_info
    scrape_edid
  end
  
  def scrape_edid
    constituency_profile = open("http://webinfo.parl.gc.ca/MembersOfParliament/ProfileConstituency.aspx?Key=#{parl_gc_constituency_id}&Language=E").read
    self.update_attribute(:ed_id,constituency_profile.match(/ED=(\d+)/)[1])
  end
end
