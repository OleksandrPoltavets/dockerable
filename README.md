1)  Rails APP

    rails new dockerable --api -d postgresql
    rails db:create
    rails generate scaffold Post title:string body:text
    rails db:migrate
    rails db:seed

2)  GIT

    cd /path/to/your/rails_project
    git init   
    git remote add origin git@github.com:OleksandrPoltavets/dockerable.git
    git add .
    git commit -m "Initial commit"
    git branch -M main
    git push -u origin main

3)  HTTP

    curl http://localhost:3000/posts
    curl -X POST -H "Content-Type: application/json" -d '{"post": {"title": "New Post", "body": "This is the body of the new post."}}' http://localhost:3000/posts

4) Dockerfile

   see docker-compose.yml file withing this gist

5) ENV file

   see .ENV file withing this gist

6) Docker build & run (development)

   docker-compose build
   docker-compose up / docker-compose up -d
   docker-compose exec web rails console
    

    