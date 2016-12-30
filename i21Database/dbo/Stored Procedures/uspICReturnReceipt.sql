﻿CREATE PROCEDURE [dbo].[uspICReturnReceipt]
	@intReceiptId AS INT
	,@intEntityUserSecurityId AS INT = NULL 
	,@intInventoryReturnId INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- TODO: Validate
-- TODO: Validate if receipt is already posted. 
-- TODO: Validate if there are enough stocks to return. 
-- TODO: Add audit-trail on the original receipt that it was returned. 
-- TODO: Add audit-trail on the inventory return that it was created. 

DECLARE @strReceiptNumber AS NVARCHAR(50)
		,@ysnPosted AS BIT 

-- Validate if the Inventory Receipt exists   
IF @intReceiptId IS NULL  
BEGIN   
	-- Cannot find the transaction.  
	RAISERROR(50004, 11, 1)  
	GOTO ReturnReceipt_Exit  
END   

SELECT TOP 1 
		@strReceiptNumber = r.strReceiptNumber
		,@ysnPosted = r.ysnPosted
FROM	tblICInventoryReceipt r
WHERE	r.intInventoryReceiptId = @intReceiptId


IF @strReceiptNumber IS NULL 
BEGIN 
	-- Cannot find the transaction.  
	RAISERROR(50004, 11, 1)  
	GOTO ReturnReceipt_Exit  
END 

IF ISNULL(@ysnPosted, 0) = 0 
BEGIN 
	-- Cannot return the inventory receipt. {Receipt Id} must be posted before it can be returned.
	RAISERROR(80097, 11, 1, @strReceiptNumber)  
	GOTO ReturnReceipt_Exit  
END 

-- Get the starting number 
BEGIN 
	-- Get the starting number 
	DECLARE @strInventoryReturnId AS NVARCHAR(50)
			,@strReceiptType AS NVARCHAR(50) = 'Inventory Return'
			,@STARTING_NUMBER_BATCH AS INT = 107

	EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strInventoryReturnId OUTPUT  
END 

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
	SELECT	strReceiptType = @strReceiptType
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
			,dblUnitCost = ISNULL(
				dbo.fnGetCostFromCostBucket(
					ri.intItemId
					,il.intItemLocationId
					,ISNULL(ri.intCostUOMId, ri.intUnitMeasureId)
					,NULL	-- If @intLotId is null, it will get the cost from the first lot record received for the line item. 
					,r.strReceiptNumber
					,r.intInventoryReceiptId
					,ri.intInventoryReceiptItemId
					,r.strActualCostId
				)
				, ri.dblUnitCost
			)
			,ri.dblUnitRetail
			,ri.ysnSubCurrency
			,ri.dblLineTotal
			,ri.intGradeId
			,ri.dblGross
			,dblNet = ri.dblNet - ISNULL(ri.dblNetReturned, 0) 
			,ri.dblTax
			,ri.intDiscountSchedule
			,ri.ysnExported
			,ri.dtmExportedDate
			,ri.intSort
			,intConcurrencyId = 1
			,ri.strComments
			,ri.intTaxGroupId
			,intSourceInventoryReceiptItemId = ri.intInventoryReceiptItemId 
	FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
				ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			LEFT JOIN tblICItemLocation il
				ON il.intItemId = ri.intItemId
				AND il.intLocationId = r.intLocationId
	WHERE	r.intInventoryReceiptId = @intReceiptId
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

-- Create the other charges. 
BEGIN 
	INSERT INTO tblICInventoryReceiptCharge (
		intInventoryReceiptId
		,intContractId
		,intContractDetailId
		,intChargeId
		,ysnInventoryCost
		,strCostMethod
		,dblRate
		,intCostUOMId
		,ysnSubCurrency
		,intCurrencyId
		,dblExchangeRate
		,intCent
		,dblAmount
		,strAllocateCostBy
		,ysnAccrue
		,intEntityVendorId
		,ysnPrice
		,dblAmountBilled
		,dblAmountPaid
		,dblAmountPriced
		,intSort
		,dblTax
		,intConcurrencyId
		,intTaxGroupId	
	)
	SELECT	
			intInventoryReceiptId = @intReceiptId
			,c.intContractId
			,c.intContractDetailId
			,c.intChargeId
			,c.ysnInventoryCost
			,c.strCostMethod
			,c.dblRate
			,c.intCostUOMId
			,c.ysnSubCurrency
			,c.intCurrencyId
			,c.dblExchangeRate
			,c.intCent
			,c.dblAmount
			,c.strAllocateCostBy
			,c.ysnAccrue
			,c.intEntityVendorId
			,c.ysnPrice
			,c.dblAmountBilled
			,c.dblAmountPaid
			,c.dblAmountPriced
			,c.intSort
			,c.dblTax
			,c.intConcurrencyId
			,c.intTaxGroupId
	FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptCharge c
				ON r.intInventoryReceiptId = c.intInventoryReceiptId
	WHERE	r.intInventoryReceiptId = @intReceiptId
END 

-- Create the taxes
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

ReturnReceipt_Exit: