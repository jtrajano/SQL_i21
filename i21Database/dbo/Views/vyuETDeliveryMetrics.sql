CREATE VIEW [dbo].[vyuETDeliveryMetrics]
	AS SELECT 
	intDeliveryMetricsId
	,intBeginningOdometerReading
	,intEndingOdometerReading
	,dblGallonsDelivered
	,dblTotalFuelSales
	,intTotalInvoice
	,strDriverNumber COLLATE Latin1_General_CI_AS  AS strDriverNumber 
	,strTruckNumber
	,strShiftNumber
	,dtmShiftBeginDate
	,dtmShiftEndDate
   ,C.strLocationName  AS strLocation 
   ,CAST(intEndingOdometerReading-intBeginningOdometerReading as DECIMAL(18,6))   AS dblMilesPerDay --Odometer End - Obometer Start
   ,dblGallonsDelivered/intTotalInvoice  AS dblGallonsPerStop --Gallons Delivered / Invoices
   ,dblGallonsDelivered/(intEndingOdometerReading-intBeginningOdometerReading)  AS dblGallonsPerMile --Gallons Delivered / (Odometer End - Odometer Start)
	FROM tblETDeliveryMetrics A
	LEFT JOIN tblEMEntity B ON A.strDriverNumber = RIGHT(RTRIM(LTRIM(B.strEntityNo)), 3)
	LEFT JOIN [tblEMEntityLocation] C ON B.intEntityId = C.intEntityId