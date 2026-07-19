# for image in killux3k/api-gateway killux3k/billing-app killux3k/inventory-app killux3k/billing-queue killux3k/billing-db killux3k/inventory-db; do docker rmi -f $image:1.0.0; done

# DOMAIN_USER=969209892845.dkr.ecr.eu-west-3.amazonaws.com make push