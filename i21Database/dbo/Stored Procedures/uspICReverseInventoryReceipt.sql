CREATE PROCEDURE uspICReverseInventoryReceipt_PPT_OnHold
	@strReceiptNumber NVARCHAR(40) = NULL 
	,@intInventoryReceipt INT = NULL 
	,@intEntityUserSecurityId AS INT = NULL 	
	,@dtmReversalDate DATETIME = NULL 
	,@intNewInventoryReceiptId AS INT = NULL OUTPUT 
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

DECLARE 
	@strNewReceiptNumber AS NVARCHAR(50)
	,@intCreatedEntityId AS INT 

SET @intNewInventoryReceiptId = NULL 
	
SELECT TOP 1 
	@strNewReceiptNumber = strReceiptNumber + '-R'
	,@intInventoryReceipt = r.intInventoryReceiptId
	,@strReceiptNumber = r.strReceiptNumber
	,@intCreatedEntityId = r.intEntityId 
FROM 
	tblICInventoryReceipt r 
WHERE 
	(r.strReceiptNumber = @strReceiptNumber OR @strReceiptNumber IS NULL)
	AND (r.intInventoryReceiptId = @intInventoryReceipt OR @intInventoryReceipt IS NULL)
	AND r.ysnPosted = 1
	AND (@strReceiptNumber IS NOT NULL OR @intInventoryReceipt IS NOT NULL) 

----------------------------------------------	
-- Validate
----------------------------------------------

-- Check if the IR record is still posted. 
IF (@strNewReceiptNumber IS NULL) 
BEGIN 
	-- Reverse can only be used on posted transaction.
	EXEC uspICRaiseError 80244; 
	RETURN -80244; 
END 

IF EXISTS (SELECT TOP 1 1 FROM tblICInventoryReceipt r WHERE r.strReceiptNumber = @strNewReceiptNumber)
BEGIN 
	-- {Transaction Id} already has an existing reversal.
	EXEC uspICRaiseError 80247, @strReceiptNumber; 
	RETURN -80247; 
END 

-- Check Company preference: Allow User Self Post  
IF	dbo.fnIsAllowUserSelfPost(@intEntityUserSecurityId) = 1 
	AND @intEntityUserSecurityId <> @intCreatedEntityId 
BEGIN   
	-- 'You cannot {Reverse} transactions you did not create. Please contact your local administrator.'  
	EXEC uspICRaiseError 80172, 'Reverse';
	RETURN -80172
END 

-- Check the entity user security id. 
BEGIN 
	SELECT 
		@intEntityUserSecurityId = e.intEntityId
	FROM 
		tblEMEntity e
	WHERE
		e.intEntityId = @intEntityUserSecurityId

	IF @intEntityUserSecurityId IS NULL 
	BEGIN 
		-- 'Entity user id is invalid.'  
		EXEC uspICRaiseError 80246;
		RETURN -80246
	END 
END 

-- Check the reversal date. 
BEGIN 
	IF dbo.fnRemoveTimeOnDate(@dtmReversalDate) < dbo.fnRemoveTimeOnDate(GETDATE())
	BEGIN 
		-- 'Back-dated reversal is not allowed.'  
		EXEC uspICRaiseError 80248;
		RETURN -80248
	END 
END 

