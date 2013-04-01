module SectionModelHelper
  module IncludeMethods
    def update_attributes_(data)
      populate(data)
      save
    end

    def to_json(options={})
      self.hashmap.to_json(options)
    end

    def populate_(data)
      self.attributes = data[self.class.name.underscore]
    end

    def populate(data)
      populate_(data)
    end

    def hashmap_
      map = HashWithIndifferentAccess.new
      map[self.class.name.underscore] = self.attributes
      map
    end

    def hashmap
      hashmap_
    end
  end

  module ExtendMethods
    def ample(options)
      self.all(self.options_for_all(options))
    end

    def quick(options)
      results = Array.new
      self.all(self.options_for_quick(options)).each do |result|
        results << [ result.id, self.quick_format(result, options[:search]) ]
      end
      results
    end

    def count_(options)
      self.count(self.options_for_count(options))
    end

    def select_conditions_joins
      []
    end

    def select_conditions_columns
      [ "#{self.name.tableize}.name" ]
    end

    def select_order_lambda_all(select)
      lambda do
        table_and_column = "#{select.order.table}.#{select.order.column}"
        direction = select.order.direction
        return "#{table_and_column} #{direction}"
      end
    end

    def select_order_lambda_quick(select)
      lambda do
        return "#{self.name.tableize}.name ASC"
      end
    end

    def select_conditions_lambda(select)
      lambda do
        return
      end
    end

    def options_for_all(options)
      options[:limit] = 25
      select = SelectHelper::Setup.new(self.name.tableize, options)
      select.order.lambda = self.select_order_lambda_all(select)
      if options[:filter]
        select.conditions.lambda = self.select_conditions_lambda(select)
      end
      if options[:search]
        self.select_conditions_joins.each { |j| select << j }
        select.conditions.columns = self.select_conditions_columns
      end    
      select.build
    end

    def options_for_quick(options)
      options[:start] = 0
      options[:limit] = 50
      select = SelectHelper::Setup.new(self.name.tableize, options)
      select.order.lambda = self.select_order_lambda_quick(select)
      if options[:search]
        self.select_conditions_joins.each { |j| select << j }
        select.conditions.columns = self.select_conditions_columns
      end    
      select.build
    end

    def options_for_filter_and_search(options)
      select = SelectHelper::Setup.new(self.name.tableize, options, :extended)
      if options[:filter]
        select.conditions.lambda = self.select_conditions_lambda(select)
      end
      if options[:search]
        self.select_conditions_joins.each { |j| select << j }
        select.conditions.columns = self.select_conditions_columns
      end    
      select.build
    end

    def options_for_count(options)
      self.options_for_filter_and_search(options)
    end

    def quick_format(result, search)
      output = String.new
      header = FormatHelper.markup_wrap(result.name, search, 'u')
      footer = nil
      FormatHelper.quick_result(header, footer)
    end
  end
end
