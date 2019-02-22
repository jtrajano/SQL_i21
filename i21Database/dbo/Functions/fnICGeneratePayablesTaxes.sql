CREATE FUNCTION dbo.fnICGeneratePayablesTaxes (@voucherItems VoucherPayable READONLY)
RETURNS @table TABLE
(
	[intVoucherPayableId]       INT NOT NULL,
    [intTaxGroupId]				INT NOT NULL, 
    [intTaxCodeId]				INT NOT NULL, 
    [intTaxClassId]				INT NOT NULL, 
	[strTaxableByOtherTaxes]	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strCalculationMethod]		NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL, 
    [dblRate]					DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [intAccountId]				INT NOT NULL, 
    [dblTax]					DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblAdjustedTax]			DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[ysnTaxAdjusted]			BIT NOT NULL DEFAULT 0, 
	[ysnSeparateOnBill]			BIT NOT NULL DEFAULT 0, 
	[ysnCheckOffTax]			BIT NOT NULL DEFAULT 0,
    [ysnTaxExempt]              BIT NOT NULL DEFAULT 0,
	[ysnTaxOnly]				BIT NOT NULL DEFAULT 0
)
AS
BEGIN
		
	DECLARE @ItemType_OtherCharge AS NVARCHAR(50) = 'Other Charge';

	INSERT INTO @table
	-- Receipt Item Taxes
	SELECT	intVoucherPayableId			= voucherItems.intVoucherPayableId
			,intTaxGroupId				= ItemTax.intTaxGroupId
			,intTaxCodeId				= ItemTax.intTaxCodeId
			,intTaxClassId				= ItemTax.intTaxClassId
			,strTaxableByOtherTaxes		= ItemTax.strTaxableByOtherTaxes
			,strCalculationMethod		= ItemTax.strCalculationMethod
			,dblRate					= ItemTax.dblRate
			,intAccountId				= ItemTax.intTaxAccountId
			,dblTax						= ItemTax.dblTax
			,dblAdjustedTax				= ISNULL(ItemTax.dblAdjustedTax, 0)
			,ysnTaxAdjusted				= ItemTax.ysnTaxAdjusted
			,ysnSeparateOnBill			= ItemTax.ysnSeparateOnInvoice
			,ysnCheckoffTax				= ItemTax.ysnCheckoffTax
			,ysnTaxExempt				= CAST(ISNULL(ItemTax.ysnTaxExempt, 0) AS BIT)
			,ysnTaxOnly					= ItemTax.ysnTaxOnly
	FROM tblICInventoryReceiptItemTax ItemTax
	INNER JOIN @voucherItems voucherItems ON voucherItems.intInventoryReceiptItemId = ItemTax.intInventoryReceiptItemId
	LEFT JOIN tblICItem Item ON Item.intItemId = voucherItems.intItemId
	WHERE voucherItems.dblTax != 0
		AND voucherItems.intInventoryReceiptChargeId IS NULL
	UNION ALL
	-- Receipt Charges Taxes
	SELECT	intVoucherPayableId			= voucherItems.intVoucherPayableId
			,intTaxGroupId				= ChargeTax.intTaxGroupId
			,intTaxCodeId				= ChargeTax.intTaxCodeId
			,intTaxClassId				= ChargeTax.intTaxClassId
			,strTaxableByOtherTaxes		= ChargeTax.strTaxableByOtherTaxes
			,strCalculationMethod		= ChargeTax.strCalculationMethod
			,dblRate					= ChargeTax.dblRate
			,intAccountId				= ChargeTax.intTaxAccountId
			,dblTax						= ChargeTax.dblTax
			,dblAdjustedTax				= ISNULL(ChargeTax.dblAdjustedTax, 0)
			,ysnTaxAdjusted				= ChargeTax.ysnTaxAdjusted
			,ysnSeparateOnBill			= 0
			,ysnCheckoffTax				= ChargeTax.ysnCheckoffTax
			,ysnTaxExempt				= CAST(ISNULL(ChargeTax.ysnTaxExempt, 0) AS BIT)
			,ysnTaxOnly					= ChargeTax.ysnTaxOnly
	FROM tblICInventoryReceiptChargeTax ChargeTax
	INNER JOIN @voucherItems voucherItems ON voucherItems.intInventoryReceiptChargeId = ChargeTax.intInventoryReceiptChargeId
	LEFT JOIN tblICItem Item ON Item.intItemId = voucherItems.intItemId
	WHERE Item.strType = @ItemType_OtherCharge COLLATE Latin1_General_CI_AS
		AND voucherItems.dblTax != 0
	
RETURN
END