-- Duplicate the IR header. 
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
	,intShipFromEntityId
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
	,ysnCostOutdated
	,intCreatedUserId
	,intEntityId
	,intConcurrencyId
	,strActualCostId
	,strReceiptOriginId
	,strWarehouseRefNo
	,ysnOrigin
	,intSourceInventoryReceiptId
	,dtmCreated
	,dtmLastFreeWhseDate
	,intCompanyId
	,intBookId
	,intSubBookId
	,dblSubTotal
	,dblGrandTotal
	,dblTotalGross
	,dblTotalNet
	,dblTotalTax
	,dblTotalCharges
	,dtmLastCalculateTotals
	,dtmDateCreated
	,dtmDateModified
	,intCreatedByUserId
	,intModifiedByUserId
	,strDataSource
)	
SELECT 
	strReceiptType
	,intSourceType
	,intEntityVendorId
	,intTransferorId
	,intLocationId
	,strReceiptNumber = @strNewReceiptNumber -- Use the new Receipt Number with the suffix '-R'
	,dtmReceiptDate = dbo.fnRemoveTimeOnDate(ISNULL(@dtmReversalDate, GETDATE())) -- Use the provided new Receipt Date or the current system date. 
	,intCurrencyId
	,intSubCurrencyCents
	,intBlanketRelease
	,strVendorRefNo
	,strBillOfLading
	,intShipViaId
	,intShipFromEntityId
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
	,ysnCostOutdated
	,intCreatedUserId
	,intEntityId
	,intConcurrencyId
	,strActualCostId
	,strReceiptOriginId
	,strWarehouseRefNo
	,ysnOrigin
	,intSourceInventoryReceiptId = r.intInventoryReceiptId -- Track the source receipt id. 
	,dtmCreated
	,dtmLastFreeWhseDate
	,intCompanyId
	,intBookId
	,intSubBookId
	,dblSubTotal = -dblSubTotal
	,dblGrandTotal = -dblGrandTotal
	,dblTotalGross = -dblTotalGross
	,dblTotalNet = -dblTotalNet
	,dblTotalTax = -dblTotalTax
	,dblTotalCharges = -dblTotalCharges
	,dtmLastCalculateTotals
	,dtmDateCreated = GETDATE()
	,dtmDateModified = GETDATE()
	,intCreatedByUserId = @intEntityUserSecurityId
	,intModifiedByUserId = @intEntityUserSecurityId
	,strDataSource = 'Reverse'
FROM 
	tblICInventoryReceipt r 
WHERE
	r.strReceiptNumber = @strReceiptNumber

SET @intNewInventoryReceiptId = SCOPE_IDENTITY()

-- Validate if the receipt header is created. 
IF (@intNewInventoryReceiptId IS NULL)
BEGIN 
	-- {New Receipt Number} failed to create its transaction id.
	EXEC uspICRaiseError 80245, @strNewReceiptNumber; 
	RETURN -80245; 	
END 

-- Duplicate and reverse the Receipt Item 
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
	,dblQtyReturned
	,dblGrossReturned
	,dblNetReturned
	,intForexRateTypeId
	,dblForexRate
	,ysnLotWeightsRequired
	,strChargesLink
	,strItemType
	,strWarehouseRefNo
	,intParentItemLinkId
	,intChildItemLinkId
	,intCostingMethod
	,dtmDateCreated
	,dtmDateModified
	,intCreatedByUserId
	,intModifiedByUserId
	,intTicketId
	,intInventoryTransferId
	,intInventoryTransferDetailId
	,intPurchaseId
	,intPurchaseDetailId
	,intContractHeaderId
	,intContractDetailId
	,intLoadShipmentId
	,intLoadShipmentDetailId
	,ysnAllowVoucher
	,strActualCostId
)	
SELECT 
	intInventoryReceiptId = @intNewInventoryReceiptId -- Use the new receipt number. 
	,intLineNo
	,intOrderId
	,intSourceId
	,intItemId
	,intContainerId
	,intSubLocationId
	,intStorageLocationId
	,intOwnershipType
	,dblOrderQty
	,dblBillQty = 0
	,dblOpenReceive = -dblOpenReceive
	,intLoadReceive = -intLoadReceive
	,dblReceived = 0
	,intUnitMeasureId
	,intWeightUOMId
	,intCostUOMId
	,dblUnitCost
	,dblUnitRetail
	,ysnSubCurrency
	,dblLineTotal = -dblLineTotal
	,intGradeId
	,dblGross = -dblGross
	,dblNet = -dblNet
	,dblTax = -dblTax
	,intDiscountSchedule
	,ysnExported
	,dtmExportedDate
	,intSort
	,intConcurrencyId
	,strComments
	,intTaxGroupId
	,intSourceInventoryReceiptItemId = ri.intInventoryReceiptItemId -- Track the source receipt item id. 
	,dblQtyReturned
	,dblGrossReturned
	,dblNetReturned
	,intForexRateTypeId
	,dblForexRate
	,ysnLotWeightsRequired
	,strChargesLink
	,strItemType
	,strWarehouseRefNo
	,intParentItemLinkId
	,intChildItemLinkId
	,intCostingMethod
	,dtmDateCreated = GETDATE()
	,dtmDateModified = GETDATE()
	,intCreatedByUserId = @intEntityUserSecurityId
	,intModifiedByUserId = @intEntityUserSecurityId
	,intTicketId
	,intInventoryTransferId
	,intInventoryTransferDetailId
	,intPurchaseId
	,intPurchaseDetailId
	,intContractHeaderId
	,intContractDetailId
	,intLoadShipmentId
	,intLoadShipmentDetailId
	,ysnAllowVoucher
	,strActualCostId
