## How to use this repo on Ubuntu server

#Switch to core-main directiory
`cd core-main`

Access as a Super User
`sudo su`

Run docker command to run the repo
`docker run --rm -it -v core-main-storage:/rails/storage -p 3000:3000 app:custom-tag`
