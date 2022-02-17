@description('The location where the resources should be deployed. Defaults to location of resource group.')
param location string = resourceGroup().location

@description('The name of the VNet to create.')
param vnetName string = 'Omexom'

param username string
param sshKey string

module vnet 'modules/network.bicep' = {
  name: 'vnet'
  params: {
    location: location
    vnetName: vnetName
  }
}

module graphdb 'modules/graphdb.bicep' = {
  name: 'graphdb'
  params: {
    adminUsername: username
    sshKey: sshKey
    subnetId: vnet.outputs.privateSubnetId
    securityGroupId: vnet.outputs.privateSubnetNsgId        
    location: location
  }
}


