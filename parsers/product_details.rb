body = Nokogiri.HTML(content)

json =CGI.unescape( body.at('script:contains("window.__PRELOADED_STATE__ =")').text).scan(/window\.__PRELOADED_STATE__ =[\n\s]*?(\{.+\});/).first.first

data = JSON.parse(json) rescue nil

offers = data['entities']['offers'].first
availability= (content.include?'OutOfStock"')?"":"1"
price = offers[1][0]['salesPrice'] rescue ''
promotion =  offers[1][0]['discount']['rate']  rescue 0
promotion_text = ""

if promotion.to_i>0
  promotion_text = promotion.to_s+'% de desconto'
end

product = data['product']
title = product['name']
description = data['description']['content']
rating = product['rating']['average'] rescue ''
reviews_number = product['rating']['reviews'] rescue ''

attributes =  product['attributes'].to_s
brand = product['supplier']
brand ||= [
    'Carnation', '5-Hour Energy Shot', 'Zipfizz', 'Starbucks', 'CYRON', 'NCAA', 'Meilo', 'Chicago Bulls',
    'AMP','Spring', 'SlimFast', "Maxx", "Hell", "Powerking", "Jupí", "Oshee",
    "N-Gine", "Isostar", "Semtex", "Big Shock!", "Tiger", "Gatorade", "Pickwick", "Rauch", "Tesco",
    "Red Bull", "Nocco", "Celsius", "Wolverine", "Monster", "Vitamin Well", "Aminopro", "Powerade", "Nobe",
    "Burn", "Njie", "Boost", "Vive", "Black", "Arctic+", "Activlab", "Air Wick", "N'Gine",
    "4Move", "i4Sport", "BLACK", "Body&Future", "X-tense", "Booster", "Rockstar", "28 Black", "Adelholzener",
    "Dr. Pepper", "Topfit", "Power System", "Berocca", "Demon", "G Force", "Lucozade", "Mother", "Nos",
    "Phoenix", "Ovaltine", "Puraty", "Homegrown", "V", "Running With Bulls",
    'Liquid Ice', 'All Sport', 'Kickstart', 'Bang', 'Full Throttle', 'Lyte Ade', 'Gamergy',
    'Ax Water', 'Propel', 'Nesquick', 'Up Energy', 'Wired Energy', 'Red Elixir',
    'Body Armor', 'Rip It', 'Fitaid', 'Focusaid', 'Partyaid', 'Lifeaid', 'Kicks Start', 'Bawls',
    'Xpress', 'Core Power', 'Runa', 'Zola', 'Outlaw', 'Uptime', 'Green Dragon', 'Gas Monkey',
    'Ruckpack', 'Xing', 'Clutch', 'Chew-A-Bull', 'Matchaah', 'Surge', 'Chew A Bull', 'Vitargo',
    'Star Nutrition', 'Monster Energy', 'Nutramino Fitness Nutrition', 'Olimp Sports Nutrition',
    'Belgian Blue', 'Maxim', 'Biotech USA', 'Gainomax', 'Chained Nutrition','TNT'
].find {|brand_name| title.downcase.include?(brand_name.downcase)} || ''
item_size = nil
uom = nil
in_pack = nil

