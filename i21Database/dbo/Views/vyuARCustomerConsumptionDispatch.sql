CREATE VIEW dbo.vyuARCustomerConsumptionDispatch
AS

SELECT 
	 TMO.intDispatchId
	,TMO.strOrderNumber
	,AC.intEntityId
	,TMS.intSiteID
	,TMS.intSiteNumber
	,strSiteNumber			= REPLACE(STR(TMS.[intSiteNumber], 4), SPACE(1), '0') COLLATE Latin1_General_CI_AS
	,TMS.strBillingBy
	,TMS.dblLastMeterReading
	,TMS.dblPriceAdjustment
	,TANK.dblConversionFactor
FROM tblTMOrder TMO
INNER JOIN tblTMDispatch TMD ON TMO.intDispatchId = TMD.intDispatchID
INNER JOIN tblTMSite TMS ON TMO.intSiteId = TMS.intSiteID
INNER JOIN tblTMCustomer TMC ON TMS.intCustomerID = TMC.intCustomerID
INNER JOIN tblARCustomer AC ON TMC.intCustomerNumber = AC.intEntityId
OUTER APPLY (
	SELECT TOP 1 
		 MT.[strMeterType]
		,MT.[dblConversionFactor]
	FROM tblTMSiteDevice SD
	INNER JOIN tblTMDevice D ON SD.[intDeviceId] = D.[intDeviceId]  
	INNER JOIN tblTMDeviceType DT ON D.[intDeviceTypeId] = DT.[intDeviceTypeId] 
	INNER JOIN tblTMMeterType MT ON D.[intMeterTypeId] = MT.[intMeterTypeId]
	WHERE SD.[intSiteID] = TMS.[intSiteID] AND DT.strDeviceType = 'Flow Meter'
	ORDER BY intSiteDeviceID ASC
) TANK