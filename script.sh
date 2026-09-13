# 1. Clonar o repositório e entrar na pasta
git clone https://github.com/annaclrl/vetly-cloud.git

cd vetly-cloud

# 2. Registrar o provedor de Web Apps na assinatura Azure (necessário uma vez por assinatura)
az provider register --namespace Microsoft.Web

# 3. Criar o grupo de recursos na Azure
az group create \
  --name rg-vetly \
  --location canadacentral

# 4. Criar o App Service Plan
az appservice plan create \
  --name vetly-plan \
  --resource-group rg-vetly \
  --location canadacentral \
  --sku B1 \
  --is-linux

# 5. Criar o Web App
az webapp create \
  --resource-group rg-vetly \
  --plan vetly-plan \
  --name vetly-app \
  --runtime "JAVA:21-java21"

# 6. Configurar as variáveis de ambiente da aplicação
az webapp config appsettings set \
  --resource-group rg-vetly \
  --name vetly-app \
  --settings \
  DB_URL="jdbc:oracle:thin:@//oracle.fiap.com.br:1521/orcl" \
  DB_USERNAME="rm561928" \
  DB_PASSWORD="100107" \
  ADMIN_EMAIL="admin@vetly.com.br" \
  ADMIN_PASSWORD="Admin@123"

# 7. Build da aplicação
./gradlew clean build -x test

# 8. Deploy do JAR gerado no App Service
az webapp deploy \
  --resource-group rg-vetly \
  --name vetly-app \
  --src-path build/libs/vetly-java-0.0.1-SNAPSHOT.jar \
  --type jar