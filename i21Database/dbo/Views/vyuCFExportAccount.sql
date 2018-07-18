CREATE VIEW [dbo].[vyuCFExportAccount]
AS

SELECT   
	strParticipant = ISNULL(cfNet.strParticipant,''),
	cfNet.intNetworkId,
	emEnt.intEntityId, 
	strEntityNo = ISNULL(emEnt.strEntityNo,''), 
	arCus.ysnActive, 
	REPLACE(REPLACE(SUBSTRING(ISNULL(emEntLoc.strAddress,''), 1, 30), CHAR(13), ''), CHAR(10), '') AS strAddress1, 
	REPLACE(REPLACE(SUBSTRING(ISNULL(emEntLoc.strAddress,''), 30, 30), CHAR(13), ''), CHAR(10), '') AS strAddress2, 
	strCity = ISNULL(emEntLoc.strCity,''), 
	strPhone = ISNULL(emEntLoc.strPhone,''), 
	strName = ISNULL(emEnt.strName,''), 
	strZipCode = ISNULL(emEntLoc.strZipCode,''), 
	strFax = ISNULL(emEntLoc.strFax,''), 
	strState = ISNULL(emEntLoc.strState,''), 
	strEmail = ISNULL(emContact.strEmail,''), 
	'' AS dtmDateLastModified, 
	'' AS dtmTimeLastModified, 
	strNetworkType = ISNULL(cfNet.strNetworkType,''),
	CONVERT(bit, 0) AS ysnUpdateFlag, 
	CONVERT(numeric(18, 6), 0) AS dblCreditLimit, 
	CONVERT(bit, 0) AS ysnCreditIndicator
	FROM        
	dbo.tblEMEntity AS emEnt INNER JOIN
	dbo.vyuEMEntityContact as emContact ON emEnt.intEntityId = emContact.intEntityId AND emContact.ysnDefaultContact = 1 INNER JOIN
	dbo.tblARCustomer AS arCus ON emEnt.intEntityId = arCus.intEntityId INNER JOIN
	dbo.tblEMEntityLocation AS emEntLoc ON emEnt.intEntityId = emEntLoc.intEntityId AND emEntLoc.ysnDefaultLocation =1 INNER JOIN 
	dbo.tblCFAccount AS cfAcc ON arCus.intEntityId = cfAcc.intCustomerId INNER JOIN
	dbo.tblCFCard AS cfCrd ON cfAcc.intAccountId = cfCrd.intAccountId INNER JOIN
	dbo.tblCFNetwork AS cfNet ON cfCrd.intNetworkId = cfNet.intNetworkId
GROUP BY 
cfNet.strParticipant,
cfNet.intNetworkId,
emEnt.intEntityId, 
emEnt.strEntityNo, 
arCus.ysnActive, 
emEntLoc.strAddress,
emEntLoc.strCity, 
emEntLoc.strPhone, 
emEnt.strName, 
emEntLoc.strZipCode, 
emEntLoc.strFax, 
emEntLoc.strState, 
emContact.strEmail,
cfNet.strNetworkType
GO


