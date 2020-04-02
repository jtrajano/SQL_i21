CREATE PROCEDURE uspICReverseInventoryShipment
	@strShipmentNumber NVARCHAR(40) = NULL 
	,@intInventoryShipmentId INT = NULL 
	,@intEntityUserSecurityId AS INT = NULL 	
	,@dtmReversalDate DATETIME = NULL 
	,@intNewInventoryShipmentId AS INT= NULL OUTPUT 
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

DECLARE 
	@strNewShipmentNumber AS NVARCHAR(50)
	,@intCreatedEntityId AS INT 
	,@strCreditMemo AS NVARCHAR(50)

SET @intNewInventoryShipmentId = NULL 

SELECT TOP 1 
	@strNewShipmentNumber = strShipmentNumber + '-R'
	,@strShipmentNumber = s.strShipmentNumber
	,@intInventoryShipmentId = s.intInventoryShipmentId
	,@intCreatedEntityId = s.intEntityId	
FROM 
	tblICInventoryShipment s
WHERE 
	(s.strShipmentNumber = @strShipmentNumber OR @strShipmentNumber IS NULL)
	AND	(s.intInventoryShipmentId = @intInventoryShipmentId OR @intInventoryShipmentId IS NULL)	
	AND s.ysnPosted = 1
	AND (@strShipmentNumber IS NOT NULL OR @intInventoryShipmentId IS NOT NULL) 

----------------------------------------------	
-- Validate
----------------------------------------------

-- Check if the IR record is still posted. 
IF (@strNewShipmentNumber IS NULL) 
BEGIN 
	-- Reverse can only be used on posted transaction.
	EXEC uspICRaiseError 80244; 
	RETURN -80244; 
END 

IF EXISTS (SELECT TOP 1 1 FROM tblICInventoryShipment s WHERE s.strShipmentNumber = @strNewShipmentNumber)
BEGIN 
	-- {Transaction Id} already has an existing reversal.
	EXEC uspICRaiseError 80247, @strShipmentNumber; 
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

-- Check if CM is already created for Scale-Ticket shipments. 
BEGIN 
	SET @strCreditMemo = NULL 
	SELECT TOP 1 
		@strCreditMemo = cm.strInvoiceNumber
	FROM 
		tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
			ON s.intInventoryShipmentId = si.intInventoryShipmentId
		INNER JOIN (
			tblARInvoice inv INNER JOIN tblARInvoiceDetail invD
				ON inv.intInvoiceId = invD.intInvoiceId
		)
			ON invD.intInventoryShipmentItemId = si.intInventoryShipmentItemId
		LEFT JOIN (
			tblARInvoice cm INNER JOIN tblARInvoiceDetail cmD
				ON cm.intInvoiceId = cmD.intInvoiceId		
		)
			ON cmD.intOriginalInvoiceDetailId = invD.intInvoiceDetailId
			AND cm.strTransactionType IN ('Credit Memo')
	WHERE
		(s.strShipmentNumber = @strShipmentNumber OR @strShipmentNumber IS NULL)
		AND	(s.intInventoryShipmentId = @intInventoryShipmentId OR @intInventoryShipmentId IS NULL)			
		AND (@strShipmentNumber IS NOT NULL OR @intInventoryShipmentId IS NOT NULL) 
		AND s.ysnPosted = 1
		AND s.intSourceType = 1 -- Scale Ticket
		AND cmD.intInvoiceDetailId IS NOT NULL 
		AND cm.ysnReversal <> 1

	IF @strCreditMemo IS NOT NULL 
	BEGIN 
		-- 'Shipment reversal is not allowed. It already has a credit memo. See %s.'
		EXEC uspICRaiseError 80249, @strCreditMemo;
		RETURN -80249
	END
END 

