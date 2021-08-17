require	"selenium-webdriver"

def setup_driver
  # driver = Selenium::WebDriver.for :chrome

  driver = Selenium::WebDriver.for :chrome, options: driver_options
  return driver
end

def driver_options
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  return options
end

def setup_wait
  wait = Selenium::WebDriver::Wait.new(:timeout => 5)
  return wait
end

def retry_check_element(d,attri,val,text="")
	wait = Selenium::WebDriver::Wait.new(:timeout => 2)
	ret = true
  retry_cnt = 0
	begin
		element = wait.until{ d.find_element(attri,val) }
	rescue
		if retry_cnt <= 2
			retry_cnt += 1
      pp "リトライ"
			retry
		end
		ret = false
	else
		if !element.text.include?(text)
			ret = false
		end
	end
	return ret
end

def check_element(d,attri,val)
	wait = Selenium::WebDriver::Wait.new(:timeout => 5)
	ret = true
	begin
		element = wait.until{ d.find_element(attri,val) }
	rescue
		ret = false
	end
	return ret
end

def error_notification(e)
  pp "Error! #{e.message},#{e.backtrace.join("\n")}"
  send_line_notification("\n Error! \n #{get_current_time} \n #{e.message}}")
end

def get_current_time
	week = %w(日 月 火 水 木 金 土)[Date.today.wday] #日
	current_time = Time.now.strftime("%Y/%m/%d(#{week}) %T") #2021/01/01(日) 01:23:45
end

def send_line_notification(msg)
  # uri = URI.parse(ENV["LINE_API_URI"])
  uri = URI.parse("https://notify-api.line.me/api/notify")
  
  request = make_request(msg,uri)
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |https|
    https.request(request)
  end
end

def make_request(msg,uri)
  request = Net::HTTP::Post.new(uri)
  # request["Authorization"] = "Bearer #{ENV["LINE_API_TOKEN"]}"
  request["Authorization"] = "Bearer k8U8bJpBJjlDyDV5joI42SNjHrw9c0qksJfNUMTRD4O"
  request.set_form_data(message: msg)
  request
end

def get_processing_time(start_time)
  process_seconds = Time.now - start_time
  time = process_seconds.round
  sec = time % 60
  time /= 60
  mins = time % 60
  return "#{mins}分#{sec}秒"
end

def click_like_btns(d,wait)
  begin
		pp "ページへ"
		d.navigate.to 'https://m.facebook.com/akihiro.nishino.16?groupid=157664324853695'
  rescue => e
    pp "エラー"
    error_notification(e)
    d.quit
    return
	end
  login_button = wait.until{d.find_element(link_text: "ログイン")}
  login_button.click

  email = wait.until{d.find_element(id: "m_login_email")}
  email.send_key("09035380252")

  pass = d.find_element(id: "m_login_password")
  pass.send_key("aishadoite91", :enter)

  pp "ログイン成功"
  
  if retry_check_element(d,:link_text, "コメント")
    lnk_comment = d.find_element(:link_text, "コメント")
  end
  lnk_comment.click
  
  pp "記事入った"
  
  begin
    comment_switcher = wait.until{d.find_element(name: "comment_switcher")}
  rescue
    pp "comment_switcher だめした"
  else
    pp "comment_switcher いけた！"
    comment_switcher_option ="All Comments"
    select = Selenium::WebDriver::Support::Select.new(comment_switcher)
    select.select_by(:text,comment_switcher_option)
  end
  
  while check_element(d,:partial_link_text, "前のコメントを見る…")
    prev_comments_btn = d.find_element(:partial_link_text, "前のコメントを見る…")
    begin
      prev_comments_btn.click
    rescue
      pp "prev_comments_btn クリックエラー"
      failure_prev_comments_btn_flag = true
      break
    else
      pp "click prev_comments_btn"
      sleep(1)
    end
  end
  
  while check_element(d,:partial_link_text, "さんが返信しました")
    reply_btn = d.find_element(:partial_link_text, "さんが返信しました")
    begin
      reply_btn.click
    rescue
      pp "reply_btn クリックエラー"
      failure_reply_btn_flag = true
      break
    else
      pp "click reply_btn"
      sleep(0.5)
    end
  end

  like_btns = wait.until{d.find_elements(link_text: "いいね！")}
  like_btns_cnt = like_btns.count
  pp "like_btns:#{like_btns_cnt}"
  click_like_btn_cnt = 0
  clicked_like_btn_cnt = 0
  failure_click_like_btn_cnt = 0
  
  like_btns.each_with_index do |like_btn,i|
    if like_btn.css_value("color")== "rgba(32, 120, 244, 1)" || like_btn.css_value("color")== "rgba(88, 144, 255, 1)"
      pp "No.#{i+1} いいね！済み"
      clicked_like_btn_cnt += 1
      next
    else
      pp "No.#{i+1} いいねをクリック"
      begin
        like_btn.click
        sleep(1)
        click_like_btn_cnt += 1
      rescue => e
        pp "No.#{i+1} いいね失敗"
        pp e
        failure_click_like_btn_cnt += 1
      end
    end
  end
  
  pp "新規いいね:いいね済み:クリック失敗:いいねボタン数＝#{click_like_btn_cnt}:#{clicked_like_btn_cnt}:#{failure_click_like_btn_cnt}:#{like_btns_cnt}"
  send_line_notification("\n いいね完了 \n #{get_current_time} \n 新規いいね:いいね済み:クリック失敗:いいねボタン数 \n＝#{click_like_btn_cnt}:#{clicked_like_btn_cnt}:#{failure_click_like_btn_cnt}:#{like_btns_cnt}")
  return
rescue => e
  pp "スクレイピングエラー"
  pp e
  sleep(10)
  # pp d.page_source
  send_line_notification("\n スクレイピングエラー \n #{get_current_time} \n 新規いいね:#{click_like_btn_cnt} \n いいね済み:#{clicked_like_btn_cnt} \n クリック失敗:#{failure_click_like_btn_cnt} \n いいねボタン数 :#{like_btns_cnt}")
  return
end

#-----------------------------

begin
  start_time = Time.now
  d = setup_driver
  wait = setup_wait

  click_like_btns(d,wait)

  send_line_notification("\n 全処理成功 \n #{get_current_time} \n 処理時間:#{get_processing_time(start_time)}")
  d.quit
  return
rescue => e
  pp "エラー発生"
  error_notification(e)
  d.quit
  return
end
