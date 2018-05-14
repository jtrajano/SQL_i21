CREATE VIEW [dbo].[vyuSTPaymentOptionDetailReport]
	AS 
SELECT ST.intStoreId
, ST.intStoreNo
, ST.strRegion
, ST.strDistrict
, ST.strDescription strStoreDescription
, CH.dtmCheckoutDate
, CH.ysnPosted
, CPO.intPaymentOptionId
, PO.strPaymentOptionId
, PO.strDescription
, CPO.dblAmount
FROM tblSTCheckoutHeader CH INNER JOIN tblSTStore ST ON ST.intStoreId = CH.intStoreId 
INNER JOIN tblSTCheckoutPaymentOptions CPO ON CPO.intCheckoutId = CH.intCheckoutId 
INNER JOIN tblSTPaymentOption PO ON PO.intPaymentOptionId = CPO.intPaymentOptionId
INNER JOIN tblICItemUOM IU ON IU.intItemUOMId = CPO.intItemId 
INNER JOIN tblICItem IT ON IT.intItemId = IU.intItemId 
WHERE CPO.dblAmount > 0