CREATE PROCEDURE uspICImportReceiptItemLotFromStaging 
	@strIdentifier NVARCHAR(100), 
	@ysnAllowOverwrite BIT = 0,
	@intDataSourceId INT = 2
AS

DELETE FROM tblICImportStagingReceiptItemLot WHERE strImportIdentifier <> @strIdentifier

DECLARE @tblItemLotLogs TABLE(
	intImportStagingReceiptItemLotId INT
	, strColumnName NVARCHAR(200)
	, strColumnValue NVARCHAR(200)
	, strLogType NVARCHAR(200)
	, strLogMessage NVARCHAR(MAX)
)

DECLARE @intRowsImported AS INT

----------------------------------------------------------------------
-- Start Validation 
----------------------------------------------------------------------
BEGIN 
	INSERT INTO @tblItemLotLogs 
	(
		intImportStagingReceiptItemLotId,
		strColumnName,
		strColumnValue,
		strLogType,
		strLogMessage
	)
	SELECT
		ReceiptItemLot.intImportStagingReceiptItemLotId,
		'Unit of Measure',
		ReceiptItemLot.strUnitMeasure,
		'Error',
		'Invalid unit of measure: ' + ReceiptItemLot.strUnitMeasure + '.'
	FROM
		tblICImportStagingReceiptItemLot ReceiptItemLot
		INNER JOIN tblICInventoryReceiptItem ReceiptItem
			ON ReceiptItemLot.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
		LEFT JOIN tblICUnitMeasure UnitMeasure
			ON ReceiptItemLot.strUnitMeasure = UnitMeasure.strUnitMeasure
		LEFT JOIN tblICItemUOM ItemUOM
			ON ReceiptItem.intItemId = ItemUOM.intItemId 
			AND UnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
	WHERE
		ItemUOM.intItemUOMId IS NULL
		AND
		ReceiptItemLot.strImportIdentifier = @strIdentifier
	UNION
	SELECT
		ReceiptItemLot.intImportStagingReceiptItemLotId,
		'Storage Unit',
		ReceiptItemLot.strStorageUnit,
		'Warning',
		'Invalid storage unit: ' + ReceiptItemLot.strStorageUnit + '. System will use the storage unit from the line item instead.'
	FROM
		tblICImportStagingReceiptItemLot ReceiptItemLot
		INNER JOIN tblICInventoryReceiptItem ReceiptItem
			ON ReceiptItemLot.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
		INNER JOIN tblICInventoryReceipt Receipt
			ON ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
		LEFT JOIN vyuICGetStorageLocation StorageLocation
			ON Receipt.intLocationId = StorageLocation.intLocationId
			AND ReceiptItem.intSubLocationId = StorageLocation.intSubLocationId
			AND ReceiptItemLot.strStorageUnit = StorageLocation.strName
	WHERE 
		StorageLocation.intStorageLocationId IS NULL
		AND ReceiptItemLot.strStorageUnit IS NOT NULL
		AND ReceiptItemLot.strImportIdentifier = @strIdentifier
	UNION
	SELECT
		ReceiptItemLot.intImportStagingReceiptItemLotId,
		'Certificate',
		ReceiptItemLot.strCertificate,
		'Error',
		'Invalid certificate: ' + ReceiptItemLot.strCertificate + '.'
	FROM
		tblICImportStagingReceiptItemLot ReceiptItemLot
		LEFT JOIN tblICCertification Certification
			ON ReceiptItemLot.strCertificate = Certification.strCertificationName
	WHERE
		Certification.intCertificationId IS NULL
		AND ReceiptItemLot.strCertificate IS NOT NULL
		AND ReceiptItemLot.strImportIdentifier = @strIdentifier
	UNION
	SELECT
		ReceiptItemLot.intImportStagingReceiptItemLotId,
		'Producer',
		ReceiptItemLot.strProducer,
		'Error',
		'Invalid producer: ' + ReceiptItemLot.strProducer + '.'
	FROM
		tblICImportStagingReceiptItemLot ReceiptItemLot
		LEFT JOIN vyuEMEntity Producer
		ON ReceiptItemLot.strProducer = Producer.strName
			AND Producer.strType = 'Producer'
	WHERE
		Producer.intEntityId IS NULL
		AND ReceiptItemLot.strProducer IS NOT NULL
		AND ReceiptItemLot.strImportIdentifier = @strIdentifier
	UNION
	SELECT
		ReceiptItemLot.intImportStagingReceiptItemLotId,
		'Origin',
		ReceiptItemLot.strOrigin,
		'Error',
		'Invalid origin: ' + ReceiptItemLot.strOrigin + '.'
	FROM
		tblICImportStagingReceiptItemLot ReceiptItemLot
		LEFT JOIN tblSMCountry Country
			ON ReceiptItemLot.strOrigin = Country.strCountry
	WHERE
		Country.intCountryID IS NULL
		AND ReceiptItemLot.strOrigin IS NOT NULL
		AND ReceiptItemLot.strImportIdentifier = @strIdentifier
