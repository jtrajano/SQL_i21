CREATE VIEW [dbo].[vyuSTConsolidatedCheckoutChangeFundDetailReport]
	AS 
SELECT ST.intStoreId
	, ST.intStoreNo
	, ST.strRegion
	, ST.strDistrict
	, ST.strDescription strStoreDescription
	, CH.dtmCheckoutDate
	, CCF.strDescription
	, SUM(CCF.dblValue) dblValue
	, ISNULL(Inv.ysnPosted, 0) ysnPosted
FROM tblSTCheckoutChangeFund CCF
INNER JOIN tblSTCheckoutHeader CH ON CH.intCheckoutId = CCF.intCheckoutId
INNER JOIN tblSTStore ST ON ST.intStoreId = CH.intStoreId
LEFT JOIN tblARInvoice Inv ON Inv.intInvoiceId = CH.intInvoiceId 
GROUP BY ST.intStoreId, 
		 ST.intStoreNo, 
		 ST.strRegion, 
		 ST.strDistrict, 
		 ST.strDescription, 
		 CH.dtmCheckoutDate, 
		 ISNULL(Inv.ysnPosted, 0), 
		 CCF.strDescription
