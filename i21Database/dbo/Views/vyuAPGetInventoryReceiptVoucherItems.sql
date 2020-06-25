CREATE VIEW [dbo].[vyuAPGetInventoryReceiptVoucherItems]
AS 

SELECT	Receipt.intEntityVendorId
		, intInventoryRecordId = Receipt.intInventoryReceiptId 		
		, intInventoryRecordItemId = receiptAndVoucheredItems.intInventoryReceiptItemId
		, intInventoryRecordChargeId = 0
		, dtmRecordDate = Receipt.dtmReceiptDate 
		, strLocationName = c.strLocationName
		, strRecordNumber = Receipt.strReceiptNumber 		
		, strBillOfLading = Receipt.strBillOfLading
		, strOrderType = Receipt.strReceiptType
		, strRecordType = 'Receipt' COLLATE Latin1_General_CI_AS
		, strOrderNumber = receiptAndVoucheredItems.strOrderNumber		
		, strItemNo = receiptAndVoucheredItems.strItemNo
		, strItemDescription = receiptAndVoucheredItems.strItemDescription
		, dblUnitCost = receiptAndVoucheredItems.dblUnitCost
		, dblRecordQty = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredItems.dblReceiptQty ELSE receiptAndVoucheredItems.dblReceiptQty END
		, dblVoucherQty  = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredItems.dblVoucherQty ELSE receiptAndVoucheredItems.dblVoucherQty END 
		, dblRecordLineTotal = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredItems.dblReceiptLineTotal ELSE receiptAndVoucheredItems.dblReceiptLineTotal END 
		, dblVoucherLineTotal = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredItems.dblVoucherLineTotal ELSE receiptAndVoucheredItems.dblVoucherLineTotal END 
		, dblRecordTax = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredItems.dblReceiptTax ELSE receiptAndVoucheredItems.dblReceiptTax END 
		, dblVoucherTax = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredItems.dblVoucherTax ELSE receiptAndVoucheredItems.dblVoucherTax END 
		, dblOpenQty = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredItems.dblOpenQty ELSE receiptAndVoucheredItems.dblOpenQty END 
		, dblItemsPayable = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredItems.dblItemsPayable ELSE receiptAndVoucheredItems.dblItemsPayable END 
		, dblTaxesPayable = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredItems.dblTaxesPayable ELSE receiptAndVoucheredItems.dblTaxesPayable END 
		, dtmLastVoucherDate = topVoucher.dtmBillDate		
		, receiptAndVoucheredItems.intCurrencyId
		, receiptAndVoucheredItems.strCurrency		
		, strAllVouchers = CAST( ISNULL(allLinkedVoucherId.strVoucherIds, 'New Voucher') AS NVARCHAR(MAX)) COLLATE Latin1_General_CI_AS
		, strFilterString = CAST(filterString.strFilterString AS NVARCHAR(MAX)) COLLATE Latin1_General_CI_AS
		, lc.intLoadContainerId
		, lc.strContainerNumber
		, intItemUOMId = COALESCE(ReceiptItem.intWeightUOMId, ReceiptItem.intUnitMeasureId)
		, strItemUOM = ItemUOMName.strUnitMeasure
		, intCostUOMId = COALESCE(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId)
		, strCostUOM = CostUOMName.strUnitMeasure
