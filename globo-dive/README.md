### Attention

## service consul
cd …globo-dive
cd consul
cat env.sh pour devenir root(consul) au cas où

consul agent -bootstrap -config-file="config/consul-config.hcl" -bind="127.0.0.1"

## networking
cd …globo-dive
cd net…
devenir MaryMoe avec env de consul
terraform init -backend-config="path=networking/state/globo-primary"

tf workspace list
tf workspace new/select development
tf plan/apply…
tf destroy

cf apps…
devenir SallySue avec env de consul
terraform init -backend-config="path=applications/state/globo-primary"
tf workspace list
tf workspace new/select development
tf plan/apply…
tf destroy

