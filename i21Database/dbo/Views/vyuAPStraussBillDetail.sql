CREATE VIEW [dbo].[vyuAPStraussBillDetail]
AS
SELECT 
	CASE A.intTransactionType
		 WHEN 1 THEN 'Voucher'
		 WHEN 2 THEN 'Vendor Prepayment'
		 WHEN 3 THEN 'Debit Memo'
		 WHEN 7 THEN 'Invalid Type'
		 WHEN 9 THEN '1099 Adjustment'
		 WHEN 11 THEN 'Claim'
		 WHEN 12 THEN 'Prepayment Reversal'
		 WHEN 13 THEN 'Basis Advance'
		 WHEN 14 THEN 'Deferred Interest'
		 WHEN 15 THEN 'Tax Adjustment'
		 WHEN 16 THEN 'Provisional Voucher'
		 ELSE 'Invalid Type'
	END AS strTransactionType,
	A.intTransactionType,
	A.strBillId,
	A.intBillId,
	A.strVendorOrderNumber AS strInvoiceNumber,
	A.dtmBillDate,
	A.dtmDateCreated,
	A.ysnPosted,
	A.dtmDate AS dtmDatePosted,
	A.ysnPaid,
	ISNULL(A2.ysnClr,0) AS ysnCleared,
	G2.strName,
	A.intEntityVendorId,
	A.intShipToId,
	CL.strLocationName AS strReceivingLocation,
	SL.strName as strStorageLocation,
	ISNULL(subLoc.strSubLocationName, receiptSubLoc.strSubLocationName) AS strSubLocationName,
	ISNULL(itemContractCountry.strCountry,CommodityAttr.strDescription) AS strCountryOrigin,
	CD.strERPPONumber,
	CD.strERPItemNumber,
	term.strTerm,
	A.intTermsId,
	A.strRemarks,
	C.strItemNo,
	B.intItemId,
	C.strDescription AS strItemDescription,
	H.strAccountId,
	H.strDescription AS strAccountDescription,
	B.strMiscDescription,
	CASE WHEN B.intInventoryShipmentChargeId IS NOT NULL THEN  ISS.strShipmentNumber WHEN B.intStorageChargeId > 0 THEN SG.strStorageChargeNumber 
	WHEN B.intInsuranceChargeDetailId > 0 THEN ichrge.strChargeNo ELSE  IR.strReceiptNumber END as strSourceNumber,
	ISNULL(SC.strTicketNumber,SCB.strTicketNumber) AS strTicketNumber, 
	CUR.strCurrency,
	CH.strContractNumber,
	ISNULL(CD.intContractSeq,0) AS intSequenceId,
	PG.strName as strPurchasingGroupName,
	CB.strContractBasis as strINCO,
	A2.strPaymentInfo COLLATE Latin1_General_CI_AS AS strPaymentInfo,
	P.strPurchaseOrderNumber,
	PD.intLineNo AS intPOLineNumber,
	B.dblCost,
	um.strUnitMeasure AS strCostUOM,
	B.dblNetWeight,
	ISNULL(A2.dblPayment,0) AS dblPayment,
	B.dblDiscount,
	CASE WHEN (A.intTransactionType NOT IN (1,9,10)) THEN B.dblQtyOrdered * -1 ELSE B.dblQtyOrdered END AS dblQtyOrdered,
	CASE WHEN (A.intTransactionType NOT IN (1,9,10)) THEN B.dblQtyReceived * -1 ELSE B.dblQtyReceived END AS dblQtyReceived,
	CASE WHEN (B.intWeightUOMId > 0) 
		THEN weightUOM.strUnitMeasure
		ELSE uom.strUnitMeasure
	END AS strUOM,
	CASE WHEN (A.intTransactionType NOT IN (1,9,10)) THEN B.dblTotal * -1 ELSE B.dblTotal END AS dblTotal,
	B.dblTax,
	B.strComment,
	B.dblVolume,
	A2.dtmDatePaid,
	A2.dtmPaymentDateReconciled,
	A2.dtmClr dtmCleared,
	B.dbl1099,
	CASE B.int1099Form WHEN 0 THEN 'NONE'  
		WHEN 1 THEN '1099 MISC'  
		WHEN 2 THEN '1099 INT'  
		WHEN 3 THEN '1099 B'  
		WHEN 4 THEN '1099 PATR'  
		WHEN 5 THEN '1099 DIV'  
		WHEN 6 THEN '1099 K'  
		WHEN 7 THEN '1099 NEC'  
	ELSE 'NONE' END COLLATE Latin1_General_CI_AS AS str1099Form,  
	 	CASE WHEN B.int1099Category IS NULL THEN 'NONE' ELSE 
		CASE B.int1099Form
			WHEN 1 THEN D.strCategory
			WHEN 7 THEN D.strCategory
			WHEN 6 THEN D2.strCategory
			WHEN 5 THEN D3.strCategory
			WHEN 4 THEN D4.strCategory
		END
 	END AS str1099Category, 
	CASE WHEN E.intTaxGroupId IS NOT NULL THEN E.strTaxGroup ELSE F.strTaxGroup END AS strTaxGroup
