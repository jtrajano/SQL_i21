CREATE VIEW [dbo].[vyuCFSearchAccountNetworkXref]
AS

SELECT 
intNetworkAccountId
,emEnt.strName AS strCustomerName
,arCust.strCustomerNumber as strCustomerNumber
,cfAccount.intCustomerId as intCustomerId
,cfAccount.intAccountId as intAccountId
,tblCFNetworkAccount.strNetworkAccountId
,tblCFNetwork.strNetwork
,tblCFNetwork.strNetworkDescription
,tblCFNetwork.strNetworkType
FROM   dbo.tblCFNetworkAccount 
INNER JOIN dbo.tblCFAccount AS cfAccount ON cfAccount.intAccountId = tblCFNetworkAccount.intAccountId 
INNER JOIN dbo.tblARCustomer AS arCust ON arCust.intEntityId = cfAccount.intCustomerId
INNER JOIN dbo.tblEMEntity AS emEnt ON emEnt.intEntityId = arCust.intEntityId
INNER JOIN dbo.tblCFNetwork ON tblCFNetworkAccount.intNetworkId = tblCFNetwork.intNetworkId

GO