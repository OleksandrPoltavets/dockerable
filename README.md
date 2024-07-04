# Rails 7.1 + Docker deployment to AWS EC2
## Step by step guide

### 1.  Create new **Rails APP**

- `rails new dockerable --api -d postgresql`
- `rails db:create`
- `rails generate scaffold Post title:string body:text`
- `rails db:migrate`
- `rails db:seed`

### 2.  Configure **GIT**

- `cd /path/to/your/rails_project`
- `git init`
- `git remote add origin git@github.com:OleksandrPoltavets/dockerable.git`
- `git add .`
- `git commit -m "Initial commit"`
- `git branch -M main`
- `git push -u origin main`

### 3.  Verify app via **HTTP** (curl or Postman) [optional]

- `curl http://localhost:3000/posts`
- `curl -X POST -H "Content-Type: application/json" -d '{"post": {"title": "New Post", "body": "This is the body of the new post."}}' http://localhost:3000/posts`

### 4. Configure `Dockerfile`

- *see `Dockerfile` file withing this gist*

### 4. Configure `docker-compose.yml`

- *see `docker-compose.yml` file withing this gist*

### 5. **ENV** file

- *see `.ENV` file withing this gist*
- RAILS_MASTER_KEY value is the value of `config/master.key` file

### 6. **Docker** build & run (localhost)

  Don't forget to disable SSL (`config.force_ssl = true`) for production if you don't have it configured locally and want to run 
rails server in production env.

- `docker-compose build`
- `docker-compose up` or `docker-compose up -d`
- [optional] `docker-compose exec web rails console` <- run rails console inside docker container 

You should be able to see Rails server up and running locally on http://localhost:3000

### 7. **AWS EC2** linux server

- *EC2 > Instances > Launch an instance > Ubuntu 24.04*
- Generate and save `.pem` key to your development environment: `dockerable-ec2.pem`
- enable http/https web access `0.0.0.0/0`

- SSH to the EC2 server
  - `sudo ssh -i dockerable-ec2.pem ubuntu@your-ec2-public-ip`
- Install **Docker** / **Docker Compose** on Ubuntu server
  - Docker: https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
  - Docker Compose: https://docs.docker.com/compose/install/linux/#install-using-the-repository
- Generate an SSH Key Pair (for GitHub)
  - `sudo ssh-keygen -t rsa`
- Add the SSH Key to Your GitHub Account (general settings)
  - `sudo cat ~/.ssh/id_rsa.pub`
- `sudo git clone git@github.com:OleksandrPoltavets/dockerable.git`
- `cd dockerable`
- `sudo nano .env` <- paste all EVN variables
- `sudo docker-compose build`
- `sudo docker-compose up -d` # `start/stop/remove`
- `sudo docker-compose ps` <- to see status
- `sudo docker-compose logs web` / `docker-compose logs db`

- **Expose port 3000 to the World !!!**
  - EC2 instance -> Security Groups -> Edit inbound rules -> Add Rule -> Custom TCP -> port 3000 : 0.0.0.0/0

### 8. NGINX
- `sudo apt install nginx`
- `sudo nano /etc/nginx/sites-available/dockerable` <- add nginx config and save file
- `sudo ln -s /etc/nginx/sites-available/dockerable /etc/nginx/sites-enabled/`
- `sudo rm /etc/nginx/sites-enabled/default`
- `sudo service nginx restart`

---

### 9. CI/CD GitHub Actions *(BONUS)*
- Set Up SSH Access from GitHub Actions to EC2
  - `ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`
  - filename `~/.ssh/github_actions`
- Copy the **PUBLIC** `.pub` Key to Your EC2 Instance
  -  ssh-copy-id -i ~/.ssh/github_actions.pub ubuntu@your-ec2-public-ip
  -  make sure you received: `Number of key(s) added: 1`
- Add the **PRIVATE** Key + other data to GitHub Secrets
  - repository on GitHub `Settings > Secrets and variables > Actions`
  - name: `EC2_SSH_KEY` and add public key from `cat .ssh/github_actions`
  - name: `EC2_HOST`, value: `your-ec2-public-ip`
  - name: `EC2_USER`, value: `ubuntu`
- Create a GitHub Actions Workflow
  - in Github repo create a directory `.github/workflows`
  - in `.github/workflows` create a file `deploy.yml` <- see example withing current gist
- Deploy Changes
  - `git add .`
  - `git commit -m "Set up GitHub Actions for deployment"`
  - `git push origin main`
  - check Github actions for any errors for the latest commit (this commit should trigger the deployment to EC2)
- ENJOY!