FROM dbo.tblAPBill A
INNER JOIN (dbo.tblAPVendor G INNER JOIN dbo.tblEMEntity G2 ON G.[intEntityId] = G2.intEntityId) ON G.[intEntityId] = A.intEntityVendorId
INNER JOIN dbo.tblAPBillDetail B 
	ON A.intBillId = B.intBillId
LEFT JOIN dbo.vyuAPVouchersPaymentInfo A2
	ON A2.intBillId = A.intBillId
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
LEFT JOIN dbo.tblAP1099KCategory D2  
 	ON D2.int1099CategoryId = B.int1099Category  
LEFT JOIN dbo.tblAP1099DIVCategory D3
 	ON D3.int1099CategoryId = B.int1099Category  
LEFT JOIN dbo.tblAP1099PATRCategory D4
	 ON D4.int1099CategoryId = B.int1099Category  
LEFT JOIN dbo.tblSMTaxGroup E 
	ON B.intTaxGroupId = E.intTaxGroupId
LEFT JOIN dbo.tblSMTaxGroup F 
	ON B.intTaxGroupId = F.intTaxGroupId
LEFT JOIN dbo.tblSCTicket SC 
	ON SC.intInventoryReceiptId = IR.intInventoryReceiptId 
LEFT JOIN dbo.tblSCTicket SCB  
	ON SCB.intTicketId = B.intScaleTicketId 
INNER JOIN dbo.tblSMCurrency CUR 
	ON CUR.intCurrencyID = A.intCurrencyId
LEFT JOIN dbo.tblCTContractDetail CD
	ON CD.intContractHeaderId = CH.intContractHeaderId
	AND CD.intContractDetailId = B.intContractDetailId
LEFT JOIN (dbo.tblICItemContract itemContract 
	INNER JOIN dbo.tblSMCountry itemContractCountry ON itemContract.intCountryId = itemContractCountry.intCountryID)
	ON CD.intItemContractId = itemContract.intItemContractId
LEFT JOIN dbo.tblICCommodityAttribute CommodityAttr 
	ON CommodityAttr.intCommodityAttributeId = C.intOriginId
LEFT JOIN dbo.tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = A.intShipToId
LEFT JOIN (dbo.tblICItemUOM weightItemUOM INNER JOIN dbo.tblICUnitMeasure weightUOM ON weightItemUOM.intUnitMeasureId = weightUOM.intUnitMeasureId)
	ON B.intWeightUOMId = weightItemUOM.intItemUOMId
LEFT JOIN (dbo.tblICItemUOM itemUOM INNER JOIN dbo.tblICUnitMeasure uom ON itemUOM.intUnitMeasureId = uom.intUnitMeasureId)
	ON B.intUnitOfMeasureId = itemUOM.intItemUOMId
LEFT JOIN (dbo.tblICItemUOM costUOM INNER JOIN dbo.tblICUnitMeasure um ON costUOM.intUnitMeasureId = um.intUnitMeasureId)
	ON B.intCostUOMId = costUOM.intItemUOMId
LEFT JOIN dbo.tblICStorageLocation SL
	ON SL.intStorageLocationId = B.intStorageLocationId
LEFT JOIN (dbo.tblPOPurchaseDetail PD LEFT JOIN dbo.tblPOPurchase P ON PD.intPurchaseId = P.intPurchaseId)
	ON PD.intPurchaseDetailId = B.intPurchaseDetailId
LEFT JOIN dbo.tblSMCompanyLocationSubLocation subLoc
	ON B.intSubLocationId = subLoc.intCompanyLocationSubLocationId
LEFT JOIN dbo.tblSMCompanyLocationSubLocation receiptSubLoc
	ON IRE.intSubLocationId = receiptSubLoc.intCompanyLocationSubLocationId
LEFT JOIN dbo.tblSMTerm term
	ON term.intTermID = A.intTermsId
LEFT JOIN dbo.tblSMPurchasingGroup PG
	ON PG.intPurchasingGroupId = CD.intPurchasingGroupId
LEFT JOIN tblCTContractBasis CB
	ON CB.intContractBasisId = CH.intContractBasisId
LEFT JOIN tblICInventoryShipmentCharge ISC 
	ON ISC.intInventoryShipmentChargeId = B.intInventoryShipmentChargeId
LEFT JOIN tblICInventoryShipment ISS 
	ON ISC.intInventoryShipmentId = ISS.intInventoryShipmentId
LEFT JOIN (tblICStorageCharge SG
		INNER JOIN tblICStorageChargeDetail schrgedtl ON SG.intStorageChargeId = schrgedtl.intStorageChargeId) ON schrgedtl.intStorageChargeDetailId = B.intStorageChargeId
LEFT JOIN (tblICInsuranceCharge ichrge
	INNER JOIN tblICInsuranceChargeDetail ichrgedtl ON ichrge.intInsuranceChargeId = ichrgedtl.intInsuranceChargeId)
		ON ichrgedtl.intInsuranceChargeDetailId = B.intInsuranceChargeDetailId

