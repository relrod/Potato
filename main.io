#!/usr/bin/env io

Potato := Object clone do (
  __GET_methods__ := Map clone
  __POST_methods__ := Map clone

  GET := method(route, implementation,
    __GET_methods__ atPut(route, implementation)
  )

  POST := method(route, implementation,
    __POST_methods__ atPut(route, implementation)
  )

  server := Object clone
  server port := 2000

  ok := method(body,
    response := "HTTP/1.1 200 OK\n\n"
    response = response .. body
    response
  )

  bad_request := method(body,
    response := "HTTP/1.1 400 Bad Request\n\n"
    response = response .. body
    response
  )

  server handleRequest := method(sock,
    sock streamReadNextChunk
    if (sock readBuffer beginsWithSeq("GET"),
      requestPath := sock readBuffer betweenSeq("GET ", " HTTP")
      "#{sock ipAddress}: #{requestPath}" interpolate println
      if (Potato __GET_methods__ keys contains(requestPath)) then (
        sock write(Potato __GET_methods__ at(requestPath) call)
        sock close
      ) else (
        response := "HTTP/1.1 404 Not Found\n\n"
        response = response .. "<b>404!</b>"
      )
    )
  )

  server serve := method(
    Server clone do (
      setPort(Potato server port)
      handleSocket := method (sock,
        Potato server @handleRequest(sock)
      )
      start
    )
  )

  run := method(server serve)

  form := Object clone do (
    field := Object clone do (

    )
  )
)

# Create a new Potato app.
app := Potato clone

# Another way of doing this is changing the variables which set the defaults
# then not overriding the serve method. Either of these options work just fine.
app server port := 2001

# Let's create a simple method.
app GET("/", block(
  f := File with("potato.html") openForReading contents
  app ok(f)
))

app GET("/random", block(
  app ok(Random value(100000) floor)
))

# And a simple method dealing with GET arguments.
app GET("/greet", block(
//  name := app args at("name")
//  app ok("Greetings, #{name}" interpolate)
))

app run
