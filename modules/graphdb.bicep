//*****************************************************************************
// BICEP script used to deploy GraphDB on a virtual machine.
//
// Sources:
//    - https://medium.com/codex/how-to-create-a-linux-virtual-machine-with-azure-bicep-template-e22f50f2baea
//
//*****************************************************************************

// Parameters
@description('The name of the resource group to install the resources in.')
param location string = resourceGroup().location

@description('The VM size to use.')
param vmSize string = 'Standard_B2s'

@description('The storage account type to use.')
param storageAccountType string = 'Standard_LRS'

@description('The version of the Ubuntu server to use.')
param ubuntuOsVersion string = '18.04-LTS'

@description('The administrator username.')
param adminUsername string

@description('The ssh key.')
@secure()
param sshKey string

@description('The id of the security group to assign.')
param securityGroupId string

@description('The id of the subnet to add the VM to.')
param subnetId string

// Variables
var vmName = 'GraphDB'
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: sshKey
      }
    ]
  }
}

//-----------------------------------------------------------------------------
// The network interface card for the VM.
//-----------------------------------------------------------------------------

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: '${vmName}-IP'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: '${vmName}_NIC'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpAddress.id
          }
          subnet: {
            id: subnetId
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
          
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    networkSecurityGroup: {
      id: securityGroupId
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}

//-----------------------------------------------------------------------------
// The GraphDB virtual machine.
//-----------------------------------------------------------------------------
resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: '${vmName}_VM'
  location: location
  zones: [
    '1'
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        name: 'GraphDB_OS_DISK'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: storageAccountType
        }
      }
      imageReference:{
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: ubuntuOsVersion
        version: 'latest'        
      }
    }
    osProfile: {
      computerName: 'graphdb'
      adminUsername: adminUsername
      adminPassword: sshKey
      linuxConfiguration: linuxConfiguration
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

//-----------------------------------------------------------------------------
// Custom script to install GraphDB.
//-----------------------------------------------------------------------------
resource installGraphDB 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  parent: vm
  name: 'install-graphdb'
  location: location
  properties: {
      publisher: 'Microsoft.Azure.Extensions'
      type: 'CustomScript'
      typeHandlerVersion: '2.1'
      autoUpgradeMinorVersion: true
      protectedSettings: {
        commandToExecute: 'install-graphdb.sh'
        fileUris: [
          ''
        ]
      }
  }
}