END 
----------------------------------------------------------------------
-- End Validation 
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Start Data Import
----------------------------------------------------------------------
IF	EXISTS (SELECT TOP 1 strSingleOrMultipleLots FROM tblICCompanyPreference WHERE strSingleOrMultipleLots IS NULL OR strSingleOrMultipleLots = 'Multiple')
	AND NOT EXISTS (SELECT TOP 1 * FROM @tblItemLotLogs WHERE strLogType = 'Error') 
BEGIN 
	INSERT INTO tblICInventoryReceiptItemLot
	(
		intInventoryReceiptItemId,
		strLotNumber,
		strLotAlias,
		intSubLocationId,
		intStorageLocationId,
		intItemUnitMeasureId,
		dblQuantity,
		dblGrossWeight,
		strWarehouseRefNo,
		dblTareWeight,
		intUnitPallet,
		dblStatedGrossPerUnit,
		dblStatedTarePerUnit,
		strContainerNo,
		strGarden,
		strMarkings,
		intOriginId,
		intSeasonCropYear,
		strVendorLotId,
		dtmManufacturedDate,
		strRemarks,
		strCondition,
		dtmCertified,
		dtmExpiryDate,
		intParentLotId,
		strParentLotNumber,
		dblStatedNetPerUnit,
		dblStatedTotalNet,
		dblPhysicalVsStated,
		strCertificate,
		intProducerId,
		strCertificateId,
		strTrackingNumber,
		intConcurrencyId
	)
	SELECT
		intInventoryReceiptItemId = ReceiptItemLot.intInventoryReceiptItemId
		,strLotNumber = ReceiptItemLot.strLotNo
		,strLotAlias = ReceiptItemLot.strLotAlias
		,intSubLocationId = ReceiptItem.intSubLocationId
		,intStorageLocationId = ISNULL(StorageLocation.intStorageLocationId, ReceiptItem.intSubLocationId) 
		,intItemUnitMeasureId = ItemUOM.intItemUOMId
		,dblQuantity = ReceiptItemLot.dblQuantity
		,dblGrossWeight = ReceiptItemLot.dblGross
		,strWarehouseRefNo = Receipt.strWarehouseRefNo
		,dblTareWeight = ReceiptItemLot.dblTare
		,intUnitPallet = ReceiptItemLot.intUnitPallet
		,dblStatedGrossPerUnit = ReceiptItemLot.dblStatedGrossPerUnit
		,dblStatedTarePerUnit = ReceiptItemLot.dblStatedTarePerUnit
		,strContainerNo = ReceiptItemLot.strContainerNo
		,strGarden = ReceiptItemLot.strGarden
		,strMarkings = ReceiptItemLot.strMarkings
		,intOriginId = Country.intCountryID
		,intSeasonCropYear = ReceiptItemLot.intSeasonCropYear
		,strVendorLotId = ReceiptItemLot.strVendorLotId
		,dtmManufacturedDate = ReceiptItemLot.dtmManufacturedDate
		,strRemarks = ReceiptItemLot.strRemarks
		,strCondition = ReceiptItemLot.strCondition
		,dtmCertified = ReceiptItemLot.dtmCertified
		,dtmExpiryDate = ReceiptItemLot.dtmExpiryDate
		,intParentLotId = ParentLot.intParentLotId
		,strParentLotNumber = ReceiptItemLot.strParentLotNo
		,dblStatedNetPerUnit = ROUND(ISNULL(ReceiptItemLot.dblStatedGrossPerUnit, 0) - ISNULL(ReceiptItemLot.dblStatedTarePerUnit, 0), 6)
		,dblStatedTotalNet = CASE
								WHEN 
									ISNULL(ItemUOM.intItemUOMId, 0) = ISNULL(ReceiptItem.intWeightUOMId, 0)
								THEN 
									ROUND(ISNULL(ReceiptItemLot.dblStatedGrossPerUnit, 0) - ISNULL(ReceiptItemLot.dblStatedTarePerUnit, 0), 6) -- Stated Net Per Unit
								ELSE 
									ROUND(
										ISNULL(ReceiptItemLot.dblQuantity, 0) * (ISNULL(ReceiptItemLot.dblStatedGrossPerUnit, 0) - -- Stated Total Net
										ISNULL(ReceiptItemLot.dblStatedTarePerUnit, 0))
									, 6)
							END
		,dblPhysicalVsStated = (ISNULL(ReceiptItemLot.dblGross, 0) - ISNULL(ReceiptItemLot.dblTare, 0)) - --Lot Net Weight
								CASE
									WHEN 
										ISNULL(ItemUOM.intItemUOMId, 0) = ISNULL(ReceiptItem.intWeightUOMId, 0)
									THEN 
										ROUND(ISNULL(ReceiptItemLot.dblStatedGrossPerUnit, 0) - ISNULL(ReceiptItemLot.dblStatedTarePerUnit, 0), 6) -- Stated Net Per Unit
									ELSE
										ROUND
										(
											dbo.fnMultiply
											(
												ISNULL(ReceiptItemLot.dblQuantity, 0),
												(ISNULL(ReceiptItemLot.dblStatedGrossPerUnit, 0) - -- Stated Total Net
												ISNULL(ReceiptItemLot.dblStatedTarePerUnit, 0))
											)
										, 6) 
									
								END
		,strCertificate = ReceiptItemLot.strCertificate
		,intProducerId = Producer.intEntityId
		,strCertificateId = ReceiptItemLot.strCertificateId
		,strTrackingNumber = ReceiptItemLot.strTrackingNumber
		,intConcurrencyId = 1
	FROM
		tblICImportStagingReceiptItemLot ReceiptItemLot
		INNER JOIN tblICInventoryReceiptItem ReceiptItem
			ON ReceiptItemLot.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
		INNER JOIN tblICInventoryReceipt Receipt
			ON ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
		LEFT JOIN tblICStorageLocation StorageLocation
			ON ReceiptItem.intSubLocationId = StorageLocation.intSubLocationId
			AND ReceiptItemLot.strStorageUnit = StorageLocation.strName
		LEFT JOIN tblICUnitMeasure UnitMeasure
			ON ReceiptItemLot.strUnitMeasure = UnitMeasure.strUnitMeasure
		LEFT JOIN tblICItemUOM ItemUOM
			ON ReceiptItem.intItemId = ItemUOM.intItemId
			AND UnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
		LEFT JOIN tblSMCountry Country
			ON ReceiptItemLot.strOrigin = Country.strCountry
		LEFT JOIN tblICParentLot ParentLot
			ON ReceiptItem.intItemId = ParentLot.intItemId
			AND ReceiptItemLot.strParentLotNo = ParentLot.strParentLotNumber
		LEFT JOIN vyuEMEntity Producer
			ON ReceiptItemLot.strProducer = Producer.strName
			AND Producer.strType = 'Producer'
	WHERE
		ReceiptItemLot.strImportIdentifier = @strIdentifier

	SELECT @intRowsImported = @@ROWCOUNT
