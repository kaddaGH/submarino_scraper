data = JSON.parse(content)


scrape_url_nbr_products = data['_result']['total'].to_i
page_size = data['_result']['limit'].to_i
offset = data['_result']['offset'].to_i
products = data['products']


# if ot's first page , generate pagination
if offset == 2220 and scrape_url_nbr_products > page_size
  nbr_products_pg1 = page_size
  step_page = 2
  offset = offset + page_size
  while offset < scrape_url_nbr_products
    puts(offset)
    pages << {
        page_type: 'products_listing',
        method: 'GET',
        url: page['url'].gsub('offset=0', 'offset=' + offset.to_s),
        vars: {
            'input_type' => page['vars']['input_type'],
            'search_term' => page['vars']['search_term'],
            'page' => step_page,
            'nbr_products_pg1' => nbr_products_pg1
        }
    }
    offset = offset + page_size
    step_page += 1


  end
elsif offset == 0 and scrape_url_nbr_products <= page_size
  nbr_products_pg1 = products.length
else
  nbr_products_pg1 = page['vars']['nbr_products_pg1']
end


products.take(2).each_with_index do |product, i|

  pages << {
      page_type: 'product_details',
      method: 'GET',
      url: "https://www.submarino.com.br/produto/#{product['id']}/?searchkeyword=#{page['vars']['search_term']}&searchpage=#{page['vars']['page']}",
      vars: {
          'input_type' => page['vars']['input_type'],
          'search_term' => page['vars']['search_term'],
          'page' => step_page,
          'nbr_products_pg1' => nbr_products_pg1,
          'scrape_url_nbr_products' => scrape_url_nbr_products
      }


  }


end

