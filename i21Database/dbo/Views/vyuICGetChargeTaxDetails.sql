CREATE VIEW [dbo].[vyuICGetChargeTaxDetails]
AS

SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY intInventoryReceiptChargeTaxId) AS INT)
, * 
FROM (
	SELECT
		ChargeTax.intInventoryReceiptChargeTaxId,
		Charge.intInventoryReceiptId,
		Charge.intChargeId,
		Item.strItemNo,
		TaxGroup.strTaxGroup,
		TaxCode.strTaxCode,
		ChargeTax.strCalculationMethod,
		ChargeTax.dblRate,
		ChargeTax.dblTax

	FROM	dbo.tblICInventoryReceiptChargeTax ChargeTax
			LEFT JOIN dbo.tblICInventoryReceiptCharge Charge on Charge.intInventoryReceiptChargeId = ChargeTax.intInventoryReceiptChargeId
			LEFT JOIN dbo.tblICItem Item on Item.intItemId = Charge.intChargeId 
			LEFT JOIN dbo.tblSMTaxGroup TaxGroup on TaxGroup.intTaxGroupId = ChargeTax.intTaxGroupId
			LEFT JOIN dbo.tblSMTaxCode TaxCode on TaxCode.intTaxCodeId = ChargeTax.intTaxCodeId
) tblChargeTaxDetails
GO