END 

-- If Lot is for single line item, clone the original receipt item. 
ELSE IF	
	EXISTS (SELECT TOP 1 strSingleOrMultipleLots FROM tblICCompanyPreference WHERE strSingleOrMultipleLots = 'Single')
	AND NOT EXISTS (SELECT TOP 1 * FROM @tblItemLotLogs WHERE strLogType = 'Error') 
BEGIN 
	DECLARE @insertedReceiptItems AS TABLE (
		intImportStagingReceiptItemLotId INT 
		,intInventoryReceiptItemId INT 
	)
	DECLARE @intImportStagingReceiptItemLotId INT
		,@intInventoryReceiptItemId INT 
		,@intInventoryReceiptId INT 

	;DECLARE loopImport CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT	intImportStagingReceiptItemLotId
	FROM	tblICImportStagingReceiptItemLot lotImport
	WHERE	lotImport.strImportIdentifier = @strIdentifier
		
	OPEN loopImport;

	FETCH NEXT FROM loopImport INTO @intImportStagingReceiptItemLotId

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		-- Split the line total using the imported lot data. 
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
			,dblTare
			,dblTarePerQuantity
			,dblNet
			,dblTax
			,intDiscountSchedule
			,ysnExported
			,dtmExportedDate
			,intSort
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
			,ysnAddPayable
			,strActualCostId
			,ysnWeighed
			,strImportDescription
			,intComputeItemTotalOption		
			,intConcurrencyId
		)
		SELECT 
			ri.intInventoryReceiptId
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
			,dblOpenReceive = --ri.dblOpenReceive
				lotImport.dblQuantity
			,ri.intLoadReceive
			,ri.dblReceived
			,ri.intUnitMeasureId
			,ri.intWeightUOMId
			,ri.intCostUOMId
			,ri.dblUnitCost
			,ri.dblUnitRetail
			,ri.ysnSubCurrency
			,ri.dblLineTotal
			,ri.intGradeId
			,dblGross = --ri.dblGross
				lotImport.dblGross
			,dblTare = --ri.dblTare
				lotImport.dblTare
			,dblTarePerQuantity = --ri.dblTarePerQuantity
				dbo.fnDivide(lotImport.dblTare, lotImport.dblQuantity) 
			,dblNet = --ri.dblNet
				ISNULL(lotImport.dblGross, 0) - ISNULL(lotImport.dblTare, 0) 
			,ri.dblTax
			,ri.intDiscountSchedule
			,ri.ysnExported
			,ri.dtmExportedDate
			,ri.intSort
			,ri.strComments
			,ri.intTaxGroupId
			,ri.intSourceInventoryReceiptItemId
			,ri.dblQtyReturned
			,ri.dblGrossReturned
			,ri.dblNetReturned
			,ri.intForexRateTypeId
			,ri.dblForexRate
			,ri.ysnLotWeightsRequired
			,ri.strChargesLink
			,ri.strItemType
			,ri.strWarehouseRefNo
			,ri.intParentItemLinkId
			,ri.intChildItemLinkId
			,ri.intCostingMethod
			,ri.dtmDateCreated
			,ri.dtmDateModified
			,ri.intCreatedByUserId
			,ri.intModifiedByUserId
			,ri.intTicketId
			,ri.intInventoryTransferId
			,ri.intInventoryTransferDetailId
			,ri.intPurchaseId
			,ri.intPurchaseDetailId
			,ri.intContractHeaderId
			,ri.intContractDetailId
			,ri.intLoadShipmentId
			,ri.intLoadShipmentDetailId
			,ri.ysnAllowVoucher
			,ri.ysnAddPayable
			,ri.strActualCostId
			,ri.ysnWeighed
			,ri.strImportDescription
			,ri.intComputeItemTotalOption		
			,intConcurrencyId = 1
		FROM 
			tblICInventoryReceiptItem ri INNER JOIN tblICImportStagingReceiptItemLot lotImport
				ON ri.intInventoryReceiptItemId = lotImport.intInventoryReceiptItemId
		WHERE
			lotImport.intImportStagingReceiptItemLotId = @intImportStagingReceiptItemLotId

		SET @intInventoryReceiptItemId = SCOPE_IDENTITY();

		-- Track the duplicate line items in @insertedReceiptItems
		IF @intInventoryReceiptItemId IS NOT NULL
		BEGIN 
			INSERT INTO @insertedReceiptItems (
				intImportStagingReceiptItemLotId 
				,intInventoryReceiptItemId
			)
			SELECT
				@intImportStagingReceiptItemLotId
				,@intInventoryReceiptItemId
		END

		FETCH NEXT FROM loopImport INTO @intImportStagingReceiptItemLotId;
	END

	CLOSE loopImport;
	DEALLOCATE loopImport;

	INSERT INTO tblICInventoryReceiptItemLot
	(
		intInventoryReceiptItemId,
		strLotNumber,
		strLotAlias,
		intSubLocationId,
		intStorageLocationId,
		intItemUnitMeasureId,
		dblQuantity,
		dblGrossWeight,
		strWarehouseRefNo,
		dblTareWeight,
		intUnitPallet,
		dblStatedGrossPerUnit,
		dblStatedTarePerUnit,
		strContainerNo,
		strGarden,
		strMarkings,
		intOriginId,
		intSeasonCropYear,
		strVendorLotId,
		dtmManufacturedDate,
		strRemarks,
		strCondition,
		dtmCertified,
		dtmExpiryDate,
		intParentLotId,
		strParentLotNumber,
		dblStatedNetPerUnit,
		dblStatedTotalNet,
		dblPhysicalVsStated,
		strCertificate,
		intProducerId,
		strCertificateId,
		strTrackingNumber,
		intConcurrencyId
	)
	SELECT
		intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
		,strLotNumber = ReceiptItemLot.strLotNo
		,strLotAlias = ReceiptItemLot.strLotAlias
		,intSubLocationId = ReceiptItem.intSubLocationId
		,intStorageLocationId = ISNULL(StorageLocation.intStorageLocationId, ReceiptItem.intSubLocationId) 
		,intItemUnitMeasureId = ItemUOM.intItemUOMId
		,dblQuantity = ReceiptItemLot.dblQuantity
		,dblGrossWeight = ReceiptItemLot.dblGross
		,strWarehouseRefNo = Receipt.strWarehouseRefNo
		,dblTareWeight = ReceiptItemLot.dblTare
		,intUnitPallet = ReceiptItemLot.intUnitPallet
		,dblStatedGrossPerUnit = ReceiptItemLot.dblStatedGrossPerUnit
		,dblStatedTarePerUnit = ReceiptItemLot.dblStatedTarePerUnit
		,strContainerNo = ReceiptItemLot.strContainerNo
		,strGarden = ReceiptItemLot.strGarden
		,strMarkings = ReceiptItemLot.strMarkings
		,intOriginId = Country.intCountryID
		,intSeasonCropYear = ReceiptItemLot.intSeasonCropYear
		,strVendorLotId = ReceiptItemLot.strVendorLotId
		,dtmManufacturedDate = ReceiptItemLot.dtmManufacturedDate
		,strRemarks = ReceiptItemLot.strRemarks
		,strCondition = ReceiptItemLot.strCondition
		,dtmCertified = ReceiptItemLot.dtmCertified
		,dtmExpiryDate = ReceiptItemLot.dtmExpiryDate
		,intParentLotId = ParentLot.intParentLotId
		,strParentLotNumber = ReceiptItemLot.strParentLotNo
		,dblStatedNetPerUnit = ROUND(ISNULL(ReceiptItemLot.dblStatedGrossPerUnit, 0) - ISNULL(ReceiptItemLot.dblStatedTarePerUnit, 0), 6)
		,dblStatedTotalNet = CASE
								WHEN 
									ISNULL(ItemUOM.intItemUOMId, 0) = ISNULL(ReceiptItem.intWeightUOMId, 0)
								THEN 
									ROUND(ISNULL(ReceiptItemLot.dblStatedGrossPerUnit, 0) - ISNULL(ReceiptItemLot.dblStatedTarePerUnit, 0), 6) -- Stated Net Per Unit
								ELSE 
									ROUND(
										ISNULL(ReceiptItemLot.dblQuantity, 0) * (ISNULL(ReceiptItemLot.dblStatedGrossPerUnit, 0) - -- Stated Total Net
										ISNULL(ReceiptItemLot.dblStatedTarePerUnit, 0))
									, 6)
							END
		,dblPhysicalVsStated = (ISNULL(ReceiptItemLot.dblGross, 0) - ISNULL(ReceiptItemLot.dblTare, 0)) - --Lot Net Weight
								CASE
									WHEN 
										ISNULL(ItemUOM.intItemUOMId, 0) = ISNULL(ReceiptItem.intWeightUOMId, 0)
									THEN 
										ROUND(ISNULL(ReceiptItemLot.dblStatedGrossPerUnit, 0) - ISNULL(ReceiptItemLot.dblStatedTarePerUnit, 0), 6) -- Stated Net Per Unit
									ELSE
										ROUND
										(
											dbo.fnMultiply
											(
												ISNULL(ReceiptItemLot.dblQuantity, 0),
												(ISNULL(ReceiptItemLot.dblStatedGrossPerUnit, 0) - -- Stated Total Net
												ISNULL(ReceiptItemLot.dblStatedTarePerUnit, 0))
											)
										, 6) 
									
								END
		,strCertificate = ReceiptItemLot.strCertificate
		,intProducerId = Producer.intEntityId
		,strCertificateId = ReceiptItemLot.strCertificateId
		,strTrackingNumber = ReceiptItemLot.strTrackingNumber
		,intConcurrencyId = 1
	FROM
		tblICImportStagingReceiptItemLot ReceiptItemLot
		INNER JOIN @insertedReceiptItems insertedReceiptItem 
			ON ReceiptItemLot.intImportStagingReceiptItemLotId = insertedReceiptItem.intImportStagingReceiptItemLotId
		INNER JOIN tblICInventoryReceiptItem ReceiptItem
			ON ReceiptItem.intInventoryReceiptItemId = insertedReceiptItem.intInventoryReceiptItemId
		INNER JOIN tblICInventoryReceipt Receipt
			ON ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
		LEFT JOIN tblICStorageLocation StorageLocation
			ON ReceiptItem.intSubLocationId = StorageLocation.intSubLocationId
			AND ReceiptItemLot.strStorageUnit = StorageLocation.strName
		LEFT JOIN tblICUnitMeasure UnitMeasure
			ON ReceiptItemLot.strUnitMeasure = UnitMeasure.strUnitMeasure
		LEFT JOIN tblICItemUOM ItemUOM
			ON ReceiptItem.intItemId = ItemUOM.intItemId
			AND UnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
		LEFT JOIN tblSMCountry Country
			ON ReceiptItemLot.strOrigin = Country.strCountry
		LEFT JOIN tblICParentLot ParentLot
			ON ReceiptItem.intItemId = ParentLot.intItemId
			AND ReceiptItemLot.strParentLotNo = ParentLot.strParentLotNumber
		LEFT JOIN vyuEMEntity Producer
			ON ReceiptItemLot.strProducer = Producer.strName
			AND Producer.strType = 'Producer'
	WHERE
		ReceiptItemLot.strImportIdentifier = @strIdentifier

	SELECT @intRowsImported = @@ROWCOUNT

	-- Recompute the taxes for the new line item. 
	SELECT TOP 1 
		@intInventoryReceiptItemId = intInventoryReceiptItemId 
	FROM 
		tblICImportStagingReceiptItemLot 
	WHERE 
		strImportIdentifier = @strIdentifier

	IF @intInventoryReceiptItemId IS NOT NULL 
	BEGIN 
		SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId 
		FROM 
			tblICInventoryReceiptItem ri 
		WHERE 
			ri.intInventoryReceiptItemId = @intInventoryReceiptItemId

		-- Delete the line item and related records. 
		DELETE FROM tblICInventoryReceiptItemTax WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId
		DELETE FROM tblICInventoryReceiptChargePerItem WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId
		DELETE FROM tblICInventoryReceiptItemAllocatedCharge WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId
		DELETE FROM tblICInventoryReceiptItem WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId
		
		-- Re-update the line total 
		UPDATE	ReceiptItem 
		SET		dblLineTotal = 
					ROUND(						

						CASE	WHEN ReceiptItem.intWeightUOMId IS NOT NULL AND ReceiptItem.intComputeItemTotalOption = 0 THEN 
									dbo.fnMultiply(
										ISNULL(ReceiptItem.dblNet, 0)
										,dbo.fnMultiply(
											dbo.fnDivide(
												ISNULL(dblUnitCost, 0) 
												,ISNULL(Receipt.intSubCurrencyCents, 1) 
											)
											,dbo.fnDivide(
												GrossNetUOM.dblUnitQty
												,CostUOM.dblUnitQty 
											)
										)
									)								 
								ELSE 
									dbo.fnMultiply(
										ISNULL(ReceiptItem.dblOpenReceive, 0)
										,dbo.fnMultiply(
											dbo.fnDivide(
												ISNULL(dblUnitCost, 0) 
												,ISNULL(Receipt.intSubCurrencyCents, 1) 
											)
											,dbo.fnDivide(
												ReceiveUOM.dblUnitQty
												,CostUOM.dblUnitQty 
											)
										)
									)
						END 
						, 2
					) 
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
				LEFT JOIN dbo.tblICItemUOM ReceiveUOM 
					ON ReceiveUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
				LEFT JOIN dbo.tblICItemUOM GrossNetUOM 
					ON GrossNetUOM.intItemUOMId = ReceiptItem.intWeightUOMId
				LEFT JOIN dbo.tblICItemUOM CostUOM
					ON CostUOM.intItemUOMId = ISNULL(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId) 								
		WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId

		-- Calculate the tax
		EXEC uspICCalculateReceiptTax @intInventoryReceiptId

		-- Calculate the other charges
		BEGIN 			
			-- Calculate the other charges. 
			EXEC dbo.uspICCalculateInventoryReceiptOtherCharges
				@intInventoryReceiptId			

			-- Calculate the surcharges
			EXEC dbo.uspICCalculateInventoryReceiptSurchargeOnOtherCharges
				@intInventoryReceiptId
			
			-- Allocate the other charges and surcharges. 
			EXEC dbo.uspICAllocateInventoryReceiptOtherCharges 
				@intInventoryReceiptId		
				
			-- Calculate Other Charges Taxes
			EXEC dbo.uspICCalculateInventoryReceiptOtherChargesTaxes
				@intInventoryReceiptId
		END 

		-- Update the receipt sub total. 
		EXEC uspICInventoryReceiptCalculateTotals @intInventoryReceiptId, 1 
	END 
