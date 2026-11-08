# Every indexable public URL. Product pages carry image entries so Google
# Images can associate the photographs with the product family.
xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9",
           "xmlns:image" => "http://www.google.com/schemas/sitemap-image/1.1" do
  @pages.each do |page|
    xml.url do
      xml.loc page[:url]
      xml.lastmod @products.maximum(:updated_at)&.to_date&.iso8601 if page[:path] == :products_path
      xml.changefreq page[:changefreq]
      xml.priority page[:priority]
    end
  end

  @products.each do |product|
    xml.url do
      xml.loc absolute_url(product_path(product.slug))
      xml.lastmod product.updated_at.to_date.iso8601
      xml.changefreq "monthly"
      xml.priority "0.8"
      if product.image_url.present?
        xml.tag! "image:image" do
          xml.tag! "image:loc", product.image_url
        end
      end
    end
  end
end
