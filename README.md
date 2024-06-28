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

### 3.  Verify app via **HTTP** (or Postman)

- `curl http://localhost:3000/posts`
- `curl -X POST -H "Content-Type: application/json" -d '{"post": {"title": "New Post", "body": "This is the body of the new post."}}' http://localhost:3000/posts`

### 4. Configure **Dockerfile**

- *see docker-compose.yml file withing this gist*

### 5. **ENV** file

- *see .ENV file withing this gist*

### 6. **Docker** build & run (development)

- `docker-compose build`
- `docker-compose up / docker-compose up -d`
- `docker-compose exec web rails console`

### 7. **AWS EC2** server

- *EC2 > Instances > Launch an instance > Ubuntu 22.04*
- Generate and save `.pem` key
- enable http/https web access `0.0.0.0/0`

- SSH to the EC2 server
    - `ssh -i dockerable-ec2.pem ubuntu@your-ec2-public-ip`
- Generate an SSH Key Pair
    - `ssh-keygen -t rsa`
- Add the SSH Key to Your GitHub Account
    - `cat ~/.ssh/id_rsa.pub`
- `git clone git@github.com:OleksandrPoltavets/dockerable.git`
- `cd dockerable`
- `nano .env` <- paste all EVN variables
- `docker-compose build`
- `docker-compose up -d` # `start/stop/remove`
- `docker-compose ps` <- to see status
- `docker-compose logs web` / `docker-compose logs db`

- **Expose port 3000 to the World !!!**
  - EC2 instance -> Security Groups -> Edit inbound rules -> Add Rule -> Custom TCP -> port 3000 : 0.0.0.0/0

### 8. NGINX
- `sudo apt install nginx`
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
