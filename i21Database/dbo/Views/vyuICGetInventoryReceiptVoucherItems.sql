﻿CREATE VIEW [dbo].[vyuICGetInventoryReceiptVoucherItems]
AS 

SELECT	Receipt.intEntityVendorId
		,intInventoryReceiptId = Receipt.intInventoryReceiptId 		
		,intInventoryReceiptItemId = receiptAndVoucheredItems.intInventoryReceiptItemId
		,dtmReceiptDate = Receipt.dtmReceiptDate 
		,strLocationName = c.strLocationName
		,strReceiptNumber = Receipt.strReceiptNumber 		
		,strBillOfLading = Receipt.strBillOfLading
		,strReceiptType = Receipt.strReceiptType
		,strOrderNumber = receiptAndVoucheredItems.strOrderNumber		
		,strItemNo = receiptAndVoucheredItems.strItemNo
		,strItemDescription = receiptAndVoucheredItems.strItemDescription
		,dblUnitCost = receiptAndVoucheredItems.dblUnitCost
		,dblReceiptQty = receiptAndVoucheredItems.dblReceiptQty
		,dblVoucherQty  = receiptAndVoucheredItems.dblVoucherQty
		,dblReceiptLineTotal = receiptAndVoucheredItems.dblReceiptLineTotal
		,dblVoucherLineTotal = receiptAndVoucheredItems.dblVoucherLineTotal
		,dblReceiptTax = receiptAndVoucheredItems.dblReceiptTax
		,dblVoucherTax = receiptAndVoucheredItems.dblVoucherTax
		,dblOpenQty = receiptAndVoucheredItems.dblOpenQty  
		,dblItemsPayable = receiptAndVoucheredItems.dblItemsPayable
		,dblTaxesPayable = receiptAndVoucheredItems.dblTaxesPayable
		,dtmLastVoucherDate = topVoucher.dtmBillDate		
		,strAllVouchers = CAST( ISNULL(allLinkedVoucherId.strVoucherIds, 'New Voucher') AS NVARCHAR(MAX)) 
		,strFilterString = CAST(filterString.strFilterString AS NVARCHAR(MAX)) 
