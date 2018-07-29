#!/bin/bash

typeset -A taskArray

while IFS== read -r key value; do
    taskArray["$key"]="$value"
done < <(task $1 export | jq -r '.[] | to_entries | .[] | .key + "=" + (.value|tostring)')

typeset -p taskArray

echo ${taskArray[uuid]}


newDescription=`termux-dialog text -i "${taskArray[description]}" -t "Modify task" | jq '.text'`


task ${taskArray[uuid]} modify $newDescription 
