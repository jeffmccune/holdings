require "holdings/version"
require "json"

module Holdings
  class Error < StandardError; end

  NO_CLASSIFICATIONS_ERROR = "No classifications, make sure to download the data from the Allocations tab!"

  def self.run!
    h = App.new; h.load("holdings.json")
    h.table.each do |row|
      puts row.join("\t")
    end
  rescue Holdings::Error => e
    STDERR.puts e
    exit(1)
  end

  class App
    attr_accessor :data

    def load(file)
      @data = JSON.parse(File.read(file))
    end

    ## Return the 7 classifications in the sole "allocationSevenBox" top level classification.
    # There is only one top level classification:
    # irb(main):011:0> h.classifications[0]["classificationTypeName"]
    # => "allocationSevenBox"
    #
    # Note, if the holdings data is downloaded without visting the
    # "Allocations" tab, then the classifications list will be empty.
    def classifications
      classifications = @data["spData"]["classifications"]
      if not classifications
        raise Holdings::Error, NO_CLASSIFICATIONS_ERROR
      end
      classifications.first["classifications"]
    end

    # Returns the single classification entrypoint of type "allocationSevenBox"
    def classification
      classifications = @data["spData"]["classifications"]
      if classifications.empty?
        raise Holdings::Error, NO_CLASSIFICATIONS_ERROR
      end
      Classification.new(classifications.first)
    end

    def table
      classification.table
    end

    ##
    # irb(main):004:0> h.types
    # => ["Cash", "Intl Bonds", "U.S. Bonds", "Intl Stocks", "U.S. Stocks", "Alternatives", "Unclassified"]
    def types
      classifications.collect() do |c|
        c["classificationTypeName"]
      end
    end
  end

  class Assets
    attr_reader :classes

    def initialize(assets, classes)
      @assets = assets
      @classes = classes
    end

    ## Return a table of asset rows
    def table
      @assets.collect() do |asset|
        # Available keys
        # ["cusip", "accountName", "description", "tradingRatio", "source",
        # "type", "taxCost", "originalTicker", "originalCusip", "holdingType",
        # "price", "percentOfParent", "fundFees", "percentOfTMV", "value",
        # "originalDescription", "ticker", "quantity", "manualClassification",
        # "oneDayValueChange", "change", "sourceAssetId", "feesPerYear",
        # "external", "userAccountId", "priceSource", "costBasis", "exchange",
        # "oneDayPercentChange"]
        [
          asset["accountName"],
          asset["description"],
          classes[-3], # My Class
          classes[-2], # One of the 7 Classes
          classes[-1], # Sector
          asset["ticker"],
          asset["quantity"],
          asset["price"],
          asset["value"],
          asset["cusip"],
          asset["taxCost"],
          asset["fundFees"],
          asset["feesPerYear"],
          asset["type"],
          "EOL"
        ]
      end
    end
  end

  ## Classifications are nested
  class Classification
    attr_reader :classification
    attr_reader :classes

    # Classes is a chain, starting with My Class, then the 7 Asset classes, then
    # what I call the "Sector".  For recursion, we just append values, but we
    # only care about the first 3.
    def initialize(classification, classes=[])
      @classification = classification
      case classes.length
      when 1
        @classes = [my_type(self.name), self.name]
      else
        @classes = [*classes, self.name]
      end
    end

    def name
      @classification["classificationTypeName"]
    end

    def assets
      @classification["assets"]
    end

    def classifications
      @classification["classifications"]
    end

    def table
      table = []
      if classifications
        classifications.each() do |c|
          rows = Classification.new(c, classes).table
          table.push(*rows)
        end
      end
      if assets
        rows = Assets.new(assets, classes).table
        table.push(*rows)
      end
      return table
    end

    ##
    # Given one of their types, map it to my type
    def my_type(type)
      case type
      when /bond/i
        "Bonds"
      when /stock/i
        "Stocks"
      when /alternative/i
        "Alternatives"
      else
        "Unclassified"
      end
    end
  end
end