FROM	tblICInventoryReceipt Receipt 
		INNER JOIN tblICInventoryReceiptItem ReceiptItem
			ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		LEFT JOIN tblSMCompanyLocation c
			ON c.intCompanyLocationId = Receipt.intLocationId
		OUTER APPLY (
			SELECT	strOrderNumber = COALESCE(ct.strContractNumber, po.strPurchaseOrderNumber, tf.strTransferNo)
					,ri.intInventoryReceiptItemId
					,dblUnitCost = dbo.fnCalculateCostBetweenUOM(ISNULL(ri.intCostUOMId, ISNULL(ri.intWeightUOMId, ri.intUnitMeasureId)), ISNULL(ri.intWeightUOMId, ri.intUnitMeasureId), ri.dblUnitCost)
					,dblReceiptQty = 
						CASE	
							WHEN ri.intWeightUOMId IS NULL THEN 
								ISNULL(ri.dblOpenReceive, 0) 
							ELSE 
								CASE 
									WHEN ISNULL(ri.dblNet, 0) = 0 THEN 
										ISNULL(dbo.fnCalculateQtyBetweenUOM(ri.intUnitMeasureId, ri.intWeightUOMId, ri.dblOpenReceive), 0)
									ELSE 
										ISNULL(ri.dblNet, 0) 
								END 
						END
					,dblVoucherQty = 
						ISNULL(voucher.QtyTotal, 0)

					,dblReceiptLineTotal = 
						ROUND(
							CASE	
								WHEN ri.intWeightUOMId IS NULL THEN 
									ISNULL(ri.dblOpenReceive, 0) 
								ELSE 
									CASE 
										WHEN ISNULL(ri.dblNet, 0) = 0 THEN 
											ISNULL(dbo.fnCalculateQtyBetweenUOM(ri.intUnitMeasureId, ri.intWeightUOMId, ri.dblOpenReceive), 0)
										ELSE 
											ISNULL(ri.dblNet, 0) 
									END 
							END
							* dbo.fnCalculateCostBetweenUOM(ISNULL(ri.intCostUOMId, ri.intUnitMeasureId), ISNULL(ri.intWeightUOMId, ri.intUnitMeasureId), ri.dblUnitCost)
							, 2
						)

					,dblVoucherLineTotal = ISNULL(voucher.LineTotal, 0)
					,dblReceiptTax = ISNULL(ri.dblTax, 0)
					,dblVoucherTax = ISNULL(voucher.TaxTotal, 0) 

					,dblOpenQty =	
						CASE	
							WHEN ri.intWeightUOMId IS NULL THEN 
								ISNULL(ri.dblOpenReceive, 0) 
							ELSE 
								CASE 
									WHEN ISNULL(ri.dblNet, 0) = 0 THEN 
										ISNULL(dbo.fnCalculateQtyBetweenUOM(ri.intUnitMeasureId, ri.intWeightUOMId, ISNULL(ri.dblOpenReceive, 0)), 0)
									ELSE 
										ISNULL(ri.dblNet, 0) 
								END 
						END
						- ISNULL(voucher.QtyTotal, 0)
					,dblItemsPayable = 
						ROUND(
							CASE	
								WHEN ri.intWeightUOMId IS NULL THEN 
									ISNULL(ri.dblOpenReceive, 0) 
								ELSE 
									CASE 
										WHEN ISNULL(ri.dblNet, 0) = 0 THEN 
											ISNULL(dbo.fnCalculateQtyBetweenUOM(ri.intUnitMeasureId, ri.intWeightUOMId, ri.dblOpenReceive), 0)
										ELSE 
											ISNULL(ri.dblNet, 0) 
									END 
							END
							* dbo.fnCalculateCostBetweenUOM(ISNULL(ri.intCostUOMId, ri.intUnitMeasureId), ISNULL(ri.intWeightUOMId, ri.intUnitMeasureId), ri.dblUnitCost)
							, 2
						)
						- ISNULL(voucher.LineTotal, 0)
					,dblTaxesPayable = 
						ISNULL(ri.dblTax, 0)
						- ISNULL(voucher.TaxTotal, 0) 
					,i.strItemNo
					,strItemDescription = i.strDescription				
			FROM	tblICInventoryReceiptItem ri 
					OUTER APPLY (
						SELECT	QtyTotal = 
									SUM (
										CASE 
											WHEN bd.intWeightUOMId IS NULL THEN 
												ISNULL(bd.dblQtyReceived, 0) 
											ELSE 
												CASE 
													WHEN ISNULL(bd.dblNetWeight, 0) = 0 THEN 
														ISNULL(dbo.fnCalculateQtyBetweenUOM(bd.intUnitOfMeasureId, bd.intWeightUOMId, ISNULL(bd.dblQtyReceived, 0)), 0)
													ELSE 
														ISNULL(bd.dblNetWeight, 0) 
												END
										END
									)									
								,LineTotal = 
									SUM (
										ROUND (
											CASE 
												WHEN bd.intWeightUOMId IS NULL THEN 
													ISNULL(bd.dblQtyReceived, 0) 
												ELSE 
													CASE 
														WHEN ISNULL(bd.dblNetWeight, 0) = 0 THEN 
															ISNULL(dbo.fnCalculateQtyBetweenUOM(bd.intUnitOfMeasureId, bd.intWeightUOMId, ISNULL(bd.dblQtyReceived, 0)), 0)
														ELSE 
															ISNULL(bd.dblNetWeight, 0) 
													END
											END		
											* dbo.fnCalculateCostBetweenUOM(ISNULL(bd.intCostUOMId, bd.intUnitOfMeasureId), ISNULL(bd.intWeightUOMId, bd.intUnitOfMeasureId), bd.dblCost)
											, 2
										)
									)

								,TaxTotal = 
									SUM(ISNULL(bd.dblTax, 0)) 
						FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
									ON b.intBillId = bd.intBillId
						WHERE	bd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
								AND bd.intInventoryReceiptChargeId IS NULL
								AND b.ysnPosted = 1 
					) voucher
					LEFT JOIN (
						tblCTContractHeader ct INNER JOIN tblCTContractDetail cd
							ON ct.intContractHeaderId = cd.intContractHeaderId
					)
						ON cd.intContractDetailId = ri.intLineNo
						AND Receipt.strReceiptType = 'Purchase Contract'

					LEFT JOIN (
						tblPOPurchase po INNER JOIN tblPOPurchaseDetail pd
							ON po.intPurchaseId = pd.intPurchaseId
					)
						ON po.intPurchaseId = ri.intOrderId
						AND pd.intPurchaseDetailId = ri.intLineNo
						AND Receipt.strReceiptType = 'Purchase Order'

					LEFT JOIN (
						tblICInventoryTransfer tf INNER JOIN tblICInventoryTransferDetail tfd
							ON tf.intInventoryTransferId = tfd.intInventoryTransferId
					)
						ON tfd.intInventoryTransferDetailId = ri.intLineNo
						AND Receipt.strReceiptType = 'Transfer Order'

					LEFT JOIN tblICItem i 
						ON i.intItemId = ri.intItemId						
			WHERE	ri.intInventoryReceiptId = Receipt.intInventoryReceiptId
					AND ri.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
		) receiptAndVoucheredItems
		OUTER APPLY (
			SELECT	TOP 1 
					b.strBillId
					,b.intBillId
					,b.dtmBillDate
			FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
						ON b.intBillId = bd.intBillId
			WHERE	bd.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
					AND bd.intInventoryReceiptChargeId IS NULL 
					AND b.ysnPosted = 1
			ORDER BY b.intBillId DESC 
		) topVoucher
		OUTER APPLY (
			SELECT strFilterString = 
				LTRIM(
					STUFF(
							' ' + (
								SELECT  CONVERT(NVARCHAR(50), b.intBillId) + '|^|'
								FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
											ON b.intBillId = bd.intBillId
								WHERE	bd.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
										AND bd.intInventoryReceiptChargeId IS NULL 
										AND b.ysnPosted = 1
								GROUP BY b.intBillId
								FOR xml path('')
							)
						, 1
						, 1
						, ''
					)
				)
		) filterString 
		OUTER APPLY (
			SELECT strVoucherIds = 
				LTRIM(
					STUFF(
							(
								SELECT  ', ' + b.strBillId
								FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
											ON b.intBillId = bd.intBillId
								WHERE	bd.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
										AND bd.intInventoryReceiptChargeId IS NULL 
										AND b.ysnPosted = 1
								GROUP BY b.strBillId
								FOR xml path('')
							)
						, 1
						, 1
						, ''
					)
				)
		) allLinkedVoucherId  
WHERE	Receipt.ysnPosted = 1