FROM 
	tblICInventoryReceiptItem ri
WHERE
	ri.intInventoryReceiptId = @intInventoryReceipt

-- Duplicate and reverse the Receipt Item Taxes
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
	,ysnTaxOnly
	,ysnSeparateOnInvoice
	,ysnCheckoffTax
	,ysnTaxExempt
	,strTaxCode
	,dblQty
	,dblCost
	,intUnitMeasureId
	,intSort
	,intConcurrencyId
	,dtmDateCreated
	,dtmDateModified
	,intCreatedByUserId
	,intModifiedByUserId
)
SELECT 
	intInventoryReceiptItemId = newRi.intInventoryReceiptItemId
	,rTax.intTaxGroupId
	,rTax.intTaxCodeId
	,rTax.intTaxClassId
	,rTax.strTaxableByOtherTaxes
	,rTax.strCalculationMethod
	,rTax.dblRate
	,dblTax = -rTax.dblTax
	,dblAdjustedTax = -rTax.dblAdjustedTax
	,rTax.intTaxAccountId
	,rTax.ysnTaxAdjusted
	,rTax.ysnTaxOnly
	,rTax.ysnSeparateOnInvoice
	,rTax.ysnCheckoffTax
	,rTax.ysnTaxExempt
	,rTax.strTaxCode
	,dblQty = -rTax.dblQty
	,rTax.dblCost
	,rTax.intUnitMeasureId
	,rTax.intSort
	,rTax.intConcurrencyId
	,dtmDateCreated = GETDATE()
	,dtmDateModified = GETDATE()
	,intCreatedByUserId = @intEntityUserSecurityId
	,intModifiedByUserId = @intEntityUserSecurityId
FROM 
	tblICInventoryReceiptItemTax rTax INNER JOIN tblICInventoryReceiptItem ri
		ON rTax.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
	INNER JOIN tblICInventoryReceiptItem newRi
		ON ri.intInventoryReceiptItemId = newRi.intSourceInventoryReceiptItemId
WHERE
	ri.intInventoryReceiptId = @intInventoryReceipt
	AND newRi.intInventoryReceiptId = @intNewInventoryReceiptId

-- Duplicate and reverse the receipt item lot
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
	,dblStatedNetPerUnit
	,dblStatedTotalNet
	,dblPhysicalVsStated
	,strCertificate
	,intProducerId
	,strWarehouseRefNo
	,strCertificateId
	,strTrackingNumber
	,intSort
	,intConcurrencyId
	,dtmDateCreated
	,dtmDateModified
	,intCreatedByUserId
	,intModifiedByUserId
	,intSourceInventoryReceiptItemLotId
)
SELECT
	newRi.intInventoryReceiptItemId
	,rLot.intLotId
	,rLot.strLotNumber
	,rLot.strLotAlias
	,rLot.intSubLocationId
	,rLot.intStorageLocationId
	,rLot.intItemUnitMeasureId
	,-rLot.dblQuantity
	,-rLot.dblGrossWeight
	,rLot.dblTareWeight
	,rLot.dblCost
	,rLot.intNoPallet
	,rLot.intUnitPallet
	,rLot.dblStatedGrossPerUnit
	,rLot.dblStatedTarePerUnit
	,rLot.strContainerNo
	,rLot.intEntityVendorId
	,rLot.strGarden
	,rLot.strMarkings
	,rLot.intOriginId
	,rLot.intGradeId
	,rLot.intSeasonCropYear
	,rLot.strVendorLotId
	,rLot.dtmManufacturedDate
	,rLot.strRemarks
	,rLot.strCondition
	,rLot.dtmCertified
	,rLot.dtmExpiryDate
	,rLot.intParentLotId
	,rLot.strParentLotNumber
	,rLot.strParentLotAlias
	,rLot.dblStatedNetPerUnit
	,rLot.dblStatedTotalNet
	,rLot.dblPhysicalVsStated
	,rLot.strCertificate
	,rLot.intProducerId
	,rLot.strWarehouseRefNo
	,rLot.strCertificateId
	,rLot.strTrackingNumber
	,rLot.intSort
	,rLot.intConcurrencyId
	,dtmDateCreated = GETDATE()
	,dtmDateModified = GETDATE()
	,intCreatedByUserId = @intEntityUserSecurityId
	,intModifiedByUserId = @intEntityUserSecurityId
	,intSourceInventoryReceiptItemLotId = rLot.intInventoryReceiptItemLotId
