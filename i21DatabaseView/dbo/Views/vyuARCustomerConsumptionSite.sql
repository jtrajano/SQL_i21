CREATE VIEW [dbo].[vyuARCustomerConsumptionSite]
AS

SELECT intEntityId			= AC.[intEntityId]
	 , strCustomerNumber	= AC.[strCustomerNumber]
	 , intSiteID			= TMS.[intSiteID]
	 , intSiteNumber		= TMS.[intSiteNumber]
	 , strSiteNumber		= REPLACE(STR(TMS.[intSiteNumber], 4), SPACE(1), '0') COLLATE Latin1_General_CI_AS
	 , strDescription		= TMS.[strDescription] 
	 , strBillingBy			= TMS.[strBillingBy] 
	 , dblLastMeterReading	= TMS.[dblLastMeterReading] 
	 , dblPriceAdjustment	= TMS.[dblPriceAdjustment]
	 , strMeterType			= TANK.[strMeterType]
	 , dblConversionFactor	= TANK.[dblConversionFactor]
	 , ysnActive			= TMS.[ysnActive] 
	 , intItemId			= TMS.intProduct
FROM tblTMSite TMS
INNER JOIN tblTMCustomer TMC ON TMS.[intCustomerID] = TMC.[intCustomerID]
INNER JOIN tblARCustomer AC ON TMC.[intCustomerNumber] = AC.[intEntityId]
OUTER APPLY (
	SELECT TOP 1 MT.[strMeterType]
			   , MT.[dblConversionFactor]
	FROM tblTMSiteDevice SD
	INNER JOIN tblTMDevice D ON SD.[intDeviceId] = D.[intDeviceId]  
	INNER JOIN tblTMDeviceType DT ON D.[intDeviceTypeId] = DT.[intDeviceTypeId] 
	INNER JOIN tblTMMeterType MT ON D.[intMeterTypeId] = MT.[intMeterTypeId]
	WHERE SD.[intSiteID] = TMS.[intSiteID] AND DT.strDeviceType = 'Flow Meter'
	ORDER BY intSiteDeviceID ASC
) TANK