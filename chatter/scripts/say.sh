
NAME=$(ctx instance id)
MESSAGE="My name is $NAME"
curl -vv -XPOST -d"{\"name\": \"$NAME\", \"message\": \"$MESSAGE\"}" http://172.17.0.1/say
