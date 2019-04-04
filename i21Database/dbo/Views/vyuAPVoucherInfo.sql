CREATE VIEW [dbo].[vyuAPVoucherInfo]
AS 

SELECT
	vendor.intEntityId AS intEntityVendorId,
	A.dtmDate AS dtmLastVoucherDate,
	ISNULL(A.dblTotal,0) AS dblLastVoucherTotal,
	ISNULL(B.dblTotal,0) AS dblLastYearVoucherTotal,
	ISNULL(C.dblTotal,0) AS dblYearToDateVoucherTotal
FROM tblAPVendor vendor
LEFT JOIN dbo.fnAPGetLastVoucherTotal() A 
	ON vendor.intEntityId = A.intEntityVendorId
LEFT JOIN dbo.fnAPGetLYVoucher() B
	ON A.intEntityVendorId = B.intEntityVendorId
LEFT JOIN dbo.fnAPGetYTDPurchases() C
	ON B.intEntityVendorId = C.intEntityVendorId