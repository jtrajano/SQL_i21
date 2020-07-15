CREATE VIEW [dbo].[vyuICGetInventoryReceiptVoucher]
AS 

SELECT	
	r.intInventoryReceiptId 
	,ri.intInventoryReceiptItemId
	,strVendor = vendor.strVendorId + ' ' + vendor.strName
	,c.strLocationName
	,r.strReceiptNumber 
	,r.dtmReceiptDate 
	,r.strBillOfLading
	,r.strReceiptType
	,ri.strOrderNumber			
	,ri.strItemDescription
	,ri.dblUnitCost
	,dblQtyToReceive = ri.dblOpenReceive
	,ri.dblLineTotal
	,dblQtyVouchered  = ri.dblQtyVouchered
	,dblVoucherAmount = ri.dblVoucherAmount
	,dblQtyToVoucher = ri.dblQtyToVoucher  
	,dblAmountToVoucher = ri.dblAmountToVoucher
	,strBillId = ISNULL(ri.strBillId, 'New Voucher')
	,dtmBillDate = ri.dtmBillDate
	,intBillId = ri.intBillId
	,r.intCurrencyId
	,currency.strCurrency
FROM	tblICInventoryReceipt r  
		LEFT JOIN vyuAPVendor vendor
			ON vendor.[intEntityId] = r.intEntityVendorId
		LEFT JOIN tblSMCompanyLocation c
			ON c.intCompanyLocationId = r.intLocationId
		LEFT JOIN tblSMCurrency currency
			ON currency.intCurrencyID = r.intCurrencyId
		OUTER APPLY (
			SELECT	strOrderNumber = COALESCE(ContractView.strContractNumber, POView.strPurchaseOrderNumber, TransferView.strTransferNo)
					,ri.intInventoryReceiptItemId
					,ri.dblUnitCost
					,ri.dblLineTotal
					,dblOpenReceive = CASE WHEN ri.intWeightUOMId IS NULL THEN ISNULL(ri.dblOpenReceive, 0) ELSE ISNULL(ri.dblNet, 0) END
					,ri.dblBillQty
					,i.strItemNo
					,strItemDescription = i.strDescription
					,b.strBillId
					,b.dtmBillDate
					,b.intBillId
					,dblQtyVouchered = 
							CASE 
								WHEN b.intTransactionType = 3 /*Debit Memo*/ AND r.strReceiptType <> 'Inventory Return' THEN 
									-CASE WHEN bd.intWeightUOMId IS NULL THEN ISNULL(bd.dblQtyReceived, 0) ELSE ISNULL(bd.dblNetWeight, 0) END
								ELSE 
									CASE WHEN bd.intWeightUOMId IS NULL THEN ISNULL(bd.dblQtyReceived, 0) ELSE ISNULL(bd.dblNetWeight, 0) END
							END 
						
					,dblVoucherAmount = 
									ISNULL(
										CASE	WHEN ri.intWeightUOMId IS NULL THEN											
													CASE 
														WHEN b.intTransactionType = 3 /*Debit Memo*/ AND r.strReceiptType <> 'Inventory Return' THEN -bd.dblQtyReceived
														ELSE bd.dblQtyReceived
													END 													
												ELSE 													
													CASE 
														WHEN b.intTransactionType = 3 /*Debit Memo*/ AND r.strReceiptType <> 'Inventory Return' THEN -bd.dblNetWeight
														ELSE bd.dblNetWeight
													END 							
										END 	
										* 
										CASE	WHEN ri.intCostUOMId IS NULL THEN 
													bd.dblCost 
												ELSE 
													dbo.fnCalculateCostBetweenUOM(bd.intUnitOfMeasureId, bd.intCostUOMId, bd.dblCost) 
										END
										,0
									)
					,dblQtyToVoucher =	CASE WHEN ri.intWeightUOMId IS NULL THEN ISNULL(ri.dblOpenReceive, 0) ELSE ISNULL(ri.dblNet, 0) END
										- 
										CASE 
											WHEN b.intTransactionType = 3 /*Debit Memo*/ AND r.strReceiptType <> 'Inventory Return' THEN -ISNULL(totalFromVouchers.totalQtyVouchered, 0) 
											ELSE ISNULL(totalFromVouchers.totalQtyVouchered, 0) 
										END 
					,dblAmountToVoucher = 
									ISNULL(
										CASE	WHEN ri.intWeightUOMId IS NULL THEN 
													ri.dblOpenReceive													
												ELSE 
													ri.dblNet
										END 	
										* 
										CASE	WHEN ri.intCostUOMId IS NULL THEN 
													ri.dblUnitCost
												ELSE 
													dbo.fnCalculateCostBetweenUOM(ri.intUnitMeasureId, ri.intCostUOMId, ri.dblUnitCost) 
										END
										,0
									)
									- 
									CASE 
										WHEN b.intTransactionType = 3 /*Debit Memo*/ AND r.strReceiptType <> 'Inventory Return' THEN -ISNULL(totalFromVouchers.totalAmountVouchered, 0) 
										ELSE ISNULL(totalFromVouchers.totalAmountVouchered, 0) 
									END 
				
			FROM	tblICInventoryReceiptItem ri OUTER APPLY (
						SELECT	totalQtyVouchered = 
									SUM(CASE WHEN bd.intWeightUOMId IS NULL THEN ISNULL(bd.dblQtyReceived, 0) ELSE ISNULL(bd.dblNetWeight, 0) END)
								,totalAmountVouchered = 
									SUM(
										ISNULL(
											CASE	WHEN bd.intWeightUOMId IS NULL THEN 
														bd.dblQtyReceived 										
													ELSE 
														bd.dblNetWeight
											END 	
											* 
											CASE	WHEN bd.intCostUOMId IS NULL THEN 
														bd.dblCost 
													ELSE 
														dbo.fnCalculateCostBetweenUOM(bd.intUnitOfMeasureId , bd.intCostUOMId, bd.dblCost) 
											END
											,0
										)									
									)
						FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
									ON b.intBillId = bd.intBillId
						WHERE	bd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
								AND bd.intInventoryReceiptChargeId IS NULL
								AND b.ysnPosted = 1 
					) totalFromVouchers
					LEFT JOIN (
						tblAPBill b INNER JOIN tblAPBillDetail bd
							ON b.intBillId = bd.intBillId
					)
						ON bd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
						AND bd.intInventoryReceiptChargeId IS NULL
						AND b.ysnPosted = 1 

					LEFT JOIN vyuCTContractDetailView ContractView
						ON ContractView.intContractDetailId = ri.intLineNo
						AND r.strReceiptType = 'Purchase Contract'
					LEFT JOIN vyuPODetails POView
						ON POView.intPurchaseId = ri.intOrderId 
						AND POView.intPurchaseDetailId = ri.intLineNo
						AND r.strReceiptType = 'Purchase Order'
					LEFT JOIN vyuICGetInventoryTransferDetail TransferView
						ON TransferView.intInventoryTransferDetailId = ri.intLineNo
						AND r.strReceiptType = 'Transfer Order'
					LEFT JOIN tblICItem i 
						ON i.intItemId = ri.intItemId						
			WHERE	ri.intInventoryReceiptId = r.intInventoryReceiptId
		) ri 
WHERE	r.ysnPosted = 1