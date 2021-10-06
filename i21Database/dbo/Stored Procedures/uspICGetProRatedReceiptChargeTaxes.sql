CREATE PROCEDURE [dbo].[uspICGetProRatedReceiptChargeTaxes]
	@intInventoryReceiptItemId AS INT 
	,@intBillUOMId AS INT 
	,@dblQtyBilled AS NUMERIC(18, 6)
	,@voucherPayable VoucherPayable READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

		
DECLARE 
		@SourceType_STORE AS INT = 7		 
		, @type_Voucher AS INT = 1
		, @type_DebitMemo AS INT = 3
		, @billTypeToUse INT
		, @ItemType_OtherCharge AS NVARCHAR(50) = 'Other Charge'

		, @dblRatio AS NUMERIC(38, 20)

-- Get the data that will allow us to compute the pro-rate. 
BEGIN 
	SELECT 
		@billTypeToUse = 
			CASE 
				WHEN dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 6) < 0 THEN 
					@type_DebitMemo
				ELSE 
					@type_Voucher
			END 
		,@dblRatio = 
			dbo.fnDivide(
				dbo.fnCalculateQtyBetweenUOM(
					@intBillUOMId
					,ri.intUnitMeasureId
					,@dblQtyBilled
				)
				, ri.dblOpenReceive
			) 
		
	FROM 
		tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
			ON r.intInventoryReceiptId = ri.intInventoryReceiptId
	WHERE
		ri.intInventoryReceiptItemId = @intInventoryReceiptItemId
		AND r.ysnPosted = 1
END 

BEGIN 
	DECLARE @voucherPayableTax VoucherDetailTax

	INSERT INTO @voucherPayableTax(
		[intVoucherPayableId]
		,[intTaxGroupId]				
		,[intTaxCodeId]				
		,[intTaxClassId]				
		,[strTaxableByOtherTaxes]	
		,[strCalculationMethod]		
		,[dblRate]					
		,[intAccountId]				
		,[dblTax]					
		,[dblAdjustedTax]			
		,[ysnTaxAdjusted]			
		,[ysnSeparateOnBill]			
		,[ysnCheckOffTax]		
		,[ysnTaxExempt]	
		,[ysnTaxOnly]
	)
	SELECT	intVoucherPayableId			= voucherItems.intVoucherPayableId
			,intTaxGroupId				= ChargeTax.intTaxGroupId
			,intTaxCodeId				= ChargeTax.intTaxCodeId
			,intTaxClassId				= ChargeTax.intTaxClassId
			,strTaxableByOtherTaxes		= ChargeTax.strTaxableByOtherTaxes
			,strCalculationMethod		= ChargeTax.strCalculationMethod
			,dblRate					= ChargeTax.dblRate
			,intAccountId				= ChargeTax.intTaxAccountId
			,dblTax						= 
				CASE 
					WHEN @billTypeToUse = @type_DebitMemo THEN 
						-ROUND(dbo.fnMultiply(ChargeTax.dblTax, @dblRatio), 2)
					ELSE 
						ROUND(dbo.fnMultiply(ChargeTax.dblTax, @dblRatio), 2)
				END 
			,dblAdjustedTax				= 
				CASE 
					WHEN @billTypeToUse = @type_DebitMemo THEN 
						-ROUND(dbo.fnMultiply(ChargeTax.dblAdjustedTax, @dblRatio), 2)
					ELSE
						ROUND(dbo.fnMultiply(ChargeTax.dblAdjustedTax, @dblRatio), 2)
				END 
			,ysnTaxAdjusted				= ChargeTax.ysnTaxAdjusted
			,ysnSeparateOnBill			= 0
			,ysnCheckoffTax				= ChargeTax.ysnCheckoffTax
			,ysnTaxExempt				= CAST(ISNULL(ChargeTax.ysnTaxExempt, 0) AS BIT)
			,ysnTaxOnly					= ChargeTax.ysnTaxOnly
	FROM 
		tblICInventoryReceiptChargeTax ChargeTax
		INNER JOIN @voucherPayable voucherItems 
			ON voucherItems.intInventoryReceiptChargeId = ChargeTax.intInventoryReceiptChargeId
		INNER JOIN tblICItem Item 
			ON Item.intItemId = voucherItems.intItemId
	WHERE 
		Item.strType = @ItemType_OtherCharge COLLATE Latin1_General_CI_AS
		AND voucherItems.dblTax <> 0
END 

SELECT 
	[intVoucherPayableId]
	,[intTaxGroupId]
	,[intTaxCodeId]
	,[intTaxClassId]
	,[strTaxableByOtherTaxes]
	,[strCalculationMethod]
	,[dblRate]
	,[intAccountId]
	,[dblTax]
	,[dblAdjustedTax]
	,[ysnTaxAdjusted]
	,[ysnSeparateOnBill]
	,[ysnCheckOffTax]
	,[ysnTaxExempt]
	,[ysnTaxOnly]
FROM 
	@voucherPayableTax