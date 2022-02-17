@description('The name of the resource group to install the resources in.')
param location string = resourceGroup().location

@description('The name of the virtual network')
param vnetName string = 'Omexom'

resource appServiceSubnetNsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: 'AppServiceSubNetNsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-graphdb'
        properties: {
          priority: 1010
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          destinationPortRange: '7200'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }                 
    ]
  }
}

resource privateSubnetNsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: 'PrivateSubNetNsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-graphdb'
        properties: {
          priority: 1010
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          destinationPortRange: '7200'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }    
      {           
        name: 'allow-ssh'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          destinationPortRange: '22'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
           destinationAddressPrefix: '*'
        }
      }                   
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${vnetName}VNet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AppServiceSubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: appServiceSubnetNsg.id
          }
        }
      }
      {
        name: 'PrivateSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: privateSubnetNsg.id
          }
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }

  resource privateSubnet 'subnets' existing = {
    name: 'PrivateSubnet'
  }

  resource appServiceSubnet 'subnets' existing = {
    name: 'PrivateSubnet'
  }

}


output privateSubnetId string = vnet::privateSubnet.id
output appServiceId string = vnet::appServiceSubnet.id
output privateSubnetNsgId string = privateSubnetNsg.id