FROM	tblICInventoryReceipt Receipt 
		INNER JOIN tblICInventoryReceiptItem ReceiptItem
			ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		INNER JOIN (
			tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure ItemUOMName
				ON ItemUOM.intUnitMeasureId = ItemUOMName.intUnitMeasureId
		)
			ON ItemUOM.intItemUOMId = COALESCE(ReceiptItem.intWeightUOMId, ReceiptItem.intUnitMeasureId)
		INNER JOIN (
			tblICItemUOM CostUOM INNER JOIN tblICUnitMeasure CostUOMName
				ON CostUOM.intUnitMeasureId = CostUOMName.intUnitMeasureId
		)
			ON CostUOM.intItemUOMId = COALESCE(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId)

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
							* (
								CASE 
									WHEN ReceiptItem.ysnSubCurrency = 1 AND ISNULL(Receipt.intSubCurrencyCents, 1) <> 0 THEN 
										1 / ISNULL(Receipt.intSubCurrencyCents, 1) 
									ELSE 
										1 
								END 
							)
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
					,intCurrencyId = currency.intCurrencyID
					,strCurrency = currency.strCurrency

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

					LEFT JOIN tblSMCurrency subCurrency
						ON subCurrency.intMainCurrencyId = CASE WHEN ri.ysnSubCurrency = 1 THEN Receipt.intCurrencyId ELSE NULL END 

					LEFT JOIN tblSMCurrency currency
						ON currency.intCurrencyID = CASE WHEN ri.ysnSubCurrency = 1 THEN subCurrency.intCurrencyID ELSE Receipt.intCurrencyId END 

			WHERE	ri.intInventoryReceiptId = Receipt.intInventoryReceiptId
					AND ri.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
					--AND ct.intPricingTypeId != 2
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
										AND b.ysnPosted = 0
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
										AND b.ysnPosted = 0
								GROUP BY b.strBillId
								FOR xml path('')
							)
						, 1
						, 1
						, ''
					)
				)
		) allLinkedVoucherId  
		LEFT JOIN tblLGLoadContainer lc
			ON lc.intLoadContainerId = ReceiptItem.intContainerId

WHERE	Receipt.ysnPosted = 1
		AND receiptAndVoucheredItems.dblReceiptQty <> receiptAndVoucheredItems.dblVoucherQty
		AND receiptAndVoucheredItems.dblUnitCost != 0 --WILL NOT SHOW RECEIPT FROM STORAGE
		AND  EXISTS (
			SELECT TOP 1 * FROM tblGRSettleStorageTicket A
			LEFT JOIN tblGRCustomerStorage B ON A.intCustomerStorageId = B.intCustomerStorageId
			WHERE ReceiptItem.intSourceId = B.intTicketId
		) 
UNION ALL


SELECT	Receipt.intEntityVendorId
		, intInventoryRecordId = Receipt.intInventoryReceiptId 		
		, intInventoryRecordItemId = receiptAndVoucheredItems.intInventoryReceiptItemId
		, intInventoryRecordChargeId = 0
		, dtmRecordDate = Receipt.dtmReceiptDate 
		, strLocationName = c.strLocationName
		, strRecordNumber = Receipt.strReceiptNumber 		
		, strBillOfLading = Receipt.strBillOfLading
		, strOrderType = Receipt.strReceiptType
		, strRecordType = 'Receipt'
		, strOrderNumber = receiptAndVoucheredItems.strOrderNumber		
		, strItemNo = receiptAndVoucheredItems.strItemNo
		, strItemDescription = receiptAndVoucheredItems.strItemDescription
		, dblUnitCost = receiptAndVoucheredItems.dblUnitCost
		, dblRecordQty = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredItems.dblReceiptQty ELSE receiptAndVoucheredItems.dblReceiptQty END
		, dblVoucherQty  = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredItems.dblVoucherQty ELSE receiptAndVoucheredItems.dblVoucherQty END 
		, dblRecordLineTotal = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredItems.dblReceiptLineTotal ELSE receiptAndVoucheredItems.dblReceiptLineTotal END 
		, dblVoucherLineTotal = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredItems.dblVoucherLineTotal ELSE receiptAndVoucheredItems.dblVoucherLineTotal END 
		, dblRecordTax = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredItems.dblReceiptTax ELSE receiptAndVoucheredItems.dblReceiptTax END 
		, dblVoucherTax = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredItems.dblVoucherTax ELSE receiptAndVoucheredItems.dblVoucherTax END 
		, dblOpenQty = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredItems.dblOpenQty ELSE receiptAndVoucheredItems.dblOpenQty END 
		, dblItemsPayable = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredItems.dblItemsPayable ELSE receiptAndVoucheredItems.dblItemsPayable END 
		, dblTaxesPayable = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredItems.dblTaxesPayable ELSE receiptAndVoucheredItems.dblTaxesPayable END 
		, dtmLastVoucherDate = topVoucher.dtmBillDate		
		, receiptAndVoucheredItems.intCurrencyId
		, receiptAndVoucheredItems.strCurrency		
		, strAllVouchers = CAST( ISNULL(allLinkedVoucherId.strVoucherIds, 'New Voucher') AS NVARCHAR(MAX)) 
		, strFilterString = CAST(filterString.strFilterString AS NVARCHAR(MAX)) 
		, lc.intLoadContainerId
		, lc.strContainerNumber
		, intItemUOMId = COALESCE(ReceiptItem.intWeightUOMId, ReceiptItem.intUnitMeasureId)
		, strItemUOM = ItemUOMName.strUnitMeasure
		, intCostUOMId = COALESCE(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId)
		, strCostUOM = CostUOMName.strUnitMeasure
