watch = require('watch')
email = require('emailjs')
schedule= require('node-schedule')
require('datejs')
fs = require('fs')
eco = require('eco')

postcards = require('./postcards')

# Filename must be formatted: 
# christina.lin.yang@gmail.com_christina_2012.06.30-08/43/02_neptune.png
# email_name_year.month.year-hour/minute/second_origin.extension


PIC_FOLDER = "pics"
template   = fs.readFileSync 'emailTemplate.eco', 'utf-8'


# - - - - - parseDataEmail 
# - - - - - Parse essential info out of the filename

parseDataEmail = (filename)=>
  file = filename.split("_")
  
  emailAddress = file[0]
  personName = file[1]
  created = new Date( file[2] )
  cardOrigin = file[3].substring(0, file[3].length-4) # remove .png
  
  newDate = calculateSendDate( created, cardOrigin )
  
  console.log "created on #{created}"
  console.log "cardOrigin #{cardOrigin}"
  
  email   : emailAddress
  person  : personName
  date    : newDate
  created : created
  origin  : cardOrigin



# - - - - - calculateSendDate
# - - - - - Calculate the date to send the email 

calculateSendDate = (cardCreated, cardOrigin) =>

  cardCreated.add( postcards[ cardOrigin ] ) if postcards[ cardOrigin ] else 0 
 
 
 
# - - - - - Connect to the mail server 
 
server  = email.server.connect
   user     : "adleremailer2" 
   password : "Neptune2012!"
   host     : "smtp.gmail.com"
   ssl      : true
   
   

# - - - - - Monitor the picture folder for filechanges

watch.createMonitor PIC_FOLDER, (monitor)=> 
  monitor.on "created", (f,stat)=>
    
    fname = f.split("/")[1]
    details = parseDataEmail( fname )
    console.log "scheduling email"
    sendEmail( details, fname ) if details.date
    
    
    
# - - - - - sendEmail 
# - - - - - Send an email based on a certain date 

sendEmail = (details, fname) =>
  
  schedule.scheduleJob details.date, =>
  console.log "sending to #{details.email} on #{details.date}"
  
  
  server.send
    text:    eco.render template, details
    from:    "The adler <username@gmail.com>"
    to:      details.email
    subject: "testing emailjs"
    attachment: [
      data: "<html>i <i>hope</i> this works!</html>"          
      ,
      type: "image/png"
      path: "#{PIC_FOLDER}/#{fname}"
      ]
    
  , (err, message)=>
    console.log err || message
        
        
# - - - - - treeWalk 
# - - - - - Walk through the picture folder and schedule images to be sent

treeWalk = -> 
  folder = fs.readdirSync(PIC_FOLDER)         
  
  for pic in folder when pic isnt ".DS_Store"
    console.log "----------"
    currPic = parseDataEmail ( pic.toString() )
    toSend = if currPic.date then Date.compare( currPic.date, Date.today().setTimeToNow() ) else -1
    
    if toSend >= 0 and currPic.email isnt "null" and currPic.date
      sendEmail( currPic, pic )
    

treeWalk()