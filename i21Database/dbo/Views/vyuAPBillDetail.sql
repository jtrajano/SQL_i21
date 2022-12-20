﻿CREATE VIEW [dbo].[vyuAPBillDetail]
--WITH SCHEMABINDING
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
		 WHEN 12 THEN 'Prepayment Reversal'
		 WHEN 13 THEN 'Basis Advance'
		 WHEN 14 THEN 'Deferred Interest'
		 WHEN 15 THEN 'Tax Adjustment'
		 WHEN 16 THEN 'Provisional Voucher'
		 ELSE 'Invalid Type'
	END AS strTransactionType,
	G2.strName,
	G2.strEntityNo,
	A.strVendorOrderNumber,
	A.intBillId,
	A.dtmDate,
	dbo.fnAPGetFiscalPeriod(A.dtmDate) strPeriod,
	A.dtmDateCreated,
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
	B.int1099Form,
	CASE B.int1099Form WHEN 0 THEN 'NONE'
		WHEN 1 THEN '1099 MISC'
		WHEN 2 THEN '1099 INT'
		WHEN 3 THEN '1099 B'
		WHEN 4 THEN '1099 PATR'
		WHEN 5 THEN '1099 DIV'
		WHEN 7 THEN '1099 NEC'
		ELSE 'NONE' END COLLATE Latin1_General_CI_AS AS str1099Form,
	B.int1099Category,
	CASE WHEN D.int1099CategoryId IS NULL THEN 'NONE' ELSE D.strCategory END AS str1099Category,
	CASE WHEN E.intTaxGroupId IS NOT NULL THEN E.strTaxGroup ELSE F.strTaxGroup END AS strTaxGroup,
	CASE WHEN B.intInventoryShipmentChargeId IS NOT NULL THEN  ISS.strShipmentNumber WHEN B.intStorageChargeId > 0 THEN SG.strStorageChargeNumber 
	WHEN B.intInsuranceChargeDetailId > 0 THEN ichrge.strChargeNo ELSE  IR.strReceiptNumber END as strReceiptNumber,
	ISNULL(IR.intInventoryReceiptId,0) AS intInventoryReceiptId,
	ISNULL(SC.strTicketNumber,SCB.strTicketNumber) AS strTicketNumber, 
	CH.strContractNumber,
	CL.strLocationName,
	CASE WHEN (B.intWeightUOMId > 0) 
		THEN weightUOM.strUnitMeasure
		ELSE uom.strUnitMeasure
	END AS strUOM,
	ISNULL(CD.intContractSeq,0) AS intSequenceId,
	ISNULL(L.strLoadNumber,receiptLoad.strLoadNumber) AS strLoadNumber,
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
	PD.intLineNo AS intPOLineNumber,
	ISNULL(subLoc.strSubLocationName, receiptSubLoc.strSubLocationName) AS strSubLocationName,
	ISNULL(itemContractCountry.strCountry,CommodityAttr.strDescription) AS strCountryOrigin,
	CD.strERPPONumber,
	CD.strERPItemNumber,
	term.strTerm,
	A.strRemarks,
	PG.strName as strPurchasingGroupName,
	CB.strContractBasis as strINCO,
	A.ysnPaid,
	A2.strPaymentInfo COLLATE Latin1_General_CI_AS AS strPaymentInfo,
	A2.dtmDatePaid,
	A2.dtmPaymentDateReconciled,
	ISNULL(A2.dblPayment,0) AS dblPayment,
	ISNULL(A2.ysnClr,0) AS ysnClr,
	A2.dtmClr,
	A.intShipToId,
	CASE WHEN B.dblCashPrice = 0 THEN B.dblCost ELSE B.dblCashPrice END dblCashPrice,
	B.dblQualityPremium,
	B.dblOptionalityPremium,
	lot.strLotNumber,
	SG.intStorageChargeId,
	ichrgedtl.intInsuranceChargeDetailId,
	B.[intSaleYear],
	B.[strSaleNumber],
	B.[dtmSaleDate], 
	B.[strVendorLotNumber],
	strPreInvoiceGarden = gm.[strGardenMark],
	B.[strPreInvoiceGardenNumber],
	book.[strBook],
	subBook.[strSubBook],
	B.[dblPackageBreakups],
	B.[intNumOfPackagesUOM],
	B.[dblNumberOfPackages],
	B.[intNumOfPackagesUOM2],
	B.[dblNumberOfPackages2],
	B.[intNumOfPackagesUOM3],
	B.[dblNumberOfPackages3],
	B.[intPurchasingGroupId],
	cgt.strCatalogueType,
	pgrp.strName AS strPurchasingGroup,
	mz.intMarketZoneId,
	strMarketZone = mz.strMarketZoneCode
