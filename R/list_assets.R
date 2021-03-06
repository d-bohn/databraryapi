#' Lists assets in a given Databrary volume and session (slot).
#'
#' @param slot Slot/session ID.
#' @param volume Selected volume number.
#' @param convert.JSON A Boolean value. If TRUE converts JSON to data frame.
#' @param vb A Boolean value. If TRUE provides verbose output.
#' @return A data frame with the assets in the selected volume and session.
#' @examples
#' list_assets()
list_assets <- function(slot = 9807, volume = 1,
                        vb = FALSE) {
  # Error handling
  if (length(slot) > 1) {
    stop("Slot must have length 1.")
  }
  if ((!is.numeric(slot)) || slot <= 0 ) {
    stop("Slot must be > 0.")
  }
  if (length(volume) > 1) {
    stop("Volume must have length 1.")
  }
  if ((!is.numeric(volume)) || volume <= 0 ) {
    stop("Volume must be > 0.")
  }

  # if ((!exists("databrary_config_status")) || (!databrary_config_status)) {
  #   config_db(vb = vb)
  # }
  #authenticate_db(vb = vb)

  # Make URL, GET(), and handle response
  slot.url <- paste0("https://nyu.databrary.org/api/volume/", volume, "/slot/", slot, "?assets")
  if (vb) {
    message(paste0("Sending GET to ", slot.url))
  }
  g <- httr::GET(slot.url)
  if (httr::status_code(g) == 200) {
    if (vb) message("Successful HTML call.")
    g.content <- httr::content(g, 'text', encoding = 'UTF-8')
    d.sess <- jsonlite::fromJSON(g.content)
    if (!is.null(d.sess)) {
      if (vb) message("Making data frame from returned content.")
      if (is.data.frame(d.sess$assets)) {
        d.sess.assets <- data.frame(d.sess$assets)
        d.sess.assets$vol.id <- volume
        d.sess.assets$sess.id <- d.sess$id
        d.sess.assets$sess.name <- d.sess$name
        d.sess.assets$sess.date <- d.sess$date
        d.sess.assets$sess.release <- d.sess$release
      } else {
        # Handle case of single value in assets field
        d.sess.assets <- data.frame(id = NA, format = NA, segment = NA,
                                    name = NA, permission = NA, size = NA,
                                    duration = NA,
                                    vol.id = volume,
                                    sess.id = d.sess$id,
                                    sess.name = d.sess$name,
                                    sess.date = d.sess$date,
                                    sess.release = d.sess$release)
      }
      return(d.sess.assets)
    } else {
      return(NULL)
    }
  } else if (vb) {
    message(paste0( 'Download Failed, HTTP status ', httr::status_code(g)))
  }
}
