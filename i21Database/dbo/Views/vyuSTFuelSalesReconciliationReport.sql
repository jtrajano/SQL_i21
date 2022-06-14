CREATE VIEW [dbo].[vyuSTFuelSalesReconciliationReport]  
AS  
SELECT        1 AS intStoreId, 101 AS intStoreNo, 'iRely Mart 101' AS strStoreDescription, 'Fort Wayne' AS strStoreAddress, 111 AS intDealerNo, '111 - LOW BOBS CITGO' AS strDealer, '05/23/2022' AS dtmReportDate, 1 AS intFuelGrade, '87 Unleaded' AS strDescription, 4.00 AS dblPrice, 0 AS dblPumpTestGallons, 0 AS dblPumpTestDollars, 1475.274 AS dblGallonsSold, 5901.10 AS dblDollarsSold
UNION
SELECT        1 AS intStoreId, 101 AS intStoreNo, 'iRely Mart 101' AS strStoreDescription, 'Fort Wayne' AS strStoreAddress, 111 AS intDealerNo, '111 - LOW BOBS CITGO' AS strDealer, '05/23/2022' AS dtmReportDate, 1 AS intFuelGrade, '87 Unleaded' AS strDescription, 4.20 AS dblPrice, 0 AS dblPumpTestGallons, 0 AS dblPumpTestDollars, 873.197 AS dblGallonsSold, 3667.43 AS dblDollarsSold
UNION
SELECT        1 AS intStoreId, 101 AS intStoreNo, 'iRely Mart 101' AS strStoreDescription, 'Fort Wayne' AS strStoreAddress, 111 AS intDealerNo, '111 - LOW BOBS CITGO' AS strDealer, '05/23/2022' AS dtmReportDate, 2 AS intFuelGrade, '89 Mid' AS strDescription, 4.25 AS dblPrice, 0 AS dblPumpTestGallons, 0 AS dblPumpTestDollars, 278.376 AS dblGallonsSold, 1183.10 AS dblDollarsSold
UNION
SELECT        1 AS intStoreId, 101 AS intStoreNo, 'iRely Mart 101' AS strStoreDescription, 'Fort Wayne' AS strStoreAddress, 111 AS intDealerNo, '111 - LOW BOBS CITGO' AS strDealer, '05/23/2022' AS dtmReportDate, 2 AS intFuelGrade, '89 Mid' AS strDescription, 4.50 AS dblPrice, 0 AS dblPumpTestGallons, 0 AS dblPumpTestDollars, 150.364 AS dblGallonsSold, 676.64 AS dblDollarsSold
UNION
SELECT        1 AS intStoreId, 101 AS intStoreNo, 'iRely Mart 101' AS strStoreDescription, 'Fort Wayne' AS strStoreAddress, 111 AS intDealerNo, '111 - LOW BOBS CITGO' AS strDealer, '05/23/2022' AS dtmReportDate, 3 AS intFuelGrade, '91 Supreme' AS strDescription, 5 AS dblPrice, 0 AS dblPumpTestGallons, 0 AS dblPumpTestDollars, 46.899 AS dblGallonsSold, 234.50 AS dblDollarsSold
UNION
SELECT        1 AS intStoreId, 101 AS intStoreNo, 'iRely Mart 101' AS strStoreDescription, 'Fort Wayne' AS strStoreAddress, 111 AS intDealerNo, '111 - LOW BOBS CITGO' AS strDealer, '05/23/2022' AS dtmReportDate, 4 AS intFuelGrade, 'Diesel' AS strDescription, 4.35 AS dblPrice, 0 AS dblPumpTestGallons, 0 AS dblPumpTestDollars, 245.85 AS dblGallonsSold, 1069.434 AS dblDollarsSold