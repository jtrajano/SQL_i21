CREATE VIEW [dbo].[vyuAPClaims]
AS

SELECT 
CAST(ROW_NUMBER() OVER(ORDER BY intContractDetailId) AS INT) AS intClaimId,
* ,
CASE WHEN ysnSubCurrency > 0 THEN (dblWeightLoss - dblFranchiseWeight) * dblCost / ISNULL(intCent,1)  ELSE (dblWeightLoss - dblFranchiseWeight) * dblCost END AS dblClaim,
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
		dblBillCost,
		dblQtyReceived,
		dblCostUnitQty,
		dblWeightUnitQty,
		dblUnitQty,
		intCostUOMId,
		strCostUOM,
		intWeightUOMId,
		strgrossNetUOM,
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
		strAccountDesc,
		intCent,
		intCurrencyId,
		strCostCurrency,
		ysnSubCurrency
	FROM (
		SELECT 
            LGC.dblNetWt AS dblNetShippedWeight
			,Receipts.dblNetQtyReceived
			,J.dblAmountApplied AS dblAppliedPrepayment
			,CASE WHEN B.dblNetWeight > 0 THEN B.dblCost * (B.dblWeightUnitQty / B.dblCostUnitQty)
					 WHEN B.intCostUOMId > 0 THEN B.dblCost * (B.dblUnitQty / B.dblCostUnitQty) ELSE B.dblCost END AS dblCost
			,B.dblCost AS dblBillCost
			,B.dblQtyReceived
			,B.dblQtyOrdered AS dblQtyBillCreated
			,B.intUnitOfMeasureId
			,UOM.strUnitMeasure
			,B.intCostUOMId
			,CostUOM.strUnitMeasure AS strCostUOM
			,B.intWeightUOMId
			,WeightUOM.strUnitMeasure AS strgrossNetUOM
			,ISNULL(B.dblCostUnitQty,1) AS dblCostUnitQty
			,ISNULL(B.dblWeightUnitQty,1) AS dblWeightUnitQty 
			,ISNULL(B.dblUnitQty,1) AS dblUnitQty 
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
			,M.strVendorId
			,M.intGLAccountExpenseId AS intAccountId
			,M3.strAccountId
			,M3.strDescription AS strAccountDesc
			,M2.strName
			,M2.str1099Form
			,M2.str1099Type
			,G.strDescription
			,ISNULL(H1.intCent,1) AS intCent
			,ISNULL(E.intCurrencyId,ISNULL(H1.intMainCurrencyId,A.intCurrencyId)) AS intCurrencyId
			,ISNULL(H1.strCurrency,(SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = A.intCurrencyId)) AS strCostCurrency
			,ISNULL(H1.ysnSubCurrency,0) AS ysnSubCurrency
		FROM tblAPBill A
		INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
		INNER JOIN (tblICItemUOM B2 INNER JOIN tblICUnitMeasure B3 ON B2.intUnitMeasureId = B3.intUnitMeasureId) ON (CASE WHEN B.dblNetWeight > 0 THEN B.intWeightUOMId WHEN B.intCostUOMId > 0 THEN B.intCostUOMId ELSE B.intUnitOfMeasureId END) = B2.intItemUOMId
		INNER JOIN (tblAPVendor M INNER JOIN tblEMEntity M2 ON M.intEntityVendorId = M2.intEntityId LEFT JOIN tblGLAccount M3 ON M.intGLAccountExpenseId = M3.intAccountId) ON A.intEntityVendorId = M.intEntityVendorId
		INNER JOIN tblICInventoryReceiptItem C2 ON B.intInventoryReceiptItemId = C2.intInventoryReceiptItemId
		INNER JOIN tblICInventoryReceipt D ON C2.intInventoryReceiptId = D.intInventoryReceiptId
		INNER JOIN tblCTContractDetail E ON C2.intLineNo = E.intContractDetailId
		INNER JOIN tblCTContractHeader H ON H.intContractHeaderId = E.intContractHeaderId
		INNER JOIN tblCTWeightGrade I ON H.intWeightId = I.intWeightGradeId
		INNER JOIN tblICItem G ON B.intItemId = G.intItemId
		INNER JOIN tblAPAppliedPrepaidAndDebit J ON J.intContractHeaderId = E.intContractHeaderId AND B.intBillDetailId = J.intBillDetailApplied
		INNER JOIN tblLGLoadContainer LGC ON LGC.intLoadContainerId = C2.intContainerId
		LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = B.intWeightUOMId
		LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = B.intCostUOMId
		LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = C2.intUnitMeasureId
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		LEFT JOIN dbo.tblSMCurrency H1 ON H1.intCurrencyID = E.intCurrencyId
		INNER JOIN tblAPBill K ON J.intTransactionId = K.intBillId
		INNER JOIN tblAPBillDetail L ON K.intBillId = L.intBillId 
					AND B.intItemId = L.intItemId 
					AND E.intContractDetailId = L.intContractDetailId
					AND E.intContractHeaderId = L.intContractHeaderId
		--CROSS APPLY (
		--	SELECT SUM(F.dblGross) AS dblNetShippedWeight
		--	FROM tblLGLoadDetail F
		--	WHERE C2.intSourceId = F.intLoadDetailId
		--	) Loads
		CROSS APPLY (
			SELECT 
				SUM(C.dblNet) AS dblNetQtyReceived
			FROM tblICInventoryReceiptItem C 
			WHERE C.intLineNo = C2.intLineNo AND C.intOrderId = C2.intOrderId AND B.intInventoryReceiptItemId = C.intInventoryReceiptItemId
		) Receipts
		WHERE A.ysnPosted = 1 
		AND D.intSourceType = 2 --Inbound Shipment
		AND E.intContractStatusId = 5
	) tmpClaim
	GROUP BY dblCost,
		dblBillCost,
		dblCostUnitQty,
		dblWeightUnitQty,
		dblUnitQty,
		dblQtyReceived,
		strCostUOM,
		strgrossNetUOM,
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
		strDescription,
		ysnSubCurrency,
		intCent,
		strCostCurrency
) Claim
WHERE dblQtyBillCreated = dblContractItemQty --make sure we fully billed the contract item
AND dblWeightLoss > dblFranchiseWeight -- Make sure the weight loss is greater then the tolerance