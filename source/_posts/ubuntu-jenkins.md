title: 'Ubuntu Jenkins'
date: 2020-07-28 16:27:35
tags: [Ubuntu, Jenkins]
categories: [Tools]
---

sudo apt install openjdk-8-jre-headless
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
echo deb https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list
sudo apt-get update
sudo apt-get install jenkins
