module SectionControllerHelper
  module IncludeMethods

    def list
      @results = []
      @total = 0

      if model().methods.include?('column_names') and model().column_names.include?('deleted')
        @results = model().scoped(:conditions => 'deleted=0').ample(params)
        @total = model().scoped(:conditions => 'deleted=0').count_(params)
      else
        @results = model().ample(params)
        @total = model().count_(params)
      end

      render :text => { :success => true, 
                        :results => @results, 
                        :total => @total }.to_json, :status => :ok
    end

    def quick
      render :text => model().quick(params).to_json, 
             :status => :ok
    end

    def load
      @entry = model().find_by_id(params[:id])

      if @entry
        render :text => { :success => true, :result => @entry }.to_json, 
               :status => :ok
      else
        render :text => { :success => false }.to_json, 
               :status => :not_found
      end
    end

    def save
      param_model = model().name.tableize.singularize
      if (params[param_model] || {})["id"].to_i > 0
        @entry = model().find_by_id(params[param_model]["id"])
        @entry.update_attributes_(params)
      else
        @entry = model().new
        @entry.populate(params)
        @entry.save
      end

      if @entry.errors.length == 0
        render :text => { :success => true, 
                          :id => @entry.id }.to_json, 
               :status => :created
      else
        render :text => { :success => false, 
                          :errors => @entry.errors }.to_json, 
               :status => :unprocessable_entity
      end
    end

    def delete
      @id = 0
      @ids = Array.new
      @entries = Array.new

      if params[:id]
        entry = model().find_by_id(params[:id])
        @entries << entry.to_s unless entry.nil?
        if entry.has_attribute?(:deleted)
          entry.update_attributes({ :deleted => true })
          @id = params[:id] if entry.deleted
        else
          entry.destroy unless entry.nil?
          @id = params[:id] if not entry.nil? and entry.destroyed?
        end
      elsif params[:ids]
        params[:ids].to_s.split(',').each do |j|
          entry = model().find_by_id(j)
          @entries << entry.to_s unless entry.nil?
          if entry.has_attribute?(:deleted)
            entry.update_attributes({ :deleted => true })
            @ids<< j if entry.deleted
          else
            entry.destroy unless entry.nil?
            @ids<< j if not entry.nil? and entry.destroyed?
          end
        end
      end

      if not @id.nil?
        render :text => { :success => true, :id => @id }.to_json, 
               :status => :ok
      elsif not @ids.nil?
        render :text => { :success => true, :ids => @ids }.to_json, 
               :status => :ok
      else
        render :text => { :success => false }.to_json, 
               :status => :not_found
      end
    end

    def delete_all_(options, table_name=nil)
      @affected = 0

      connection = ActiveRecord::Base.connection
      criteria = model().options_for_filter_and_search(options)
      
      table_name = model().to_s.tableize if table_name.nil?
      table_singular = table_name.singularize

      query = Array.new
      query<< "CREATE TEMPORARY TABLE temporary_#{table_singular}_ids"
      query<< "(#{table_singular}_id INT UNSIGNED)"
      connection.execute(query.join(' '))

      query = Array.new
      query<< "INSERT INTO temporary_#{table_singular}_ids"
      query<< "SELECT #{table_name}.id FROM #{table_name}"
      query<< "#{criteria[:joins]}" if criteria[:joins]
      query<< "WHERE #{criteria[:conditions]}" if criteria[:conditions]
      connection.execute(query.join(' '))

      query = Array.new
      query<< "DELETE FROM #{table_name} WHERE #{table_name}.id IN("
      query<< "SELECT #{table_singular}_id FROM temporary_#{table_singular}_ids)"
      @affected = connection.delete(query.join(' '))

      # drop temporary table
      query = "DROP TEMPORARY TABLE temporary_#{table_singular}_ids"
      connection.execute(query)

      render :text => { :success => true }.to_json, :status => :ok
    end

    protected

    def model
      Object::const_get(self.class.name.sub(/Controller$/, ""))
    end
  end
end
