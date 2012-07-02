watch = require('watch')
email = require('emailjs')
schedule= require('node-schedule')
require('datejs')
fs = require('fs');

PIC_FOLDER = "pics"

postcards = 
  neptune: 
    minutes: 12
  voyager: 
    hours: 16           
  proxima:
    years: 4
    days: 73     


# Filename must be formatted: 
# christina.lin.yang@gmail.com_2012.06.30-08/43/02_neptune

parseDataEmail = (filename)=>
  file = filename.split("_")
  
  emailAddress = file[0]
  created = new Date( file[1] )
  cardOrigin = file[2]
  
  newDate = addLightYears( created, cardOrigin )
  
  { email: emailAddress, date: newDate, origin: cardOrigin }


addLightYears = (cardCreated, cardOrigin) =>
  
  now = Date.today().setTimeToNow() 
  now.add( postcards[ cardOrigin ] )  
  
server  = email.server.connect
   user:    "adlerphotoemail" 
   password:"adlerPhotoEmail"
   host:    "smtp.gmail.com"
   ssl:     true


watch.createMonitor PIC_FOLDER, (monitor)=> 
  monitor.on "created", (f,stat)=>
    details = parseDataEmail(f.split("/")[1])
    console.log "scheduling email"
    sendEmail( details.date, details.email )
    
sendEmail = (sendDate, address) =>

  schedule.scheduleJob sendDate, =>
  console.log "sending to #{address}"
  
  server.send
    text:    "i hope this works"
    from:    "The adler <username@gmail.com>"
    to:      address
    subject: "testing emailjs"
    attachment: [
      data: "<html>i <i>hope</i> this works!</html>"          
      ,
      type: "image/png"
      path: "pics/test.png"
      ]
    
  , (err, message)=>
    console.log err || message
        
treeWalk = -> 
  folder = fs.readdirSync(PIC_FOLDER)         
  
  for pic in folder when pic isnt ".DS_Store"
    currPic = parseDataEmail ( pic.toString() )
    toSend = Date.compare( currPic.date, Date.today().setTimeToNow() )
    
    if toSend == 0 or toSend == 1    
      sendEmail( currPic.date, currPic.email )
    

treeWalk()     