-- Duplicate and reverse the shipment. 
INSERT INTO tblICInventoryShipment (
	strShipmentNumber
	,dtmShipDate
	,intOrderType
	,intSourceType
	,strReferenceNumber
	,dtmRequestedArrivalDate
	,intShipFromLocationId
	,intEntityCustomerId
	,intShipToLocationId
	,intShipToCompanyLocationId
	,intFreightTermId
	,strBOLNumber
	,intCurrencyId
	,intShipViaId
	,strVessel
	,strProNumber
	,strDriverId
	,strSealNumber
	,strDeliveryInstruction
	,dtmAppointmentTime
	,dtmDepartureTime
	,dtmArrivalTime
	,dtmDeliveredDate
	,dtmFreeTime
	,strFreeTime
	,strReceivedBy
	,strComment
	,ysnPosted
	,ysnDestinationPosted
	,dtmDestinationDate
	,intEntityId
	,intCreatedUserId
	,intConcurrencyId
	,dtmCreated
	,intCompanyId
	,dtmDateCreated
	,dtmDateModified
	,intCreatedByUserId
	,intModifiedByUserId
	,strDataSource
	,intSourceInventoryShipmentId
)
SELECT 
	strShipmentNumber = @strNewShipmentNumber -- Use the new Shipment Number with the suffix '-R'
	,dtmShipDate = dbo.fnRemoveTimeOnDate(ISNULL(@dtmReversalDate, GETDATE())) -- Use the provided new Receipt Date or the current system date. 
	,intOrderType
	,intSourceType
	,strReferenceNumber
	,dtmRequestedArrivalDate
	,intShipFromLocationId
	,intEntityCustomerId
	,intShipToLocationId
	,intShipToCompanyLocationId
	,intFreightTermId
	,strBOLNumber
	,intCurrencyId
	,intShipViaId
	,strVessel
	,strProNumber
	,strDriverId
	,strSealNumber
	,strDeliveryInstruction
	,dtmAppointmentTime
	,dtmDepartureTime
	,dtmArrivalTime
	,dtmDeliveredDate
	,dtmFreeTime
	,strFreeTime
	,strReceivedBy
	,strComment
	,ysnPosted = 0 
	,ysnDestinationPosted
	,dtmDestinationDate
	,intEntityId
	,intCreatedUserId
	,intConcurrencyId
	,dtmCreated
	,intCompanyId
	,dtmDateCreated = GETDATE()
	,dtmDateModified = GETDATE() 
	,intCreatedByUserId = @intEntityUserSecurityId
	,intModifiedByUserId = @intEntityUserSecurityId
	,strDataSource = 'Reverse'
	,intSourceInventoryShipmentId = s.intInventoryShipmentId
FROM 
	tblICInventoryShipment s
WHERE
	s.strShipmentNumber = @strShipmentNumber

SET @intNewInventoryShipmentId = SCOPE_IDENTITY()

-- Validate if the receipt header is created. 
IF (@intNewInventoryShipmentId IS NULL)
BEGIN 
	-- {New Receipt Number} failed to create its transaction id.
	EXEC uspICRaiseError 80245, @strNewShipmentNumber; 
	RETURN -80245; 	
END 

