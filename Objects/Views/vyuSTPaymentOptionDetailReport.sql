﻿CREATE VIEW [dbo].[vyuSTPaymentOptionDetailReport]
	AS 
SELECT ST.intStoreId
	, ST.intStoreNo
	, ST.strRegion
	, ST.strDistrict
	, CL.strCity
	, CL.strStateProvince
	, CL.strZipPostalCode
	, ST.strDescription strStoreDescription
	, CH.dtmCheckoutDate
	, ISNULL(Inv.ysnPosted, 0) ysnPosted
	, CPO.intPaymentOptionId
	, PO.strPaymentOptionId
	, PO.strDescription
	, CPO.dblAmount
FROM tblSTCheckoutHeader CH 
INNER JOIN tblSTStore ST 
	ON ST.intStoreId = CH.intStoreId 
INNER JOIN tblSMCompanyLocation CL
	ON ST.intCompanyLocationId = CL.intCompanyLocationId
LEFT JOIN tblARInvoice Inv 
	ON Inv.intInvoiceId = CH.intInvoiceId
INNER JOIN tblSTCheckoutPaymentOptions CPO 
	ON CPO.intCheckoutId = CH.intCheckoutId
INNER JOIN tblSTPaymentOption PO 
	ON PO.intPaymentOptionId = CPO.intPaymentOptionId
INNER JOIN tblICItem IT 
	ON IT.intItemId = CPO.intItemId
--INNER JOIN tblICItemUOM IU 
--	ON IU.intItemUOMId = CPO.intItemId 
WHERE CPO.dblAmount <> 0