﻿CREATE VIEW [dbo].[vyuETDeliveryMetrics]
	AS SELECT 
	intDeliveryMetricsId
	,intBeginningOdometerReading
	,intEndingOdometerReading
	,dblGallonsDelivered
	,dblTotalFuelSales
	,intTotalInvoice
	,A.strDriverNumber COLLATE Latin1_General_CI_AS  AS strDriverNumber 
	,strTruckNumber
	,strShiftNumber
	,dtmShiftBeginDate
	,dtmShiftEndDate
   ,C.strLocationName  AS strLocation 
   ,CAST(intEndingOdometerReading-intBeginningOdometerReading as DECIMAL(18,6))   AS dblMilesPerDay --Odometer End - Obometer Start
   ,dblGallonsDelivered/intTotalInvoice  AS dblGallonsPerStop --Gallons Delivered / Invoices
   ,dblGallonsDelivered/NULLIF(intEndingOdometerReading-intBeginningOdometerReading,0) AS dblGallonsPerMile  --Gallons Delivered / (Odometer End - Odometer Start)
	FROM tblETDeliveryMetrics A
	LEFT JOIN tblEMEntity B ON A.strDriverNumber = RIGHT(RTRIM(LTRIM(B.strEntityNo)), 3)
	LEFT JOIN [tblEMEntityLocation] C ON B.intEntityId = C.intEntityId
	INNER JOIN tblARSalesperson D ON B.intEntityId = D.intEntityId
	WHERE D.strType = 'Driver'
	AND C.ysnDefaultLocation = 1
	