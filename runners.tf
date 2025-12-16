# # Runner Docker
# # resource "gitlab_runner" "docker_runner" {
# #   description        = "Runner Docker sur VM"
# #   run_untagged       = true
# #   locked             = false
# #   tag_list           = ["docker", "ci"]
# #   registration_token = var.gitlab_registration_token
# # }

# # Runner Shell
# resource "gitlab_runner" "shell_runner" {
#   description        = "Runner Shell sur VM"
#   run_untagged       = true
#   locked             = false
#   tag_list           = ["shell", "ci"]
#   registration_token = var.gitlab_registration_token
# }
