CREATE VIEW [dbo].[vyuAPGetInventoryReceiptVoucherPriceCharges]
AS 

SELECT	intEntityVendorId = Receipt.intEntityVendorId
		, intInventoryRecordId = Receipt.intInventoryReceiptId
		, intInventoryRecordItemId = 0
		, intInventoryRecordChargeId = receiptAndVoucheredCharges.intInventoryReceiptChargeId
		, dtmRecordDate = Receipt.dtmReceiptDate 
		, strLocationName = c.strLocationName
		, strRecordNumber = Receipt.strReceiptNumber 		
		, strBillOfLading = Receipt.strBillOfLading
		, strOrderType = Receipt.strReceiptType
		, strRecordType = 'Receipt'
		, strOrderNumber = receiptAndVoucheredCharges.strOrderNumber		
		, strItemNo = receiptAndVoucheredCharges.strItemNo
		, strItemDescription = receiptAndVoucheredCharges.strItemDescription
		, dblUnitCost = receiptAndVoucheredCharges.dblUnitCost
		, dblRecordQty = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblReceiptQty ELSE receiptAndVoucheredCharges.dblReceiptQty END 
		, dblVoucherQty  = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblVoucherQty ELSE receiptAndVoucheredCharges.dblVoucherQty END 
		, dblRecordLineTotal = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblReceiptLineTotal ELSE receiptAndVoucheredCharges.dblReceiptLineTotal END 
		, dblVoucherLineTotal = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblVoucherLineTotal ELSE receiptAndVoucheredCharges.dblVoucherLineTotal END 
		, dblRecordTax = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblReceiptTax ELSE receiptAndVoucheredCharges.dblReceiptTax END 
		, dblVoucherTax = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblVoucherTax ELSE receiptAndVoucheredCharges.dblVoucherTax END 
		, dblOpenQty = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblOpenQty ELSE receiptAndVoucheredCharges.dblOpenQty END 
		, dblItemsPayable = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblItemsPayable ELSE receiptAndVoucheredCharges.dblItemsPayable END 
		, dblTaxesPayable = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblTaxesPayable ELSE receiptAndVoucheredCharges.dblTaxesPayable END 
		, dtmLastVoucherDate = topVoucher.dtmBillDate			
		, receiptAndVoucheredCharges.intCurrencyId
		, receiptAndVoucheredCharges.strCurrency
		, strAllVouchers = CAST( ISNULL(allLinkedVoucherId.strVoucherIds, 'New Voucher') AS NVARCHAR(MAX)) 
		, strFilterString = CAST(filterString.strFilterString AS NVARCHAR(MAX)) 
		, strItemUOM = ItemUOMName.strUnitMeasure
		, strCostUOM = ItemUOMName.strUnitMeasure
