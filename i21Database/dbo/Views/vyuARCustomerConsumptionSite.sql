CREATE VIEW [dbo].[vyuARCustomerConsumptionSite]
AS

SELECT
	 AC.[intEntityCustomerId]
	,AC.[strCustomerNumber]
	,TMS.[intSiteID] 
	,TMS.[intSiteNumber]
	,TMS.[strDescription] 
	,TMS.[strBillingBy] 
	,TMS.[dblLastMeterReading] 
	,TMD.[strMeterType]
	,TMD.[dblConversionFactor] 
FROM
	tblTMSite TMS
INNER JOIN
	tblTMCustomer TMC
		ON TMS.[intCustomerID] = TMC.[intCustomerID]
INNER JOIN
	tblARCustomer AC
		ON TMC.[intCustomerNumber] = AC.[intEntityCustomerId]
LEFT OUTER JOIN
	(
		SELECT TOP 1
			 SD.[intSiteID]
			,MT.[strMeterType] 
			,MT.[dblConversionFactor]
		FROM
			tblTMSiteDevice SD
		LEFT OUTER JOIN
			tblTMDevice D
				ON SD.[intSiteID] = SD.[intSiteID]
		INNER JOIN
			tblTMDeviceType DT
				ON D.[intDeviceTypeId] = DT.[intDeviceTypeId] 
		LEFT OUTER JOIN
			tblTMMeterType MT
				ON D.[intMeterTypeId] = MT.[intMeterTypeId]
		WHERE
			DT.strDeviceType = 'Flow Meter'
		ORDER BY
			SD.[intSiteDeviceID] ASC
	) TMD
		ON TMS.[intSiteID] = TMD.[intSiteID]

