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


PIC_FOLDER = "../photos"
template   = fs.readFileSync 'emailTemplate.eco', 'utf-8'


# - - - - - parseDataEmail 
# - - - - - Parse essential info out of the filename

parseDataEmail = (filename)=>
  file = filename.split("_")
  emailAddress = file[0]
  
  personName = file[1]
  if personName == "null"
    personName = "Someone"
  else
    personName = personName[0].toUpperCase() + personName[1..-1]
  
  created =  file[2].split("-")
  day = created[0]
  time = created[1].replace /\./g, ':'
  newTime = new Date( "#{day}-#{time}")
  
  cardOrigin = file[3].substring(0, file[3].length-4)            # remove .png
  
  
  newDate = calculateSendDate( newTime, cardOrigin )
  cardOrigin = cardOrigin[0].toUpperCase() + cardOrigin[1..-1]   # capitalize origin
  console.log "created on #{newTime} on #{cardOrigin}"
  console.log "sending on #{newDate.sendDate} to #{emailAddress}"
  
  console.log newDate.timeDelayed
    
  email   : emailAddress
  person  : personName
  date    : newDate.sendDate
  created : newTime.toString("MMMM dS, yyyy")
  origin  : cardOrigin
  duration : newDate.timeDelayed



# - - - - - calculateSendDate
# - - - - - Calculate the date to send the email 

calculateSendDate = (cardCreated, cardOrigin) =>
  location = postcards[ cardOrigin ]
  formatted = 0
  sendDate  = 0
  
  if location
    duration =  ("#{len} #{unit}" for unit, len of location)
    formatted = duration.join(" and ")
     
    console.log formatted
    
  timeDelayed : formatted
  sendDate    : cardCreated.add( location ) 
 


# - - - - - Connect to the mail server 
 
server  = email.server.connect
   
   user     : "adleremailer2"
   password : "Neptune2012!"
   ssl      : true
   host     : "smtp.gmail.com"
   
# - - - - - Monitor the picture folder for filechanges


createOK = false

watch.createMonitor PIC_FOLDER, (monitor)=> 
  monitor.on "created", (f,stat)=>
  
  	if createOK==true 
    	console.log "------- file change --------"
	    pic = f.split("/")[2]
	    currPic = parseDataEmail( pic )
	    console.log "scheduling email"
	    if currPic.date
	      toSend = Date.compare( currPic.date, Date.today().setTimeToNow() )
	    else
	      toSend = -1
	    
	    if toSend >= 0 and currPic.email isnt "null" and currPic.date
	      console.log "IT'S OK TO SEND THIS"
	      sendEmail( currPic, pic )
	      
    	createOK=false
    	
  	else 
   		createOK=true

    
# - - - - - sendEmail 
# - - - - - Send an email based on a certain date 

sendEmail = (details, fname) =>
  
  schedule.scheduleJob details.date, =>
  
	  console.log "sending to #{details.email} on #{details.date}"
	  server.send
	    text:    eco.render template, details
	    from:    "The adler <adleremailer2@gmail.com>"
	    to:      details.email
	    bcc:     "christina.lin.yang@gmail.com"
	    subject: "Greetings from the Universe!"
	    attachment: [
	      data: "<html>i <i>hope</i> this works!</html>"          
	      ,
	      type: "image/png"
	      path: "#{PIC_FOLDER}/#{fname}"
	      name: "adler.jpg"
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
    if currPic.date
      toSend = Date.compare( currPic.date, Date.today().setTimeToNow() )
    else
      toSend = -1
    
    if toSend >= 0 and currPic.email isnt "null" and currPic.date
      
      sendEmail( currPic, pic )
    

treeWalk()