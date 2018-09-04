when HTTP_REQUEST {
   HTTP::respond 200 content {
      <html>
         <head>
            <title>Service A Page</title>
         </head>
         <body>
            <H1>Service A</h1>
            You have accessed service A
         </body>
      </html>
   } noserver Cache-Control no-cache Connection Close
}
