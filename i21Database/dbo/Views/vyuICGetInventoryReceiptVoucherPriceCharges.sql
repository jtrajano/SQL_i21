CREATE VIEW [dbo].[vyuICGetInventoryReceiptVoucherPriceCharges]
AS 

SELECT	intEntityVendorId = Receipt.intEntityVendorId
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
		,dblReceiptQty = receiptAndVoucheredCharges.dblReceiptQty
		,dblVoucherQty  = receiptAndVoucheredCharges.dblVoucherQty
		,dblReceiptLineTotal = receiptAndVoucheredCharges.dblReceiptLineTotal
		,dblVoucherLineTotal = receiptAndVoucheredCharges.dblVoucherLineTotal
		,dblReceiptTax = receiptAndVoucheredCharges.dblReceiptTax
		,dblVoucherTax = receiptAndVoucheredCharges.dblVoucherTax
		,dblOpenQty = receiptAndVoucheredCharges.dblOpenQty  
		,dblItemsPayable = receiptAndVoucheredCharges.dblItemsPayable
		,dblTaxesPayable = receiptAndVoucheredCharges.dblTaxesPayable
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
					,dblReceiptQty = -1
					,dblVoucherQty = ISNULL(voucher.QtyTotal, 0)
					,dblReceiptLineTotal = ROUND(-rc.dblAmount, 2)
					,dblVoucherLineTotal = ISNULL(voucher.LineTotal, 0)
					,dblReceiptTax = ISNULL(rc.dblTax, 0)
					,dblVoucherTax = ISNULL(voucher.TaxTotal, 0) 
					,dblOpenQty = -1 - ISNULL(voucher.QtyTotal, 0)
					,dblItemsPayable = 
						ROUND(-rc.dblAmount, 2)
						- ISNULL(voucher.LineTotal, 0)
					,dblTaxesPayable = 
						ISNULL(rc.dblTax, 0)
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
				STUFF(
						(
							SELECT  ', ' + b.strBillId
							FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
										ON b.intBillId = bd.intBillId
							WHERE	bd.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
									AND b.intEntityVendorId = Receipt.intEntityVendorId
									AND b.ysnPosted = 1
							GROUP BY b.strBillId
							FOR xml path('')
						)
					, 1
					, 1
					, ''
				)
		) allLinkedVoucherId  
WHERE	Receipt.ysnPosted = 1
		AND ReceiptCharge.ysnPrice = 1 