@description('The location where the resources should be deployed.')
param location string

@description('The name of the environment to deploy in.')
param environmentName string = 'dev'

@description('The app service plan SKU')
param appServicePlanSku string = 'F1'

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: 'omexom-db-app-svc-plan-${environmentName}'
  location: location
  sku: {
    name: appServicePlanSku
  }
}

resource libraryServiceApp 'Microsoft.Web/sites@2021-02-01' = {
  name: 'omexom-db-libraries-${environmentName}-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

output libraryAppServiceHostName string = libraryServiceApp.properties.defaultHostName
