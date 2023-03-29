CREATE PROCEDURE [dbo].[uspGRGenerateAPClearingForStorageInventoryReceipt]
AS
BEGIN
	IF (SELECT TOP 1 1 FROM tblGRStorageInventoryReceipt) > 1
	BEGIN
		TRUNCATE TABLE tblGRAPClearingStorageInventoryReceipt

		INSERT INTO tblGRAPClearingStorageInventoryReceipt
		SELECT
			-- '3' as strMark,
			bill.intEntityVendorId
			,bill.dtmDate AS dtmDate
			,Receipt.strReceiptNumber
			,Receipt.intInventoryReceiptId
			,bill.intBillId
			,bill.strBillId
			,billDetail.intBillDetailId
			,StorageReceipt.intInventoryReceiptItemId
			,billDetail.intItemId
			,billDetail.intUnitOfMeasureId AS intItemUOMId
			,unitMeasure.strUnitMeasure AS strUOM
			,StorageReceipt.dblUnits * ReceiptItem.dblUnitCost as dblVoucherTotal	
			,Round(StorageReceipt.dblUnits, 2) AS dblVoucherQty
			,0 AS dblReceiptTotal
			,0 AS dblReceiptQty
   
			,Receipt.intLocationId
			,compLoc.strLocationName
			,CAST(1 AS BIT) ysnAllowVoucher
			,APClearing.intAccountId
			,APClearing.strAccountId
		FROM tblGRStorageInventoryReceipt StorageReceipt
					join ( 

						select  Charge.intInventoryReceiptId, Tickets.intTicketId from (
							select strTicketNumber, intTicketId, intItemId from tblSCTicket where intInventoryReceiptId is not null and intDeliverySheetId > 0
							) Tickets
							join tblICInventoryReceiptItem Item
								on Item.intSourceId = Tickets.intTicketId				
							join tblQMTicketDiscount TicketDiscount
								on TicketDiscount.intTicketId = Tickets.intTicketId
							join tblGRDiscountScheduleCode DiscountScheduleCode
								on DiscountScheduleCode.intDiscountScheduleCodeId = TicketDiscount.intDiscountScheduleCodeId
							join tblICInventoryReceiptCharge Charge
								on Item.intInventoryReceiptId = Charge.intInventoryReceiptId				
									and Charge.intChargeId = DiscountScheduleCode.intItemId		
						
				) TicketLinking			
					on StorageReceipt.intInventoryReceiptId = TicketLinking.intInventoryReceiptId
					
				join tblICInventoryReceipt Receipt
					on Receipt.intInventoryReceiptId = TicketLinking.intInventoryReceiptId
				join tblICInventoryReceiptItem ReceiptItem
					on Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId			
					and ReceiptItem.intInventoryReceiptItemId = StorageReceipt.intInventoryReceiptItemId
		join tblAPBillDetail billDetail
					on  billDetail.intCustomerStorageId = StorageReceipt.intCustomerStorageId
						and ReceiptItem.intItemId = billDetail.intItemId
				INNER JOIN tblAPBill bill ON billDetail.intBillId = bill.intBillId
		INNER JOIN tblSMCompanyLocation compLoc
			ON Receipt.intLocationId = compLoc.intCompanyLocationId
		INNER JOIN vyuGLAccountDetail APClearing
			ON APClearing.intAccountId = billDetail.intAccountId AND APClearing.intAccountCategoryId = 45
		LEFT JOIN tblSMFreightTerms ft
			ON ft.intFreightTermId = Receipt.intFreightTermId
		LEFT JOIN 
		(
			tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
				ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
		)
			ON itemUOM.intItemUOMId = COALESCE(billDetail.intWeightUOMId, billDetail.intUnitOfMeasureId)
		--receipts in storage that were transferred
		--LEFT JOIN vyuGRTransferClearing transferClr
		--    ON transferClr.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
		OUTER APPLY (
			SELECT TOP 1 [ysnExists] = 1
			FROM tblICInventoryReceipt IR
			INNER JOIN tblICInventoryReceiptItem IRI
				ON IRI.intInventoryReceiptId = IR.intInventoryReceiptId
				AND IRI.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
			INNER JOIN tblGRStorageHistory SH
				ON SH.intInventoryReceiptId = IR.intInventoryReceiptId
				AND ISNULL(IRI.intContractHeaderId, 0) = ISNULL(SH.intContractHeaderId, 0)
			INNER JOIN tblGRCustomerStorage CS
				ON CS.intCustomerStorageId = SH.intCustomerStorageId
				AND CS.ysnTransferStorage = 0
			INNER JOIN tblGRStorageType ST
				ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
			INNER JOIN tblGRTransferStorageReference TSR
				ON TSR.intSourceCustomerStorageId = CS.intCustomerStorageId
			WHERE IR.intInventoryReceiptId = Receipt.intInventoryReceiptId
			AND IR.strReceiptNumber = Receipt.strReceiptNumber
			AND IRI.intOwnershipType = (CASE WHEN ST.ysnDPOwnedType = 1 THEN 1 ELSE 2 END)
		) transferClr
		--receipts in storage that were FULLY transferred from DP to DP only
		LEFT JOIN vyuGRTransferClearing_FullDPtoDP transferClrDP
			ON transferClrDP.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
		WHERE 
			 bill.ysnPosted = 1
			--AND transferClr.intInventoryReceiptItemId IS NULL
			 AND transferClrDP.intInventoryReceiptItemId IS NULL
			AND Receipt.strReceiptType != 'Transfer Order'
			AND transferClr.ysnExists IS NULL

		--AND receipt.dtmReceiptDate >= '2020-09-09'GO








		--Vouchers for receipt items
		union all
		SELECT
			bill.intEntityVendorId
			,bill.dtmDate AS dtmDate
			,Receipt.strReceiptNumber
			,Receipt.intInventoryReceiptId
			,bill.intBillId
			,bill.strBillId
			,billDetail.intBillDetailId
			,StorageReceipt.intInventoryReceiptItemId
			,billDetail.intItemId
			,billDetail.intUnitOfMeasureId AS intItemUOMId
			,unitMeasure.strUnitMeasure AS strUOM
			,StorageReceipt.dblUnits * ReceiptItem.dblUnitCost as dblVoucherTotal	
			,Round(StorageReceipt.dblUnits, 2) AS dblVoucherQty
			,0 AS dblReceiptTotal
			,0 AS dblReceiptQty
   
			,Receipt.intLocationId
			,compLoc.strLocationName
			,CAST(1 AS BIT) ysnAllowVoucher
			,APClearing.intAccountId
			,APClearing.strAccountId
		FROM tblGRStorageInventoryReceipt StorageReceipt
					join ( 

						select  Charge.intInventoryReceiptId, Tickets.intTicketId from (
							select strTicketNumber, intTicketId, intItemId from tblSCTicket where intInventoryReceiptId is not null and intDeliverySheetId > 0
							) Tickets
							join tblICInventoryReceiptItem Item
								on Item.intSourceId = Tickets.intTicketId				
							join tblQMTicketDiscount TicketDiscount
								on TicketDiscount.intTicketId = Tickets.intTicketId
							join tblGRDiscountScheduleCode DiscountScheduleCode
								on DiscountScheduleCode.intDiscountScheduleCodeId = TicketDiscount.intDiscountScheduleCodeId
							join tblICInventoryReceiptCharge Charge
								on Item.intInventoryReceiptId = Charge.intInventoryReceiptId				
									and Charge.intChargeId = DiscountScheduleCode.intItemId		
						
				) TicketLinking			
					on StorageReceipt.intInventoryReceiptId = TicketLinking.intInventoryReceiptId
					
				join tblICInventoryReceipt Receipt
					on Receipt.intInventoryReceiptId = TicketLinking.intInventoryReceiptId
				join tblICInventoryReceiptItem ReceiptItem
					on Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId			
					and ReceiptItem.intInventoryReceiptItemId = StorageReceipt.intInventoryReceiptItemId
		join tblAPBillDetail billDetail
					on  billDetail.intCustomerStorageId = StorageReceipt.intCustomerStorageId
						and ReceiptItem.intItemId = billDetail.intItemId
				INNER JOIN tblAPBill bill ON billDetail.intBillId = bill.intBillId
		INNER JOIN tblSMCompanyLocation compLoc
			ON Receipt.intLocationId = compLoc.intCompanyLocationId
		INNER JOIN vyuGLAccountDetail APClearing
			ON APClearing.intAccountId = billDetail.intAccountId AND APClearing.intAccountCategoryId = 45
		LEFT JOIN tblSMFreightTerms ft
			ON ft.intFreightTermId = Receipt.intFreightTermId
		LEFT JOIN 
		(
			tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
				ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
		)
			ON itemUOM.intItemUOMId = COALESCE(billDetail.intWeightUOMId, billDetail.intUnitOfMeasureId)
		WHERE 
			 bill.ysnPosted = 1


		AND Receipt.strReceiptType != 'Transfer Order'

		AND NOT EXISTS (
			--receipts in storage that were transferred
			SELECT intInventoryReceiptItemId
			FROM vyuGRTransferClearing transferClr
			WHERE transferClr.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
		)
		AND NOT EXISTS (
			--receipts in storage that were FULLY transferred from DP to DP only
			SELECT intInventoryReceiptItemId
			FROM vyuGRTransferClearing_FullDPtoDP transferClrDP
			WHERE transferClrDP.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
		)
		--AND receipt.dtmReceiptDate >= '2020-09-09'GO


		--This is for the settlement of the remaining IR in a transfer
		union all
		SELECT
			--'4' as flag,
			--*
	
			-- original select
			bill.intEntityVendorId
			,bill.dtmDate AS dtmDate
			,Receipt.strReceiptNumber
			,Receipt.intInventoryReceiptId
			,bill.intBillId
			,bill.strBillId
			,billDetail.intBillDetailId
			,StorageReceipt.intInventoryReceiptItemId
			,billDetail.intItemId
			,billDetail.intUnitOfMeasureId AS intItemUOMId
			,unitMeasure.strUnitMeasure AS strUOM
			,(StorageReceipt.dblTransactionUnits + ((StorageReceipt.dblTransactionUnits / S.dblNetUnits) * ABS(S.dblShrinkage)))  * ReceiptItem.dblUnitCost as dblVoucherTotal	
			,Round((StorageReceipt.dblTransactionUnits + ((StorageReceipt.dblTransactionUnits / S.dblNetUnits) * ABS(S.dblShrinkage))) , 2) AS dblVoucherQty
			,0 AS dblReceiptTotal
			,0 AS dblReceiptQty
   
			,Receipt.intLocationId
			,compLoc.strLocationName
			,CAST(1 AS BIT) ysnAllowVoucher
			,APClearing.intAccountId
			,APClearing.strAccountId
	
		FROM tblGRStorageInventoryReceipt StorageReceipt
		INNER JOIN (
			SELECT 
				intCustomerStorageId
				,intInventoryReceiptId
				,intInventoryReceiptItemId
				,dblNetUnits
				,dblShrinkage
				,ROW_NUMBER() OVER(PARTITION BY intInventoryReceiptId
										 ORDER BY intStorageInventoryReceipt) AS rk
			FROM tblGRStorageInventoryReceipt
			WHERE ysnUnposted = 0
		) S ON S.intInventoryReceiptId = StorageReceipt.intInventoryReceiptId AND S.intInventoryReceiptItemId = StorageReceipt.intInventoryReceiptItemId AND S.rk = 1
					join ( 

						select  Item.intInventoryReceiptId, Tickets.intTicketId from (
							select strTicketNumber, intTicketId, intItemId from tblSCTicket where intInventoryReceiptId is not null and intDeliverySheetId > 0
							) Tickets
							join tblICInventoryReceiptItem Item
								on Item.intSourceId = Tickets.intTicketId				
							--join tblQMTicketDiscount TicketDiscount
							--	on TicketDiscount.intTicketId = Tickets.intTicketId
							--join tblGRDiscountScheduleCode DiscountScheduleCode
							--	on DiscountScheduleCode.intDiscountScheduleCodeId = TicketDiscount.intDiscountScheduleCodeId
							--join tblICInventoryReceiptCharge Charge
							--	on Item.intInventoryReceiptId = Charge.intInventoryReceiptId				
							--		and Charge.intChargeId = DiscountScheduleCode.intItemId		
						
				) TicketLinking			
					on StorageReceipt.intInventoryReceiptId = TicketLinking.intInventoryReceiptId
					
				join tblICInventoryReceipt Receipt
					on Receipt.intInventoryReceiptId = TicketLinking.intInventoryReceiptId
				join tblICInventoryReceiptItem ReceiptItem
					on Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId			
					and ReceiptItem.intInventoryReceiptItemId = StorageReceipt.intInventoryReceiptItemId
		join tblAPBillDetail billDetail
					on  billDetail.intCustomerStorageId = StorageReceipt.intCustomerStorageId
						and ReceiptItem.intItemId = billDetail.intItemId
						and billDetail.intSettleStorageId = StorageReceipt.intSettleStorageId
				INNER JOIN tblAPBill bill ON billDetail.intBillId = bill.intBillId
		INNER JOIN tblSMCompanyLocation compLoc
			ON Receipt.intLocationId = compLoc.intCompanyLocationId
		INNER JOIN vyuGLAccountDetail APClearing
			ON APClearing.intAccountId = billDetail.intAccountId AND APClearing.intAccountCategoryId = 45
		LEFT JOIN tblSMFreightTerms ft
			ON ft.intFreightTermId = Receipt.intFreightTermId
		LEFT JOIN 
		(
			tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
				ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
		)
			ON itemUOM.intItemUOMId = COALESCE(billDetail.intWeightUOMId, billDetail.intUnitOfMeasureId)
		WHERE 
			StorageReceipt.intSettleStorageId is not null 
		and bill.ysnPosted = 1
		AND Receipt.strReceiptType != 'Transfer Order'

		--Vouchers for receipt items
		union all
		SELECT
			bill.intEntityVendorId
			,bill.dtmDate AS dtmDate
			,Receipt.strReceiptNumber
			,Receipt.intInventoryReceiptId
			,bill.intBillId
			,bill.strBillId
			,billDetail.intBillDetailId
			,StorageReceipt.intInventoryReceiptItemId
			,billDetail.intItemId
			,billDetail.intUnitOfMeasureId AS intItemUOMId
			,unitMeasure.strUnitMeasure AS strUOM
			,StorageReceipt.dblUnits * ReceiptItem.dblUnitCost as dblVoucherTotal	
			,Round(StorageReceipt.dblUnits, 2) AS dblVoucherQty
			,0 AS dblReceiptTotal
			,0 AS dblReceiptQty
   
			,Receipt.intLocationId
			,compLoc.strLocationName
			,CAST(1 AS BIT) ysnAllowVoucher
			,APClearing.intAccountId
			,APClearing.strAccountId
		FROM tblGRStorageInventoryReceipt StorageReceipt
					join ( 

						select  Charge.intInventoryReceiptId, Tickets.intTicketId from (
							select strTicketNumber, intTicketId, intItemId from tblSCTicket where intInventoryReceiptId is not null and intDeliverySheetId > 0
							) Tickets
							join tblICInventoryReceiptItem Item
								on Item.intSourceId = Tickets.intTicketId				
							join tblQMTicketDiscount TicketDiscount
								on TicketDiscount.intTicketId = Tickets.intTicketId
							join tblGRDiscountScheduleCode DiscountScheduleCode
								on DiscountScheduleCode.intDiscountScheduleCodeId = TicketDiscount.intDiscountScheduleCodeId
							join tblICInventoryReceiptCharge Charge
								on Item.intInventoryReceiptId = Charge.intInventoryReceiptId				
									and Charge.intChargeId = DiscountScheduleCode.intItemId		
						
				) TicketLinking			
					on StorageReceipt.intInventoryReceiptId = TicketLinking.intInventoryReceiptId
					
				join tblICInventoryReceipt Receipt
					on Receipt.intInventoryReceiptId = TicketLinking.intInventoryReceiptId
				join tblICInventoryReceiptItem ReceiptItem
					on Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId			
					and ReceiptItem.intInventoryReceiptItemId = StorageReceipt.intInventoryReceiptItemId
		join tblAPBillDetail billDetail
					on  billDetail.intCustomerStorageId = StorageReceipt.intCustomerStorageId
						and ReceiptItem.intItemId = billDetail.intItemId
				INNER JOIN tblAPBill bill ON billDetail.intBillId = bill.intBillId
		INNER JOIN tblSMCompanyLocation compLoc
			ON Receipt.intLocationId = compLoc.intCompanyLocationId
		INNER JOIN vyuGLAccountDetail APClearing
			ON APClearing.intAccountId = billDetail.intAccountId AND APClearing.intAccountCategoryId = 45
		LEFT JOIN tblSMFreightTerms ft
			ON ft.intFreightTermId = Receipt.intFreightTermId
		LEFT JOIN 
		(
			tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
				ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
		)
			ON itemUOM.intItemUOMId = COALESCE(billDetail.intWeightUOMId, billDetail.intUnitOfMeasureId)
		WHERE 
			 bill.ysnPosted = 1


		AND Receipt.strReceiptType != 'Transfer Order'

		AND NOT EXISTS (
			--receipts in storage that were transferred
			SELECT intInventoryReceiptItemId
			FROM vyuGRTransferClearing transferClr
			WHERE transferClr.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
		)
		AND NOT EXISTS (
			--receipts in storage that were FULLY transferred from DP to DP only
			SELECT intInventoryReceiptItemId
			FROM vyuGRTransferClearing_FullDPtoDP transferClrDP
			WHERE transferClrDP.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
		)
		--AND receipt.dtmReceiptDate >= '2020-09-09'GO


		--This is for the settlement of the remaining IR in a transfer
		union all
		SELECT
			--'4' as flag,
			--*
	
			-- original select
			bill.intEntityVendorId
			,bill.dtmDate AS dtmDate
			,Receipt.strReceiptNumber
			,Receipt.intInventoryReceiptId
			,bill.intBillId
			,bill.strBillId
			,billDetail.intBillDetailId
			,StorageReceipt.intInventoryReceiptItemId
			,billDetail.intItemId
			,billDetail.intUnitOfMeasureId AS intItemUOMId
			,unitMeasure.strUnitMeasure AS strUOM
			,(StorageReceipt.dblTransactionUnits + ((StorageReceipt.dblTransactionUnits / S.dblNetUnits) * ABS(S.dblShrinkage)))  * ReceiptItem.dblUnitCost as dblVoucherTotal	
			,Round((StorageReceipt.dblTransactionUnits + ((StorageReceipt.dblTransactionUnits / S.dblNetUnits) * ABS(S.dblShrinkage))) , 2) AS dblVoucherQty
			,0 AS dblReceiptTotal
			,0 AS dblReceiptQty
   
			,Receipt.intLocationId
			,compLoc.strLocationName
			,CAST(1 AS BIT) ysnAllowVoucher
			,APClearing.intAccountId
			,APClearing.strAccountId
	
		FROM tblGRStorageInventoryReceipt StorageReceipt
		INNER JOIN (
			SELECT 
				intCustomerStorageId
				,intInventoryReceiptId
				,intInventoryReceiptItemId
				,dblNetUnits
				,dblShrinkage
				,ROW_NUMBER() OVER(PARTITION BY intInventoryReceiptId
										 ORDER BY intStorageInventoryReceipt) AS rk
			FROM tblGRStorageInventoryReceipt
			WHERE ysnUnposted = 0
		) S ON S.intInventoryReceiptId = StorageReceipt.intInventoryReceiptId AND S.intInventoryReceiptItemId = StorageReceipt.intInventoryReceiptItemId AND S.rk = 1
					join ( 

						select  Item.intInventoryReceiptId, Tickets.intTicketId from (
							select strTicketNumber, intTicketId, intItemId from tblSCTicket where intInventoryReceiptId is not null and intDeliverySheetId > 0
							) Tickets
							join tblICInventoryReceiptItem Item
								on Item.intSourceId = Tickets.intTicketId				
							--join tblQMTicketDiscount TicketDiscount
							--	on TicketDiscount.intTicketId = Tickets.intTicketId
							--join tblGRDiscountScheduleCode DiscountScheduleCode
							--	on DiscountScheduleCode.intDiscountScheduleCodeId = TicketDiscount.intDiscountScheduleCodeId
							--join tblICInventoryReceiptCharge Charge
							--	on Item.intInventoryReceiptId = Charge.intInventoryReceiptId				
							--		and Charge.intChargeId = DiscountScheduleCode.intItemId		
						
				) TicketLinking			
					on StorageReceipt.intInventoryReceiptId = TicketLinking.intInventoryReceiptId
					
				join tblICInventoryReceipt Receipt
					on Receipt.intInventoryReceiptId = TicketLinking.intInventoryReceiptId
				join tblICInventoryReceiptItem ReceiptItem
					on Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId			
					and ReceiptItem.intInventoryReceiptItemId = StorageReceipt.intInventoryReceiptItemId
		join tblAPBillDetail billDetail
					on  billDetail.intCustomerStorageId = StorageReceipt.intCustomerStorageId
						and ReceiptItem.intItemId = billDetail.intItemId
						and billDetail.intSettleStorageId = StorageReceipt.intSettleStorageId
				INNER JOIN tblAPBill bill ON billDetail.intBillId = bill.intBillId
		INNER JOIN tblSMCompanyLocation compLoc
			ON Receipt.intLocationId = compLoc.intCompanyLocationId
		INNER JOIN vyuGLAccountDetail APClearing
			ON APClearing.intAccountId = billDetail.intAccountId AND APClearing.intAccountCategoryId = 45
		LEFT JOIN tblSMFreightTerms ft
			ON ft.intFreightTermId = Receipt.intFreightTermId
		LEFT JOIN 
		(
			tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
				ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
		)
			ON itemUOM.intItemUOMId = COALESCE(billDetail.intWeightUOMId, billDetail.intUnitOfMeasureId)
		WHERE 
			StorageReceipt.intSettleStorageId is not null 

	END
END