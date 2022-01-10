CREATE PROCEDURE uspICImportReceiptItemLotFromStaging 
	@strIdentifier NVARCHAR(100), 
	@ysnAllowOverwrite BIT = 0,
	@intDataSourceId INT = 2
AS

DELETE FROM tblICImportStagingReceiptItemLot WHERE strImportIdentifier <> @strIdentifier

DECLARE @tblItemLotLogs TABLE(intImportStagingReceiptItemLotId INT, strColumnName NVARCHAR(200), strColumnValue NVARCHAR(200), strLogType NVARCHAR(200), strLogMessage NVARCHAR(MAX))

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
INNER JOIN
	tblICInventoryReceiptItem ReceiptItem
    ON
        ReceiptItemLot.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
LEFT JOIN
	tblICUnitMeasure UnitMeasure
    ON
        ReceiptItemLot.strUnitMeasure = UnitMeasure.strUnitMeasure
LEFT JOIN
	tblICItemUOM ItemUOM
	ON
		ReceiptItem.intItemId = ItemUOM.intItemId
		AND
		UnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
WHERE
    ItemUOM.intItemUOMId IS NULL
	AND
	ReceiptItemLot.strImportIdentifier = @strIdentifier
UNION
SELECT
	ReceiptItemLot.intImportStagingReceiptItemLotId,
	'Storage Unit',
	ReceiptItemLot.strStorageUnit,
	'Error',
	'Invalid storage unit: ' + ReceiptItemLot.strStorageUnit + '.'
FROM
	tblICImportStagingReceiptItemLot ReceiptItemLot
INNER JOIN
	tblICInventoryReceiptItem ReceiptItem
    ON
        ReceiptItemLot.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
INNER JOIN
    tblICInventoryReceipt Receipt
    ON
        ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
LEFT JOIN 
    vyuICGetStorageLocation StorageLocation
    ON
        Receipt.intLocationId = StorageLocation.intLocationId
        AND
        ReceiptItem.intSubLocationId = StorageLocation.intSubLocationId
        AND
        ReceiptItemLot.strStorageUnit = StorageLocation.strName
WHERE 
    StorageLocation.intStorageLocationId IS NULL
	AND
	ReceiptItemLot.strStorageUnit IS NOT NULL
	AND
	ReceiptItemLot.strImportIdentifier = @strIdentifier
UNION
SELECT
	ReceiptItemLot.intImportStagingReceiptItemLotId,
	'Certificate',
	ReceiptItemLot.strCertificate,
	'Error',
	'Invalid certificate: ' + ReceiptItemLot.strCertificate + '.'
FROM
	tblICImportStagingReceiptItemLot ReceiptItemLot
LEFT JOIN
	tblICCertification Certification
    ON
        ReceiptItemLot.strCertificate = Certification.strCertificationName
WHERE
    Certification.intCertificationId IS NULL
    AND
    ReceiptItemLot.strCertificate IS NOT NULL
	AND
	ReceiptItemLot.strImportIdentifier = @strIdentifier
UNION
SELECT
	ReceiptItemLot.intImportStagingReceiptItemLotId,
	'Producer',
	ReceiptItemLot.strProducer,
	'Error',
	'Invalid producer: ' + ReceiptItemLot.strProducer + '.'
FROM
	tblICImportStagingReceiptItemLot ReceiptItemLot
LEFT JOIN
	vyuEMEntity Producer
    ON
        ReceiptItemLot.strProducer = Producer.strName
        AND
        Producer.strType = 'Producer'
WHERE
    Producer.intEntityId IS NULL
    AND
    ReceiptItemLot.strProducer IS NOT NULL
	AND
	ReceiptItemLot.strImportIdentifier = @strIdentifier
UNION
SELECT
	ReceiptItemLot.intImportStagingReceiptItemLotId,
	'Origin',
	ReceiptItemLot.strOrigin,
	'Error',
	'Invalid origin: ' + ReceiptItemLot.strOrigin + '.'
FROM
	tblICImportStagingReceiptItemLot ReceiptItemLot
