pages << {
    page_type: 'products_listing',
    method: 'GET',
    url: "https://mystique-v2-submarino.b2w.io/search?offset=0&sortBy=topSelling&source=omega&filter=%7B%22id%22%3A%22category.id%22%2C%22value%22%3A%22300228%22%2C%22fixed%22%3Atrue%7D&limit=24&suggestion=false",
    vars: {
        'input_type' => 'taxonomy',
        'search_term' => '-',
        'page' => 1
    }


}
search_terms = ['Red Bull', 'RedBull', 'Energético', 'Energéticos']
search_terms.each do |search_term|

  pages << {
      page_type: 'products_listing',
      method: 'GET',
      url: "https://mystique-v2-submarino.b2w.io/search?content=#{search_term}&offset=0&sortBy=relevance&source=nanook&limit=24&suggestion=false&c_b2wSid=469.846063031196620192141153145&c_b2wUid=va_201913311927_801.2812056579871",
      vars: {
          'input_type' => 'search',
          'search_term' => search_term,
          'page' => 1
      }


  }

end