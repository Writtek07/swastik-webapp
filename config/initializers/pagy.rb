# Pagy powers pagination in the admin console (price history tables).
# https://ddnexus.github.io/pagy/

Pagy::DEFAULT[:limit] = 25
Pagy::DEFAULT[:size] = 7 # page links shown in the nav, gaps included

# A stale or hand-edited ?page= past the end shows the last page instead of
# raising Pagy::OverflowError.
require "pagy/extras/overflow"
Pagy::DEFAULT[:overflow] = :last_page

Pagy::DEFAULT.freeze