FROM	tblICInventoryReceipt Receipt 
		INNER JOIN tblICInventoryReceiptItem ReceiptItem
			ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		INNER JOIN (
			tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure ItemUOMName
				ON ItemUOM.intUnitMeasureId = ItemUOMName.intUnitMeasureId
		)
			ON ItemUOM.intItemUOMId = COALESCE(ReceiptItem.intWeightUOMId, ReceiptItem.intUnitMeasureId)
		INNER JOIN (
			tblICItemUOM CostUOM INNER JOIN tblICUnitMeasure CostUOMName
				ON CostUOM.intUnitMeasureId = CostUOMName.intUnitMeasureId
		)
			ON CostUOM.intItemUOMId = COALESCE(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId)

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
							* (
								CASE 
									WHEN ReceiptItem.ysnSubCurrency = 1 AND ISNULL(Receipt.intSubCurrencyCents, 1) <> 0 THEN 
										1 / ISNULL(Receipt.intSubCurrencyCents, 1) 
									ELSE 
										1 
								END 
							)
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
					,intCurrencyId = currency.intCurrencyID
					,strCurrency = currency.strCurrency

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

					LEFT JOIN tblSMCurrency subCurrency
						ON subCurrency.intMainCurrencyId = CASE WHEN ri.ysnSubCurrency = 1 THEN Receipt.intCurrencyId ELSE NULL END 

					LEFT JOIN tblSMCurrency currency
						ON currency.intCurrencyID = CASE WHEN ri.ysnSubCurrency = 1 THEN subCurrency.intCurrencyID ELSE Receipt.intCurrencyId END 

			WHERE	ri.intInventoryReceiptId = Receipt.intInventoryReceiptId
					AND ri.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
					--AND ct.intPricingTypeId != 2
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
										AND b.ysnPosted = 0
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
										AND b.ysnPosted = 0
								GROUP BY b.strBillId
								FOR xml path('')
							)
						, 1
						, 1
						, ''
					)
				)
		) allLinkedVoucherId  
		LEFT JOIN tblLGLoadContainer lc
			ON lc.intLoadContainerId = ReceiptItem.intContainerId
		LEFT JOIN tblSCTicket SC ON SC.intTicketId = ReceiptItem.intSourceId
WHERE	Receipt.ysnPosted = 1
		AND receiptAndVoucheredItems.dblReceiptQty <> receiptAndVoucheredItems.dblVoucherQty
		AND receiptAndVoucheredItems.dblUnitCost != 0 --WILL NOT SHOW RECEIPT FROM STORAGE
		AND ISNULL(SC.strDistributionOption,'') != 'DP' --EXCLUDE DELAYED PRICING TYPE FOR RECEIPT VENDOR
		
GO


