CREATE VIEW [dbo].[vyuCFUsageExceptionAlertTransaction]
AS

SELECT
	strCustomerNumber = cfcustomer.strEntityNo
	,strName = cfcustomer.strName
	,intTransactionLimit = cfCard.intDailyTransactionCount
	,strNetwork = cfnetwork.strNetwork
	,strEmailDistributionOption = entityContact.strEmailDistributionOption 
	,strEmail = entityContact.strEmail
	,strCardNumber = cfCard.strCardNumber
	,strCardDescription = cfCard.strCardDescription
	,strProduct = icitem.strItemNo
	,strProductDescription = icitem.strDescription
	,strSiteNumber = cfsite.strSiteNumber
	,strSiteName = cfsite.strSiteName
	,dtmTransactionDate = cfTransaction.dtmTransactionDate
	,dblQuantity = cfTransaction.dblQuantity
	,dblTotal = cfTransaction.dblCalculatedTotalPrice
	,strDriverPin = cfVehicle.strVehicleNumber
	,intTransactionId = cfTransaction.intTransactionId
	,strAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, emcuslocation.strLocationName, emcuslocation.strAddress, emcuslocation.strCity, emcuslocation.strState, emcuslocation.strZipCode, emcuslocation.strCountry, NULL, 0) 
	,intEntityId = cfcustomer.intEntityId
FROM dbo.tblCFTransaction cfTransaction 
LEFT JOIN tblCFNetwork cfnetwork
	ON cfnetwork.intNetworkId = cfTransaction.intNetworkId
LEFT OUTER JOIN (SELECT   
					cfiCard.intCardId
					,cfiCard.strCardNumber
					,cfiCard.strCardDescription 
					,cfiAccount.intDailyTransactionCount
					,cfiAccount.intCustomerId
					FROM dbo.tblCFAccount AS cfiAccount 
					INNER JOIN dbo.tblCFCard AS cfiCard 
					ON cfiCard.intAccountId = cfiAccount.intAccountId 
				
) AS cfCard 
	ON cfTransaction.intCardId = cfCard.intCardId
LEFT JOIN dbo.tblEMEntity AS cfcustomer
	ON cfcustomer.intEntityId = (CASE WHEN cfTransaction.strTransactionType = 'Foreign Sale' 
										THEN 
											cfnetwork.intCustomerId
										ELSE
											cfCard.intCustomerId
										END)
LEFT JOIN tblCFItem cfiitem
	ON cfTransaction.intProductId = intItemId
LEFT JOIN tblICItem icitem
	ON cfiitem.intARItemId = icitem.intItemId
LEFT JOIN tblCFSite cfsite
	ON cfTransaction.intSiteId = cfsite.intSiteId
LEFT OUTER JOIN dbo.tblCFVehicle AS cfVehicle 
	ON cfTransaction.intVehicleId = cfVehicle.intVehicleId 
OUTER APPLY (
				SELECT TOP 1 
					strEmailDistributionOption
					,strEmail 
				FROM vyuARCustomerContacts 
				WHERE [intEntityId] = cfcustomer.intEntityId
					AND strEmailDistributionOption LIKE '%CF Alert%' 
					AND ISNULL(strEmail,'') != ''
		
) entityContact 
LEFT JOIN tblEMEntityLocation emcuslocation
	ON cfcustomer.intEntityId = emcuslocation.intEntityId
		AND emcuslocation.ysnDefaultLocation = 1
WHERE cfTransaction.ysnPosted = 1


