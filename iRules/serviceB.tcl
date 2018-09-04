when HTTP_REQUEST {
   HTTP::respond 200 content {
      <html>
         <head>
            <title>Service B Page</title>
         </head>
         <body>
            <H1>Service B</h1>
            You have accessed service B
         </body>
      </html>
   } noserver Cache-Control no-cache Connection Close
}
