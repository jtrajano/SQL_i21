CREATE VIEW [dbo].[vyuLGCustomerConsumptionSiteDevice]
AS  
SELECT
	TMSD.intSiteDeviceID
	,TMD.intDeviceId
	,TMD.intDeviceTypeId
	,TMD.strSerialNumber
	,TMDT.strDeviceType
	,TMD.strOwnership
	,TMD.dblTankCapacity
	,TMD.strDescription

	,TMS.intSiteID
	,E.strName
	,E.strEntityNo
	,strSiteID = RIGHT('000'+ CAST(TMS.intSiteNumber AS NVARCHAR(4)),4)  COLLATE Latin1_General_CI_AS
	,strSiteDescription = TMS.strDescription
	,ysnSiteActive = TMS.ysnActive 
	,TMSD.intConcurrencyId
FROM 
	tblTMSiteDevice TMSD
	INNER JOIN tblTMDevice TMD ON TMD.intDeviceId = TMSD.intDeviceId 
	INNER JOIN tblTMDeviceType TMDT ON TMDT.intDeviceTypeId = TMD.intDeviceTypeId
	INNER JOIN tblTMSite TMS ON TMS.intSiteID = TMSD.intSiteID
	INNER JOIN tblTMCustomer TMC ON TMC.intCustomerID = TMS.intCustomerID
	INNER JOIN tblEMEntity E ON E.intEntityId = TMC.intCustomerNumber 
		
GO