CREATE PROCEDURE [dbo].[uspICReturnReceipt]
	@intReceiptId AS INT
	,@intEntityUserSecurityId AS INT = NULL 
	,@intInventoryReturnId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @strReceiptNumber AS NVARCHAR(50)
		,@ysnPosted AS BIT 
		,@strReceiptType AS NVARCHAR(50)
		,@intReturnValue AS INT
		,@intLocationId AS INT

-- Validate if the Inventory Receipt exists   
IF @intReceiptId IS NULL  
BEGIN   
	-- Cannot find the transaction.  
	EXEC uspICRaiseError 80167;  
	GOTO _Exit  
END   

SELECT TOP 1 
		@strReceiptNumber = r.strReceiptNumber
		,@ysnPosted = r.ysnPosted
		,@strReceiptType = r.strReceiptType 
		,@intLocationId = r.intLocationId
FROM	tblICInventoryReceipt r
WHERE	r.intInventoryReceiptId = @intReceiptId


IF @strReceiptNumber IS NULL 
BEGIN 
	-- Cannot find the transaction.  
	EXEC uspICRaiseError 80167;  
	GOTO _Exit  
END 

IF ISNULL(@ysnPosted, 0) = 0 
BEGIN 
	-- Cannot return the inventory receipt. {Receipt Id} must be posted before it can be returned.
	EXEC uspICRaiseError 80100, @strReceiptNumber
	GOTO _Exit  
END 

IF @strReceiptType = 'Transfer Order'
BEGIN 
	-- 'Cannot return {Receipt Id} because it is a Transfer Order.'
	EXEC uspICRaiseError 80103, @strReceiptNumber;
	GOTO _Exit  
END 

-- Get the starting number 
BEGIN 
	-- Get the starting number 
	DECLARE @strInventoryReturnId AS NVARCHAR(50)
			,@receiptType AS NVARCHAR(50) = 'Inventory Return'
			,@STARTING_NUMBER_BATCH AS INT = 107

	EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strInventoryReturnId OUTPUT, @intLocationId
END 

SET @intInventoryReturnId = NULL

-- Create a new Inventory Return Transaction (header). 
BEGIN 
	INSERT INTO tblICInventoryReceipt (
			strReceiptType
			,intSourceType
			,intEntityVendorId
			,intTransferorId
			,intLocationId
			,strReceiptNumber
			,dtmReceiptDate
			,intCurrencyId
			,intSubCurrencyCents
			,intBlanketRelease
			,strVendorRefNo
			,strBillOfLading
			,intShipViaId
			,intShipFromId
			,intReceiverId
			,strVessel
			,intFreightTermId
			,intShiftNumber
			,dblInvoiceAmount
			,ysnPrepaid
			,ysnInvoicePaid
			,intCheckNo
			,dtmCheckDate
			,intTrailerTypeId
			,dtmTrailerArrivalDate
			,dtmTrailerArrivalTime
			,strSealNo
			,strSealStatus
			,dtmReceiveTime
			,dblActualTempReading
			,intShipmentId
			,intTaxGroupId
			,ysnPosted
			,intCreatedUserId
			,intEntityId
			,intConcurrencyId
			,strActualCostId
			,strReceiptOriginId
			,strWarehouseRefNo
			,ysnOrigin
			,intSourceInventoryReceiptId 
	)
	SELECT	strReceiptType = @receiptType
			,intSourceType
			,intEntityVendorId
			,intTransferorId
			,intLocationId
			,strReceiptNumber = @strInventoryReturnId
			,dtmReceiptDate = dbo.fnRemoveTimeOnDate(GETDATE()) 
			,intCurrencyId
			,intSubCurrencyCents
			,intBlanketRelease
			,strVendorRefNo
			,strBillOfLading
			,intShipViaId
			,intShipFromId
			,intReceiverId
			,strVessel
			,intFreightTermId
			,intShiftNumber
			,dblInvoiceAmount
			,ysnPrepaid
			,ysnInvoicePaid
			,intCheckNo
			,dtmCheckDate
			,intTrailerTypeId
			,dtmTrailerArrivalDate
			,dtmTrailerArrivalTime
			,strSealNo
			,strSealStatus
			,dtmReceiveTime
			,dblActualTempReading
			,intShipmentId
			,intTaxGroupId
			,ysnPosted = 0 
			,intCreatedUserId = @intEntityUserSecurityId
			,intEntityId
			,intConcurrencyId = 1
			,strActualCostId
			,strReceiptOriginId
			,strWarehouseRefNo
			,ysnOrigin
			,intSourceInventoryReceiptId = r.intInventoryReceiptId 
	FROM	tblICInventoryReceipt r 
	WHERE	r.intInventoryReceiptId = @intReceiptId

	SELECT @intInventoryReturnId = SCOPE_IDENTITY();