-- Duplicate and reverse Shipment Item
INSERT INTO tblICInventoryShipmentItem (
	intInventoryShipmentId
	,intOrderId
	,intSourceId
	,intLineNo
	,intItemId
	,intSubLocationId
	,intStorageLocationId
	,intOwnershipType
	,dblQuantity
	,intLoadShipped
	,intItemUOMId
	,intCurrencyId
	,intWeightUOMId
	,dblGross
	,dblTare
	,dblUnitPrice
	,intPriceUOMId
	,intDockDoorId
	,strNotes
	,intGradeId
	,intDestinationGradeId
	,intDestinationWeightId
	,intDiscountSchedule
	,intStorageScheduleTypeId
	,intSort
	,intForexRateTypeId
	,dblForexRate
	,dblDestinationQuantity
	,dblDestinationGross
	,dblDestinationNet
	,strItemType
	,strChargesLink
	,intParentItemLinkId
	,intChildItemLinkId
	,dblLineTotal
	,intConcurrencyId
	,dblNet
	,dtmDateCreated
	,dtmDateModified
	,intCreatedByUserId
	,intModifiedByUserId
	,ysnDestinationWeightsAndGrades
	,ysnAllowInvoice
	,intItemContractHeaderId
	,intItemContractDetailId
	,intSourceInventoryShipmentItemId
)
SELECT 
	intInventoryShipmentId = @intNewInventoryShipmentId
	,intOrderId
	,intSourceId
	,intLineNo
	,intItemId
	,intSubLocationId
	,intStorageLocationId
	,intOwnershipType
	,-dblQuantity
	,intLoadShipped
	,intItemUOMId
	,intCurrencyId
	,intWeightUOMId
	,-dblGross
	,-dblTare
	,dblUnitPrice
	,intPriceUOMId
	,intDockDoorId
	,strNotes
	,intGradeId
	,intDestinationGradeId
	,intDestinationWeightId
	,intDiscountSchedule
	,intStorageScheduleTypeId
	,intSort
	,intForexRateTypeId
	,dblForexRate
	,dblDestinationQuantity
	,dblDestinationGross
	,dblDestinationNet
	,strItemType
	,strChargesLink
	,intParentItemLinkId
	,intChildItemLinkId
	,-dblLineTotal
	,intConcurrencyId
	,-dblNet
	,dtmDateCreated = GETDATE()
	,dtmDateModified = GETDATE()
	,intCreatedByUserId = @intEntityUserSecurityId
	,intModifiedByUserId = @intEntityUserSecurityId
	,ysnDestinationWeightsAndGrades
	,ysnAllowInvoice
	,intItemContractHeaderId
	,intItemContractDetailId
	,intSourceInventoryShipmentItemId = si.intInventoryShipmentItemId
FROM
	tblICInventoryShipmentItem si
WHERE
	si.intInventoryShipmentId = @intInventoryShipmentId

-- Duplicate and reverse the Shipment Item Lot 
INSERT INTO tblICInventoryShipmentItemLot (
	intInventoryShipmentItemId
	,intLotId
	,dblQuantityShipped
	,dblGrossWeight
	,dblTareWeight
	,dblWeightPerQty
	,strWarehouseCargoNumber
	,dblDestinationQuantityShipped
	,dblDestinationGrossWeight
	,dblDestinationTareWeight
	,intSort
	,intConcurrencyId
	,dtmDateCreated
	,dtmDateModified
	,intCreatedByUserId
	,intModifiedByUserId
	,intSourceInventoryShipmentItemLotId
)
SELECT 
	intInventoryShipmentItemId = newSi.intInventoryShipmentItemId
	,sl.intLotId
	,-sl.dblQuantityShipped
	,-sl.dblGrossWeight
	,-sl.dblTareWeight
	,sl.dblWeightPerQty
	,sl.strWarehouseCargoNumber
	,sl.dblDestinationQuantityShipped
	,sl.dblDestinationGrossWeight
	,sl.dblDestinationTareWeight
	,sl.intSort
	,sl.intConcurrencyId
	,dtmDateCreated = GETDATE()
	,dtmDateModified = GETDATE()
	,intCreatedByUserId = @intEntityUserSecurityId
	,intModifiedByUserId = @intEntityUserSecurityId
	,intSourceInventoryShipmentItemLotId = sl.intInventoryShipmentItemLotId
FROM 
	tblICInventoryShipmentItem si INNER JOIN tblICInventoryShipmentItemLot sl
		ON si.intInventoryShipmentItemId = sl.intInventoryShipmentItemId
	INNER JOIN tblICInventoryShipmentItem newSi
		ON si.intInventoryShipmentItemId = newSi.intSourceInventoryShipmentItemId
WHERE
	si.intInventoryShipmentId = @intInventoryShipmentId
	AND newSi.intInventoryShipmentId = @intNewInventoryShipmentId

