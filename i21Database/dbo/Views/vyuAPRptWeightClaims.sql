﻿CREATE VIEW [dbo].[vyuAPRptWeightClaims]
AS

SELECT 
CAST(ROW_NUMBER() OVER(ORDER BY intContractDetailId) AS INT) AS intClaimId,
(SELECT TOP 1	strCompanyName FROM dbo.tblSMCompanySetup) AS strCompanyName,
(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress,
CASE WHEN ysnSubCurrency > 0 THEN (dblWeightLoss - dblFranchiseWeight) * dblCost / ISNULL(intCent,1)  ELSE (dblWeightLoss - dblFranchiseWeight) * dblCost END AS dblClaim,
((dblWeightLoss - dblFranchiseWeight) * (dblCost / ISNULL(intCent,1))  - dblTotalClaimAmount) * -1 AS  dblFranchiseAmount,
(dblWeightLoss - dblFranchiseWeight) AS dblQtyToBill ,
* 
FROM (
	SELECT
		RTRIM(LTRIM(strVendorId)) + ' - ' + strName AS strVendorName,
		strItemNo,  
		SUM(dblNetShippedWeight) AS dblNetShippedWeight,
		SUM(dblGrossShippedWeight) AS dblGrossShippedWeight,
		SUM(dblNetShippedWeight) - SUM(dblNetQtyReceived) AS dblWeightLoss,
		SUM(dblTareShippedWeight) AS dblShipmentWeightLoss,
		dblAmountPaid,
		SUM(dblAppliedPrepayment) AS dblAppliedPrepayment,
		SUM(dblQtyBillCreated) AS dblQtyBillCreated,
		SUM(dblNetQtyReceived) AS dblNetQtyReceived,
		SUM(dblGrossQtyReceived) AS dblGrossQtyReceived,
		SUM(dblGrossQtyReceived) - SUM(dblNetQtyReceived) AS dblIRWeightLoss,
		CASE 
		WHEN dblFranchise > 0
			THEN SUM(dblNetShippedWeight) * (dblFranchise / 100)
		ELSE 0 END AS dblFranchiseWeight,		
		(SUM(dblNetShippedWeight) - SUM(dblNetQtyReceived) - SUM(dblNetShippedWeight) * (dblFranchise / 100)) dblClaimQuantity,
		(SUM(dblAmountPaid) - SUM(dblAppliedPrepayment)) AS dblTotalClaimAmount,
		0.00000 dblDamageQty,
		0.00000 dblAdjustments,
		dblCost,
		dblQtyReceived,
		dblCostUnitQty,
		dblWeightUnitQty,
		dblContractItemQty,
		dblPrepaidTotal,
		strUnitMeasure AS strUOM,
		strContractNumber,
		strDescription,
		strAccountId,
		strAccountDesc,
		strVendorOrderNumber AS strInvoiceNo,
		strBillOfLading,
		strCurrency,
		dtmDueDate, 
		dtmDate,
		intBillId,      
		intCostUOMId,
		intWeightUOMId,
		intUnitOfMeasureId,
		intItemId,
		intContractDetailId,
		intContractHeaderId,
		intEntityVendorId,
		intShipToId,
		intAccountId,
		--strBankAccountNo,
		--strBankName,
		--strBankAddress,
		--strNotes,
		strContainerNumber,
		strWeightGradeDesc,
		strComment,
		intCent,
		intCurrencyId,
		strCostCurrency,
		ysnSubCurrency
	FROM (
		SELECT
			 BillClaim.intBillId 
			,IRI.dblNet AS dblNetQtyReceived--Receipts.dblNetQtyReceived
			,IRI.dblGross AS dblGrossQtyReceived--Receipts.dblGrossQtyReceived
			,J.dblAmountApplied AS dblAppliedPrepayment
			,CASE WHEN B.dblNetWeight > 0 THEN B.dblCost * (B.dblWeightUnitQty / B.dblCostUnitQty)
					 WHEN B.intCostUOMId > 0 THEN B.dblCost * (B.dblUnitQty / B.dblCostUnitQty) ELSE B.dblCost END AS dblCost
			,B.dblQtyReceived
			,B.dblQtyOrdered AS dblQtyBillCreated
			,B.intCostUOMId AS intUnitOfMeasureId
			,UM.strUnitMeasure
			,B.intCostUOMId
			,B.intWeightUOMId
			,B.dblCostUnitQty
			,B.dblWeightUnitQty
			,G.strItemNo
			,G.intItemId
			,E.intContractDetailId
			,E.intContractHeaderId
			,E.intContractSeq
			,E.dblTotalCost AS dblAmountPaid
			,E.dblQuantity AS dblContractItemQty
			,H.strContractNumber
			,I.dblFranchise
			,A.intEntityVendorId
			,A.intShipToId
			,L.dblTotal + L.dblTax AS dblPrepaidTotal
			,LGC.dblGrossWt AS dblGrossShippedWeight
			,LGC.dblNetWt AS dblNetShippedWeight--Loads.dblNetShippedWeight
			,LGC.dblTareWt AS dblTareShippedWeight
			,Container.strContainerNumber
			,M.strVendorId
			,M.intGLAccountExpenseId AS intAccountId
			,M3.strAccountId
			,M3.strDescription AS strAccountDesc
			,M2.strName
			,M2.str1099Form
			,M2.str1099Type
			,G.strDescription
			,BillClaim.strVendorOrderNumber
			,BillClaim.dtmDueDate
			,BillClaim.dtmDate
			,ISNULL(BillClaim.strComment, 'N/A') AS strComment
			,D.strBillOfLading
			,N.strCurrency
			,I.strWeightGradeDesc
			,ISNULL(H1.intCent,1) AS intCent
			,ISNULL(E.intCurrencyId,ISNULL(H1.intMainCurrencyId,A.intCurrencyId)) AS intCurrencyId
			,ISNULL(H1.strCurrency,(SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = A.intCurrencyId)) AS strCostCurrency
			,ISNULL(H1.ysnSubCurrency,0) AS ysnSubCurrency
			--,Payments.strBankAccountNo
			--,Payments.strBankName
			--,Payments.strBankAddress
			--,ISNULL(Payments.strNotes, 'N/A') AS strNotes
		FROM tblAPBill A
		INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
		INNER JOIN (tblICItemUOM IUOM INNER JOIN tblICUnitMeasure UM ON IUOM.intUnitMeasureId = UM.intUnitMeasureId) ON B.intCostUOMId = IUOM.intItemUOMId
		INNER JOIN (tblAPVendor M INNER JOIN tblEMEntity M2 ON M.intEntityVendorId = M2.intEntityId LEFT JOIN tblGLAccount M3 ON M.intGLAccountExpenseId = M3.intAccountId) ON A.intEntityVendorId = M.intEntityVendorId
		INNER JOIN tblICInventoryReceiptItem IRI ON B.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
		INNER JOIN tblICInventoryReceipt D ON IRI.intInventoryReceiptId = D.intInventoryReceiptId
		INNER JOIN tblCTContractDetail E ON IRI.intLineNo = E.intContractDetailId
		INNER JOIN tblCTContractHeader H ON H.intContractHeaderId = E.intContractHeaderId
		INNER JOIN tblCTWeightGrade I ON H.intWeightId = I.intWeightGradeId
		INNER JOIN tblICItem G ON B.intItemId = G.intItemId
		INNER JOIN tblAPAppliedPrepaidAndDebit J ON J.intContractHeaderId = E.intContractHeaderId AND B.intBillDetailId = J.intBillDetailApplied
		INNER JOIN tblAPBill K ON J.intTransactionId = K.intBillId
		INNER JOIN tblLGLoadContainer LGC ON LGC.intLoadContainerId = IRI.intContainerId
		LEFT JOIN dbo.tblSMCurrency N ON A.intCurrencyId = N.intCurrencyID
		INNER JOIN tblAPBillDetail L ON K.intBillId = L.intBillId 
					AND B.intItemId = L.intItemId 
					AND E.intContractDetailId = L.intContractDetailId
					AND E.intContractHeaderId = L.intContractHeaderId
		INNER JOIN dbo.tblAPBillDetail P ON P.intContractHeaderId = H.intContractHeaderId
		INNER JOIN dbo.tblAPBill BillClaim ON BillClaim.intBillId = P.intBillId
		LEFT JOIN dbo.tblSMCurrency H1 ON H1.intCurrencyID = E.intCurrencyId
		--CROSS APPLY (
		--	SELECT SUM(F.dblGross) AS dblNetShippedWeight
		--	FROM tblLGLoadDetail F
		--	WHERE IRI.intSourceId = F.intLoadDetailId
		--	) Loads
		CROSS APPLY (
			SELECT TOP 1 GLC.strContainerNumber
			FROM tblLGLoadDetail F
			INNER JOIN tblLGLoadDetailContainerLink GLCL ON GLCL.intLoadId = F.intLoadId
			INNER JOIN tblLGLoadContainer GLC ON GLC.intLoadContainerId = GLCL.intLoadContainerId
			WHERE IRI.intSourceId = F.intLoadDetailId
		) Container
		--CROSS APPLY (
		--	SELECT 
		--		SUM(C.dblNet) AS dblNetQtyReceived,
		--		SUM(C.dblGross) AS dblGrossQtyReceived
		--	FROM tblICInventoryReceiptItem C 
		--	WHERE C.intLineNo = IRI.intLineNo AND C.intOrderId = IRI.intOrderId AND B.intInventoryReceiptItemId = C.intInventoryReceiptItemId
		--) Receipts
		/*CROSS APPLY (
			SELECT 
				TOP 1 strBankAccountNo,
				strBankName,
				dbo.[fnAPFormatAddress](NULL, NULL, NULL, CBA.strAddress, CBA.strCity, CBA.strState, CBA.strZipCode, CBA.strCountry, NULL) as strBankAddress,
				strNotes
			FROM dbo.tblAPPaymentDetail PD
			INNER JOIN dbo.tblAPPayment P ON P.intPaymentId = PD.intPaymentId
			INNER JOIN dbo.tblCMBankAccount CBA ON CBA.intBankAccountId = P.intBankAccountId
			INNER JOIN dbo.tblCMBank CB ON CB.intBankId = CBA.intBankId
			WHERE PD.intBillId = K.intBillId
		) Payments*/
		WHERE A.ysnPosted = 1 
		AND D.intSourceType = 2 --Inbound Shipment
		AND E.intContractStatusId = 5
		AND BillClaim.intTransactionType = 11 --Only Show Claims 
		
	) tmpClaim
	GROUP BY dblCost,
		dblCostUnitQty,
		dblWeightUnitQty,
		dblQtyReceived,
		dblFranchise,
		dblContractItemQty,
		dblAmountPaid,
		dblPrepaidTotal,
		dtmDueDate,
		dtmDate,
		intBillId,
		intCostUOMId,
		intWeightUOMId,
		intUnitOfMeasureId,
		intItemId,
		intContractDetailId,
		intContractHeaderId,
		intEntityVendorId,
		intShipToId,
		intCurrencyId,
		intAccountId,
		strUnitMeasure,
		strItemNo,
		strContractNumber,
		strVendorId,		
		strAccountId,
		strAccountDesc,
		strName,
		str1099Form,
		str1099Type,
		strDescription,
		strVendorOrderNumber,
		strBillOfLading,		
		strCurrency,
		--strBankAccountNo,
		--strBankName,
		--strBankAddress,		
		--strNotes,
		strContainerNumber,
		strWeightGradeDesc,
		strComment,
		intCent,
		strCostCurrency,
		ysnSubCurrency
) Claim
WHERE dblQtyBillCreated = dblContractItemQty --make sure we fully billed the contract item
AND dblWeightLoss > dblFranchiseWeight -- Make sure the weight loss is greater then the tolerance