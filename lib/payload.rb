require 'digest/crc16'

class Payload
  attr_reader :pix_key, :description, :merchant_name, :merchant_city, :tx_id, :amount
  
  # Payload ids
  ID_PAYLOAD_FORMAT_INDICATOR = '00';
  ID_MERCHANT_ACCOUNT_INFORMATION = '26';
  ID_MERCHANT_ACCOUNT_INFORMATION_GUI = '00';
  ID_MERCHANT_ACCOUNT_INFORMATION_KEY = '01';
  ID_MERCHANT_ACCOUNT_INFORMATION_DESCRIPTION = '02';
  ID_MERCHANT_CATEGORY_CODE = '52';
  ID_TRANSACTION_CURRENCY = '53';
  ID_TRANSACTION_AMOUNT = '54';
  ID_COUNTRY_CODE = '58';
  ID_MERCHANT_NAME = '59';
  ID_MERCHANT_CITY = '60';
  ID_ADDITIONAL_DATA_FIELD_TEMPLATE = '62';
  ID_ADDITIONAL_DATA_FIELD_TEMPLATE_TXID = '05';
  ID_CRC16 = '63';

  def self.build
    builder = new
    yield(builder)
    builder
  end

  def set_pix_key=(pix_key)
    @pix_key = pix_key
  end
  
  def set_description=(desc)
    @description = desc
  end

  def set_merchant_name=(name)
    @merchant_name = name
  end
  
  def set_merchant_city=(merchant_city)
    @merchant_city = merchant_city
  end
  
  def set_tx_id=(tx_id)
    @tx_id = tx_id
  end
  
  def set_amount=(amount)
    @amount = amount.to_s
  end

  def get_payload
    payload = self.get_value(ID_PAYLOAD_FORMAT_INDICATOR, "01") +
              get_merchant_account_information +
              self.get_value(ID_MERCHANT_CATEGORY_CODE, "0000") +
              self.get_value(ID_TRANSACTION_CURRENCY, "986") +
              self.get_value(ID_TRANSACTION_AMOUNT, @amount) +
              self.get_value(ID_COUNTRY_CODE, 'BR') +
              self.get_value(ID_MERCHANT_NAME, @merchant_name) +
              self.get_value(ID_MERCHANT_CITY, @merchant_city) +
              get_additional_data_field_template
              
     payload + get_crc_16(payload)
  end


  def get_value(id, value)
    size = value.length.to_s.rjust(2, "0").to_s
    id + size + value
  end

  def get_merchant_account_information
    gui         = get_value(ID_MERCHANT_ACCOUNT_INFORMATION_GUI, 'br.gov.bcb.pix')
    key         = get_value(ID_MERCHANT_ACCOUNT_INFORMATION_KEY, @pix_key)
    description = ""#get_value(ID_MERCHANT_ACCOUNT_INFORMATION_DESCRIPTION, @description)

    get_value(ID_MERCHANT_ACCOUNT_INFORMATION, gui + key + description)
  end

  def get_additional_data_field_template
    txid = get_value(ID_ADDITIONAL_DATA_FIELD_TEMPLATE_TXID, @tx_id)
    
    return get_value(ID_ADDITIONAL_DATA_FIELD_TEMPLATE, txid)
  end

  def get_crc_16(payload)
    ID_CRC16 + '04' + Digest::CRC16.hexdigest(payload + ID_CRC16 + '04').upcase
  end
end

payload = Payload.build do |config|
  config.set_pix_key = "123e4567-e12b-12d1-a456-426655440000"
  config.set_description = "Me da um dinhero"
  config.set_merchant_name = "Fulano de Tal"
  config.set_merchant_city = "BRASILIA"
  config.set_amount = "986.00"
  config.set_tx_id = "txId"
end

qr_code = payload.get_payload

pp qr_code
