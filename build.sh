docker build -t diatigrah_web .

docker create --name diatigrah_mysql_data arungupta/mysql-data-container

docker run  --name diatigrah_mysql \
            --volumes-from diatigrah_mysql_data \
            -v /var/lib/mysql:/var/lib/mysql \
            -e MYSQL_USER=dev \
            -e MYSQL_PASSWORD=dev123 \
            -e MYSQL_DATABASE=mydatabase \
            -e MYSQL_ROOT_PASSWORD=supersecret \
            -P -d \
          mysql

docker run  --name diatigrah_web_1 \
            --link diatigrah_mysql:db \
            -v $(pwd)/application:/var/www \
            -e APP_ENV=dev \
            -p 80:80 -d \
          diatigrah_web
