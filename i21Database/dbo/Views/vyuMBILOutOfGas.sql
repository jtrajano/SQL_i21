CREATE VIEW [dbo].[vyuMBILOutOfGas]
	AS
	
SELECT 
	OOG.intOutOfGasId
	, OOG.intEntityId
	, CustomerSite.strCustomerNumber
	, CustomerSite.strName
	, CustomerSite.intSiteId
	, CustomerSite.intSiteNumber
	, CustomerSite.strSerialNumber
	, CustomerSite.dblTankCapacity
	, CustomerSite.strDescription
	, OOG.ysnLeakTest
	, OOG.dblPressureReading
	, OOG.dblMinutesHeld
	, OOG.ysnTaggedLocked
	, OOG.ysnCustomerNotified
	, OOG.ysnAppliancesLit
	, OOG.strNotes
	, OOG.intConcurrencyId
FROM tblMBILOutOfGas OOG
LEFT JOIN vyuMBILSite CustomerSite ON CustomerSite.intEntityId = OOG.intEntityId AND CustomerSite.intSiteId = OOG.intSiteId
