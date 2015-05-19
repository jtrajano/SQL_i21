CREATE VIEW [dbo].[vyuAPPurchase]
WITH SCHEMABINDING
AS 
SELECT 
A.intPurchaseId
,A.dtmDate
,A.[intEntityVendorId]
,A.intOrderStatusId
,A.strVendorOrderNumber
,A.strPurchaseOrderNumber
,B.strVendorId 
,B1.strName
,C.strStatus
,D.strLocationName
FROM dbo.tblPOPurchase A
	INNER JOIN dbo.tblAPVendor B ON A.[intEntityVendorId] = B.[intEntityVendorId]
	INNER JOIN dbo.tblEntity B1 ON B.intEntityVendorId = B1.intEntityId
	INNER JOIN dbo.tblPOOrderStatus C ON A.intOrderStatusId = C.intOrderStatusId
	INNER JOIN dbo.tblSMCompanyLocation D ON A.intShipToId = D.intCompanyLocationId
