CREATE VIEW [dbo].[vyuARCustomerConsumptionSite]
AS

SELECT
	 AC.[intEntityId]
	,AC.[strCustomerNumber]
	,TMS.[intSiteID]
	,TMS.[intSiteNumber]
	,REPLACE(STR(TMS.[intSiteNumber], 4), SPACE(1), '0') AS [strSiteNumber]
	,TMS.[strDescription] 
	,TMS.[strBillingBy] 
	,TMS.[dblLastMeterReading] 
	,(SELECT TOP 1 MT.[strMeterType] FROM tblTMSiteDevice SD
		INNER JOIN tblTMDevice D ON SD.[intDeviceId] = D.[intDeviceId]  
		INNER JOIN tblTMDeviceType DT ON D.[intDeviceTypeId] = DT.[intDeviceTypeId] 
		INNER JOIN tblTMMeterType MT ON D.[intMeterTypeId] = MT.[intMeterTypeId]
		WHERE SD.[intSiteID] = TMS.[intSiteID] AND DT.strDeviceType = 'Flow Meter'
		ORDER BY intSiteDeviceID ASC)
		AS [strMeterType]
	,(SELECT TOP 1 MT.[dblConversionFactor] FROM tblTMSiteDevice SD
		INNER JOIN tblTMDevice D ON SD.[intDeviceId] = D.[intDeviceId]  
		INNER JOIN tblTMDeviceType DT ON D.[intDeviceTypeId] = DT.[intDeviceTypeId] 
		INNER JOIN tblTMMeterType MT ON D.[intMeterTypeId] = MT.[intMeterTypeId]
		WHERE SD.[intSiteID] = TMS.[intSiteID] AND DT.strDeviceType = 'Flow Meter'
		ORDER BY intSiteDeviceID ASC)
		AS [dblConversionFactor] 
	,TMS.[ysnActive] 
FROM
	tblTMSite TMS
INNER JOIN
	tblTMCustomer TMC
		ON TMS.[intCustomerID] = TMC.[intCustomerID]
INNER JOIN
	tblARCustomer AC
		ON TMC.[intCustomerNumber] = AC.[intEntityId]
--LEFT OUTER JOIN
--	(
--		SELECT TOP 1
--			 SD.[intSiteID]
--			,MT.[strMeterType] 
--			,MT.[dblConversionFactor]
--		FROM
--			tblTMSiteDevice SD
--		INNER JOIN
--			tblTMDevice D
--				ON SD.[intDeviceId] = D.[intDeviceId]  
--		INNER JOIN
--			tblTMDeviceType DT
--				ON D.[intDeviceTypeId] = DT.[intDeviceTypeId] 
--		INNER JOIN
--			tblTMMeterType MT
--				ON D.[intMeterTypeId] = MT.[intMeterTypeId]
--		WHERE
--			DT.strDeviceType = 'Flow Meter'
--		ORDER BY
--			intSiteDeviceID ASC

--	) TMD
--		ON TMS.[intSiteID] = TMD.[intSiteID]

