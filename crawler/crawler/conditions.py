import logging
import sys

log = logging.getLogger(f"notion-proxy-ng.{__name__}")
log.setLevel(logging.DEBUG)
log_screen_handler = logging.StreamHandler(stream=sys.stdout)
log.addHandler(log_screen_handler)
log.propagate = False
try:
    import colorama, copy

    LOG_COLORS = {
        logging.DEBUG: colorama.Fore.GREEN,
        logging.INFO: colorama.Fore.BLUE,
        logging.WARNING: colorama.Fore.YELLOW,
        logging.ERROR: colorama.Fore.RED,
        logging.CRITICAL: colorama.Back.RED,
    }

    class ColorFormatter(logging.Formatter):
        def format(self, record, *args, **kwargs):
            # if the corresponding logger has children, they may receive modified
            # record, so we want to keep it intact
            new_record = copy.copy(record)
            if new_record.levelno in LOG_COLORS:
                new_record.levelname = "{color_begin}{level}{color_end}".format(
                    level=new_record.levelname,
                    color_begin=LOG_COLORS[new_record.levelno],
                    color_end=colorama.Style.RESET_ALL,
                )
            return super(ColorFormatter, self).format(new_record, *args, **kwargs)

    log_screen_handler.setFormatter(
        ColorFormatter(
            fmt="%(asctime)s %(levelname)-8s %(message)s",
            datefmt="{color_begin}[%H:%M:%S]{color_end}".format(
                color_begin=colorama.Style.DIM, color_end=colorama.Style.RESET_ALL
            ),
        )
    )
except ModuleNotFoundError as identifier:
    pass

class notion_page_loaded(object):
    """An expectation for checking that a notion page has loaded."""

    def __call__(self, driver):
      notion_presence = len(
          driver.find_elements_by_class_name("notion-presence-container")
      )
      if (notion_presence):
        calendar = driver.find_elements_by_class_name("notion-calendar-view")
        if not calendar:
            scroller = driver.find_element_by_css_selector(
                ".notion-frame > .notion-scroller"
            )
            log.debug(f'scroller: {scroller}')
            last_height = scroller.get_attribute("scrollHeight")
            log.debug(f"Scrolling to bottom of notion-scroller (height: {last_height})")
            while True:
                driver.execute_script(
                    "arguments[0].scrollTo(0, arguments[0].scrollHeight)", scroller
                )
                #import time
                #time.sleep(60)
                new_height = scroller.get_attribute("scrollHeight")
                log.debug(f"New notion-scroller height after timeout is: {new_height}")
                if new_height == last_height:
                    break
                last_height = new_height
       
        unknown_blocks = len(driver.find_elements_by_class_name("notion-unknown-block"))
        loading_spinners = len(driver.find_elements_by_class_name("loading-spinner"))
        scrollers = driver.find_elements_by_class_name("notion-scroller")
        scrollers_with_children = []
        for scroller in scrollers:
            children = len(scroller.find_elements_by_tag_name("div"))
            if children > 0:
                scrollers_with_children.append(scroller)
        log.debug(
            f"Waiting for page content to load"
            f" (pending blocks: {unknown_blocks},"
            f" loading spinners: {loading_spinners},"
            f" loaded scrollers: {len(scrollers_with_children)} / {len(scrollers)})"
        )
        all_scrollers_loaded = len(scrollers) == len(scrollers_with_children)
        if (all_scrollers_loaded and not unknown_blocks and not loading_spinners):
            return True
        else:
            return False
      else:
          return False


class toggle_block_has_opened(object):
    """An expectation for checking that a notion toggle block has been opened.
  It does so by checking if the div hosting the content has enough children,
  and the abscence of the loading spinner."""

    def __init__(self, toggle_block):
        self.toggle_block = toggle_block

    def __call__(self, driver):
        toggle_content = self.toggle_block.find_element_by_css_selector("div:not([style]")
        if toggle_content:
            content_children = len(toggle_content.find_elements_by_tag_name("div"))
            unknown_children = len(
                toggle_content.find_elements_by_class_name("notion-unknown-block")
            )
            is_loading = len(
                self.toggle_block.find_elements_by_class_name("loading-spinner")
            )
            log.debug(
                f"Waiting for toggle block to load"
                f" (pending blocks: {unknown_children}, loaders: {is_loading})"
            )
            if not unknown_children and not is_loading:
                return True
            else:
                return False
        else:
            return False
