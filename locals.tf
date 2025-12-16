locals {
  docker_user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io docker-compose
    systemctl enable docker
    systemctl start docker
  EOF

  gitlab_runner_user_data = <<-EOF
    #!/bin/bash
    curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash
    apt-get install -y gitlab-runner docker.io
    systemctl enable docker gitlab-runner
    systemctl start docker gitlab-runner
  EOF

  instances = {
    deploy-dev = {
      subnet_id = aws_subnet.subnet_1.id
      role      = "deployment"
      user_data = local.docker_user_data
    }

    deploy-staging = {
      subnet_id = aws_subnet.subnet_1.id
      role      = "deployment"
      user_data = local.docker_user_data
    }

    deploy-prod = {
      subnet_id = aws_subnet.subnet_1.id
      role      = "deployment"
      user_data = local.docker_user_data
    }

    docker-runner = {
      subnet_id = aws_subnet.subnet_2.id
      role      = "gitlab-runner"
      executor  = "docker"
      user_data = local.gitlab_runner_user_data
    }

    shell-runner = {
      subnet_id = aws_subnet.subnet_2.id
      role      = "gitlab-runner"
      executor  = "shell"
      user_data = local.gitlab_runner_user_data
    }
  }
}
