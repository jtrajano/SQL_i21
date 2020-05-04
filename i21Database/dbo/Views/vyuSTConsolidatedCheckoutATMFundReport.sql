﻿CREATE VIEW [dbo].[vyuSTConsolidatedCheckoutATMFundReport]
	AS 
SELECT ST.intStoreId
	, ST.intStoreNo
	, ST.strRegion
	, ST.strDistrict
	, ST.strDescription strStoreDescription
	, CH.dtmCheckoutDate
	, ISNULL(Inv.ysnPosted, 0) ysnPosted
	, REPLACE(atm.strType, 'ATM ', '') AS strType
	, item.strItemNo
	, SUM(atm.dblItemAmount) dblItemAmountTotal
	, atm.intSequence
FROM tblSTCheckoutHeader CH 
INNER JOIN tblSTStore ST 
	ON ST.intStoreId = CH.intStoreId 
LEFT JOIN tblARInvoice Inv 
	ON Inv.intInvoiceId = CH.intInvoiceId 
INNER JOIN vyuSTCheckoutATMFund atm 
	ON atm.intCheckoutId = CH.intCheckoutId 
LEFT JOIN tblICItem item 
	ON item.intItemId = atm.intItemId 
GROUP BY ST.intStoreId, 
		 ST.intStoreNo, 
		 ST.strRegion, 
		 ST.strDistrict, 
		 ST.strDescription, 
		 CH.dtmCheckoutDate, 
		 ISNULL(Inv.ysnPosted, 0), 
		 atm.strType,
		 item.strItemNo,		 
		 atm.intSequence