LEFT JOIN
	tblSMCountry Country
    ON
        ReceiptItemLot.strOrigin = Country.strCountry
WHERE
    Country.intCountryID IS NULL
    AND
    ReceiptItemLot.strOrigin IS NOT NULL
	AND
	ReceiptItemLot.strImportIdentifier = @strIdentifier

DECLARE @intRowsImported AS INT

INSERT INTO tblICInventoryReceiptItemLot
(
	intInventoryReceiptItemId,
	intLotId,
	strLotNumber,
	strLotAlias,
	intSubLocationId,
	intStorageLocationId,
	intItemUnitMeasureId,
	dblQuantity,
	dblGrossWeight,
	strWarehouseRefNo,
	dblTareWeight,
	-- dblCost,
	-- intNoPallet,
	intUnitPallet,
	dblStatedGrossPerUnit,
	dblStatedTarePerUnit,
	strContainerNo,
	-- intEntityVendorId,
	strGarden,
	strMarkings,
	intOriginId,
	-- intGradeId,
	intSeasonCropYear,
	strVendorLotId,
	dtmManufacturedDate,
	strRemarks,
	strCondition,
	dtmCertified,
	dtmExpiryDate,
	intParentLotId,
	strParentLotNumber,
	-- strParentLotAlias,
	dblStatedNetPerUnit,
	dblStatedTotalNet,
	dblPhysicalVsStated,
	strCertificate,
	intProducerId,
	strCertificateId,
	strTrackingNumber
	-- ,
	-- intSort,
	-- strCargoNo,
	-- strWarrantNo,
	-- intLotStatusId,
	-- intSourceLotId,
)
SELECT
	intInventoryReceiptItemId = ReceiptItemLot.intInventoryReceiptItemId,
	intLotId = Lot.strLotNumber,
	strLotNumber = ReceiptItemLot.strLotNo,
	strLotAlias = ReceiptItemLot.strLotAlias,
	intSubLocationId = ReceiptItem.intSubLocationId,
	intStorageLocationId = StorageLocation.intStorageLocationId,
	intItemUnitMeasureId = ItemUOM.intItemUOMId,
	dblQuantity = ReceiptItemLot.dblQuantity,
	dblGrossWeight = ReceiptItemLot.dblGross,
	strWarehouseRefNo = Receipt.strWarehouseRefNo,
	dblTareWeight = ReceiptItemLot.dblTare,
	-- dblCost = 0, TO ASK
	-- intNoPallet = 0, TO ASK
	intUnitPallet = ReceiptItemLot.intUnitPallet,
	dblStatedGrossPerUnit = ReceiptItemLot.dblStatedGrossPerUnit,
	dblStatedTarePerUnit = ReceiptItemLot.dblStatedTarePerUnit,
	strContainerNo = ReceiptItemLot.strContainerNo,
	-- intEntityVendorId = NULL, 
	strGarden = ReceiptItemLot.strGarden,
	strMarkings = ReceiptItemLot.strMarkings,
	intOriginId = Country.intCountryID,
	-- intGradeId = 0, TO ASK
	intSeasonCropYear = ReceiptItemLot.intSeasonCropYear,
	strVendorLotId = ReceiptItemLot.strVendorLotId,
	dtmManufacturedDate = ReceiptItemLot.dtmManufacturedDate,
	strRemarks = ReceiptItemLot.strRemarks,
	strCondition = ReceiptItemLot.strCondition,
	dtmCertified = ReceiptItemLot.dtmCertified,
	dtmExpiryDate = ReceiptItemLot.dtmExpiryDate,
	intParentLotId = ParentLot.intParentLotId,
	strParentLotNumber = ReceiptItemLot.strParentLotNo,
	-- strParentLotAlias = NULL, TO ASK
	dblStatedNetPerUnit = ROUND(ISNULL(ReceiptItemLot.dblStatedGrossPerUnit, 0) - ISNULL(ReceiptItemLot.dblStatedTarePerUnit, 0), 6),
	dblStatedTotalNet = CASE
							WHEN 
								ISNULL(ItemUOM.intItemUOMId, 0) = ISNULL(ReceiptItem.intWeightUOMId, 0)
							THEN 
								ROUND(ISNULL(ReceiptItemLot.dblStatedGrossPerUnit, 0) - ISNULL(ReceiptItemLot.dblStatedTarePerUnit, 0), 6) -- Stated Net Per Unit
							ELSE 
								ROUND(
									ISNULL(ReceiptItemLot.dblQuantity, 0) * (ISNULL(ReceiptItemLot.dblStatedGrossPerUnit, 0) - -- Stated Total Net
									ISNULL(ReceiptItemLot.dblStatedTarePerUnit, 0))
								, 6)
						END,
	dblPhysicalVsStated = (ISNULL(ReceiptItemLot.dblGross, 0) - ISNULL(ReceiptItemLot.dblTare, 0)) - --Lot Net Weight
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
									
							END,
	strCertificate = ReceiptItemLot.strCertificate,
	intProducerId = Producer.intEntityId,
	strCertificateId = ReceiptItemLot.strCertificateId,
	strTrackingNumber = ReceiptItemLot.strTrackingNumber
	-- ,
	-- intSort = NULL, TO ASK
	-- strCargoNo = NULL, TO ASK
	-- strWarrantNo = NULL, TO ASK
	-- intLotStatusId = NULL, TO ASK
	-- intSourceLotId = NULL, TO ASK
