CREATE VIEW [dbo].[vyuSTDepartmentProfitSummaryReport]
	AS 
SELECT ST.intStoreId
	, ST.intStoreNo
	, ST.strRegion
	, ST.strDistrict
	, CL.strCity
	, CL.strStateProvince
	, CL.strZipPostalCode
	, ST.strDescription strStoreDescription
	, CAT.intCategoryId
	, CAT.strCategoryCode
	, CAT.strDescription strCategoryDescription
	, CH.dtmCheckoutDate
	, ISNULL(Inv.ysnPosted, 0) ysnPosted
	, SUM(CDT.intItemsSold) intItemsSold
	, SUM(CDT.intTotalSalesCount) intTotalSalesCount
	, SUM(CDT.dblRegisterSalesAmountComputed) dblTotalRegisterAmount
	, SUM(CDT.dblTotalSalesAmountComputed) dblTotalSalesAmount
	, SUM(CDT.dblRegisterSalesAmountComputed) - SUM(CDT.dblTotalSalesAmountComputed) as  dblDiffRegisterAndSales
	, SUM(tblARSalesAnalysisReport.dblTotalCost) dblCost
FROM tblSTCheckoutHeader CH 
INNER JOIN tblSTStore ST 
	ON ST.intStoreId = CH.intStoreId 
INNER JOIN tblSTCheckoutDepartmetTotals CDT 
	ON CDT.intCheckoutId = CH.intCheckoutId 
INNER JOIN tblSMCompanyLocation CL
	ON ST.intCompanyLocationId = CL.intCompanyLocationId
LEFT JOIN tblARInvoice Inv 
	ON Inv.intInvoiceId = CH.intInvoiceId
LEFT JOIN (
	SELECT 
		 SUM(dblTotalCost) as dblTotalCost , intCategoryId , intTransactionId
	FROM vyuARSalesAnalysisReport 
	GROUP BY   intCategoryId , intTransactionId
) as tblARSalesAnalysisReport
ON tblARSalesAnalysisReport.intTransactionId = CH.intInvoiceId
AND tblARSalesAnalysisReport.intCategoryId = CDT.intCategoryId
INNER JOIN tblICItem IT 
	ON IT.intItemId = CDT.intItemId 
INNER JOIN tblICCategory CAT 
	ON CAT.intCategoryId = IT.intCategoryId
WHERE (CDT.dblTotalSalesAmountComputed <> 0	
	OR CDT.intTotalSalesCount <> 0)
GROUP BY 
ST.intStoreId, ST.intStoreNo, ST.strRegion, ST.strDistrict, CL.strCity, CL.strStateProvince, CL.strZipPostalCode, ST.strDescription, CAT.intCategoryId, CAT.strCategoryCode, CAT.strDescription, CH.dtmCheckoutDate, ISNULL(Inv.ysnPosted, 0)

GO


