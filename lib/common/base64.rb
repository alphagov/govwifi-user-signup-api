class Common::Base64
  def self.encode_array(arr)
    Base64.strict_encode64(arr.join)
  end
end
