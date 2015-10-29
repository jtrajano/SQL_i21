CREATE VIEW [dbo].[vyuAPBillDetail]
WITH SCHEMABINDING
AS

SELECT 
	A.strBillId,
	G2.strName,
	A.strVendorOrderNumber,
	A.intBillId,
	B.intBillDetailId,
	A.intEntityVendorId,
	C.strItemNo,
	B.dblCost,
	B.dblQtyOrdered,
	B.dblQtyReceived,
	B.dblTotal,
	B.dblTax,
	B.strMiscDescription,
	C.strDescription AS strItemDescription,
	H.strAccountId,
	B.dbl1099,
	CASE B.int1099Form WHEN 0 THEN 'NONE'
		WHEN 1 THEN '1099 MISC'
		WHEN 2 THEN '1099 INT'
		WHEN 3 THEN '1099 B'
		ELSE 'NONE' END AS str1099Form,
	CASE WHEN D.int1099CategoryId IS NULL THEN 'NONE' ELSE D.strCategory END AS str1099Category,
	CASE WHEN E.intTaxGroupId IS NOT NULL THEN E.strTaxGroup ELSE F.strTaxGroup END AS strTaxGroup
FROM dbo.tblAPBill A
INNER JOIN (dbo.tblAPVendor G INNER JOIN dbo.tblEntity G2 ON G.intEntityVendorId = G2.intEntityId) ON G.intEntityVendorId = A.intEntityVendorId
INNER JOIN dbo.tblAPBillDetail B ON A.intBillId = B.intBillId
LEFT JOIN dbo.tblGLAccount H ON B.intAccountId = H.intAccountId
LEFT JOIN dbo.tblICItem C ON B.intItemId = C.intItemId
LEFT JOIN dbo.tblAP1099Category D ON D.int1099CategoryId = B.int1099Category
LEFT JOIN dbo.tblSMTaxGroup E ON B.intTaxGroupId = E.intTaxGroupId
LEFT JOIN dbo.tblSMTaxGroup F ON B.intTaxGroupId = F.intTaxGroupId
