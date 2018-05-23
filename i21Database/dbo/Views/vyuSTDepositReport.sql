CREATE VIEW [dbo].[vyuSTDepositReport]
	AS 
SELECT ST.intStoreId
, ST.intStoreNo
, ST.strRegion
, ST.strDistrict
, ST.strDescription strStoreDescription
, CH.dtmCheckoutDate
, ISNULL(Inv.ysnPosted, 0) ysnPosted
, SUM(D.dblCash) dblCash
, SUM(D.dblCoin) dblCoin
, SUM(D.dblTotalDeposit) dblTotalDeposit
FROM tblSTCheckoutHeader CH INNER JOIN tblSTStore ST ON ST.intStoreId = CH.intStoreId 
LEFT JOIN tblARInvoice Inv ON Inv.intInvoiceId = CH.intInvoiceId
INNER JOIN tblSTCheckoutDeposits D ON D.intCheckoutId = CH.intCheckoutId 
WHERE D.dblTotalDeposit > 0	
GROUP BY ST.intStoreId, ST.intStoreNo, ST.strRegion, ST.strDistrict, ST.strDescription, CH.dtmCheckoutDate, ISNULL(Inv.ysnPosted, 0)