END 

-- Create the details for the Inventory Return Transaction (detail). 
IF @intInventoryReturnId IS NOT NULL 
BEGIN 
	INSERT INTO tblICInventoryReceiptItem (
		intInventoryReceiptId
		,intLineNo
		,intOrderId
		,intSourceId
		,intItemId
		,intContainerId
		,intSubLocationId
		,intStorageLocationId
		,intOwnershipType
		,dblOrderQty
		,dblBillQty
		,dblOpenReceive
		,intLoadReceive
		,dblReceived
		,intUnitMeasureId
		,intWeightUOMId
		,intCostUOMId
		,dblUnitCost
		,dblUnitRetail
		,ysnSubCurrency
		,dblLineTotal
		,intGradeId
		,dblGross
		,dblNet
		,dblTax
		,intDiscountSchedule
		,ysnExported
		,dtmExportedDate
		,intSort
		,intConcurrencyId
		,strComments
		,intTaxGroupId
		,intSourceInventoryReceiptItemId
		,intForexRateTypeId
		,dblForexRate
	)
	SELECT	intInventoryReceiptId = @intInventoryReturnId
			,ri.intLineNo
			,ri.intOrderId
			,ri.intSourceId
			,ri.intItemId
			,ri.intContainerId
			,ri.intSubLocationId
			,ri.intStorageLocationId
			,ri.intOwnershipType
			,ri.dblOrderQty
			,ri.dblBillQty
			,dblOpenReceive = ri.dblOpenReceive - ISNULL(ri.dblQtyReturned, 0) 
			,ri.intLoadReceive
			,ri.dblReceived
			,ri.intUnitMeasureId
			,ri.intWeightUOMId
			,ri.intCostUOMId
			,dblUnitCost = ri.dblUnitCost
			,ri.dblUnitRetail
			,ri.ysnSubCurrency
			,dblLineTotal = 
				CASE 
					-- Recompute the line total since it is a partial return. 
					WHEN ISNULL(ri.dblQtyReturned, 0) <> 0 THEN 
						ROUND(
							CASE 
								-- If using sub-currency, then divide it by the cents. 
								WHEN ri.ysnSubCurrency = 1 AND ISNULL(r.intSubCurrencyCents, 0) <> 0 THEN 
									CASE 
										WHEN ri.intWeightUOMId IS NOT NULL THEN 
											(ISNULL(ri.dblNet, 0) - ISNULL(ri.dblNetReturned, 0))
											* dbo.fnCalculateCostBetweenUOM(COALESCE(ri.intCostUOMId, ri.intUnitMeasureId), ri.intWeightUOMId, ri.dblUnitCost) 
										ELSE 
											(ISNULL(ri.dblOpenReceive, 0) - ISNULL(ri.dblQtyReturned, 0))
											* dbo.fnCalculateCostBetweenUOM(COALESCE(ri.intCostUOMId, ri.intUnitMeasureId), ri.intUnitMeasureId, ri.dblUnitCost) 			
									END 
									/ CASE WHEN ISNULL(r.intSubCurrencyCents, 0) <= 0 THEN 1 ELSE r.intSubCurrencyCents END 
								-- If a regular currency, then calculate as usual. 
								ELSE 
									CASE 
										WHEN ri.intWeightUOMId IS NOT NULL THEN 
											(ISNULL(ri.dblNet, 0) - ISNULL(ri.dblNetReturned, 0))
											* dbo.fnCalculateCostBetweenUOM(COALESCE(ri.intCostUOMId, ri.intUnitMeasureId), ri.intWeightUOMId, ri.dblUnitCost) 
										ELSE 
											(ISNULL(ri.dblOpenReceive, 0) - ISNULL(ri.dblQtyReturned, 0))
											* dbo.fnCalculateCostBetweenUOM(COALESCE(ri.intCostUOMId, ri.intUnitMeasureId), ri.intUnitMeasureId, ri.dblUnitCost) 			
									END 
							END 
							, 2
						)
					
					-- If it is a full return, use the same value for the line total. 
					ELSE 
						ri.dblLineTotal 
				END 					
			,ri.intGradeId
			,ri.dblGross
			,dblNet = ri.dblNet - ISNULL(ri.dblNetReturned, 0) 
			,dblTax = 
				CASE 
					WHEN ISNULL(ri.dblQtyReturned, 0) <> 0 THEN 0 -- Recompute the tax because this is a partial return. 
					ELSE ri.dblTax 
				END 
			,ri.intDiscountSchedule
			,ri.ysnExported
			,ri.dtmExportedDate
			,ri.intSort
			,intConcurrencyId = 1
			,ri.strComments
			,ri.intTaxGroupId
			,intSourceInventoryReceiptItemId = ri.intInventoryReceiptItemId 
			,ri.intForexRateTypeId
			,ri.dblForexRate
	FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
				ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			LEFT JOIN tblICItemLocation il
				ON il.intItemId = ri.intItemId
				AND il.intLocationId = r.intLocationId
	WHERE	r.intInventoryReceiptId = @intReceiptId
			AND ri.dblOpenReceive - ISNULL(ri.dblQtyReturned, 0) > 0
