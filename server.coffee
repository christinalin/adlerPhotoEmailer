watch = require('watch')
email = require('emailjs')
schedule= require('node-schedule')
require('datejs')
fs = require('fs');

PIC_FOLDER = "pics"

postcards = 
  neptune: "4.2 hours",
  voyager: "16 hours",
  proxima: "4.2 years"

# Filename must be formatted: 
# christina.lin.yang@gmail.com_2012.06.30-08/43/02

parseDataEmail = (filename)=>
  emailAddress = filename.split("_")[0]
  dateTime = new Date(filename.split("_")[1])
  {email: emailAddress.split("/")[1], date: dateTime}


server  = email.server.connect
   user:    "adlerphotoemail" 
   password:"adlerPhotoEmail"
   host:    "smtp.gmail.com"
   ssl:     true


watch.createMonitor PIC_FOLDER, (monitor)=> 
  monitor.on "created", (f,stat)=>
    details = parseDataEmail(f)
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
    now = Date.today().setTimeToNow()
    picDateTime = currPic.date
    
    console.log picDateTime 

treeWalk()     