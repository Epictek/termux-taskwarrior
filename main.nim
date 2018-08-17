import json, rdstdin, strutils, osproc, system, os

var tasks : JsonNode
try:
  tasks = execProcess("task status:pending export").parseJson
except JsonParsingError:
  echo "Unable to parse task export, is taskwarrior installed?"

case paramStr(1):
  of "notify-all":
    for task in tasks:
      echo task
      var content = task["status"].getStr()
      echo task{"due"}.getStr()

      let p = startProcess(command="/data/data/com.termux/files/usr/bin/termux-notification",
        args=["--id", task["uuid"].getStr(),
        "--title", task["description"].getStr(),
        "--content", content,
        "--priority", "low",
        "--button1", "Done",
        "--button1-action","task $1 done" % [task["uuid"].getStr()],
        "--button2", "Modify",
        "--button2-action","task diagnostic"])
  of "modify":
    let p = startProcess(command="termux-dialog sheet", args=["-v","something","else"])
  else:
    echo "help"
