CREATE VIEW [dbo].[vyuAPPurchase]
WITH SCHEMABINDING
AS 
SELECT 
A.intPurchaseId
,A.dtmDate
,A.[intVendorId]
,A.intOrderStatusId
,A.strVendorOrderNumber
,A.strPurchaseOrderNumber
,B.strVendorId 
,C.strStatus
,D.strLocationName
FROM dbo.tblPOPurchase A
	INNER JOIN dbo.tblAPVendor B ON A.[intVendorId] = B.[intEntityVendorId]
	INNER JOIN dbo.tblPOOrderStatus C ON A.intOrderStatusId = C.intOrderStatusId
	INNER JOIN dbo.tblSMCompanyLocation D ON A.intShipToId = D.intCompanyLocationId
