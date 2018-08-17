import json, rdstdin, strutils,osproc,system

var task : JsonNode
try:
  task = readLineFromStdin("").parseJson
except IOError:
   quit(0)
except AssertionError:
   quit(0)

case task["status"].getStr(): 
  of "completed","deleted":
    let p = startProcess(command="/data/data/com.termux/files/usr/bin/termux-notification-remove",args=[task["uuid"].getStr()])
  of "pending":
    let p = startProcess(command="/data/data/com.termux/files/usr/bin/termux-notification",
                         args=["--id", task["uuid"].getStr(),
                               "--title", task["description"].getStr(),
                               "--content", task["status"].getStr(),
                               "--priority", "low",
                               "--button1", "Done",
                               "--button1-action","task $1 done" % [task["uuid"].getStr()],
                               "--button2", "Modify",
                               "--button2-action","task diagnostic"])
