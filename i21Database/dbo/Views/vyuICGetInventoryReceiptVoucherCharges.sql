CREATE VIEW [dbo].[vyuICGetInventoryReceiptVoucherCharges]
AS 

SELECT	intEntityVendorId = ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId) 
		,intInventoryReceiptId = Receipt.intInventoryReceiptId 		
		,intInventoryReceiptChargeId = receiptAndVoucheredCharges.intInventoryReceiptChargeId
		,dtmReceiptDate = Receipt.dtmReceiptDate 
		,strLocationName = c.strLocationName
		,strReceiptNumber = Receipt.strReceiptNumber 		
		,strBillOfLading = Receipt.strBillOfLading
		,strReceiptType = Receipt.strReceiptType
		,strOrderNumber = receiptAndVoucheredCharges.strOrderNumber		
		,strItemNo = receiptAndVoucheredCharges.strItemNo
		,strItemDescription = receiptAndVoucheredCharges.strItemDescription
		,dblUnitCost = receiptAndVoucheredCharges.dblUnitCost
		,dblReceiptQty = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblReceiptQty ELSE receiptAndVoucheredCharges.dblReceiptQty END 
		,dblVoucherQty  = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblVoucherQty ELSE receiptAndVoucheredCharges.dblVoucherQty END 
		,dblReceiptLineTotal = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblReceiptLineTotal ELSE receiptAndVoucheredCharges.dblReceiptLineTotal END 
		,dblVoucherLineTotal = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblVoucherLineTotal ELSE receiptAndVoucheredCharges.dblVoucherLineTotal END 
		,dblReceiptTax = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblReceiptTax ELSE receiptAndVoucheredCharges.dblReceiptTax END 
		,dblVoucherTax = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblVoucherTax ELSE receiptAndVoucheredCharges.dblVoucherTax END 
		,dblOpenQty = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblOpenQty ELSE receiptAndVoucheredCharges.dblOpenQty END 
		,dblItemsPayable = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblItemsPayable ELSE receiptAndVoucheredCharges.dblItemsPayable END 
		,dblTaxesPayable = CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN -receiptAndVoucheredCharges.dblTaxesPayable ELSE receiptAndVoucheredCharges.dblTaxesPayable END 
		,dtmLastVoucherDate = topVoucher.dtmBillDate			
		,receiptAndVoucheredCharges.intCurrencyId
		,receiptAndVoucheredCharges.strCurrency
		,strAllVouchers = CAST( ISNULL(allLinkedVoucherId.strVoucherIds, 'New Voucher') AS NVARCHAR(MAX)) 
		,strFilterString = CAST(filterString.strFilterString AS NVARCHAR(MAX)) 
FROM	tblICInventoryReceipt Receipt 
		INNER JOIN tblICInventoryReceiptCharge ReceiptCharge
			ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
		LEFT JOIN tblSMCompanyLocation c
			ON c.intCompanyLocationId = Receipt.intLocationId
		OUTER APPLY (
			SELECT	strOrderNumber = ct.strContractNumber
					,rc.intInventoryReceiptChargeId
					,dblUnitCost = ROUND(rc.dblAmount, 2) 
					,dblReceiptQty = 1
					,dblVoucherQty = ISNULL(voucher.QtyTotal, 0)
					,dblReceiptLineTotal = ROUND(rc.dblAmount, 2)
					,dblVoucherLineTotal = ISNULL(voucher.LineTotal, 0)
					,dblReceiptTax = ISNULL(CASE WHEN rc.ysnPrice = 1 THEN -rc.dblTax ELSE rc.dblTax END, 0)
					,dblVoucherTax = ISNULL(voucher.TaxTotal, 0) 
					,dblOpenQty = 1 - ISNULL(voucher.QtyTotal, 0)
					,dblItemsPayable = 
						ROUND(rc.dblAmount, 2)
						- ISNULL(voucher.LineTotal, 0)
					,dblTaxesPayable = 
						ISNULL(CASE WHEN rc.ysnPrice = 1 THEN -rc.dblTax ELSE rc.dblTax END, 0)
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
								AND b.intEntityVendorId = ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId) 
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
		) receiptAndVoucheredCharges
		OUTER APPLY (					
			SELECT	TOP 1 
					b.dtmBillDate
			FROM	tblAPBill b CROSS APPLY (
						SELECT	TOP  5
								bb.intBillId
						FROM	tblAPBill bb INNER JOIN tblAPBillDetail bd
									ON bb.intBillId = bd.intBillId
						WHERE	bd.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
								AND bb.ysnPosted = 1
					) chargeVouchers
			WHERE	b.intBillId = chargeVouchers.intBillId 
					AND b.intEntityVendorId = ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId) 
			ORDER BY b.intBillId DESC 
		) topVoucher
		OUTER APPLY (
			SELECT strFilterString = 
				LTRIM(
					STUFF(
							' ' + (
								SELECT	CONVERT(NVARCHAR(50), b.intBillId) + '|^|'
								FROM	tblAPBill b CROSS APPLY (
											SELECT	bb.intBillId
											FROM	tblAPBill bb INNER JOIN tblAPBillDetail bd
														ON bb.intBillId = bd.intBillId
											WHERE	bd.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
													AND bb.ysnPosted = 1
										) chargeVouchers
								WHERE	b.intBillId = chargeVouchers.intBillId 
										AND b.intEntityVendorId = ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId) 
								FOR XML PATH('')
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
							SELECT	', ' + b.strBillId
							FROM	tblAPBill b CROSS APPLY (
										SELECT	bb.intBillId
										FROM	tblAPBill bb INNER JOIN tblAPBillDetail bd
													ON bb.intBillId = bd.intBillId
										WHERE	bd.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
												AND bb.ysnPosted = 1
									) chargeVouchers
							WHERE	b.intBillId = chargeVouchers.intBillId 
									AND b.intEntityVendorId = ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId) 
							FOR XML PATH('')
						)
					, 1
					, 1
					, ''
				)
		) allLinkedVoucherId   
WHERE	Receipt.ysnPosted = 1
		AND ReceiptCharge.ysnAccrue = 1 