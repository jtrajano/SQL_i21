CREATE VIEW [dbo].[vyuAPBillDetail]
WITH SCHEMABINDING
AS

SELECT 
	A.strBillId,
	A.intTransactionType,
	G2.strName,
	A.strVendorOrderNumber,
	A.intBillId,
	A.dtmDate,
	A.ysnPosted,
	B.intBillDetailId,
	A.intEntityVendorId,
	C.strItemNo,
	CUR.strCurrency,
	B.dblCost,
	CASE WHEN (A.intTransactionType NOT IN (1,9,10)) THEN B.dblQtyOrdered * -1 ELSE B.dblQtyOrdered END AS dblQtyOrdered,
	CASE WHEN (A.intTransactionType NOT IN (1,9,10)) THEN B.dblQtyReceived * -1 ELSE B.dblQtyReceived END AS dblQtyReceived,
	CASE WHEN (A.intTransactionType NOT IN (1,9,10)) THEN B.dblTotal * -1 ELSE B.dblTotal END AS dblTotal,
	B.dblTax,
	B.dblRate,
	B.ysnSubCurrency,
	B.strMiscDescription,
	C.strDescription AS strItemDescription,
	H.strAccountId,
	B.dbl1099,
	CASE B.int1099Form WHEN 0 THEN 'NONE'
		WHEN 1 THEN '1099 MISC'
		WHEN 2 THEN '1099 INT'
		WHEN 3 THEN '1099 B'
		WHEN 4 THEN '1099 PATR'
		ELSE 'NONE' END AS str1099Form,
	CASE WHEN D.int1099CategoryId IS NULL THEN 'NONE' ELSE D.strCategory END AS str1099Category,
	CASE WHEN E.intTaxGroupId IS NOT NULL THEN E.strTaxGroup ELSE F.strTaxGroup END AS strTaxGroup,
	IR.strReceiptNumber,
	ISNULL(IR.intInventoryReceiptId,0) AS intInventoryReceiptId,
	SC.strTicketNumber
FROM dbo.tblAPBill A
INNER JOIN (dbo.tblAPVendor G INNER JOIN dbo.tblEMEntity G2 ON G.[intEntityId] = G2.intEntityId) ON G.[intEntityId] = A.intEntityVendorId
INNER JOIN dbo.tblAPBillDetail B 
	ON A.intBillId = B.intBillId
LEFT JOIN dbo.tblAPBillDetailTax BD 
	ON BD.intBillDetailId = B.intBillDetailId
LEFT JOIN dbo.tblICInventoryReceiptItem IRE 
	ON B.intInventoryReceiptItemId = IRE.intInventoryReceiptItemId
LEFT JOIN dbo.tblICInventoryReceipt IR 
	ON IR.intInventoryReceiptId = IRE.intInventoryReceiptId
LEFT JOIN dbo.tblGLAccount H 
	ON B.intAccountId = H.intAccountId
LEFT JOIN dbo.tblICItem C 
	ON B.intItemId = C.intItemId
LEFT JOIN dbo.tblAP1099Category D 
	ON D.int1099CategoryId = B.int1099Category
LEFT JOIN dbo.tblSMTaxGroup E 
	ON BD.intTaxGroupId = E.intTaxGroupId
LEFT JOIN dbo.tblSMTaxGroup F 
	ON BD.intTaxGroupId = F.intTaxGroupId
LEFT JOIN dbo.tblSCTicket SC 
	ON SC.intInventoryReceiptId = IR.intInventoryReceiptId
INNER JOIN dbo.tblSMCurrency CUR 
	ON CUR.intCurrencyID = A.intCurrencyId
