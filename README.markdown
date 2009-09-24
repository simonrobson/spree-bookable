Spree Bookable Extension
=========

Spree extension to add 'Bookable' products. A bookable product has a user selectable start and/or end date, configurable in the product admin. The extension adds date selectors to the product pages where appropriate, and also summarises the selected dates in the cart and order summary. 

Confirmed working with Spree 0.9.0

Installation
------------------------

$ ./script/extension install git://github.com/simonrobson/spree-bookable.git

$ rake db:migrate

$ rake spree:extensions:bookable:update

(Note that the final command copies over jquery UI assets and theme to support the date picker)

