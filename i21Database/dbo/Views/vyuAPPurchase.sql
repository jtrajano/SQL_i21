CREATE VIEW [dbo].[vyuAPPurchase]
WITH SCHEMABINDING
AS 
SELECT 
A.intPurchaseId
,A.dtmDate
,A.intVendorId
,A.strPONumber
,B.strVendorId 
FROM dbo.tblPOPurchase A
	INNER JOIN dbo.tblAPVendor B ON A.intVendorId = B.intVendorId