END 

-- Create the lots for the return transaction 
BEGIN 
	INSERT INTO tblICInventoryReceiptItemLot (
			intInventoryReceiptItemId
			,intLotId
			,strLotNumber
			,strLotAlias
			,intSubLocationId
			,intStorageLocationId
			,intItemUnitMeasureId
			,dblQuantity
			,dblGrossWeight
			,dblTareWeight
			,dblCost
			,intNoPallet
			,intUnitPallet
			,dblStatedGrossPerUnit
			,dblStatedTarePerUnit
			,strContainerNo
			,intEntityVendorId
			,strGarden
			,strMarkings
			,intOriginId
			,intGradeId
			,intSeasonCropYear
			,strVendorLotId
			,dtmManufacturedDate
			,strRemarks
			,strCondition
			,dtmCertified
			,dtmExpiryDate
			,intParentLotId
			,strParentLotNumber
			,strParentLotAlias
			,intSort
			,intConcurrencyId	
	)
	SELECT 
			ri.intInventoryReceiptItemId
			,ril.intLotId
			,ril.strLotNumber
			,ril.strLotAlias
			,ril.intSubLocationId
			,ril.intStorageLocationId
			,ril.intItemUnitMeasureId
			,ril.dblQuantity
			,ril.dblGrossWeight
			,ril.dblTareWeight
			,ril.dblCost
			,ril.intNoPallet
			,ril.intUnitPallet
			,ril.dblStatedGrossPerUnit
			,ril.dblStatedTarePerUnit
			,ril.strContainerNo
			,ril.intEntityVendorId
			,ril.strGarden
			,ril.strMarkings
			,ril.intOriginId
			,ril.intGradeId
			,ril.intSeasonCropYear
			,ril.strVendorLotId
			,ril.dtmManufacturedDate
			,ril.strRemarks
			,ril.strCondition
			,ril.dtmCertified
			,ril.dtmExpiryDate
			,ril.intParentLotId
			,ril.strParentLotNumber
			,ril.strParentLotAlias
			,ril.intSort
			,intConcurrencyId = 1
	FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
				ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblICInventoryReceiptItemLot ril
				ON ril.intInventoryReceiptItemId = ri.intSourceInventoryReceiptItemId
	WHERE	r.intInventoryReceiptId = @intInventoryReturnId
