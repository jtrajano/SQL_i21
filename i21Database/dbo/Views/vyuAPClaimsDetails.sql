CREATE VIEW [dbo].[vyuAPClaimsDetails]
AS
       SELECT 
			 A.intBillId
			,Bill.dblCost
			,Bill.dblBillCost
		    ,SUM(Container.dblNetShippedWeight) AS dblNetShippedWeight
			,SUM(Receipts.dblNetQtyReceived) AS dblNetQtyReceived
			,SUM(J.dblAmountApplied) AS dblAppliedPrepayment
			,SUM(B.dblQtyReceived) AS dblQtyReceived
			,SUM(B.dblQtyOrdered) AS dblQtyBillCreated
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
			,ISNULL(A.intSubCurrencyCents,1) AS intCent
			,ISNULL(A.intCurrencyId,H1.intMainCurrencyId) AS intCurrencyId
			,(SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = A.intCurrencyId)AS strCostCurrency
			,ISNULL(B.ysnSubCurrency,0) AS ysnSubCurrency
			,Term.intTermID
			,Term.strTerm
		FROM tblAPBill A
		INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
		INNER JOIN (tblICItemUOM B2 INNER JOIN tblICUnitMeasure B3 ON B2.intUnitMeasureId = B3.intUnitMeasureId) ON (CASE WHEN B.dblNetWeight > 0 THEN B.intWeightUOMId WHEN B.intCostUOMId > 0 THEN B.intCostUOMId ELSE B.intUnitOfMeasureId END) =		B2.intItemUOMId
		INNER JOIN (tblAPVendor M INNER JOIN tblEMEntity M2 ON M.[intEntityId] = M2.intEntityId LEFT JOIN tblGLAccount M3 ON M.intGLAccountExpenseId = M3.intAccountId) ON A.intEntityVendorId = M.[intEntityId]
		INNER JOIN tblICInventoryReceiptItem C2 ON B.intInventoryReceiptItemId = C2.intInventoryReceiptItemId
		INNER JOIN tblICInventoryReceipt D ON C2.intInventoryReceiptId = D.intInventoryReceiptId
		INNER JOIN tblCTContractDetail E ON C2.intLineNo = E.intContractDetailId
		INNER JOIN tblCTContractHeader H ON H.intContractHeaderId = E.intContractHeaderId
		INNER JOIN tblCTWeightGrade I ON H.intWeightId = I.intWeightGradeId
		INNER JOIN tblICItem G ON B.intItemId = G.intItemId
		INNER JOIN tblAPAppliedPrepaidAndDebit J ON J.intContractHeaderId = E.intContractHeaderId AND B.intBillDetailId = J.intBillDetailApplied
		LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = B.intWeightUOMId
		LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = B.intCostUOMId
		LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = C2.intUnitMeasureId
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		LEFT JOIN dbo.tblSMCurrency H1 ON H1.intCurrencyID = E.intCurrencyId
		INNER JOIN tblAPBill K ON J.intTransactionId = K.intBillId
		LEFT JOIN tblSMTerm Term ON H.intTermId = Term.intTermID
		INNER JOIN tblAPBillDetail L ON K.intBillId = L.intBillId 
					AND B.intItemId = L.intItemId 
					AND E.intContractDetailId = L.intContractDetailId
					AND E.intContractHeaderId = L.intContractHeaderId
		CROSS APPLY (
			SELECT SUM(dblNetQtyReceived) dblNetQtyReceived FROM (
				SELECT 
					(CASE WHEN B.dblNetWeight > 0 THEN C.dblNet * (ISNULL(ICWeightUOM.dblUnitQty,1) / ICUOM.dblUnitQty)
							ELSE C.dblOrderQty END) AS dblNetQtyReceived
				FROM tblICInventoryReceiptItem C 
				INNER JOIN tblICItemUOM ICUOM ON C.intUnitMeasureId = ICUOM.intItemUOMId AND C.intItemId = ICUOM.intItemId
				LEFT JOIN tblICItemUOM ICWeightUOM ON C.intWeightUOMId = ICWeightUOM.intItemUOMId AND C.intItemId = ICWeightUOM.intItemId
				WHERE C.intLineNo = C2.intLineNo AND C.intOrderId = C2.intOrderId AND B.intInventoryReceiptItemId = C.intInventoryReceiptItemId
			) ReceiptsQtyReceived
		) Receipts
		CROSS APPLY (
			SELECT 
				SUM(LGC.dblNetWt) AS dblNetShippedWeight
			FROM tblLGLoadContainer LGC
			WHERE LGC.intLoadContainerId = C2.intContainerId
		) Container
		CROSS APPLY (
			SELECT 
				CASE WHEN B.dblNetWeight > 0 THEN B.dblCost * (B.dblWeightUnitQty / ISNULL(NULLIF(B.dblCostUnitQty, 0),1))
					 WHEN B.intCostUOMId > 0 THEN B.dblCost * (B.dblUnitQty /  ISNULL(NULLIF(B.dblCostUnitQty, 0),1)) ELSE B.dblCost END AS dblCost,
				B.dblCost  AS dblBillCost
			FROM tblAPBillDetail BD
			WHERE BD.intBillId = A.intBillId AND B.intBillDetailId = BD.intBillDetailId
		) Bill
		WHERE A.ysnPosted = 1 
		AND D.intSourceType = 2 --Inbound Shipment
		AND E.intContractStatusId = 5
		GROUP BY A.intBillId
				 ,Bill.dblCost
				 ,Bill.dblBillCost
				 ,B.intUnitOfMeasureId
				 ,UOM.strUnitMeasure
				 ,B.intCostUOMId
				 ,CostUOM.strUnitMeasure
				 ,B.intWeightUOMId
				 ,WeightUOM.strUnitMeasure
				 ,B.dblCostUnitQty
				 ,B.dblWeightUnitQty
				 ,B.dblUnitQty
				 ,G.strItemNo
				 ,G.intItemId
				 ,E.intContractDetailId
				 ,E.intContractHeaderId
				 ,E.intContractSeq
				 ,E.dblTotalCost
				 ,E.dblQuantity
				 ,H.strContractNumber
				 ,I.dblFranchise
				 ,A.intEntityVendorId
				 ,A.intShipToId
				 ,L.dblTotal 
				 ,L.dblTax
				 ,M.strVendorId
				 ,M.intGLAccountExpenseId 
				 ,M3.strAccountId
				 ,M3.strDescription
				 ,M2.strName
				 ,M2.str1099Form
				 ,M2.str1099Type
				 ,G.strDescription
				 ,A.intSubCurrencyCents
				 ,E.intCurrencyId
				 ,H1.intMainCurrencyId
				 ,A.intCurrencyId
				 ,H1.strCurrency
			     ,H1.ysnSubCurrency
				 ,B.ysnSubCurrency
				 ,Term.intTermID
				 ,Term.strTerm