END 

----------------------------------------------------------------------
-- End Data Import
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Create Logs 
----------------------------------------------------------------------
DECLARE @intRowsSkipped AS INT
DECLARE @intTotalErrors AS INT

SELECT 
	@intRowsSkipped = COUNT(*) - @intRowsImported, 
	@intTotalErrors = COUNT(*) - @intRowsImported 
FROM 
	tblICImportStagingReceiptItemLot 
WHERE 
	strImportIdentifier = @strIdentifier

BEGIN 
	INSERT INTO tblICImportLogFromStaging (
		[strUniqueId] 
		,[intRowsImported] 
		,[intRowsUpdated] 
		,[intRowsSkipped]
		,[intTotalWarnings]
		,[intTotalErrors]
	)
	SELECT
		@strIdentifier,
		intRowsImported = ISNULL(@intRowsImported, 0),
		intRowsUpdated = 0,
		intRowsSkipped = ISNULL(@intRowsSkipped, 0),
		intTotalWarnings = 0,
		intTotalErrors = ISNULL(@intTotalErrors, 0)

	INSERT INTO tblICImportLogDetailFromStaging(
		strUniqueId,
		strField,
		strAction,
		strValue,
		strMessage,
		strStatus,
		strType,
		intConcurrencyId
	)
	SELECT 
		@strIdentifier,
		strColumnName,
		CASE
			WHEN strLogType = 'Error'
			THEN 'Import Failed.'
			ELSE 'Import Finished'
		END,
		strColumnValue,
		strLogMessage,
		CASE
			WHEN strLogType = 'Error'
			THEN 'Failed.'
			ELSE 'Skipped'
		END,
		CASE
			WHEN strLogType = 'Error'
			THEN 'Error'
			ELSE 'Warning'
		END,
		1
	FROM 
		@tblItemLotLogs
END