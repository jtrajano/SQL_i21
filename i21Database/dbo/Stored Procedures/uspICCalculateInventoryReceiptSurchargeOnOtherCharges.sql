CREATE PROCEDURE [dbo].[uspICCalculateInventoryReceiptSurchargeOnOtherCharges]
	@intInventoryReceiptId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Declare the variables
BEGIN
	-- Constants
	DECLARE @COST_METHOD_PER_UNIT AS NVARCHAR(50) = 'Per Unit'
			,@COST_METHOD_PERCENTAGE AS NVARCHAR(50) = 'Percentage'
			,@COST_METHOD_AMOUNT AS NVARCHAR(50) = 'Amount'

	DECLARE @strItemNo AS NVARCHAR(50)
			,@strUnitMeasure AS NVARCHAR(50)
			,@intItemId AS INT
END 

-- Check if there are receipt charges to process
BEGIN 	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblICInventoryReceiptCharge WHERE intInventoryReceiptId = @intInventoryReceiptId)
	BEGIN
		-- Exit and do nothing. 
		GOTO _Exit
	END
END

-- Validate for cyclic computations
BEGIN 
	DECLARE @intCyclicOtherChargesItemId AS INT 
			,@strCyclicOtherChargesItem AS NVARCHAR(50)
			,@intCyclicSurchargeOnOtherChargesItemId AS INT
			,@strCyclicSurchargeOnOtherChargesItem AS NVARCHAR(50)

	SELECT	@intCyclicOtherChargesItemId = OtherChargesItem.intItemId
			,@strCyclicOtherChargesItem = OtherChargesItem.strItemNo
			,@intCyclicSurchargeOnOtherChargesItemId = SurchargeOnOtherChargesItem.intItemId
			,@strCyclicSurchargeOnOtherChargesItem = SurchargeOnOtherChargesItem.strItemNo
			--,CyclicSurchargeOnOtherChargesItem.intItemId			
	FROM	dbo.tblICInventoryReceiptItem ReceiptItem INNER JOIN dbo.tblICInventoryReceiptCharge OtherCharges
				ON ReceiptItem.intInventoryReceiptId = OtherCharges.intInventoryReceiptId
			INNER JOIN dbo.tblICItem OtherChargesItem 
				ON OtherChargesItem.intItemId = OtherCharges.intChargeId
			LEFT JOIN dbo.tblICItem SurchargeOnOtherChargesItem
				ON SurchargeOnOtherChargesItem.intItemId = OtherChargesItem.intOnCostTypeId				
			LEFT JOIN dbo.tblICInventoryReceiptCharge CyclicOtherCharges
				ON CyclicOtherCharges.intChargeId = SurchargeOnOtherChargesItem.intOnCostTypeId
			LEFT JOIN dbo.tblICItem CyclicSurchargeOnOtherChargesItem 
				ON CyclicSurchargeOnOtherChargesItem.intItemId = CyclicOtherCharges.intChargeId
	WHERE	CyclicSurchargeOnOtherChargesItem.intItemId IS NOT NULL 
			AND ReceiptItem.intInventoryReceiptId = @intInventoryReceiptId
			
	IF @intCyclicOtherChargesItemId IS NOT NULL 
	BEGIN 
		-- 'Cyclic situation found. Unable to compute surcharge because {Item X} depends on {Item Y} and vice-versa.'
		RAISERROR(51156, 11, 1, @strCyclicOtherChargesItem, @strCyclicSurchargeOnOtherChargesItem)  
		GOTO _Exit  
	END 
END 


_Exit: