import json, rdstdin, strutils, osproc, system, os, docopt

proc listTasks(filter : string): JsonNode =
  var tasks : JsonNode
#  try:
  tasks = execProcess("task " & filter & " export").parseJson
#  except JsonParsingError:
#    echo "Unable to parse task export, is taskwarrior installed?"
  return tasks

proc getTask(uuid: string): JsonNode =
  var task : JsonNode
  try:
    task = execProcess("task " & uuid & " status:pending export").parseJson
  except JsonParsingError:
    echo "Unable to parse task export, is taskwarrior installed?"
  return task[0]

let termuxdialog="/data/data/com.termux/files/home/termux-taskwarrior/termux-dialog" 
let termuxnotification = "/data/data/com.termux/files/usr/bin/termux-notification"

let doc = """
termux-task

Usage:
  termux-task add
  termux-task modify <uuid>
  termux-task notify <filter>
  termux-task list <filter>
Options:
  -h --help Show this screen
  -v --version
"""


let args = docopt(doc, version = "1")

echo $args["<filter>"]


if args["notify"]:
  var filter = $args["<filter>"]
  echo filter
  if filter != "":
    filter="status:pending"
  for task in listTasks(filter):
    echo task
    var content = task["status"].getStr()
    echo task{"due"}.getStr()

    let p = startProcess(command=termuxnotification,
        args=["--id", task["uuid"].getStr(),
        "--title", task["description"].getStr(),
        "--content", content,
        "--priority", "low",
        "--button1", "Done",
        "--button1-action","task $1 done" % [task["uuid"].getStr()],
        "--button2", "Modify",
        "--button2-action","task diagnostic"])


if args["modify"] or args["add"]: 
  var modifying = true
  var params = ""

  if args["modify"]:
    var task = getTask($args["<uuid>"])
    params &= execProcess(command=termuxdialog & " -t 'Modify Task' -h " & task["description"].getStr)
  else:
    params &= execProcess(command=termuxdialog & " -t 'New Task'")



  while true:
    let p = execProcess(command=termuxdialog & " sheet -v 'Due Date, Due Time, Schedule Date, Repeat, Done'").parseJson

    if p["code"].getInt() != -2:
      case p["text"].getStr():
        of "Due Date":
          let p = execProcess(command=termuxdialog & " date -d d").parseJson
          if p["code"].getInt() != -2:
            params&="due:" & p["text"].getStr()
        of "Due Time":
          let p = execProcess(command=termuxdialog & " time -d d").parseJson
          if p["code"].getInt() != -2:
            params&=p["text"].getStr()
        of "Schedule Date":
          let p = execProcess(command=termuxdialog & " date -d d").parseJson
          if p["code"].getInt() != -2:
            params&="due:" & p["text"].getStr()
        of "Repeat":
          let p = execProcess(command=termuxdialog & " repeat -d d").parseJson
          if p["code"].getInt() != -2:
            params&="repeat:" & p["text"].getStr()
        of "Done":
          if args["modify"]:
            let p = execProcess("task $1 modify $2" % [ $args["<uuid>"], params ])
          else:
            let p = execProcess("task add $2" % [params])
          break