FROM dbo.tblAPBill A
INNER JOIN (dbo.tblAPVendor G INNER JOIN dbo.tblEMEntity G2 ON G.[intEntityId] = G2.intEntityId) ON G.[intEntityId] = A.intEntityVendorId
INNER JOIN dbo.tblAPBillDetail B 
	ON A.intBillId = B.intBillId
LEFT JOIN dbo.vyuAPVouchersPaymentInfo A2
	ON A2.intBillId = A.intBillId
-- LEFT JOIN dbo.tblAPBillDetailTax BD 
-- 	ON BD.intBillDetailId = B.intBillDetailId
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
LEFT JOIN dbo.tblLGLoad L
	ON L.intLoadId = B.intLoadId
LEFT JOIN (dbo.tblICItemUOM costUOM INNER JOIN dbo.tblICUnitMeasure um ON costUOM.intUnitMeasureId = um.intUnitMeasureId)
	ON B.intCostUOMId = costUOM.intItemUOMId
LEFT JOIN dbo.tblICStorageLocation SL
	ON SL.intStorageLocationId = B.intStorageLocationId
LEFT JOIN (dbo.tblPOPurchaseDetail PD LEFT JOIN dbo.tblPOPurchase P ON PD.intPurchaseId = P.intPurchaseId)
	ON PD.intPurchaseDetailId = B.intPurchaseDetailId
LEFT JOIN dbo.tblSMCompanyLocationSubLocation subLoc
	--ON IRE.intSubLocationId = subLoc.intCompanyLocationSubLocationId
	ON B.intSubLocationId = subLoc.intCompanyLocationSubLocationId
LEFT JOIN dbo.tblSMCompanyLocationSubLocation receiptSubLoc
	ON IRE.intSubLocationId = receiptSubLoc.intCompanyLocationSubLocationId
LEFT JOIN dbo.tblSMTerm term
	ON term.intTermID = A.intTermsId
LEFT JOIN dbo.tblSMPurchasingGroup PG
	ON PG.intPurchasingGroupId = CD.intPurchasingGroupId
LEFT JOIN tblCTContractBasis CB
	ON CB.intContractBasisId = CH.intContractBasisId
-- LEFT JOIN vyuICGetReceiptItemSource ICS 
--      ON ICS.intInventoryReceiptItemId = IRE.intInventoryReceiptItemId AND ICS.strSourceType = 'Inbound Shipment'   
LEFT JOIN tblICInventoryShipmentCharge ISC 
	ON ISC.intInventoryShipmentChargeId = B.intInventoryShipmentChargeId
LEFT JOIN tblICInventoryShipment ISS 
	ON ISC.intInventoryShipmentId = ISS.intInventoryShipmentId
LEFT JOIN (tblLGLoad receiptLoad INNER JOIN tblLGLoadDetail receiptLoadDetail ON receiptLoad.intLoadId = receiptLoadDetail.intLoadId)
	ON receiptLoadDetail.intLoadDetailId = IRE.intSourceId 
			AND IR.intSourceType = 2
			AND (IR.strReceiptType = 'Purchase Contract' OR IR.strReceiptType = 'Inventory Return')
LEFT JOIN (tblICStorageCharge SG
		INNER JOIN tblICStorageChargeDetail schrgedtl ON SG.intStorageChargeId = schrgedtl.intStorageChargeId) ON schrgedtl.intStorageChargeDetailId = B.intStorageChargeId
LEFT JOIN (tblICInsuranceCharge ichrge
	INNER JOIN tblICInsuranceChargeDetail ichrgedtl ON ichrge.intInsuranceChargeId = ichrgedtl.intInsuranceChargeId)
		ON ichrgedtl.intInsuranceChargeDetailId = B.intInsuranceChargeDetailId
LEFT JOIN tblICLot lot
	ON lot.intLotId = B.intLotId
LEFT JOIN tblQMCatalogueType cgt ON cgt.intCatalogueTypeId = B.intCatalogueTypeId
LEFT JOIN tblCTBook book ON book.intBookId = B.intBookId
LEFT JOIN tblCTSubBook subBook ON subBook.intSubBookId = B.intSubBookId
LEFT JOIN tblSMPurchasingGroup pgrp ON pgrp.intPurchasingGroupId = B.intPurchasingGroupId
LEFT JOIN tblQMGardenMark gm ON gm.intGardenMarkId = B.intGardenMarkId
LEFT JOIN tblARMarketZone mz ON mz.intMarketZoneId = B.intMarketZoneId