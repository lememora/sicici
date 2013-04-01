module SelectHelper

  SelectOrder = Struct.new(:table, :column, :direction, :lambda)
  SelectConditions = Struct.new(:search, :columns, :filter, :operator, :lambda)

  class Setup
    attr_reader :table, :order, :conditions, :limit, :offset, :joins
    attr_accessor :include

    def initialize(table, options, extended=false)
      extended = true if extended==:full
      @table = table
      initialize_order(options[:sort], options[:dir]) unless extended
      initialize_conditions(options[:search], options[:filter], options[:operator])
      initialize_limit_and_offset(options[:start], options[:limit]) unless extended
      initialize_joins
    end

    def <<(join)
      join = join.to_s
      if join.match(/^[[:digit:][:alpha:]_]+$/) # table
        jp = join.pluralize
        tp = @table.pluralize
        ts = @table.singularize
        @joins |= [ "LEFT JOIN #{jp} ON (#{jp}.#{ts}_id = #{tp}.id)" ] unless jp==tp
      else
        @joins |= [ join ]
      end
    end

    def build
      options = Hash.new
      options[:select] = "DISTINCT `#{@table}`.*" if @limit
      options[:select] = "DISTINCT `#{@table}`.`id`" unless @limit
      options[:include] = build_include
      options[:order] = build_order
      options[:conditions] = build_conditions
      options[:limit], options[:offset] = build_limit_and_offset
      options[:joins] = build_joins
      options
    end

    private

    def initialize_order(column, direction)
      @order = SelectOrder.new
      @order.table = @table
      @order.column = column || "id"
      nested_regexp = /([[:digit:][:alpha:]_]+)[\.\[]([[:digit:][:alpha:]_]+)[\]]*$/
      if (nested = @order.column.match(nested_regexp))
        @order.table, @order.column = nested.to_a[1..2]
        @order.table = @order.table.pluralize
      end
      sanitize_regexp = /[^[:digit:][:alpha:]_]/
      @order.table = @order.table.gsub(sanitize_regexp,"")
      @order.column = @order.column.gsub(sanitize_regexp,"")
      @order.direction = (direction || "ASC").to_s.upcase.index("DESC") ? "DESC" : "ASC"
      self << @order.table
    end

    def initialize_conditions(search, filter, operator)
      @conditions = SelectConditions.new
      @conditions.search = search.to_s
      @conditions.columns = Array.new
      @conditions.filter = filter.to_s
      @conditions.operator = (operator || "OR").to_s.upcase.index("AND") ? "AND" : "OR"
    end

    def initialize_limit_and_offset(start, limit)
      @limit = limit
      @offset = (start || 0).to_i
    end

    def initialize_joins
      @joins = Array.new
    end

    def build_include
      @include
    end

    def build_order
      return nil if @order.nil?
      return (@order.lambda.instance_of? Proc) ? 
        @order.lambda.call : "#{@order.table}.#{@order.column} #{@order.direction}"
    end

    def build_conditions
      conditions = Array.new
      if @conditions.lambda.instance_of? Proc
        conditions<< @conditions.lambda.call
      end
      if not @conditions.search.empty?
        if @conditions.columns.length > 0
          search = ApplicationHelper.remove_diacritics(@conditions.search)
          search = "%#{search.gsub(/[^[:digit:][:alpha:]]/, '%')}%"
          search = search.gsub(/[%]+/,'%')
          conditions<< @conditions.columns.map { |c| "#{c} LIKE \"#{search}\"" }.join(" OR ")
        end
      end
      conditions = conditions.select { |j| not j.to_s.empty? }
      "(#{conditions.join(") AND (")})" if conditions.length > 0
    end

    def build_limit_and_offset
      return nil if @limit.nil?
      return @limit, @offset
    end

    def build_joins
      return @joins.join(' ')
    end
  end
end
