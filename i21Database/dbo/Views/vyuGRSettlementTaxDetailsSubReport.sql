CREATE VIEW [dbo].[vyuGRSettlementTaxDetailsSubReport]
AS

	-- We are using this view to directly insert table to an API Export table
	-- If there are changes in the view please update the insert in uspGRAPISettlementReportExport as well

SELECT *
FROM (
	SELECT *
	FROM (
		SELECT 
			 strBillId = Bill.strBillId
			,strTaxClass = TaxClass.strTaxClass
			,dblTax = CASE 
						WHEN Tax.ysnTaxAdjusted = 1 THEN Tax.dblAdjustedTax
						ELSE Tax.dblTax
					END
			,intInventoryReceiptItemId = ISNULL(BillDtl.intInventoryReceiptItemId, 0) 
			,intContractDetailId = ISNULL(BillDtl.intContractDetailId, 0)
			,strItemNo = Item.strItemNo
			,BillDtl.intBillDetailId
		FROM tblAPBill Bill
		JOIN tblAPBillDetail BillDtl 
			ON Bill.intBillId = BillDtl.intBillId
		JOIN vyuAPBillDetailTax Tax 
			ON BillDtl.intBillDetailId = Tax.intBillDetailId
		JOIN tblSMTaxClass TaxClass 
			ON Tax.intTaxClassId = TaxClass.intTaxClassId
		JOIN tblICItem Item 
			ON Item.intItemId = BillDtl.intItemId 
		) A
	UNION
	SELECT 
		strId
		,strTaxClass
		,dblTax   
		,0
		,0
		,strDiscountCodeDescription
		,intBillDetailId
	FROM vyuGRSettlementSubReport
) B
WHERE dblTax <> 0