FROM	tblICInventoryReceipt Receipt 
		INNER JOIN tblICInventoryReceiptCharge ReceiptCharge
			ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
		LEFT JOIN tblSMCompanyLocation c
			ON c.intCompanyLocationId = Receipt.intLocationId
		LEFT JOIN (
			tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure ItemUOMName
				ON ItemUOM.intUnitMeasureId = ItemUOMName.intUnitMeasureId
		)
		ON ItemUOM.intItemUOMId = ReceiptCharge.intCostUOMId
		OUTER APPLY (
			SELECT	strOrderNumber = ct.strContractNumber
					,rc.intInventoryReceiptChargeId
					,dblUnitCost = (CASE WHEN rc.strCostMethod = 'Per Unit' THEN  ROUND(rc.dblRate, 2) ELSE ROUND(rc.dblAmount, 2) END )
					,dblReceiptQty = (CASE WHEN rc.dblQuantityPriced <> 0 THEN ISNULL(rc.dblQuantityPriced,0) ELSE ISNULL(rc.dblQuantity,0) END)
					,dblVoucherQty = ISNULL(voucher.QtyTotal, 0)
					,dblReceiptLineTotal = ROUND(-rc.dblAmount, 2)
					,dblVoucherLineTotal = ISNULL(voucher.LineTotal, 0)
					,dblReceiptTax = ISNULL(-rc.dblTax, 0)
					,dblVoucherTax = ISNULL(voucher.TaxTotal, 0) 
					,dblOpenQty = -ISNULL(rc.dblQuantity,1) - ISNULL(voucher.QtyTotal, 0)
					,dblItemsPayable = 
						ROUND(-rc.dblAmount, 2)
						- ISNULL(voucher.LineTotal, 0)
					,dblTaxesPayable = 
						ISNULL(-rc.dblTax, 0)
						- ISNULL(voucher.TaxTotal, 0) 
					,i.strItemNo
					,strItemDescription = i.strDescription	
					,intCurrencyId = ISNULL(rc.intCurrencyId, Receipt.intCurrencyId)
					,currency.strCurrency
			FROM	tblICInventoryReceiptCharge rc 
					OUTER APPLY (
						SELECT	QtyTotal = 
									SUM (ISNULL(bd.dblQtyReceived, 0))									
								,LineTotal = 
									SUM (
										ROUND (
											ISNULL(bd.dblQtyReceived, 0)		
											* ISNULL(bd.dblCost, 0) 
											, 2
										)
									)

								,TaxTotal = 
									SUM(ISNULL(bd.dblTax, 0)) 
						FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
									ON b.intBillId = bd.intBillId
						WHERE	bd.intInventoryReceiptChargeId = rc.intInventoryReceiptChargeId
								AND b.intEntityVendorId = Receipt.intEntityVendorId
								AND b.ysnPosted = 1 
					) voucher
					LEFT JOIN (
						tblCTContractHeader ct INNER JOIN tblCTContractDetail cd
							ON ct.intContractHeaderId = cd.intContractHeaderId
					)
						ON cd.intContractDetailId = rc.intContractDetailId
						AND Receipt.strReceiptType = 'Purchase Contract'

					LEFT JOIN tblICItem i 
						ON i.intItemId = rc.intChargeId

					LEFT JOIN tblSMCurrency currency
						ON currency.intCurrencyID = ISNULL(rc.intCurrencyId, Receipt.intCurrencyId) 

			WHERE	rc.intInventoryReceiptId = Receipt.intInventoryReceiptId
					AND rc.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
					--AND ct.intPricingTypeId != 2
		) receiptAndVoucheredCharges

		OUTER APPLY (
			SELECT	TOP 1 
					b.strBillId
					,b.intBillId
					,b.dtmBillDate
			FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
						ON b.intBillId = bd.intBillId
			WHERE	bd.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
					AND b.intEntityVendorId = Receipt.intEntityVendorId
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
								WHERE	bd.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
										AND b.intEntityVendorId = Receipt.intEntityVendorId
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
				STUFF(
						(
							SELECT  ', ' + b.strBillId
							FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
										ON b.intBillId = bd.intBillId
							WHERE	bd.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
									AND b.intEntityVendorId = Receipt.intEntityVendorId
									AND b.ysnPosted = 0
							GROUP BY b.strBillId
							FOR xml path('')
						)
					, 1
					, 1
					, ''
				)
		) allLinkedVoucherId  
		OUTER APPLY (
			SELECT	TOP 1 
					intSourceId
			FROM	tblICInventoryReceiptItem b 
			WHERE	b.intInventoryReceiptId = Receipt.intInventoryReceiptId
		) ri
		
