echo "run . ./env.sh"

export TF_VAR_AWS_REGION=us-east-1
export TF_VAR_COMPANY=Globomantics
export TF_VAR_PROJECT="Globo-Website"
export TF_VAR_AWS_PUBLIC_KEY_PATH=/Users/mex/.ssh/vex-rsa-virginia.pub
echo "Memo : BILLING CODE can't start with number or contain #"
export TF_VAR_BILLING_CODE="G1080"
env|grep TF_VAR
