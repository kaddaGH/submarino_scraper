body = Nokogiri.HTML(content)

json = body.at('script:contains("window.__PRELOADED_STATE__ =")').text.scan(/window\.__PRELOADED_STATE__ =[\n\s]*?(\{.+\});/).first.first

data = JSON.parse(json) rescue nil

offers = data['entities']['offers'].first
availability= (content.include?'OutOfStock"')?"":"1"
price = offers[1][0]['salesPrice']
promotion =  offers[1][0]['discount']['rate']  rescue 0
promotion_text = ""
if promotion.to_i>0
  promotion_text = promotion+'% de desconto'
end

product = data['product']
title = product['name']
description = data['description']['content']
rating = product['rating']['average'] rescue ''
reviews_number = product['rating']['reviews'] rescue ''

attributes =  product['attributes'].to_s



match_text= attributes
[
    /(\d*[\.,]?\d+)[-\s]*?([Ff][Ll]\.?[-\s]*?[Oo][Zz])/,
    /(\d*[\.,]?\d+)[-\s]*?([Oo][Zz])/,
    /(\d*[\.,]?\d+)[-\s]*?([Ff][Oo])/,
    /(\d*[\.,]?\d+)[-\s]*?([Ee][Aa])/,
    /(\d*[\.,]?\d+)[-\s]*?([Ff][Zz])/,
    /(\d*[\.,]?\d+)[-\s]*?(Fluid Ounces?)/,
    /(\d*[\.,]?\d+)[-\s]*?([Oo]unce)/,
    /(\d*[\.,]?\d+)[-\s]*?([Pp]ounds)/,
    /(\d*[\.,]?\d+)[-\s]*?([Cc][Ll])/,
    /(\d*[\.,]?\d+)[-\s]*?([Mm][Ll])/,
    /(\d*[\.,]?\d+)[-\s]*?([Ll][Bb][Ss])/,
    /(\d*[\.,]?\d+)[-\s]*?([Ll][Bb])/,
    /(\d*[\.,]?\d+)[-\s]*?([Ll])/,
    /(\d*[\.,]?\d+)[-\s]*?([Gg])/,
    /(\d*[\.,]?\d+)[-\s]*?([Ll]itre)/,
    /(\d*[\.,]?\d+)[-\s]*?((Single\s)?[Ss]ervings?)/,
    /(\d*[\.,]?\d+)[-\s]*?([Pp]acket\(?s?\)?)/,
    /(\d*[\.,]?\d+)[-\s]*?([Cc]apsules)/,
    /(\d*[\.,]?\d+)[-\s]*?([Tt]ablets)/,
    /(\d*[\.,]?\d+)[-\s]*?([Tt]ubes)/,
    /(\d*[\.,]?\d+)[-\s]*?([Cc]hews)/
].find {|regexp| match_text =~ regexp}
item_size = $1
uom = $2


match = [
    /(\d+)[-\s]*?[xX]/,
    /Pack of (\d+)/,
    /Box of (\d+)/,
    /Case of (\d+)/,
    /Count of (\d+)/,
    /(\d+)[-\s]*?[Cc]ount/,
    /(\d+)[-\s]*?[Ll]atas/,
    /(\d+)[-\s]*?[Uu]nidades/,
    /(\d+)[-\s]*?[Cc][Tt]/,
    /(\d+)[\s-]?Pack($|[^e])/,
    /(\d+)[-\s]*?[Pp][Kk]/
].find {|regexp| match_text =~ regexp}
in_pack = match ? $1 : '1'

info = {
    RETAILER_ID: '117',
    RETAILER_NAME: 'submarino',
    GEOGRAPHY_NAME: 'BR',
    SCRAPE_INPUT_TYPE: page['vars']['input_type'],
    SCRAPE_INPUT_SEARCH_TERM: page['vars']['search_term'],
    SCRAPE_INPUT_CATEGORY: page['vars']['input_type'] == 'taxonomy' ? 'Isotônico e Energéticos' : '-',
    SCRAPE_URL_NBR_PRODUCTS: page['vars']['scrape_url_nbr_products'],
    SCRAPE_URL_NBR_PROD_PG1: page['vars']['nbr_products_pg1'],
    PRODUCT_BRAND: product['supplier'],
    PRODUCT_RANK: page['vars']['rank'],
    PRODUCT_PAGE: page['vars']['page'],
    PRODUCT_ID: product['supplier'],
    PRODUCT_NAME: title,
    PRODUCT_DESCRIPTION: CGI.unescapeHTML(description).gsub(/<\/?[^>]*>/, " ").gsub('[\s\n\r,]+?',' '),
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
