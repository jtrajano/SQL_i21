﻿CREATE VIEW [dbo].[vyuSTFuelSalesReconciliationReport]  
AS  
SELECT 
CH.intStoreId,
ST.intStoreNo,
ST.strDescription AS strStoreDescription,
SMCL.strAddress AS strStoreAddress,
EE.strEntityNo AS intDealerNo,
EE.strName AS strDealer,
CH.dtmCheckoutDate AS dtmReportDate,
FSBGPP.intProductNumber AS intFuelGrade,
I.strItemNo AS strDescription,
FSBGPP.dblPrice,
ISNULL(FSBGPP.dblPumpTestGallons,0) AS dblPumpTestGallons,
ISNULL(FSBGPP.dblPumpTestDollars,0) AS dblPumpTestDollars,
FSBGPP.dblGallonsSold,
FSBGPP.dblDollarsSold,
ST.ysnConsMeterReadingsForDollars,
ST.ysnConsAddOutsideFuelDiscounts,
CH.dblEditableAggregateMeterReadingsForDollars AS dblEditableAggregateMeterReadingsForDollars,
(SELECT dbo.fnSTGetDepartmentTotalsForFuel(CH.intCheckoutId)) AS dblDepartmentTotalsForFuel,
(SELECT dbo.fnSTGetGrossFuelSalesByCheckoutId(CH.intCheckoutId)) AS  dblGrossFuelSales,
((SELECT dbo.fnSTGetGrossFuelSalesByCheckoutId(CH.intCheckoutId)) - CH.dblDealerCommission) AS dblCalculatedBankDeposit,
(CASE WHEN ST.ysnConsMeterReadingsForDollars = 0 AND ST.ysnConsAddOutsideFuelDiscounts = 1 THEN 'Department Total For Fuel + Outside Discounts' 
WHEN ST.ysnConsMeterReadingsForDollars = 1 AND ST.ysnConsAddOutsideFuelDiscounts = 1 THEN 'Meter Readings for Dollars + Outside Discounts' 
WHEN ST.ysnConsMeterReadingsForDollars = 1 AND ST.ysnConsAddOutsideFuelDiscounts = 0 THEN 'Meter Readings for Dollars' 
WHEN ST.ysnConsMeterReadingsForDollars = 0 AND ST.ysnConsAddOutsideFuelDiscounts = 0 THEN 'Department Total For Fuel' END) AS strGrossFuelSalesFormula,
CH.dblEditableOutsideFuelDiscount AS dblOutsideFuelDiscounts,
(SELECT dbo.fnSTTotalAmountOfDepositablePaymentMethods(CH.intCheckoutId)) AS dblTotalAmountOfDepositablePaymentMethods
FROM dbo.tblSTStore ST
JOIN tblSMCompanyLocation SMCL
	ON ST.intCompanyLocationId = SMCL.intCompanyLocationId
JOIN tblEMEntity EE
	ON ST.intCheckoutCustomerId =  EE.intEntityId
JOIN tblSTCheckoutHeader CH 
	ON ST.intStoreId = CH.intStoreId
JOIN tblSTCheckoutFuelSalesByGradeAndPricePoint FSBGPP
	ON CH.intCheckoutId = FSBGPP.intCheckoutId
JOIN tblICItemUOM UOM
	ON FSBGPP.intItemUOMId = UOM.intItemUOMId
JOIN tblICItem I
	ON UOM.intItemId = I.intItemId