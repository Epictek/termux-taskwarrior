#!/bin/bash

date_format(){
  date -d "$(echo $1 | sed -r 's/(.*)T(..)(..)(..)/\1 \2:\3:\4/')"
}



task status:pending or status:active export | jq -c '.[]' | while read i; do
	typeset -A task

	while IFS== read -r key value; do
	  task["$key"]="$value"
	done < <(echo "$i" | jq -r 'to_entries  | .[] | .key + "=" + (.value|tostring)') 

	typeset -p task


	content="Status ${task[status]} "
	if [ -n "${task[project]}" ] ; then
	  content+="Project: ${task[project]}"
	fi
	if [ -n "${task[due]}" ] ; then
	 echo "derp" 
	  #content+="Due:" $(date_format ${task[due]})
	fi

	termux-notification --title "${task[description]}" --id "${task[uuid]}" --button1 "Done" --button1-action="termux-notification-remove ${task[uuid]} && task done ${task[uuid]}" --button2="modify" --button2-action=""--content "$content"
done

