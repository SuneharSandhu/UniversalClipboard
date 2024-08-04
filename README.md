<!-- PROJECT LOGO -->
<div align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="https://github.com/user-attachments/assets/81cd8ee6-504f-4276-9582-68f4d1d03595" alt="Logo" width="150" height="80">
  </a>

  <h3 align="center">UniversalClipboard</h3>

  <p align="center">
    A lightweight app to be able to copy text from a windows machine and be able to <br /> immediately paste on all apple devices and vice versa!
    <br />
    <br />
    <br />
  </p>
</div>

<!-- GETTING STARTED -->
## Getting Started

### Prerequisites
- MacOS 13.0 or >
- XCode 
- NodeJS

### Installation
1. Clone the repo
   ```sh
   git clone https://github.com/SuneharSandhu/UniversalClipboard.git
   ```
2. On a Mac, open `UniversalClipboard.xcodeproj`
3. On a windows machine, start the websocket server from terminal:
   - ```
     node server.js
     ```
   - You should see this:
      <br />
     ![server](https://github.com/user-attachments/assets/3de92629-bd68-4b84-bb67-79b3bc7b42ad)



   - Download Ngrok: `https://ngrok.com/download` (allows clients to connect to server without being on localhost)
   - Open up another terminal and start the port forwarding:
     ```
      ngrok tcp 8080
     ```
     You should see something like this in the terminal:
       <br />
       <br />
       <img src="https://github.com/user-attachments/assets/c35a53a6-cd31-45c4-9b42-f313e0cb59aa" >
       
 5. Copy the address from the forwarding line and paste that in the index.html here:
    ![socket](https://github.com/user-attachments/assets/ac08da3a-8726-422c-acbf-b258a574d82f)

    **Note**: Prefix with `ws` instead of `tcp` here.

 6. Now in yet again another terminal, start the http server:
    ```
    http-server -p 8889 // you can use any port number here
    ```
 7. Open up a browser and type in localhost:8889
    - You should see 'Client connected' printed out in the server.js terminal
       <br />
       ![web](https://github.com/user-attachments/assets/e8cb3a4d-a3f0-4652-9433-4abfb1218fbc)
    - Webpage UI
      <br />
      ![html](https://github.com/user-attachments/assets/ef13c591-10c7-4f8b-963c-f78c71e2da76)
 #### WebClient and Server are now fully setup ✅
 <br />

 8. Now open `UniversalClipboard.xcodeproj` in XCode on your Mac and paste the same forwarding address you pasted in `index.html` in the `WebsocketManager.swift` file
 9. Now run the project and you should see a menu bar icon at the top like so:
    <br />
    <img width="547" alt="Screenshot 2024-08-03 at 7 19 25 PM" src="https://github.com/user-attachments/assets/20b731b9-9261-47e5-b63e-56bc1c2d7ea8">

    **Note:** If you see a slash, it means it either failed to connect to the websocket or the server isnt running.