FROM 
	tblICInventoryReceiptItemLot rLot INNER JOIN tblICInventoryReceiptItem ri
		ON rLot.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
	INNER JOIN tblICInventoryReceiptItem newRi
		ON ri.intInventoryReceiptItemId = newRi.intSourceInventoryReceiptItemId
WHERE
	ri.intInventoryReceiptId = @intInventoryReceipt

-- Duplicate and reverse the charges
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
	,intForexRateTypeId
	,dblForexRate
	,dblQuantity
	,dblQuantityBilled
	,dblQuantityPriced
	,strChargesLink
	,intLoadShipmentId
	,intLoadShipmentCostId
	,dtmDateCreated
	,dtmDateModified
	,intCreatedByUserId
	,intModifiedByUserId
	,ysnAllowVoucher
	,intSourceInventoryReceiptChargeId
)
SELECT 
	intInventoryReceiptId = @intNewInventoryReceiptId
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
	,dblAmount = -dblAmount
	,strAllocateCostBy
	,ysnAccrue
	,intEntityVendorId
	,ysnPrice
	,dblAmountBilled = 0 
	,dblAmountPaid = 0 
	,dblAmountPriced = 0 
	,intSort
	,dblTax = -dblTax
	,intConcurrencyId
	,intTaxGroupId
	,intForexRateTypeId
	,dblForexRate
	,dblQuantity = CASE WHEN rc.strCostMethod = 'Amount' THEN rc.dblQuantity ELSE -rc.dblQuantity END 
	,dblQuantityBilled = 0 
	,dblQuantityPriced = 0 
	,strChargesLink
	,intLoadShipmentId
	,intLoadShipmentCostId
	,dtmDateCreated = GETDATE()
	,dtmDateModified = GETDATE()
	,intCreatedByUserId = @intEntityUserSecurityId
	,intModifiedByUserId = @intEntityUserSecurityId
	,ysnAllowVoucher
	,intSourceInventoryReceiptChargeId = rc.intInventoryReceiptChargeId
FROM 
	tblICInventoryReceiptCharge rc
WHERE
	rc.intInventoryReceiptId = @intInventoryReceipt

-- Duplicate and reverse the charge taxes
INSERT INTO tblICInventoryReceiptChargeTax (
	intInventoryReceiptChargeId
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
	,ysnTaxOnly
	,ysnCheckoffTax
	,ysnTaxExempt
	,strTaxCode
	,dblQty
	,dblCost
	,intUnitMeasureId
	,intSort
	,intConcurrencyId
	,dtmDateCreated
	,dtmDateModified
	,intCreatedByUserId
	,intModifiedByUserId
	,intSourceInventoryReceiptChargeTaxId
)
SELECT 
	intInventoryReceiptChargeId = newRc.intInventoryReceiptChargeId
	,rcTax.intTaxGroupId
	,rcTax.intTaxCodeId
	,rcTax.intTaxClassId
	,rcTax.strTaxableByOtherTaxes
	,rcTax.strCalculationMethod
	,rcTax.dblRate
	,dblTax = -rcTax.dblTax
	,dblAdjustedTax = -rcTax.dblAdjustedTax
	,rcTax.intTaxAccountId
	,rcTax.ysnTaxAdjusted
	,rcTax.ysnTaxOnly
	,rcTax.ysnCheckoffTax
	,rcTax.ysnTaxExempt
	,rcTax.strTaxCode
	,dblQty = -rcTax.dblQty
	,rcTax.dblCost
	,rcTax.intUnitMeasureId
	,rcTax.intSort
	,rcTax.intConcurrencyId
	,dtmDateCreated = GETDATE()
	,dtmDateModified = GETDATE()
	,intCreatedByUserId = @intEntityUserSecurityId
	,intModifiedByUserId = @intEntityUserSecurityId
	,intSourceInventoryReceiptChargeTaxId = rcTax.intInventoryReceiptChargeTaxId
FROM 
	tblICInventoryReceiptChargeTax rcTax INNER JOIN tblICInventoryReceiptCharge rc
		ON rcTax.intInventoryReceiptChargeId = rc.intInventoryReceiptChargeId
	INNER JOIN tblICInventoryReceiptCharge newRc
		ON rc.intInventoryReceiptChargeId = newRc.intSourceInventoryReceiptChargeId
WHERE
	rc.intInventoryReceiptId = @intInventoryReceipt
	AND newRc.intInventoryReceiptId = @intNewInventoryReceiptId