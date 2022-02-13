# Infrastructure bootstrap

This bootstrap module is a step that creates:
- the core project that host all resources (not the optimal setup but due to the lack of an organization, embedding projects in folders is not possible)
- the GCS bucket that stores the terraform state
- the terraform service account and grants it the appropriate IAM permissions
- the Github Actions Workload Identity Federation with GCP (related [doc](https://github.com/google-github-actions/auth)) that allows the Actions Runner to (temporarily) impersonnate the terraform service account and perform high privilege operations safely `terraform apply`)
