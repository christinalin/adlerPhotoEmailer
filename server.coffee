watch = require('watch')
email = require('emailjs')
schedule= require('node-schedule')
require('datejs')
fs = require('fs');


# Filename must be formatted: 
# christina.lin.yang@gmail.com_2012.06.30-08/43/02_neptune



PIC_FOLDER = "pics"

postcards = 
  neptune: 
    minutes: 12
  voyager: 
    hours: 16           
  proxima:
    years: 4
    days: 73     



# - - - - - parseDataEmail 
# - - - - - Parse essential info out of the filename

parseDataEmail = (filename)=>
  file = filename.split("_")
  
  emailAddress = file[0]
  created = new Date( file[1] )
  cardOrigin = file[2]
  
  newDate = calculateSendDate( created, cardOrigin )
  
  { email: emailAddress, date: newDate, origin: cardOrigin }



# - - - - - calculateSendDate
# - - - - - Calculate the date to send the email 

calculateSendDate = (cardCreated, cardOrigin) =>
  
  now = Date.today().setTimeToNow() 
  now.add( postcards[ cardOrigin ] )  
 
 
 
# - - - - - Connect to the mail server 
 
server  = email.server.connect
   user:    "adlerphotoemail" 
   password:"adlerPhotoEmail"
   host:    "smtp.gmail.com"
   ssl:     true
   
   

# - - - - - Monitor the picture folder for filechanges

watch.createMonitor PIC_FOLDER, (monitor)=> 
  monitor.on "created", (f,stat)=>
    details = parseDataEmail(f.split("/")[1])
    console.log "scheduling email"
    sendEmail( details.date, details.email )
    
    
    
# - - - - - sendEmail 
# - - - - - Send an email based on a certain date 

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
        
        
# - - - - - treeWalk 
# - - - - - Walk through the picture folder and schedule images to be sent

treeWalk = -> 
  folder = fs.readdirSync(PIC_FOLDER)         
  
  for pic in folder when pic isnt ".DS_Store"
    currPic = parseDataEmail ( pic.toString() )
    toSend = Date.compare( currPic.date, Date.today().setTimeToNow() )
    
    if toSend == 0 or toSend == 1    
      sendEmail( currPic.date, currPic.email )
    

treeWalk()     