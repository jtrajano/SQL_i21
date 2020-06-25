CREATE VIEW [dbo].[vyuAPGetInventoryReceiptVoucher]
AS 

SELECT	
	[intInventoryRecordId] = r.intInventoryReceiptId 
	, [intInventoryRecordItemId] = ri.intInventoryReceiptItemId
	, [intInventoryRecordChargeId] = 0
	, strVendor = vendor.strVendorId + ' ' + vendor.strName
	, c.strLocationName
	, [strRecordNumber] = r.strReceiptNumber 
	, [dtmRecordDate] = r.dtmReceiptDate 
	, r.strBillOfLading
	, [strOrderType] = r.strReceiptType
	, [strRecordType] = 'Receipt' COLLATE Latin1_General_CI_AS
	, ri.strOrderNumber			
	, ri.strItemDescription
	, ri.dblUnitCost
	, dblQtyToReceive = ri.dblOpenReceive
	, ri.dblLineTotal
	, dblQtyVouchered  = ri.dblQtyVouchered
	, dblVoucherAmount = ri.dblVoucherAmount
	, dblQtyToVoucher = ri.dblQtyToVoucher  
	, dblAmountToVoucher = ri.dblAmountToVoucher
	, strBillId = ISNULL(ri.strBillId, 'New Voucher')
	, dtmBillDate = ri.dtmBillDate
	, intBillId = ri.intBillId
	, r.intCurrencyId
	, currency.strCurrency
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
					,dblQtyVouchered = CASE WHEN bd.intWeightUOMId IS NULL THEN ISNULL(bd.dblQtyReceived, 0) ELSE ISNULL(bd.dblNetWeight, 0) END
					,dblVoucherAmount = 
									ISNULL(
										CASE	WHEN ri.intWeightUOMId IS NULL THEN 
													bd.dblQtyReceived 										
												ELSE 
													bd.dblNetWeight
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
										- ISNULL(totalFromVouchers.totalQtyVouchered, 0) 
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
									- ISNULL(totalFromVouchers.totalAmountVouchered, 0) 
				
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
						AND b.ysnPosted = 0 

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
		AND ri.dblOpenReceive <> ri.dblQtyVouchered
GO


