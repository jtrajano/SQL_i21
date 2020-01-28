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
	, TC.strTaxCode strTaxCode
	,SUM(STT.dblTotalTax) dblTotalTax
	,SUM(STT.dblTaxableSales) dblTaxableSales
	,SUM(STT.dblTaxExemptSales) dblTaxExemptSales
FROM tblSTCheckoutSalesTaxTotals STT 
	INNER JOIN tblSTCheckoutHeader CH ON STT.intCheckoutId = CH.intCheckoutId 
INNER JOIN tblSTStore ST 
	ON ST.intStoreId = CH.intStoreId 
INNER JOIN tblSTStoreTaxTotals STTax
		ON ST.intStoreId = STTax.intStoreId
		AND STT.strTaxNo = STTax.strTaxCodeNumber
LEFT JOIN tblARInvoice Inv 
	ON Inv.intInvoiceId = CH.intInvoiceId
LEFT JOIN tblGLAccount ACC 
	ON ACC.intAccountId = STT.intSalesTaxAccount
LEFT JOIN tblSMTaxCode TC
		ON STTax.intTaxCodeId = TC.intTaxCodeId
WHERE (STT.dblTotalTax <> 0	OR STT.dblTaxableSales <> 0)
GROUP BY ST.intStoreId, ST.intStoreNo, ST.strRegion, ST.strDistrict, ST.strDescription, CH.dtmCheckoutDate, Inv.ysnPosted, ACC.strAccountId, STT.strTaxNo, TC.strTaxCode
