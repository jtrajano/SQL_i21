CREATE VIEW [dbo].[vyuSTFuelSalesReconciliationReport]  
AS  
SELECT 
CH.intStoreId,
ST.intStoreNo,
ST.strDescription + ' - ' + CAST(ST.intStoreNo AS VARCHAR(20)) AS strStoreDescription,
SMCL.strAddress + ', ' + SMCL.strCity + ', ' + SMCL.strZipPostalCode + ', ' + SMCL.strCountry  AS strStoreAddress,
EE.strEntityNo AS intDealerNo,
EE.strName AS strDealer,
CH.dtmCheckoutDate AS dtmReportDate,
FORMAT(CH.dtmCheckoutDate, 'd','us') AS strReportDate,
FSBGPP.intProductNumber AS intFuelGrade,
I.strItemNo + ' - ' + I.strDescription AS strDescription,
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
((SELECT dbo.fnSTGetGrossFuelSalesByCheckoutId(CH.intCheckoutId)) - ((SELECT dbo.fnSTTotalAmountOfDepositablePaymentMethods(CH.intCheckoutId)) + CH.dblDealerCommission)) AS dblCalculatedBankDeposit,
(CASE WHEN ST.ysnConsMeterReadingsForDollars = 0 AND ST.ysnConsAddOutsideFuelDiscounts = 1 THEN 'Department Total For Fuel + Inside/Outside Fuel Discounts' 
WHEN ST.ysnConsMeterReadingsForDollars = 1 AND ST.ysnConsAddOutsideFuelDiscounts = 1 THEN 'Meter Readings for Dollars + Outside Fuel  Discounts' 
WHEN ST.ysnConsMeterReadingsForDollars = 1 AND ST.ysnConsAddOutsideFuelDiscounts = 0 THEN 'Meter Readings for Dollars Only' 
WHEN ST.ysnConsMeterReadingsForDollars = 0 AND ST.ysnConsAddOutsideFuelDiscounts = 0 THEN 'Department Total For Fuel Only' END) AS strGrossFuelSalesFormula,
ISNULL(CH.dblEditableOutsideFuelDiscount,0) AS dblOutsideFuelDiscounts,
ISNULL(CH.dblEditableInsideFuelDiscount,0) AS dblInsideFuelDiscounts,
(SELECT dbo.fnSTTotalAmountOfDepositablePaymentMethods(CH.intCheckoutId)) AS dblTotalAmountOfDepositablePaymentMethods,
CH.dblDealerCommission,
(CASE WHEN ((SELECT dbo.fnSTGetGrossFuelSalesByCheckoutId(CH.intCheckoutId)) - ((SELECT dbo.fnSTTotalAmountOfDepositablePaymentMethods(CH.intCheckoutId)) + CH.dblDealerCommission)) > 0 THEN 'Calculated Bank Withdrawal'
WHEN ((SELECT dbo.fnSTGetGrossFuelSalesByCheckoutId(CH.intCheckoutId)) - ((SELECT dbo.fnSTTotalAmountOfDepositablePaymentMethods(CH.intCheckoutId)) + CH.dblDealerCommission)) < 0 THEN 'Calculated Bank Deposit'
ELSE 'BALANCE' END) AS strCalculatedBankAmountLabel,
ABS((SELECT dbo.fnSTGetGrossFuelSalesByCheckoutId(CH.intCheckoutId)) - ((SELECT dbo.fnSTTotalAmountOfDepositablePaymentMethods(CH.intCheckoutId)) + CH.dblDealerCommission)) AS dblCalculatedBankAmount,
(CASE WHEN ST.ysnConsMeterReadingsForDollars = 0 THEN 'Department Total for Fuel' COLLATE Latin1_General_CI_AS 
WHEN ST.ysnConsMeterReadingsForDollars = 1 THEN 'Meter Readings for Dollars' COLLATE Latin1_General_CI_AS END) AS strGoverningFactor,
(CASE WHEN ST.ysnConsMeterReadingsForDollars = 0 THEN 'Inside/Outside Fuel Discounts' COLLATE Latin1_General_CI_AS 
WHEN ST.ysnConsMeterReadingsForDollars = 1 THEN 'Outside Fuel  Discounts' COLLATE Latin1_General_CI_AS END) AS strFuelDiscount,
(CASE WHEN ST.ysnConsMeterReadingsForDollars = 1 THEN CH.dblEditableAggregateMeterReadingsForDollars
WHEN ST.ysnConsMeterReadingsForDollars = 0 THEN (SELECT dbo.fnSTGetDepartmentTotalsForFuel(CH.intCheckoutId)) END) AS dblFuelSales,
(CASE WHEN ST.ysnConsMeterReadingsForDollars = 0 AND ST.ysnConsAddOutsideFuelDiscounts = 1 THEN (ISNULL(CH.dblEditableOutsideFuelDiscount,0) + ISNULL(CH.dblEditableInsideFuelDiscount,0))
WHEN ST.ysnConsMeterReadingsForDollars = 1 AND ST.ysnConsAddOutsideFuelDiscounts = 1 THEN (ISNULL(CH.dblEditableOutsideFuelDiscount,0))
WHEN ST.ysnConsMeterReadingsForDollars = 1 AND ST.ysnConsAddOutsideFuelDiscounts = 0 THEN 0
WHEN ST.ysnConsMeterReadingsForDollars = 0 AND ST.ysnConsAddOutsideFuelDiscounts = 0 THEN 0 END) AS dblFuelDiscount,
((SELECT dbo.fnSTTotalAmountOfDepositablePaymentMethods(CH.intCheckoutId)) - (SELECT dbo.fnSTGetGrossFuelSalesByCheckoutId(CH.intCheckoutId))) AS dblSubTotal
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