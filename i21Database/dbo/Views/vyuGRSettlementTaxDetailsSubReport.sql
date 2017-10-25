CREATE VIEW [dbo].[vyuGRSettlementTaxDetailsSubReport]
AS
SELECT 
 strBillId = Bill.strBillId
,strTaxClass = TaxClass.strTaxClass
,dblTax =   CASE 
					WHEN BillDtl.intInventoryReceiptChargeId IS NULL THEN Tax.dblTax
					ELSE 
							CASE 
								WHEN Charge.ysnPrice = 1 THEN Tax.dblTax * - 1
								ELSE Tax.dblTax
							END
			END
   
,intInventoryReceiptItemId = ISNULL(BillDtl.intInventoryReceiptItemId, 0) 
,intContractDetailId = ISNULL(BillDtl.intContractDetailId, 0)
,strItemNo = Item.strItemNo 
FROM tblAPBill Bill
JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId
JOIN vyuAPBillDetailTax Tax ON BillDtl.intBillDetailId = Tax.intBillDetailId
JOIN tblSMTaxClass TaxClass ON Tax.intTaxClassId = TaxClass.intTaxClassId
JOIN tblICItem Item ON Item.intItemId =BillDtl.intItemId 
LEFT JOIN tblICInventoryReceiptCharge Charge ON BillDtl.intInventoryReceiptChargeId = Charge.intInventoryReceiptChargeId

