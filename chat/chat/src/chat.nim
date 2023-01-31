import std/[asyncnet, asynchttpserver, asyncdispatch, asyncfutures, deques, json, sequtils, sugar]

const
  index = staticRead("index.html")
  linesep = "\c\L"

const ads {.booldefine.}: bool = false

when(ads):
  import std/random
  const
    adTexts = [
      "drink pepsi",
      "eat mcdonalds",
      "buy hp",
      "buy apple",
      "buy samsung",
      "buy dell",
      "drive bmw",
      "eat kfc",
      "drink heineken",
      "drink coca cola",
      "drive audi",
      "drive tesla",
    ]

type
  ChatServer = ref object
    chatClients: seq[AsyncSocket]
    counter: int
    messages: Deque[ChatMessage]
  ChatMessage = ref object
    name: string
    message: string

proc sendEvent(cs: ChatServer, c: AsyncSocket, id: int, eventName: string, eventData: JSONNode): Future[void] =
  c.send(
    "id: " & $id & linesep &
    "event: " & eventName & linesep &
    "data: " & $eventData & linesep & linesep
  )

proc handleLive(cs: ChatServer, req: Request) {. async .} =
    await req.client.send("HTTP/1.1 200 OK" & linesep)
    let hdrs = newHttpHeaders([
      ("Content-type", "text/event-stream"),
    ])
    await req.sendHeaders(hdrs)
    await req.client.send(linesep)
    cs.chatClients.add req.client
    for msg in cs.messages:
      await sendEvent(cs, req.client, 0, "say", %* msg)

proc handleSay(cs: ChatServer, req: Request) {. async .} =
    let parsed = parseJson(req.body).to(ChatMessage)

    when(ads):
      parsed.message = parsed.message & "... also, remember to " & sample adTexts

    let evtId = cs.counter
    inc cs.counter

    cs.chatClients = collect:
      for c in cs.chatclients:
        if not c.isClosed:
          c
    cs.messages.addLast parsed
    while cs.messages.len > 10:
      cs.messages.popFirst

    let futs = map(cs.chatClients, proc(c: AsyncSocket): Future[void] =
      cs.sendEvent(c, cs.counter, "say", %* parsed)
    )
    await all futs
    await req.respond(Http200, "ok")

proc handleRequest(cs: ChatServer, req: Request) {. async .} =
  if req.url.path == "/" and req.reqMethod == HttpGet:
    await req.respond(Http200, index)
  elif req.url.path == "/live" and req.reqMethod == HttpGet:
    await cs.handleLive(req)
  elif req.url.path == "/say" and req.reqMethod == HttpPost:
    await cs.handleSay(req)
  else:
    await req.respond(Http404, "404")

proc main: Future[void] =
  let server = newAsyncHttpServer()
  let cs = ChatServer(counter: 0)
  echo "ads", ads
  echo "listening on port 8080"
  server.serve(
    port=8080.Port,
    callback=proc(req: Request): Future[void] = cs.handleRequest(req)
  )

when(isMainModule):
  waitFor main()
