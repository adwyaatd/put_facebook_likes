from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.select import Select
from time import sleep
import sys
import traceback

def headless_chrome():
  options = webdriver.ChromeOptions()
  # options.binary_location = "/usr/local/bin/chromedriver"
  options.add_argument("--headless")
  options.add_argument("--no-sandbox")
  options.add_argument("--lang=ja-JP")
  options.add_argument("--single-process")
  # options.add_argument("--disable-gpu")
  options.add_argument("--window-size=1280x1696")
  options.add_argument("--disable-application-cache")
  options.add_argument("--disable-infobars")
  # options.add_argument("--hide-scrollbars")
  # options.add_argument("--enable-logging")
  # options.add_argument("--log-level=0")
  # options.add_argument("--ignore-certificate-errors")
  options.add_argument("--homedir=/tmp")
  options.add_argument("start-maximized")
  options.add_argument("--disable-extensions")
  options.add_argument("--disable-dev-shm-usage")

  driver = webdriver.Chrome("/usr/local/bin/chromedriver",options=options)
  return driver

def is_findable_element(driver,attribute,attribute_value,target=None):
  print(attribute_value + "is_findable_element入った")
  attribute = attribute.upper()

  if target and attribute == "XPATH":
    raise Exception("XPATH is invaild to find in target")
  
  result = driver.find_elements(getattr(By, attribute),attribute_value)

  print(len(result))

  return bool(result)

def run(driver):
  try:
    driver.implicitly_wait(10)

    driver.get("https://m.facebook.com/akihiro.nishino.16?groupid=157664324853695")

    login_button = driver.find_element_by_link_text("ログイン")
    login_button.click()

    email_col = driver.find_element_by_id("m_login_email")
    print(email_col)
    print(type(email_col))
    email_col.send_keys("09035380252")

    password_col = driver.find_element_by_id("m_login_password")
    password_col.send_keys("aishadoite91")
    password_col.send_keys(Keys.ENTER)

    print("ログイン成功")

    lnk_comment = driver.find_element_by_link_text("コメント")
    lnk_comment.click()

    print("記事入った")

    comment_switcher = driver.find_element_by_name("comment_switcher")
    comment_switcher_option ="All Comments"
    select = Select(comment_switcher)
    select.select_by_visible_text(comment_switcher_option)

    print("選択成功")

    while is_findable_element(driver,"partial_link_text","前のコメントを見る…"):
      try:
        prev_comments_btn = driver.find_element_by_partial_link_text("前のコメントを見る…")
        prev_comments_btn.click()
      except:
        print("prev_comments_btn クリックエラー")
        break
      else:
        print("click prev_comments_btn")
        sleep(1)

    print("----------")

    reply_btns = driver.find_elements_by_partial_link_text("さんが返信しました")
    print("reply_btns:" + str(len(reply_btns)) + "個")
    for reply_btn in reply_btns:
      reply_btn.click()
      print("click reply_btn")

    like_btns = driver.find_elements_by_link_text("いいね！")
    like_btns_cnt = len(like_btns)
    print("like_btns:" + str(like_btns_cnt) + "個")

    for like_btn_num,like_btn in enumerate(like_btns,1):
      print("no.{}: ".format(like_btn_num), end = "")
      try:
        if like_btn.value_of_css_property("color") == "rgba(32, 120, 244, 1)" or like_btn.value_of_css_property("color")== "rgba(88, 144, 255, 1)":
          print("next")
          next
          # sleep(1)
        else:
          like_btn.click()
          print("click like_btn")
          sleep(0.8)
      except:
        print("エラー")
        next
  except Exception:
    raise
  else:
    print("All success")

print('1')

driver = headless_chrome()

try:
  run(driver)
except Exception as e:
  print("----------")
  type_, value, traceback_ = sys.exc_info()
  print(type_)
  print(value)
  print(traceback_)
  print(traceback.format_exception(type_, value, traceback_))
  print("----------")
  # sleep(60)
  driver.quit()

driver.quit()
print("終わった")

