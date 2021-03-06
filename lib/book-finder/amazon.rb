require 'selenium-webdriver'

class Amazon
  def initialize( chrome = null )
    if( chrome )
      @chrome = chrome
    else
      @chrome = Chrome.new
    end
    
  end
  
  def find_kindle_book_by_asin( book_asin )
    driver = @chrome.fetch_url("https://www.amazon.com/dp/#{book_asin}")
    if( has_kindle_book?( driver ) )
      driver = ensure_on_kindle_page( driver )
      if( kindle_book_discontinued?( driver ) )
        return nil
      end

      price_node = driver.find_element(:xpath => "//*[contains(@class, 'a-color-price')]")
      if( price_node.find_elements( :xpath => "*" ).count > 0 )
        price = price_node.text.gsub( price_node.find_elements( :xpath => "*" ).first.text, "" )
      else
        price = price_node.text
      end

      kindle_unlimited = driver.find_elements(:xpath => "//i[contains( @class, 'a-icon-kindle-unlimited')]").count > 0
      return AmazonBook.new( kindle_unlimited, price )
    else
      return nil
    end
  end

  private
  def ensure_on_kindle_page( driver )
    driver.find_elements(:xpath => "//div[contains( @id, 'formats')]//*/ul/li[contains(@class, 'unselected')]//*/a").each do |element|
      if (element.text.index( 'Kindle' ) )
        element.click
        wait = Selenium::WebDriver::Wait.new(:timeout => 5)
        wait.until { driver.find_element( :id, "ebooksProductTitle" ) }

        break
      end
    end
    driver
  end

  def has_kindle_book?( driver )
    to_return = false
    driver.find_elements(:xpath => "//div[contains( @id, 'formats')]//*/ul/li//*/a").each do |element|
      if( element.text.index( 'Kindle' ) )
        to_return = true
        return to_return
      end
    end
    return to_return
  end

  def kindle_book_discontinued?( driver )
    return driver.find_elements( :xpath => "//span[contains(@class, 'no-kindle-offer-message')]" ).count > 0
  end
  
end
