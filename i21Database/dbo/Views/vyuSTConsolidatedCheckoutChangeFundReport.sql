CREATE VIEW [dbo].[vyuSTConsolidatedCheckoutChangeFundReport]
	AS 
SELECT ST.intStoreId
	, ST.intStoreNo
	, ST.strRegion
	, ST.strDistrict
	, ST.strDescription strStoreDescription
	, CH.dtmCheckoutDate
	, ISNULL(Inv.ysnPosted, 0) ysnPosted
	, REPLACE(cf.strType, 'Change Fund ', '') COLLATE Latin1_General_CI_AS AS strType
	, item.strItemNo
	, SUM(cf.dblItemAmount) dblItemAmountTotal
	, cf.intSequence 
FROM tblSTCheckoutHeader CH 
INNER JOIN tblSTStore ST 
	ON ST.intStoreId = CH.intStoreId 
LEFT JOIN tblARInvoice Inv 
	ON Inv.intInvoiceId = CH.intInvoiceId 
INNER JOIN vyuSTCheckoutChangeFund cf 
	ON cf.intCheckoutId = CH.intCheckoutId 
LEFT JOIN tblICItem item 
	ON item.intItemId = cf.intItemId 
GROUP BY ST.intStoreId, 
		 ST.intStoreNo, 
		 ST.strRegion, 
		 ST.strDistrict, 
		 ST.strDescription, 
		 CH.dtmCheckoutDate, 
		 ISNULL(Inv.ysnPosted, 0), 
		 cf.strType,
		 item.strItemNo,
		 cf.intSequence