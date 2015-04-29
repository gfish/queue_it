module QueueIt
  module Api
    class Error < StandardError
      attr_accessor :status, :code, :text

      def initialize(msg = nil, status: nil, code: nil, text: nil)
        self.code   = code
        self.text   = text
        self.status = status
        super(msg)
      end
    end

    BadRequest          = Class.new(Error)
    Forbidden           = Class.new(Error)
    NotFound            = Class.new(Error)
    InternalServerError = Class.new(Error)
    ServiceUnavailable  = Class.new(Error)
  end
end
