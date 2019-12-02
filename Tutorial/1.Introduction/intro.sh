#Commentings


#!/bin/sh
# This is comment
echo Hello World #Yo this is comment as well

#Writing directly into file
echo '#!/bin/sh' > my-first-script.sh
echo 'echo Hello there my first script' >> my-first-script.sh
chmod 755 my-first-script.sh
./my-first-script.sh