WHERE	Receipt.ysnPosted = 1
		AND ReceiptCharge.ysnPrice = 1
		AND receiptAndVoucheredCharges.dblReceiptQty <> receiptAndVoucheredCharges.dblVoucherQty
		AND ReceiptCharge.dblAmount <> 0 --WILL NOT SHOW RECEIPT FROM STORAGE
		AND  EXISTS (
			SELECT intTicketId,* FROM tblGRSettleStorageTicket A
			LEFT JOIN tblGRCustomerStorage B ON A.intCustomerStorageId = B.intCustomerStorageId
			WHERE ri.intSourceId = B.intTicketId
		) 
 

 UNION ALL

 SELECT	
		intEntityVendorId = Receipt.intEntityVendorId
		, intInventoryRecordId = Receipt.intInventoryReceiptId
		, intInventoryRecordItemId = 0
		, intInventoryRecordChargeId = receiptAndVoucheredCharges.intInventoryReceiptChargeId
		, dtmRecordDate = Receipt.dtmReceiptDate 
		, strLocationName = c.strLocationName
		, strRecordNumber = Receipt.strReceiptNumber 		
		, strBillOfLading = Receipt.strBillOfLading
		, strOrderType = Receipt.strReceiptType
		, strRecordType = 'Receipt' COLLATE Latin1_General_CI_AS
		, strOrderNumber = receiptAndVoucheredCharges.strOrderNumber		
		, strItemNo = receiptAndVoucheredCharges.strItemNo
		, strItemDescription = receiptAndVoucheredCharges.strItemDescription
		, dblUnitCost = receiptAndVoucheredCharges.dblUnitCost
		, dblRecordQty = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblReceiptQty ELSE receiptAndVoucheredCharges.dblReceiptQty END 
		, dblVoucherQty  = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblVoucherQty ELSE receiptAndVoucheredCharges.dblVoucherQty END 
		, dblRecordLineTotal = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblReceiptLineTotal ELSE receiptAndVoucheredCharges.dblReceiptLineTotal END 
		, dblVoucherLineTotal = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblVoucherLineTotal ELSE receiptAndVoucheredCharges.dblVoucherLineTotal END 
		, dblRecordTax = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblReceiptTax ELSE receiptAndVoucheredCharges.dblReceiptTax END 
		, dblVoucherTax = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblVoucherTax ELSE receiptAndVoucheredCharges.dblVoucherTax END 
		, dblOpenQty = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblOpenQty ELSE receiptAndVoucheredCharges.dblOpenQty END 
		, dblItemsPayable = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblItemsPayable ELSE receiptAndVoucheredCharges.dblItemsPayable END 
		, dblTaxesPayable = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblTaxesPayable ELSE receiptAndVoucheredCharges.dblTaxesPayable END 
		, dtmLastVoucherDate = topVoucher.dtmBillDate			
		, receiptAndVoucheredCharges.intCurrencyId
		, receiptAndVoucheredCharges.strCurrency
		, strAllVouchers = CAST( ISNULL(allLinkedVoucherId.strVoucherIds, 'New Voucher') AS NVARCHAR(MAX)) COLLATE Latin1_General_CI_AS
		, strFilterString = CAST(filterString.strFilterString AS NVARCHAR(MAX)) COLLATE Latin1_General_CI_AS 
		, strItemUOM = ItemUOMName.strUnitMeasure
		, strCostUOM = ItemUOMName.strUnitMeasure