-- Duplicate and reverse the Shipment Charges
INSERT INTO tblICInventoryShipmentCharge (
	intInventoryShipmentId
	,intContractId
	,intContractDetailId
	,intChargeId
	,strCostMethod
	,dblRate
	,intCostUOMId
	,intCurrencyId
	,dblAmount
	,strAllocatePriceBy
	,ysnAccrue
	,intEntityVendorId
	,ysnPrice
	,intSort
	,intConcurrencyId
	,ysnSubCurrency
	,intCent
	,dblAmountBilled
	,dblAmountPaid
	,dblAmountPriced
	,intForexRateTypeId
	,dblForexRate
	,dblQuantity
	,dblQuantityBilled
	,dblQuantityPriced
	,intTaxGroupId
	,dblTax
	,dblAdjustedTax
	,strChargesLink
	,dtmDateCreated
	,dtmDateModified
	,intCreatedByUserId
	,intModifiedByUserId
	,ysnAllowVoucher
	,ysnAllowInvoice
	,intItemContractHeaderId
	,intItemContractDetailId
	,intSourceInventoryShipmentChargeId
)
SELECT 
	intInventoryShipmentId = @intNewInventoryShipmentId
	,intContractId
	,intContractDetailId
	,intChargeId
	,strCostMethod
	,dblRate
	,intCostUOMId
	,intCurrencyId
	,-dblAmount
	,strAllocatePriceBy
	,ysnAccrue
	,intEntityVendorId
	,ysnPrice
	,intSort
	,intConcurrencyId
	,ysnSubCurrency
	,intCent
	,dblAmountBilled = 0 
	,dblAmountPaid = 0 
	,dblAmountPriced = 0 
	,intForexRateTypeId
	,dblForexRate
	,dblQuantity = CASE WHEN sCharge.strCostMethod = 'Amount' THEN sCharge.dblQuantity ELSE -sCharge.dblQuantity END 
	,dblQuantityBilled = 0 
	,dblQuantityPriced = 0 
	,intTaxGroupId
	,-dblTax
	,-dblAdjustedTax
	,strChargesLink
	,dtmDateCreated
	,dtmDateModified
	,intCreatedByUserId
	,intModifiedByUserId
	,ysnAllowVoucher
	,ysnAllowInvoice
	,intItemContractHeaderId
	,intItemContractDetailId
	,intSourceInventoryShipmentChargeId = sCharge.intInventoryShipmentChargeId
FROM 
	tblICInventoryShipmentCharge sCharge 
WHERE
	sCharge.intInventoryShipmentId = @intInventoryShipmentId

-- Duplicate and reverse the Shipment Charge Taxes
INSERT INTO tblICInventoryShipmentChargeTax (
	intInventoryShipmentChargeId
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
	,intSourceInventoryShipmentChargeTaxId
)
SELECT 
	intInventoryShipmentChargeId = newSc.intInventoryShipmentChargeId
	,scTax.intTaxGroupId 
	,scTax.intTaxCodeId
	,scTax.intTaxClassId
	,scTax.strTaxableByOtherTaxes
	,scTax.strCalculationMethod
	,scTax.dblRate
	,-scTax.dblTax
	,-scTax.dblAdjustedTax
	,scTax.intTaxAccountId
	,scTax.ysnTaxAdjusted
	,scTax.ysnTaxOnly
	,scTax.ysnCheckoffTax
	,scTax.ysnTaxExempt
	,scTax.strTaxCode
	,-dblQty
	,scTax.dblCost
	,scTax.intUnitMeasureId
	,scTax.intSort
	,scTax.intConcurrencyId
	,dtmDateCreated = GETDATE()
	,dtmDateModified = GETDATE()
	,intCreatedByUserId = @intEntityUserSecurityId
	,intModifiedByUserId = @intEntityUserSecurityId
	,intSourceInventoryShipmentChargeTaxId = scTax.intInventoryShipmentChargeTaxId
FROM 
	tblICInventoryShipmentChargeTax scTax INNER JOIN tblICInventoryShipmentCharge sc
		ON scTax.intInventoryShipmentChargeId = sc.intInventoryShipmentChargeId
	INNER JOIN tblICInventoryShipmentCharge newSc
		ON sc.intInventoryShipmentChargeId = newSc.intSourceInventoryShipmentChargeId
WHERE
	sc.intInventoryShipmentId = @intInventoryShipmentId
	AND newSc.intInventoryShipmentId = @intNewInventoryShipmentId