END 

DECLARE @isPartialReturn AS BIT = 0 
SELECT	TOP 1 
		@isPartialReturn = 1 
FROM	tblICInventoryReceiptItem 
WHERE	intInventoryReceiptId = @intReceiptId 
		AND ISNULL(dblQtyReturned, 0) <> 0

-- Copy the taxes from the original if doing a full return. 
IF (@isPartialReturn = 0)
BEGIN 
	INSERT INTO tblICInventoryReceiptItemTax (
			intInventoryReceiptItemId
			,intTaxGroupId
			,intTaxCodeId
			,intTaxClassId
			,strTaxableByOtherTaxes
			,strCalculationMethod
			,dblRate
			,dblTax
			,dblAdjustedTax
			,intTaxAccountId
			,ysnTaxAdjusted
			,ysnSeparateOnInvoice
			,ysnCheckoffTax
			,strTaxCode
			,intSort
			,intConcurrencyId	
	)
	SELECT	
			ri.intInventoryReceiptItemId
			,tx.intTaxGroupId
			,tx.intTaxCodeId
			,tx.intTaxClassId
			,tx.strTaxableByOtherTaxes
			,tx.strCalculationMethod
			,tx.dblRate
			,tx.dblTax
			,tx.dblAdjustedTax
			,tx.intTaxAccountId
			,tx.ysnTaxAdjusted
			,tx.ysnSeparateOnInvoice
			,tx.ysnCheckoffTax
			,tx.strTaxCode
			,tx.intSort
			,intConcurrencyId = 1
	FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
				ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblICInventoryReceiptItemTax tx
				ON tx.intInventoryReceiptItemId = ri.intSourceInventoryReceiptItemId
	WHERE	r.intInventoryReceiptId = @intInventoryReturnId
END 
-- If it is a partial return, recalculate the taxes. 
ELSE 
BEGIN
	EXEC uspICCalculateReceiptTax @intInventoryReturnId
END 

---- Copy the charges of the receipt to the return transaction if the other charge is part of the inventory cost. 
--BEGIN 
--	INSERT INTO tblICInventoryReceiptCharge (
--		intInventoryReceiptId
--		,intContractId
--		,intContractDetailId
--		,intChargeId
--		,ysnInventoryCost
--		,strCostMethod
--		,dblRate
--		,intCostUOMId
--		,ysnSubCurrency
--		,intCurrencyId
--		,dblExchangeRate
--		,intCent
--		,dblAmount
--		,strAllocateCostBy
--		,ysnAccrue
--		,intEntityVendorId
--		,ysnPrice
--		,dblAmountBilled
--		,dblAmountPaid
--		,dblAmountPriced
--		,intSort
--		,dblTax
--		,intConcurrencyId
--		,intTaxGroupId	
--		,intForexRateTypeId
--		,dblForexRate
--	)
--	SELECT	
--			intInventoryReceiptId = @intInventoryReturnId
--			,c.intContractId
--			,c.intContractDetailId
--			,c.intChargeId
--			,c.ysnInventoryCost
--			,c.strCostMethod
--			,c.dblRate
--			,c.intCostUOMId
--			,c.ysnSubCurrency
--			,c.intCurrencyId
--			,c.dblExchangeRate
--			,c.intCent
--			,c.dblAmount
--			,c.strAllocateCostBy
--			,c.ysnAccrue
--			,c.intEntityVendorId
--			,c.ysnPrice
--			,c.dblAmountBilled
--			,c.dblAmountPaid
--			,c.dblAmountPriced
--			,c.intSort
--			,c.dblTax
--			,c.intConcurrencyId
--			,c.intTaxGroupId
--			,c.intForexRateTypeId
--			,c.dblForexRate
--	FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptCharge c
--				ON r.intInventoryReceiptId = c.intInventoryReceiptId
--	WHERE	r.intInventoryReceiptId = @intReceiptId 
--			AND c.ysnInventoryCost = 1 
--END 