FROM	tblICInventoryReceipt Receipt 
		INNER JOIN tblICInventoryReceiptCharge ReceiptCharge
			ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
		LEFT JOIN tblSMCompanyLocation c
			ON c.intCompanyLocationId = Receipt.intLocationId
		LEFT JOIN (
			tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure ItemUOMName
				ON ItemUOM.intUnitMeasureId = ItemUOMName.intUnitMeasureId
		)
		ON ItemUOM.intItemUOMId = ReceiptCharge.intCostUOMId
		OUTER APPLY (
			SELECT	strOrderNumber = ct.strContractNumber
					,rc.intInventoryReceiptChargeId
					,dblUnitCost = (CASE WHEN rc.strCostMethod = 'Per Unit' THEN  ROUND(rc.dblRate, 2) ELSE ROUND(rc.dblAmount, 2) END )
					,dblReceiptQty = (CASE WHEN rc.dblQuantityPriced <> 0 THEN ISNULL(rc.dblQuantityPriced,0) ELSE ISNULL(rc.dblQuantity,0) END)
					,dblVoucherQty = ISNULL(voucher.QtyTotal, 0)
					,dblReceiptLineTotal = ROUND(-rc.dblAmount, 2)
					,dblVoucherLineTotal = ISNULL(voucher.LineTotal, 0)
					,dblReceiptTax = ISNULL(-rc.dblTax, 0)
					,dblVoucherTax = ISNULL(voucher.TaxTotal, 0) 
					,dblOpenQty = -ISNULL(rc.dblQuantity,1) - ISNULL(voucher.QtyTotal, 0)
					,dblItemsPayable = 
						ROUND(-rc.dblAmount, 2)
						- ISNULL(voucher.LineTotal, 0)
					,dblTaxesPayable = 
						ISNULL(-rc.dblTax, 0)
						- ISNULL(voucher.TaxTotal, 0) 
					,i.strItemNo
					,strItemDescription = i.strDescription	
					,intCurrencyId = ISNULL(rc.intCurrencyId, Receipt.intCurrencyId)
					,currency.strCurrency
			FROM	tblICInventoryReceiptCharge rc 
					OUTER APPLY (
						SELECT	QtyTotal = 
									SUM (ISNULL(bd.dblQtyReceived, 0))									
								,LineTotal = 
									SUM (
										ROUND (
											ISNULL(bd.dblQtyReceived, 0)		
											* ISNULL(bd.dblCost, 0) 
											, 2
										)
									)

								,TaxTotal = 
									SUM(ISNULL(bd.dblTax, 0)) 
						FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
									ON b.intBillId = bd.intBillId
						WHERE	bd.intInventoryReceiptChargeId = rc.intInventoryReceiptChargeId
								AND b.intEntityVendorId = Receipt.intEntityVendorId
								AND b.ysnPosted = 1 
					) voucher
					LEFT JOIN (
						tblCTContractHeader ct INNER JOIN tblCTContractDetail cd
							ON ct.intContractHeaderId = cd.intContractHeaderId
					)
						ON cd.intContractDetailId = rc.intContractDetailId
						AND Receipt.strReceiptType = 'Purchase Contract'

					LEFT JOIN tblICItem i 
						ON i.intItemId = rc.intChargeId

					LEFT JOIN tblSMCurrency currency
						ON currency.intCurrencyID = ISNULL(rc.intCurrencyId, Receipt.intCurrencyId) 

			WHERE	rc.intInventoryReceiptId = Receipt.intInventoryReceiptId
					AND rc.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
					--AND ct.intPricingTypeId != 2
		) receiptAndVoucheredCharges

		OUTER APPLY (
			SELECT	TOP 1 
					b.strBillId
					,b.intBillId
					,b.dtmBillDate
			FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
						ON b.intBillId = bd.intBillId
			WHERE	bd.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
					AND b.intEntityVendorId = Receipt.intEntityVendorId
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
								WHERE	bd.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
										AND b.intEntityVendorId = Receipt.intEntityVendorId
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
				STUFF(
						(
							SELECT  ', ' + b.strBillId
							FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
										ON b.intBillId = bd.intBillId
							WHERE	bd.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
									AND b.intEntityVendorId = Receipt.intEntityVendorId
									AND b.ysnPosted = 0
							GROUP BY b.strBillId
							FOR xml path('')
						)
					, 1
					, 1
					, ''
				)
		) allLinkedVoucherId  
		OUTER APPLY (
			SELECT	TOP 1 
					intSourceId  
			FROM	tblICInventoryReceiptItem b 
			WHERE	b.intInventoryReceiptId = Receipt.intInventoryReceiptId
		) ri
		LEFT JOIN tblSCTicket SC ON SC.intTicketId = ri.intSourceId
WHERE	Receipt.ysnPosted = 1
		AND ReceiptCharge.ysnPrice = 1
		AND receiptAndVoucheredCharges.dblReceiptQty <> receiptAndVoucheredCharges.dblVoucherQty
		AND ReceiptCharge.dblAmount <> 0 --WILL NOT SHOW RECEIPT FROM STORAGE
		AND SC.strDistributionOption != 'DP' --EXCLUDE DELAYED PRICING TYPE FOR RECEIPT VENDOR
GO


