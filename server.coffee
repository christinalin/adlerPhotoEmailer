watch = require('watch')
email = require('emailjs')
schedule= require('node-schedule')
require('datejs')
fs = require('fs')
eco = require('eco')

postcards = require('./postcards')

# Filename must be formatted: 
# christina.lin.yang@gmail.com_2012.06.30-08/43/02_neptune.png
# email_year.month.year-hour/minute/second_origin.extension


PIC_FOLDER = "pics"
template   = fs.readFileSync 'emailTemplate.eco', 'utf-8'


# - - - - - parseDataEmail 
# - - - - - Parse essential info out of the filename

parseDataEmail = (filename)=>
  file = filename.split("_")
  
  emailAddress = file[0]
  created = new Date( file[1] )
  cardOrigin = file[2].substring(0, file[2].length-4) # remove .png
  
  newDate = calculateSendDate( created, cardOrigin )
  
  console.log "created on #{created}"
  
  email   : emailAddress
  date    : newDate
  created : created
  origin  : cardOrigin



# - - - - - calculateSendDate
# - - - - - Calculate the date to send the email 

calculateSendDate = (cardCreated, cardOrigin) =>
  
  cardCreated.add( postcards[ cardOrigin ] )  
 
 
 
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
    sendEmail( details, fname )
    
    
    
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
    toSend = Date.compare( currPic.date, Date.today().setTimeToNow() )
    
    if toSend >= 0
      sendEmail( currPic, pic )
    

treeWalk()