-- Recalculate the other charges. 
BEGIN 
	-- Calculate the other charges. 
	EXEC dbo.uspICCalculateInventoryReceiptOtherCharges
		@intInventoryReturnId			

	-- Calculate the surcharges
	EXEC dbo.uspICCalculateInventoryReceiptSurchargeOnOtherCharges
		@intInventoryReturnId
			
	-- Allocate the other charges and surcharges. 
	EXEC dbo.uspICAllocateInventoryReceiptOtherCharges 
		@intInventoryReturnId		
				
	-- Calculate Other Charges Taxes
	EXEC dbo.uspICCalculateInventoryReceiptOtherChargesTaxes
		@intInventoryReturnId
END

-- Update the returned qty
BEGIN 
	UPDATE	ri	
	SET		ri.dblQtyReturned = ISNULL(ri.dblQtyReturned, 0) + rtnItem.dblOpenReceive
			,ri.dblNetReturned = ISNULL(ri.dblNetReturned, 0) + rtnItem.dblNet
	FROM	tblICInventoryReceipt rtn INNER JOIN tblICInventoryReceiptItem rtnItem
				ON rtn.intInventoryReceiptId = rtnItem.intInventoryReceiptId
			INNER JOIN (
				tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
					ON r.intInventoryReceiptId = ri.intInventoryReceiptId					
			)
				ON ri.intInventoryReceiptItemId = rtnItem.intSourceInventoryReceiptItemId
			INNER JOIN tblICItem i 
				ON i.intItemId = ri.intItemId 
	WHERE	rtn.intInventoryReceiptId = @intInventoryReturnId

	-- Validate for over-return 
	EXEC @intReturnValue = uspICValidateReceiptForReturn
		@intReceiptId = NULL
		,@intReturnId = @intInventoryReturnId

	IF @intReturnValue < 0 GOTO _Exit 
END 

-- Add the audit-trail 
BEGIN 
	DECLARE @strDescription AS NVARCHAR(100) 
			,@actionType AS NVARCHAR(50)

	SET @actionType = 'Returned'

	-- Create an Audit Log for the Inventory Receipt 			
	EXEC	dbo.uspSMAuditLog 
			@keyValue = @intReceiptId								-- Primary Key Value of the Inventory Receipt. 
			,@screenName = 'Inventory.view.InventoryReceipt'        -- Screen Namespace
			,@entityId = @intEntityUserSecurityId					-- Entity Id.
			,@actionType = @actionType                              -- Action Type
			,@changeDescription = @strDescription					-- Description
			,@fromValue = @strReceiptNumber							-- Previous Value
			,@toValue = @strInventoryReturnId						-- New Value
	
	-- Create an Audit Log for the Inventory Return
	EXEC	dbo.uspSMAuditLog 
			@keyValue = @intInventoryReturnId						-- Primary Key Value of the Inventory Return. 
			,@screenName = 'Inventory.view.InventoryReceipt'        -- Screen Namespace
			,@entityId = @intEntityUserSecurityId					-- Entity Id.
			,@actionType = @actionType                              -- Action Type
			,@changeDescription = @strDescription					-- Description
			,@fromValue = @strReceiptNumber							-- Previous Value
			,@toValue = @strInventoryReturnId						-- New Value
END

_Exit: