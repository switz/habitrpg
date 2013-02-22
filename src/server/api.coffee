express = require 'express'
router = new express.Router()

scoring = require '../app/scoring'
_ = require 'underscore'
icalendar = require('icalendar')

NO_TOKEN_OR_UID = err: "You must include a token and uid (user id) in your request"
NO_USER_FOUND = err: "No user found."

# ---------- /v1 API ------------
# Every url added beneath router is prefaced by /v1

###
  v1 API. Requires user-id and apiToken, task-id, direction. Test with:
  curl -X POST -H "Content-Type:application/json" -d '{"apiToken":"{TOKEN}"}' localhost:3000/v1/users/{UID}/tasks/productivity/up
###

router.get '/status', (req, res) ->
  res.json
    status: 'up'

router.get '/user', (req, res) ->
  console.log 'hi', { uid, token } = req.query
  return res.json 500, NO_TOKEN_OR_UID unless uid || token

  model = req.getModel()
  query = model.query('users').withIdAndToken(uid, token)

  query.fetch (err, user) ->
    return res.json 500, err: err if err
    self = user.at(0).get()
    console.log self
    return res.json 500, NO_USER_FOUND if !self || _.isEmpty(self)

    return res.json self

router.post '/task', (req, res) ->
  { uid, token, type, text, notes } = req.body
  return res.json 500, NO_TOKEN_OR_UID unless uid || token
  # Don't add a blank task
  return res.json err: "Task text entered was an empty string." if /^(\s)*$/.test(text)

  model = req.getModel()
  query = model.query('users').withIdAndToken(uid, token)

  query.fetch (err, user) ->
    return res.json 500, err: err if err
    self = user.at(0).get()
    return res.json 500, NO_USER_FOUND if !self || _.isEmpty(self)

    newModel = model.at('_new' + type.charAt(0).toUpperCase() + type.slice(1))
    text = newModel.get()

    newModel.set ''
    switch type

      when 'habit'
        list.unshift {type: type, text: text, notes: '', value: 0, up: true, down: true}

      when 'reward'
        list.unshift {type: type, text: text, notes: '', value: 20 }

      when 'daily'
        list.unshift {type: type, text: text, notes: '', value: 0, repeat:{su:true,m:true,t:true,w:true,th:true,f:true,s:true}, completed: false }

      when 'todo'
        list.unshift {type: type, text: text, notes: '', value: 0, completed: false }


router.get '/user/calendar.ics', (req, res) ->
  #return next() #disable for now
  {uid} = req.params
  {apiToken} = req.query

  model = req.getModel()
  query = model.query('users').withIdAndToken(uid, apiToken)
  query.fetch (err, result) ->
    return res.send(500, err) if err
    tasks = result.at(0).get('tasks')
    #      tasks = result[0].tasks
    tasksWithDates = _.filter tasks, (task) -> !!task.date
    return res.send(500, "No events found") if _.isEmpty(tasksWithDates)

    ical = new icalendar.iCalendar()
    ical.addProperty('NAME', 'HabitRPG')
    _.each tasksWithDates, (task) ->
      event = new icalendar.VEvent(task.id);
      event.setSummary(task.text);
      d = new Date(task.date)
      d.date_only = true
      event.setDate d
      ical.addComponent event
    res.type('text/calendar')
    formattedIcal = ical.toString().replace(/DTSTART\:/g, 'DTSTART;VALUE=DATE:')
    res.send(200, formattedIcal)

module.exports = router
