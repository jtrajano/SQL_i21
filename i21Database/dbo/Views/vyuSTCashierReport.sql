
CREATE VIEW [dbo].[vyuSTCashierReport]
	AS 
SELECT 
	 ST.intStoreId
	, ST.intStoreNo
	, ST.strRegion
	, ST.strDistrict
	, CL.strCity
	, CL.strStateProvince
	, CL.strZipPostalCode
	, ST.strDescription strStoreDescription
	, CC.intCashierId
	, C.strCashierNumber
	, C.strCashierName
	, CH.dtmCheckoutDate
	, ISNULL(Inv.ysnPosted, 0) ysnPosted
	, ISNULL(SUM(CC.dblRefundAmount),0) AS dblRefundAmount
	, ISNULL(SUM(CC.dblTotalDeposit),0) AS dblTotalDeposit
	, ISNULL(SUM(CC.dblTotalPaymentOption),0) AS dblTotalPaymentOption
	, ISNULL(SUM(CC.dblTotalSales),0) AS dblTotalSales
	, ISNULL(SUM(CC.dblVoidAmount),0) AS dblVoidAmount
	, ISNULL(SUM(CC.dblTotalDeposit) - SUM(CC.dblTotalSales) + SUM(CC.dblTotalPaymentOption),0) as dblOverShort
	, ISNULL(CC.intNumberOfRefunds,0) as intNumberOfRefunds
	, ISNULL(CC.intNumberOfVoids,0) as intNumberOfVoids
	, ISNULL(CC.intNoSalesCount,0) as intNoSalesCount
	, ISNULL(CC.intCustomerCount,0) as intCustomerCount
	, ISNULL(CC.intOverrideCount,0) as intOverrideCount
FROM tblSTCheckoutHeader CH 
INNER JOIN tblSTStore ST 
	ON ST.intStoreId = CH.intStoreId 
INNER JOIN tblSMCompanyLocation CL
	ON ST.intCompanyLocationId = CL.intCompanyLocationId
LEFT JOIN tblARInvoice Inv 
	ON Inv.intInvoiceId = CH.intInvoiceId
INNER JOIN tblSTCheckoutCashiers CC
	ON CC.intCheckoutId = CH.intCheckoutId
LEFT JOIN tblSTCashier C
	ON C.intCashierId = CC.intCashierId
GROUP BY 
ST.intStoreId, 
ST.intStoreNo, 
ST.strRegion, 
ST.strDistrict, 
CL.strCity, 
CL.strStateProvince, 
CL.strZipPostalCode, 
ST.strDescription, 
CC.intCashierId, 
CH.dtmCheckoutDate, 
C.strCashierNumber, 
C.strCashierName, 
CC.intNumberOfRefunds, 
CC.intNumberOfVoids, 
CC.intNoSalesCount,
CC.intCustomerCount,
CC.intOverrideCount,
ISNULL(Inv.ysnPosted, 0)