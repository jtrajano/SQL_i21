CREATE VIEW [dbo].[vyuAPRptPurchase]
WITH SCHEMABINDING
AS 
SELECT 
A.intPurchaseId
,A.dtmDate
,A.intVendorId
,A.strPurchaseOrderNumber
,B.strVendorId 
FROM dbo.tblPOPurchase A
	INNER JOIN dbo.tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
	INNER JOIN dbo.tblAPVendor B ON A.intVendorId = B.intVendorId