[ attributes , title].each do |size_text|
  next unless size_text
  regexps = [
      /(\d*[\.,]?\d+)\s?([Ff][Ll]\.?\s?[Oo][Zz])/,
      /(\d*[\.,]?\d+)\s?([Oo][Zz])/,
      /(\d*[\.,]?\d+)\s?([Ff][Oo])/,
      /(\d*[\.,]?\d+)\s?([Ee][Aa])/,
      /(\d*[\.,]?\d+)\s?([Ff][Zz])/,
      /(\d*[\.,]?\d+)\s?(Fluid Ounces?)/,
      /(\d*[\.,]?\d+)\s?([Oo]unce)/,
      /(\d*[\.,]?\d+)\s?([Cc][Ll])/,
      /(\d*[\.,]?\d+)\s?([Mm][Ll])/,
      /(\d*[\.,]?\d+)\s?([Ll])\s/,
      /(\d*[\.,]?\d+)\s?([Gg])/,
      /(\d*[\.,]?\d+)\s?([Ll]itre)/,
      /(\d*[\.,]?\d+)\s?([Ss]ervings)/,
      /(\d*[\.,]?\d+)\s?([Pp]acket\(?s?\)?)/,
      /(\d*[\.,]?\d+)\s?([Cc]apsules)/,
      /(\d*[\.,]?\d+)\s?([Tt]ablets)/,
      /(\d*[\.,]?\d+)\s?([Tt]ubes)/,
      /(\d*[\.,]?\d+)\s?([Cc]hews)/,
      /(\d*[\.,]?\d+)\s?([Mm]illiliter)/i,
  ]
  regexps.find {|regexp| size_text =~ regexp}
  item_size = $1
  uom = $2

  break item_size, uom if item_size && uom
end
[ attributes , title].each do |size_text|
  match = [
      /(\d+)\s?[xX]/,
      /Pack of (\d+)/,
      /Box of (\d+)/,
      /Case of (\d+)/,
      /(\d+)\s?[Cc]ount/,
      /(\d+)[-\s]*?[Ll]atas/,
      /(\d+)[-\s]*?[Uu]nidades/,
      /(\d+)\s?[Cc][Tt]/,
      /(\d+)[\s-]?Pack($|[^e])/,
      /(\d+)[\s-]pack($|[^e])/,
      /(\d+)[\s-]?[Pp]ak($|[^e])/,
      /(\d+)[\s-]?Tray/,
      /(\d+)\s?[Pp][Kk]/,
      /(\d+)\s?([Ss]tuks)/i,
      /(\d+)\s?([Pp]ak)/i,
      /(\d+)\s?([Pp]ack)/i,
      /[Pp]ack\s*of\s*(\d+)/,
  ].find {|regexp| size_text =~ regexp}
  in_pack = $1

  break in_pack if in_pack
end


in_pack ||= '1'


info = {
    RETAILER_ID: '117',
    RETAILER_NAME: 'submarino',
    GEOGRAPHY_NAME: 'BR',
    SCRAPE_INPUT_TYPE: page['vars']['input_type'],
    SCRAPE_INPUT_SEARCH_TERM: page['vars']['search_term'],
    SCRAPE_INPUT_CATEGORY: page['vars']['input_type'] == 'taxonomy' ? 'Isotônico e Energéticos' : '-',
    SCRAPE_URL_NBR_PRODUCTS: page['vars']['scrape_url_nbr_products'],
    SCRAPE_URL_NBR_PROD_PG1: page['vars']['nbr_products_pg1'],
    PRODUCT_BRAND: brand,
    PRODUCT_RANK: page['vars']['rank'],
    PRODUCT_PAGE: page['vars']['page'],
    PRODUCT_ID: product['id'],
    PRODUCT_NAME: title,
    PRODUCT_DESCRIPTION: CGI.unescapeHTML(description).gsub(/<\/?[^>]*>/, " ").gsub(/[\s\n\r]+?/,' ').gsub(/,/,'.'),
    PRODUCT_MAIN_IMAGE_URL: product['images'][0]['big'],
    PRODUCT_ITEM_SIZE: item_size ,
    PRODUCT_ITEM_SIZE_UOM: uom ,
    PRODUCT_ITEM_QTY_IN_PACK: in_pack ,
    PRODUCT_STAR_RATING: rating,
    PRODUCT_NBR_OF_REVIEWS: reviews_number,
    SALES_PRICE: price,
    IS_AVAILABLE: availability,
    PROMOTION_TEXT: promotion_text,
    EXTRACTED_ON: Time.now.to_s,

}


info['_collection'] = 'products'


outputs << info
