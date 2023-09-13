#!/bin/bash

# Elenco template
template_files=("vpc.yaml" "security-group.yaml" "load-balancer.yaml" "rds.yaml" "ec2.yaml" "cloudfront.yaml")

# Elenco parametri json
parameter_files=("vpcpar.json" "sgpar.json" "lbpar.json" "rdspar.json" "ec2par.json" "cloudfrontpar.json")

# controllo se numero di template =  file di parametri  per evitare errori
if [ ${#template_files[@]} -ne ${#parameter_files[@]} ]; then
  echo "Il numero di file di template e file di parametri non corrisponde."
  exit 1
fi

# Itera attraverso gli elenchi dei file di template e crea gli stack con i parametri corrispondenti
for ((i=0; i<${#template_files[@]}; i++)); do
  template_file="${template_files[i]}"
  parameter_file="${parameter_files[i]}"
  stack_name=$(basename "$template_file" .yaml)  # Estrarre il nome dello stack dal nome del file
  
  aws cloudformation create-stack \
    --stack-name "$stack_name" \
    --template-body "file://./CloudFormation/$template_file" \
    --parameters "file://./Parameters/$parameter_file"
  
  # Attendere che lo stack si crei completamente prima di passare al successivo , altrimenti si rischia Rollback
  aws cloudformation wait stack-create-complete --stack-name "$stack_name"
done
