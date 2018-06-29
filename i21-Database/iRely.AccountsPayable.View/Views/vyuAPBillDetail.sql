CREATE VIEW [dbo].[vyuAPBillDetail]
WITH SCHEMABINDING
AS

SELECT 
	A.strBillId,
	A.intTransactionType,
	CASE A.intTransactionType
		 WHEN 1 THEN 'Voucher'
		 WHEN 2 THEN 'Vendor Prepayment'
		 WHEN 3 THEN 'Debit Memo'
		 WHEN 7 THEN 'Invalid Type'
		 WHEN 9 THEN '1099 Adjustment'
		 WHEN 11 THEN 'Claim'
		 WHEN 13 THEN 'Basis Advance'
		 WHEN 14 THEN 'Deferred Interest'
		 ELSE 'Invalid Type'
	END AS strTransactionType,
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
	SC.strTicketNumber,
	CH.strContractNumber,
	CL.strLocationName,
	CASE WHEN (B.intWeightUOMId > 0) 
		THEN weightUOM.strUnitMeasure
		ELSE uom.strUnitMeasure
	END AS strUOM,
	ISNULL(CD.intContractSeq,0) AS intSequenceId,
	L.strLoadNumber,
	um.strUnitMeasure AS strCostUOM,
	B.dblNetWeight,
	B.dblDiscount,
	H.strDescription AS strAccountDescription,
	B.strComment,
	B.dblVolume,
	SL.strName as strStorageLocation,
	B.dtmExpectedDate,
	B.strBillOfLading,
	P.strPurchaseOrderNumber,
	PD.intLineNo AS intPOLineNumber
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
LEFT JOIN dbo.tblCTContractHeader CH
	ON CH.intContractHeaderId = B.intContractHeaderId
LEFT JOIN dbo.tblGLAccount H 
	ON B.intAccountId = H.intAccountId
LEFT JOIN dbo.tblICItem C 
	ON B.intItemId = C.intItemId
LEFT JOIN dbo.tblAP1099Category D 
	ON D.int1099CategoryId = B.int1099Category
LEFT JOIN dbo.tblSMTaxGroup E 
	ON B.intTaxGroupId = E.intTaxGroupId
LEFT JOIN dbo.tblSMTaxGroup F 
	ON BD.intTaxGroupId = F.intTaxGroupId
LEFT JOIN dbo.tblSCTicket SC 
	ON SC.intInventoryReceiptId = IR.intInventoryReceiptId
INNER JOIN dbo.tblSMCurrency CUR 
	ON CUR.intCurrencyID = A.intCurrencyId
LEFT JOIN dbo.tblCTContractDetail CD
	ON CD.intContractHeaderId = CH.intContractHeaderId
	AND CD.intContractDetailId = B.intContractDetailId
LEFT JOIN dbo.tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = A.intShipToId
LEFT JOIN (dbo.tblICItemUOM weightItemUOM INNER JOIN dbo.tblICUnitMeasure weightUOM ON weightItemUOM.intUnitMeasureId = weightUOM.intUnitMeasureId)
	ON B.intWeightUOMId = weightItemUOM.intItemUOMId
LEFT JOIN (dbo.tblICItemUOM itemUOM INNER JOIN dbo.tblICUnitMeasure uom ON itemUOM.intUnitMeasureId = uom.intUnitMeasureId)
	ON B.intUnitOfMeasureId = itemUOM.intItemUOMId
LEFT JOIN dbo.tblLGLoad L
	ON L.intLoadId = B.intLoadId
LEFT JOIN (dbo.tblICItemUOM costUOM INNER JOIN dbo.tblICUnitMeasure um ON costUOM.intUnitMeasureId = um.intUnitMeasureId)
	ON B.intCostUOMId = costUOM.intItemUOMId
LEFT JOIN dbo.tblICStorageLocation SL
	ON SL.intStorageLocationId = B.intStorageLocationId
LEFT JOIN (dbo.tblPOPurchaseDetail PD LEFT JOIN dbo.tblPOPurchase P ON PD.intPurchaseId = P.intPurchaseId)
	ON PD.intPurchaseDetailId = B.intPurchaseDetailId
-- WHERE weightItemUOM.intItemUOMId IS NOT NULL OR itemUOM.intItemUOMId IS NOT NULL
