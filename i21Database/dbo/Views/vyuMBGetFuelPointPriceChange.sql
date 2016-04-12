﻿CREATE VIEW [dbo].[vyuMBGetFuelPointPriceChange]
	AS 
	
SELECT FPPriceChange.intFuelPointPriceChangeId
	, FPPriceChange.intEntityCustomerId
	, strCustomerName = Customer.strName
	, Customer.strCustomerNumber
	, FPPriceChange.intEntityLocationId
	, EntityLocation.strLocationName
	, FPPriceChange.dtmDateFrom
	, FPPriceChange.dtmDateTo
	, FPPriceChange.intSort
FROM tblMBFuelPointPriceChange FPPriceChange
LEFT JOIN vyuARCustomer Customer ON Customer.intEntityCustomerId = FPPriceChange.intEntityCustomerId
LEFT JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityLocationId = FPPriceChange.intEntityLocationId