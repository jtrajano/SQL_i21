CREATE VIEW [dbo].[vyuSTSalesTaxReport]
	AS 
SELECT ST.intStoreId
	, ST.intStoreNo
	, ST.strRegion
	, ST.strDistrict
	, ST.strDescription strStoreDescription
	, CH.dtmCheckoutDate
	, ISNULL(Inv.ysnPosted, CAST(0 AS BIT)) AS ysnPosted
	, ACC.strAccountId
	, STT.strTaxNo
	, SMTax.strTaxCode
	, SUM(STT.dblTotalTax) dblTotalTax
	, SUM(STT.dblTaxableSales) dblTaxableSales
	, SUM(STT.dblTaxExemptSales) dblTaxExemptSales
FROM tblSTCheckoutHeader CH 
INNER JOIN tblSTStore ST 
	ON ST.intStoreId = CH.intStoreId 
INNER JOIN tblSTStoreTaxTotals STTax
	ON ST.intStoreId = STTax.intStoreId
LEFT JOIN tblARInvoice Inv 
	ON Inv.intInvoiceId = CH.intInvoiceId
INNER JOIN tblSTCheckoutSalesTaxTotals STT 
	ON STT.intCheckoutId = CH.intCheckoutId 
INNER JOIN tblSMTaxCode SMTax
	ON STTax.intTaxCodeId = SMTax.intTaxCodeId
	AND STT.strTaxNo = SMTax.strStoreTaxNumber
INNER JOIN tblGLAccount ACC 
	ON ACC.intAccountId = STT.intSalesTaxAccount
INNER JOIN tblICItem IT 
	ON IT.intItemId = STT.intItemId 
INNER JOIN tblICCategory CAT 
	ON CAT.intCategoryId = IT.intCategoryId
WHERE STT.dblTotalTax <> 0	
	OR STT.dblTaxableSales <> 0	
GROUP BY ST.intStoreId, ST.intStoreNo, ST.strRegion, ST.strDistrict, ST.strDescription, CH.dtmCheckoutDate, Inv.ysnPosted, ACC.strAccountId, STT.strTaxNo, strTaxCode