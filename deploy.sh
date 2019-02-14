# Input variables
echo "Please enter the name of your AWS ssh-keypair: "
read -r SSH_KEYPAIR
echo "Please enter desired stack name: "
read -r STACK_NAME
echo "How many k8s computes do you want: "
read -r CMP_COUNT

# Stack creation
aws cloudformation create-stack --stack-name $STACK_NAME --disable-rollback --template-body file://cfn/k8s_ha_calico.yml --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=KeyName,ParameterValue=${SSH_KEYPAIR} ParameterKey=NodeCluster,ParameterValue=virtual-mcp11-k8s-calico-aws ParameterKey=CmpNodeCount,ParameterValue=$CMP_COUNT

date
echo "Please wait until cfn stack is being created, it takes around 15 minutes to spin everything up ☕"
until aws cloudformation describe-stacks --stack-name $STACK_NAME --query 'Stacks[0].StackStatus'  | grep -q CREATE_COMPLETE; do
	sleep 60
	date
	echo "Stack ${STACK_NAME} is still creating..."
done

# Output
JENKINS_IP=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Outputs[?OutputKey=='SaltMasterPublicIP'].OutputValue" --output text)
echo "${STACK_NAME} is up, Jenkins is at http://${JENKINS_IP}:18081/"
echo "Log in with admin:r00tme"

echo "Access the environment over ssh:"
echo "ssh ubuntu@${JENKINS_IP} -A"
