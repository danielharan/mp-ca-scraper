require 'csv'
class MpsController < ApplicationController
  
  # non-REST method defined in config/routes.rb -- not sure if this is appropriate
  def search
    @mps = PostalCode.mps_for(params[:postal_code])
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @mps.to_xml}
      format.json { render :text => @mps.to_json}
      format.csv { render :text => list_to_csv}
    end
  end
  
  # GET /mps
  # GET /mps.xml
  def index
    @mps = Mp.find(:all, :conditions => 'ed_id IS NOT NULL')

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @mps.to_xml }
      format.json { render :text => @mps.to_json}
      format.csv { render :text => list_to_csv}
    end
  end

  # GET /mps/1
  # GET /mps/1.xml
  def show
    @mp = Mp.find_by_ed_id(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @mp.to_xml }
      format.json { render :text => @mp.to_json }
    end
  end
  
  private 
  def list_to_csv
    proc {|response, output|
      CSV::Writer.generate(output) do |csv|
        csv << Mp.column_names.sort
        @mps.each do |mp|
          csv << mp.attributes.sort.collect{|key,val| val}
        end
      end
    }
  end
end
