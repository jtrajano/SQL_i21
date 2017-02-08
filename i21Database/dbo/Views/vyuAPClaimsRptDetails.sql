CREATE VIEW [dbo].[vyuAPClaimsRptDetails]
AS
       SELECT 
			 A.intBillId
			,Bill.dblCost
			,Bill.dblBillCost
			,ISNULL(SUM(Container.dblGrossShippedWeight), SUM(B.dblWeight)) AS dblGrossShippedWeight
		    ,ISNULL(SUM(Container.dblNetShippedWeight), SUM(B.dblNetShippedWeight)) AS dblNetShippedWeight
			,ISNULL(SUM(Container.dblTareShippedWeight), 0) AS dblTareShippedWeight
			,ISNULL(SUM(Receipts.dblGrossQtyReceived), SUM(B.dblQtyReceived)) AS dblGrossQtyReceived
			,ISNULL(SUM(Receipts.dblNetQtyReceived), SUM(B.dblNetWeight)) AS dblNetQtyReceived
			,ISNULL(SUM(J.dblAmountApplied),0) AS dblAppliedPrepayment
			,SUM(B.dblQtyReceived) AS dblQtyReceived
			,SUM(B.dblQtyOrdered) AS dblQtyBillCreated
			,B.intUnitOfMeasureId
			,B.intCostUOMId
			,B.intWeightUOMId
			,UOM.strUnitMeasure
			,CostUOM.strUnitMeasure AS strCostUOM
			,WeightUOM.strUnitMeasure AS strgrossNetUOM
			,ISNULL(B.dblCostUnitQty,1) AS dblCostUnitQty
			,ISNULL(B.dblWeightUnitQty,1) AS dblWeightUnitQty 
			,ISNULL(B.dblUnitQty,1) AS dblUnitQty 
			,Item.strItemNo
			,Item.intItemId
			,Item.strDescription
			,B.intContractDetailId
			,B.intContractHeaderId
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
			,ISNULL(A.intSubCurrencyCents,1) AS intCent
			,ISNULL(A.intCurrencyId,H1.intMainCurrencyId) AS intCurrencyId
			,(SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = A.intCurrencyId)AS strCostCurrency
			,ISNULL(B.ysnSubCurrency,0) AS ysnSubCurrency
			,ContainerDetails.strContainerNumber
			,D.strBillOfLading
			,Claim.strBillId
			,Claim.strVendorOrderNumber
			,Claim.dtmDate
			,Claim.dtmDueDate
			,Claim.strComment
			,I.strWeightGradeDesc
			,N.strCurrency
		FROM tblAPBill A
		INNER JOIN tblAPBillDetail B 
			ON A.intBillId = B.intBillId
		INNER JOIN (tblICItemUOM B2 INNER JOIN tblICUnitMeasure B3 
			ON B2.intUnitMeasureId = B3.intUnitMeasureId) ON (CASE WHEN B.dblNetWeight > 0 THEN B.intWeightUOMId WHEN B.intCostUOMId > 0 THEN B.intCostUOMId ELSE B.intUnitOfMeasureId END) =		B2.intItemUOMId
		INNER JOIN (tblAPVendor M INNER JOIN tblEMEntity M2 
			ON M.intEntityVendorId = M2.intEntityId LEFT JOIN tblGLAccount M3 ON M.intGLAccountExpenseId = M3.intAccountId) ON A.intEntityVendorId = M.intEntityVendorId
		LEFT JOIN tblICInventoryReceiptItem C2 
			ON B.intInventoryReceiptItemId = C2.intInventoryReceiptItemId
		LEFT JOIN tblICInventoryReceipt D 
			ON C2.intInventoryReceiptId = D.intInventoryReceiptId
		LEFT JOIN (tblCTContractDetail E INNER JOIN tblCTContractHeader H ON E.intContractHeaderId = H.intContractHeaderId)
			ON B.intContractDetailId = E.intContractDetailId
		LEFT JOIN tblCTWeightGrade I 
			ON H.intWeightId = I.intWeightGradeId
		LEFT JOIN tblICItem Item 
			ON B.intItemId = Item.intItemId
		LEFT JOIN tblAPAppliedPrepaidAndDebit J 
			ON J.intContractHeaderId = E.intContractHeaderId 
			AND B.intBillDetailId = J.intBillDetailApplied
		LEFT JOIN tblICItemUOM ItemWeightUOM 
			ON ItemWeightUOM.intItemUOMId = B.intWeightUOMId
		LEFT JOIN tblICUnitMeasure WeightUOM 
			ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM ItemCostUOM 
			ON ItemCostUOM.intItemUOMId = B.intCostUOMId
		LEFT JOIN tblICUnitMeasure CostUOM 
			ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM ItemUOM 
			ON ItemUOM.intItemUOMId = C2.intUnitMeasureId
		LEFT JOIN tblICUnitMeasure UOM 
			ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		LEFT JOIN dbo.tblSMCurrency H1 
			ON H1.intCurrencyID = E.intCurrencyId
		LEFT JOIN dbo.tblSMCurrency N 
			ON A.intCurrencyId = N.intCurrencyID
		LEFT JOIN tblAPBill K 
			ON J.intTransactionId = K.intBillId
		LEFT JOIN tblAPBillDetail L 
			ON K.intBillId = L.intBillId 
					AND B.intItemId = L.intItemId 
					AND E.intContractDetailId = L.intContractDetailId
					AND E.intContractHeaderId = L.intContractHeaderId
		OUTER APPLY (
			SELECT 
				SUM(C.dblGross) AS dblGrossQtyReceived,
				SUM(C.dblNet) AS dblNetQtyReceived
			FROM tblICInventoryReceiptItem C 
			WHERE C.intLineNo = C2.intLineNo AND C.intOrderId = C2.intOrderId AND B.intInventoryReceiptItemId = C.intInventoryReceiptItemId
		) Receipts
		OUTER APPLY (
			SELECT 
				SUM(LGC.dblNetWt) AS dblNetShippedWeight,
				SUM(LGC.dblGrossWt) AS dblGrossShippedWeight,
				SUM(LGC.dblTareWt) AS dblTareShippedWeight
			FROM tblLGLoadContainer LGC
			WHERE LGC.intLoadContainerId = C2.intContainerId
		) Container
		OUTER APPLY (
			SELECT 
				CASE WHEN B.dblNetWeight > 0 THEN B.dblCost * (B.dblWeightUnitQty / ISNULL(NULLIF(B.dblCostUnitQty, 0),1))
					 WHEN B.intCostUOMId > 0 THEN B.dblCost * (B.dblUnitQty /  ISNULL(NULLIF(B.dblCostUnitQty, 0),1)) ELSE B.dblCost END AS dblCost,
				B.dblCost  AS dblBillCost
			FROM tblAPBillDetail BD
			WHERE BD.intBillId = A.intBillId AND B.intBillDetailId = BD.intBillDetailId
		) Bill
		OUTER APPLY (
			SELECT 
				C.intBillId,
				C.strBillId,
				C.strVendorOrderNumber,
				C.dtmDate,
				C.dtmDueDate,
				C.strComment
			FROM tblAPBillDetail P
			INNER JOIN dbo.tblAPBill C ON C.intBillId = P.intBillId 
			WHERE P.intContractHeaderId = H.intContractHeaderId AND P.intInventoryReceiptItemId IS NULL AND C.intTransactionType = 11
		) Claim
		OUTER APPLY(
			SELECT TOP 1 strContainerNumber
			FROM tblLGLoadContainer LGC
			INNER JOIN tblICInventoryReceiptItem C2 ON C2.intContainerId = LGC.intLoadContainerId
		) ContainerDetails
		WHERE 1 = CASE WHEN A.ysnPosted = 0 AND A.intTransactionType = 11 THEN 1 ELSE 
					CASE WHEN A.ysnPosted = 1 THEN 1 ELSE 0 END
				END
		AND 1 = CASE WHEN (D.intSourceType IS NULL) THEN 1 ELSE 
			CASE WHEN D.intSourceType = 2 THEN 1 ELSE 0 END
		 END --Inbound Shipment
		AND 1 = CASE WHEN E.intContractStatusId IS NULL THEN 1 ELSE 
					CASE WHEN E.intContractStatusId = 5 THEN 1 ELSE 0 END
				END
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
				 ,Item.strItemNo
				 ,Item.intItemId
				 ,B.intContractDetailId
				 ,B.intContractHeaderId
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
				 ,Item.strDescription
				 ,A.intSubCurrencyCents
				 ,E.intCurrencyId
				 ,H1.intMainCurrencyId
				 ,A.intCurrencyId
				 ,H1.strCurrency
			     ,H1.ysnSubCurrency
				 ,D.strBillOfLading
				 ,Claim.strBillId
				 ,Claim.strVendorOrderNumber
				 ,Claim.dtmDate
				 ,Claim.dtmDueDate
				 ,Claim.strComment
				 ,I.strWeightGradeDesc
				 ,N.strCurrency
				 ,ContainerDetails.strContainerNumber
				 ,B.ysnSubCurrency