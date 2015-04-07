CREATE VIEW [dbo].[vyuAPPurchase]
WITH SCHEMABINDING
AS 
SELECT 
A.intPurchaseId
,A.dtmDate
,A.intEntityVendorId
,A.strPurchaseOrderNumber
,B.strVendorId 
FROM dbo.tblPOPurchase A
	INNER JOIN dbo.tblAPVendor B ON A.intEntityVendorId = B.[intEntityVendorId]
