
default:
	landslide -c landslide.cfg

push:
	rsync -av * linode:/var/www/anandology.com/presentations/messing-with-government-data/
