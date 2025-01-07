%%-------------------------------------------------------------------------%%--
 % Pro-Food-Log Restaurants
 %
 % Each restaurant has the following:
 %  - Name
 %  - Hours
 %  - Price
 %  - Cuisine
 % See `pro-food-log.pl` for the data descriptions.
 % 
 % Note: these remove separate case warnings from swipl
:- discontiguous restaurant/1.
:- discontiguous hours/3.
:- discontiguous price/2.
:- discontiguous makes/2.

 %
 % List of Restaurants
 %
restaurant("Kyle's Kurry").
hours("Kyle's Kurry", 11.00, 21.00).
price("Kyle's Kurry", 2).
makes("Kyle's Kurry", "Japanese").

restaurant("Kae's Kopitiam").
hours("Kae's Kopitiam", 7.00, 22.00).
price("Kae's Kopitiam", 4).
makes("Kae's Kopitiam", "Malaysian").

restaurant("Ivan's Arepas").
hours("Ivan's Arepas", 7.00, 23.00).
price("Ivan's Arepas", 2).
makes("Ivan's Arepas", "Venezuelan").

restaurant("Sophia's Sandos").
hours("Sophia's Sandos", 10, 15.5).
price("Sophia's Sandos", 1).
makes("Sophia's Sandos", "Korean").

restaurant("Grace's Georgous Waffle House").
hours("Grace's Georgous Waffle House", 5.75, 21).
price("Grace's Georgous Waffle House", 2).
makes("Grace's Georgous Waffle House", "Canadian").

restaurant("Beth's Bakery").
hours("Beth's Bakery", 06.00, 17.00).
price("Beth's Bakery", 5).
makes("Beth's Bakery", "French").

restaurant("Cristina's Cucina").
hours("Cristina's Cucina", 11.5, 22.5).
price("Cristina's Cucina", 4).
makes("Cristina's Cucina", "Italian").

restaurant("Toky-yaki").
hours("Toky-yaki", 11.00, 22.00).
price("Toky-yaki", 4).
makes("Toky-yaki", "Japanese").

restaurant("Rocco's Rice Bowl").
hours("Rocco's Rice Bowl", 10.00, 20.00).
price("Rocco's Rice Bowl", 2).
makes("Rocco's Rice Bowl", "Chinese").

restaurant("Caspian Delights").
hours("Caspian Delights", 12.00, 22.00).
price("Caspian Delights", 4).
makes("Caspian Delights", "Persian").

restaurant("Steve's Wolf Den").
hours("Steve's Wolf Den", 11.00, 21.00).
price("Steve's Wolf Den", 3).
makes("Steve's Wolf Den", "Canadian").

restaurant("Indinaan").
hours("Indinaan", 11.00, 22.00).
price("Indinaan", 4).
makes("Indinaan", "Indian").

restaurant("Oliver's Olive Shop").
hours("Oliver's Olive Shop", 12.00, 23.00).
price("Oliver's Olive Shop", 1).
makes("Oliver's Olive Shop", "Greek").
%%-----------------------------------------------------------------------------