FROM
	tblICImportStagingReceiptItemLot ReceiptItemLot
INNER JOIN
	tblICInventoryReceiptItem ReceiptItem
	ON
		ReceiptItemLot.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
INNER JOIN
	tblICInventoryReceipt Receipt
	ON
		ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
LEFT JOIN
	vyuICGetLot Lot
	ON
		Receipt.intLocationId = Lot.intLocationId
		AND
		ReceiptItem.intSubLocationId = Lot.intSubLocationId
		AND
		ReceiptItem.intStorageLocationId = Lot.intStorageLocationId
		AND
		ReceiptItem.intOwnershipType = Lot.intOwnershipType
		AND
		ReceiptItemLot.strLotNo = Lot.strLotNumber
LEFT JOIN
	tblICStorageLocation StorageLocation
	ON
		ReceiptItem.intSubLocationId = StorageLocation.intSubLocationId
		AND
		ReceiptItemLot.strStorageUnit = StorageLocation.strName
LEFT JOIN
	tblICUnitMeasure UnitMeasure
	ON
		ReceiptItemLot.strUnitMeasure = UnitMeasure.strUnitMeasure
LEFT JOIN
	tblICItemUOM ItemUOM
	ON
		ReceiptItem.intItemId = ItemUOM.intItemId
		AND
		UnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN
	tblSMCountry Country
	ON
		ReceiptItemLot.strOrigin = Country.strCountry
LEFT JOIN
	tblICParentLot ParentLot
	ON
		ReceiptItem.intItemId = ParentLot.intItemId
		AND
		ReceiptItemLot.strParentLotNo = ParentLot.strParentLotNumber
LEFT JOIN
	vyuEMEntity Producer
	ON
		ReceiptItemLot.strProducer = Producer.strName
		AND
		Producer.strType = 'Producer'
LEFT JOIN
	@tblItemLotLogs Logs
	ON
		ReceiptItemLot.intImportStagingReceiptItemLotId = Logs.intImportStagingReceiptItemLotId
WHERE
	Logs.intImportStagingReceiptItemLotId IS NULL
	AND
	ReceiptItemLot.strImportIdentifier = @strIdentifier

SELECT @intRowsImported = @@ROWCOUNT

DECLARE @intRowsSkipped AS INT
DECLARE @intTotalErrors AS INT

SELECT 
	@intRowsSkipped = COUNT(*) - @intRowsImported, 
	@intTotalErrors = COUNT(*) - @intRowsImported 
FROM 
	tblICImportStagingReceiptItemLot 
WHERE 
	strImportIdentifier = @strIdentifier

-- Logs
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