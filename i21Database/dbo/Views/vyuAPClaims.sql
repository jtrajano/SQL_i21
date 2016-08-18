CREATE VIEW [dbo].[vyuAPClaims]
AS

SELECT 
CAST(ROW_NUMBER() OVER(ORDER BY intContractDetailId) AS INT) AS intClaimId,
* ,
(dblWeightLoss - dblFranchiseWeight) * dblCost AS dblClaim,
(dblWeightLoss - dblFranchiseWeight) AS dblQtyToBill 
FROM (
	SELECT
		SUM(dblNetQtyReceived) AS dblNetQtyReceived,
		SUM(dblAppliedPrepayment) AS dblAppliedPrepayment,
		SUM(dblNetShippedWeight) AS dblNetShippedWeight,
		SUM(dblQtyBillCreated) AS dblQtyBillCreated,
		CASE 
		WHEN dblFranchise > 0
			THEN SUM(dblNetShippedWeight) * (dblFranchise / 100)
		ELSE 0 END AS dblFranchiseWeight,
		dblCost,
		dblQtyReceived,
		dblCostUnitQty,
		dblWeightUnitQty,
		intCostUOMId,
		intWeightUOMId,
		intUnitOfMeasureId,
		strUnitMeasure AS strUOM,
		strItemNo,
		strVendorId,
		strName,
		str1099Form,
		str1099Type,
		strContractNumber,
		strDescription,
		intItemId,
		intContractDetailId,
		intContractHeaderId,
		dblAmountPaid,
		dblContractItemQty,
		intEntityVendorId,
		intShipToId,
		SUM(dblNetShippedWeight) - SUM(dblNetQtyReceived) AS dblWeightLoss,
		dblPrepaidTotal,
		intAccountId,
		strAccountId,
		strAccountDesc
	FROM (
		SELECT 
			Loads.dblNetShippedWeight
			,Receipts.dblNetQtyReceived
			,J.dblAmountApplied AS dblAppliedPrepayment
			,B.dblCost
			,B.dblQtyReceived
			,B.dblQtyOrdered AS dblQtyBillCreated
			,B.intCostUOMId AS intUnitOfMeasureId
			,B3.strUnitMeasure
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
			,A.intCurrencyId
			,L.dblTotal + L.dblTax AS dblPrepaidTotal
			,M.strVendorId
			,M.intGLAccountExpenseId AS intAccountId
			,M3.strAccountId
			,M3.strDescription AS strAccountDesc
			,M2.strName
			,M2.str1099Form
			,M2.str1099Type
			,G.strDescription
		FROM tblAPBill A
		INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
		INNER JOIN (tblICItemUOM B2 INNER JOIN tblICUnitMeasure B3 ON B2.intUnitMeasureId = B3.intUnitMeasureId) ON B.intCostUOMId = B2.intItemUOMId
		INNER JOIN (tblAPVendor M INNER JOIN tblEMEntity M2 ON M.intEntityVendorId = M2.intEntityId LEFT JOIN tblGLAccount M3 ON M.intGLAccountExpenseId = M3.intAccountId) ON A.intEntityVendorId = M.intEntityVendorId
		INNER JOIN tblICInventoryReceiptItem C2 ON B.intInventoryReceiptItemId = C2.intInventoryReceiptItemId
		INNER JOIN tblICInventoryReceipt D ON C2.intInventoryReceiptId = D.intInventoryReceiptId
		INNER JOIN tblCTContractDetail E ON C2.intLineNo = E.intContractDetailId
		INNER JOIN tblCTContractHeader H ON H.intContractHeaderId = E.intContractHeaderId
		INNER JOIN tblCTWeightGrade I ON H.intWeightId = I.intWeightGradeId
		INNER JOIN tblICItem G ON B.intItemId = G.intItemId
		INNER JOIN tblAPAppliedPrepaidAndDebit J ON J.intContractHeaderId = E.intContractHeaderId AND B.intBillDetailId = J.intBillDetailApplied
		INNER JOIN tblAPBill K ON J.intTransactionId = K.intBillId
		INNER JOIN tblAPBillDetail L ON K.intBillId = L.intBillId 
					AND B.intItemId = L.intItemId 
					AND E.intContractDetailId = L.intContractDetailId
					AND E.intContractHeaderId = L.intContractHeaderId
		CROSS APPLY (
			SELECT SUM(F.dblGross) AS dblNetShippedWeight
			FROM tblLGLoadDetail F
			WHERE C2.intSourceId = F.intLoadDetailId
			) Loads
		CROSS APPLY (
			SELECT 
				SUM(C.dblNet) AS dblNetQtyReceived
			FROM tblICInventoryReceiptItem C 
			WHERE C.intLineNo = C2.intLineNo AND C.intOrderId = C2.intOrderId AND B.intInventoryReceiptItemId = C.intInventoryReceiptItemId
		) Receipts
		WHERE A.ysnPosted = 1 
		AND D.intSourceType = 2 --Inbound Shipment
		AND E.intContractStatusId = 5
		AND NOT EXISTS (
			--MAKE SURE THERE WAS NO CLAIM CREATED YET
			SELECT 1 FROM tblAPBill N 
			INNER JOIN tblAPBillDetail N2 ON N.intBillId = N2.intBillId
			WHERE B.intContractDetailId = N2.intContractDetailId AND B.intContractHeaderId = N2.intContractHeaderId AND N.intTransactionType = 11
		)
	) tmpClaim
	GROUP BY dblCost,
		dblCostUnitQty,
		dblWeightUnitQty,
		dblQtyReceived,
		intCostUOMId,
		intWeightUOMId,
		intUnitOfMeasureId,
		strUnitMeasure,
		dblFranchise,
		strItemNo,
		strContractNumber,
		intItemId,
		intContractDetailId,
		intContractHeaderId,
		dblContractItemQty,
		dblAmountPaid,
		intEntityVendorId,
		intShipToId,
		intCurrencyId,
		dblPrepaidTotal,
		strVendorId,
		intAccountId,
		strAccountId,
		strAccountDesc,
		strName,
		str1099Form,
		str1099Type,
		strDescription
) Claim
WHERE dblQtyBillCreated = dblContractItemQty --make sure we fully billed the contract item
AND dblWeightLoss > dblFranchiseWeight -- Make sure the weight loss is greater then the tolerance
