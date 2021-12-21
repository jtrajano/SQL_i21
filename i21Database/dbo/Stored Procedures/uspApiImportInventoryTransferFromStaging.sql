CREATE PROCEDURE [dbo].[uspApiImportInventoryTransferFromStaging] (@guiApiUniqueId UNIQUEIDENTIFIER, @ysnAutoPost BIT = 0)
AS

DECLARE @Logs TABLE (strError NVARCHAR(500), strField NVARCHAR(100), strValue NVARCHAR(500), intLineNumber INT NULL, dblTotalAmount NUMERIC(18, 6), intLinePosition INT NULL, strLogLevel NVARCHAR(50))

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'Cannot find the fromLocationId ''' + CAST(s.intFromLocationId AS NVARCHAR(50)) + '''', 'fromLocationId', 'Error',  CAST(s.intFromLocationId AS NVARCHAR(50))
FROM tblApiInventoryTransferStaging s
LEFT JOIN tblSMCompanyLocation l ON l.intCompanyLocationId = s.intFromLocationId
WHERE l.intCompanyLocationId IS NULL
	AND s.guiApiUniqueId = @guiApiUniqueId

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'Cannot find the toLocationId ''' + CAST(s.intToLocationId AS NVARCHAR(50)) + '''', 'toLocationId', 'Error',  CAST(s.intToLocationId AS NVARCHAR(50))
FROM tblApiInventoryTransferStaging s
LEFT JOIN tblSMCompanyLocation l ON l.intCompanyLocationId = s.intToLocationId
WHERE l.intCompanyLocationId IS NULL
	AND s.guiApiUniqueId = @guiApiUniqueId

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'Cannot find the brokerId ''' + CAST(t.intBrokerId AS NVARCHAR(50)) + '''', 'brokerId', 'Error',  CAST(t.intBrokerId AS NVARCHAR(50))
FROM tblApiInventoryTransferStaging t
LEFT JOIN tblEMEntity e ON e.intEntityId = t.intBrokerId
WHERE e.intEntityId IS NULL
	AND t.guiApiUniqueId = @guiApiUniqueId
	AND t.intBrokerId IS NOT NULL

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'The entity ''' + e.strName + ''' with brokerId ''' + CAST(t.intBrokerId AS NVARCHAR(50)) + ''' is not a valid broker.', 'brokerId', 'Error',  CAST(t.intBrokerId AS NVARCHAR(50))
FROM tblApiInventoryTransferStaging t
LEFT JOIN tblEMEntity e ON e.intEntityId = t.intBrokerId
LEFT JOIN tblEMEntityType et ON et.intEntityId = e.intEntityId
	AND et.strType = 'Broker'
WHERE e.intEntityId IS NOT NULL
	AND t.guiApiUniqueId = @guiApiUniqueId
	AND t.intBrokerId IS NOT NULL
	AND et.intEntityTypeId IS NULL

IF EXISTS(SELECT * FROM @Logs)
	GOTO Logging

DECLARE @intInventorTransferId INT
DECLARE @strStartingNumber NVARCHAR(100)
DECLARE @intApiInventoryTransferStagingId INT
DECLARE @intFromLocationId INT
DECLARE @intToLocationId INT
DECLARE @dtmTransferDate DATETIME
DECLARE @strDescription NVARCHAR(200)
DECLARE @ysnShipmentRequired BIT
DECLARE @intTransferStatus INT
DECLARE @intShipViaId INT
DECLARE @intBrokerId INT
DECLARE @dtmBOLDate DATETIME
DECLARE @dtmBOLReceiveDate DATETIME
DECLARE @strBOLNumber NVARCHAR(400)

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
SELECT
	  s.intApiInventoryTransferStagingId
	, s.intFromLocationId
	, s.intToLocationId
	, s.dtmTransferDate
	, s.strDescription
	, s.ysnShipmentRequired
	, s.intStatusId
	, s.intShipViaId
	, s.intBrokerId
	, s.dtmBOLDate
	, s.dtmBOLReceiveDate
	, s.strBOLNumber
FROM tblApiInventoryTransferStaging s
WHERE s.guiApiUniqueId = @guiApiUniqueId

OPEN cur

FETCH NEXT FROM cur INTO
	  @intApiInventoryTransferStagingId
	, @intFromLocationId
	, @intToLocationId
	, @dtmTransferDate
	, @strDescription
	, @ysnShipmentRequired
	, @intTransferStatus
	, @intShipViaId
	, @intBrokerId
	, @dtmBOLDate
	, @dtmBOLReceiveDate
	, @strBOLNumber

WHILE @@FETCH_STATUS = 0 AND NOT EXISTS(SELECT * FROM @Logs)
BEGIN
	EXEC dbo.uspSMGetStartingNumber 41, @strStartingNumber OUTPUT, @intFromLocationId

	INSERT INTO tblICInventoryTransfer(
		  strTransferNo
		, intFromLocationId
		, intToLocationId
		, intSourceType
		, strDescription
		, strTransferType
		, dtmTransferDate
		, intStatusId
		, ysnShipmentRequired
		, intShipViaId
		, intBrokerId
		, strBolNumber
		, dtmBolDate
		, dtmBolReceivedDate
		, dtmCreated
		, dtmDateCreated
		, intConcurrencyId
		, guiApiUniqueId)
	SELECT
		  @strStartingNumber
		, @intFromLocationId
		, @intToLocationId
		, 0
		, @strDescription
		, 'Location to Location'
		, @dtmTransferDate
		, @intTransferStatus
		, @ysnShipmentRequired
		, @intShipViaId
		, @intBrokerId
		, @strBOLNumber
		, @dtmBOLDate
		, @dtmBOLReceiveDate
		, GETUTCDATE()
		, GETUTCDATE()
		, 1
		, @guiApiUniqueId

	SET @intInventorTransferId = SCOPE_IDENTITY()

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'The itemId/itemNo is required.', td.intItemId, 'itemId/itemNo', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	WHERE td.intApiInventoryTransferStagingId = @intApiInventoryTransferStagingId
		AND td.intItemId IS NULL
		AND NULLIF(td.strItemNo, '') IS NULL

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'Can''t find the itemId: ''' + CAST(td.intItemId AS NVARCHAR(50)) + '''', td.intItemId, 'itemId', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	LEFT JOIN tblICItem item ON item.intItemId = td.intItemId
	WHERE td.intApiInventoryTransferStagingId = @intApiInventoryTransferStagingId
		AND item.intItemId IS NULL
		AND td.intItemId IS NOT NULL

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'Can''t find the itemNo: ''' + CAST(td.strItemNo AS NVARCHAR(50)) + '''', td.strItemNo, 'itemNo', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	LEFT JOIN tblICItem item ON item.strItemNo = td.strItemNo
	WHERE td.intApiInventoryTransferStagingId = @intApiInventoryTransferStagingId
		AND item.intItemId IS NULL
		AND td.strItemNo IS NOT NULL
		AND td.intItemId IS NULL

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'The item with an itemId of ''' + CAST(td.intItemId AS NVARCHAR(50)) + ''' is not active.', td.intItemId, 'itemId', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	LEFT JOIN tblICItem item ON item.intItemId = td.intItemId
	WHERE td.intApiInventoryTransferStagingId = @intApiInventoryTransferStagingId
		AND item.strStatus != 'Active'
		AND item.intItemId IS NOT NULL
		AND td.intItemId IS NOT NULL

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'The item with an itemId of ''' + CAST(td.intItemId AS NVARCHAR(50)) + ''' is not active.', td.intItemId, 'itemId', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	LEFT JOIN tblICItem item ON item.strItemNo = td.strItemNo
	WHERE td.intApiInventoryTransferStagingId = @intApiInventoryTransferStagingId
		AND item.strStatus != 'Active'
		AND item.intItemId IS NOT NULL
		AND td.intItemId IS NULL

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'The item ''' + item.strItemNo + ''' with itemId ''' + ISNULL(CAST(td.intItemId AS NVARCHAR(50)), '') + ''' was not set up for the location ''' + c.strLocationName + ''' with fromLocationId ''' +
		CAST(@intFromLocationId AS nvarchar(50)) + '''', td.intItemId, 'itemId', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	LEFT JOIN tblICItem item ON item.intItemId = td.intItemId
	LEFT JOIN tblICItemLocation il ON il.intItemId = item.intItemId
		AND il.intLocationId = @intFromLocationId
	LEFT JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = @intFromLocationId
	WHERE td.intApiInventoryTransferStagingId = @intApiInventoryTransferStagingId
		AND item.intItemId IS NOT NULL
		AND c.intCompanyLocationId IS NOT NULL
		AND il.intItemLocationId IS NULL
		AND td.intItemId IS NOT NULL
	
	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'The item ''' + td.strItemNo + ''' with strItemNo ''' + ISNULL(CAST(item.intItemId AS NVARCHAR(50)), '') + ''' was not set up for the location ''' + c.strLocationName + ''' with fromLocationId ''' +
		CAST(@intFromLocationId AS nvarchar(50)) + '''', td.strItemNo, 'itemNo', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	LEFT JOIN tblICItem item ON item.strItemNo = td.strItemNo
	LEFT JOIN tblICItemLocation il ON il.intItemId = item.intItemId
		AND il.intLocationId = @intFromLocationId
	LEFT JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = @intFromLocationId
	WHERE td.intApiInventoryTransferStagingId = @intApiInventoryTransferStagingId
		AND item.intItemId IS NOT NULL
		AND c.intCompanyLocationId IS NOT NULL
		AND il.intItemLocationId IS NULL
		AND td.intItemId IS NULL
		AND NULLIF(td.strItemNo, '') IS NOT NULL

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'Can''t find the uomId: ''' + ISNULL(CAST(td.intUOMId AS NVARCHAR(50)), '') + '''', td.intUOMId, 'uomId', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	LEFT JOIN tblICUnitMeasure u ON u.intUnitMeasureId = td.intUOMId
	WHERE u.intUnitMeasureId IS NULL
		AND td.intUOMId IS NOT NULL

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'The UOM ''' + u.strUnitMeasure + ''' with uomId: ''' + ISNULL(CAST(td.intUOMId AS nvarchar(50)), '') + ''' is not valid for the item ''' +
		item.strItemNo + ''' with itemId ''' + CAST(td.intItemId AS nvarchar(100)) + '''', td.intUOMId, 'uomId', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	LEFT JOIN tblICItem item ON item.intItemId = td.intItemId
	LEFT JOIN tblICUnitMeasure u ON u.intUnitMeasureId = td.intUOMId
	LEFT JOIN tblICItemUOM um ON um.intItemId = item.intItemId
		AND um.intUnitMeasureId = u.intUnitMeasureId
	WHERE td.intApiInventoryTransferStagingId = @intApiInventoryTransferStagingId
		AND td.intUOMId IS NOT NULL
		AND u.intUnitMeasureId IS NOT NULL
		AND um.intItemUOMId IS NULL
		AND td.intItemId IS NOT NULL
		AND item.intItemId IS NOT NULL

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'The UOM ''' + u.strUnitMeasure + ''' with uomId: ''' + ISNULL(CAST(td.intUOMId AS nvarchar(50)), '') + ''' is not valid for the item ''' +
		item.strItemNo + ''' with itemId ''' + CAST(item.intItemId AS nvarchar(100)) + '''', td.intUOMId, 'uomId', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	LEFT JOIN tblICItem item ON item.strItemNo = td.strItemNo
	LEFT JOIN tblICUnitMeasure u ON u.intUnitMeasureId = td.intUOMId
	LEFT JOIN tblICItemUOM um ON um.intItemId = item.intItemId
		AND um.intUnitMeasureId = u.intUnitMeasureId
	WHERE td.intApiInventoryTransferStagingId = @intApiInventoryTransferStagingId
		AND td.intUOMId IS NOT NULL
		AND u.intUnitMeasureId IS NOT NULL
		AND um.intItemUOMId IS NULL
		AND td.intItemId IS NULL
		AND ISNULL(td.strItemNo, '') IS NOT NULL
		AND item.intItemId IS NOT NULL

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'Can''t find the itemUOMId: ''' + ISNULL(CAST(td.intItemUOMId AS NVARCHAR(50)), '') + '''', td.intItemUOMId, 'itemUOMId', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	LEFT JOIN tblICItemUOM uom ON uom.intItemUOMId = td.intItemUOMId
	WHERE uom.intItemUOMId IS NULL
		AND td.intItemUOMId IS NOT NULL

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'The item UOM ''' + u.strUnitMeasure + ''' with itemUOMId: ''' + ISNULL(CAST(td.intItemUOMId AS nvarchar(50)), '') + ''' is not valid for the item ''' +
		item.strItemNo + ''' with itemId ''' + CAST(td.intItemId AS nvarchar(100)) + '''', td.intItemUOMId, 'itemUOMId', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	LEFT JOIN tblICItem item ON item.intItemId = td.intItemId
	LEFT JOIN tblICItemUOM uom1 ON uom1.intItemUOMId = td.intItemUOMId
	LEFT JOIN tblICItemUOM uom ON uom.intItemUOMId = td.intItemUOMId
		AND td.intItemId = uom.intItemId
	LEFT JOIN tblICUnitMeasure u ON u.intUnitMeasureId = uom1.intUnitMeasureId
	WHERE td.intApiInventoryTransferStagingId = @intApiInventoryTransferStagingId
		AND uom.intItemUOMId IS NULL
		AND uom1.intItemId IS NOT NULL
		AND item.intItemId IS NOT NULL
		AND td.intItemUOMId IS NOT NULL

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'grossUOMId was not specified', CAST(td.intGrossUOMId AS NVARCHAR(50)), 'grossUOMId', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	WHERE td.intApiInventoryTransferStagingId = @intApiInventoryTransferStagingId
		AND td.intGrossUOMId IS NULL
		AND td.dblGross > 0

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'Invalid grossUOMId: ''' + CAST(td.intGrossUOMId AS NVARCHAR(50)) + '''', td.intGrossUOMId, 'grossUOMId', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	LEFT JOIN tblICItemUOM uom ON uom.intItemUOMId = td.intGrossUOMId
	WHERE td.intApiInventoryTransferStagingId = @intApiInventoryTransferStagingId
		AND uom.intItemUOMId IS NULL
		AND td.intGrossUOMId IS NOT NULL

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'The gross UOM ''' + u.strUnitMeasure + ''' with grossUOMId: ''' + CAST(td.intGrossUOMId AS nvarchar(50)) + ''' is not valid for the item ''' +
		item.strItemNo + ''' with itemId ''' + CAST(td.intItemId AS nvarchar(100)) + '''', td.intGrossUOMId, 'grossUOMId', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	LEFT JOIN tblICItem item ON item.intItemId = td.intItemId
	LEFT JOIN tblICItemUOM uom1 ON uom1.intItemUOMId = td.intGrossUOMId
	LEFT JOIN tblICItemUOM uom ON uom.intItemUOMId = td.intGrossUOMId
		AND td.intItemId = uom.intItemId
	LEFT JOIN tblICUnitMeasure u ON u.intUnitMeasureId = uom1.intUnitMeasureId
	WHERE td.intApiInventoryTransferStagingId = @intApiInventoryTransferStagingId
		AND uom.intItemUOMId IS NULL
		AND uom1.intItemId IS NOT NULL
		AND td.intGrossUOMId IS NOT NULL

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'Cannot find the From Storage Location with fromStorageLocationId: ''' + CAST(td.intFromStorageLocationId AS NVARCHAR(50)) + '''', td.intFromStorageLocationId, 'fromStorageLocationId', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	LEFT JOIN tblSMCompanyLocationSubLocation sub ON sub.intCompanyLocationSubLocationId = td.intFromStorageLocationId
	WHERE td.intApiInventoryTransferStagingId = @intApiInventoryTransferStagingId
		AND td.intFromStorageLocationId IS NOT NULL
		AND sub.intCompanyLocationSubLocationId IS NULL

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'Cannot find the From Storage Unit with fromStorageUnitId: ''' + CAST(td.intFromStorageUnitId AS NVARCHAR(50)) + '''', td.intFromStorageUnitId, 'fromStorageUnitId', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = td.intFromStorageUnitId
	WHERE td.intApiInventoryTransferStagingId = @intApiInventoryTransferStagingId
		AND td.intFromStorageUnitId IS NOT NULL
		AND sl.intStorageLocationId IS NULL

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'Cannot find the To Storage Location with toStorageLocationId: ''' + CAST(td.intToStorageLocationId AS NVARCHAR(50)) + '''', td.intToStorageLocationId, 'toStorageLocationId', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	LEFT JOIN tblSMCompanyLocationSubLocation sub ON sub.intCompanyLocationSubLocationId = td.intToStorageLocationId
	WHERE td.intApiInventoryTransferStagingId = @intApiInventoryTransferStagingId
		AND td.intToStorageLocationId IS NOT NULL
		AND sub.intCompanyLocationSubLocationId IS NULL

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'Cannot find the To Storage Unit with toStorageUnitId: ''' + CAST(td.intToStorageUnitId AS NVARCHAR(50)) + '''', td.intToStorageUnitId, 'toStorageUnitId', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = td.intToStorageUnitId
	WHERE td.intApiInventoryTransferStagingId = @intApiInventoryTransferStagingId
		AND td.intToStorageUnitId IS NOT NULL
		AND sl.intStorageLocationId IS NULL

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'Invalid From Storage Location ''' + sub2.strSubLocationName + ''' with fromStorageLocationId ''' + CAST(td.intFromStorageLocationId AS nvarchar(100)) + '''. It''s not set up for the company location ''' + c.strLocationName + ''' with fromLocationId ''' + CAST(@intFromLocationId AS NVARCHAR(100)) + '''', td.intFromStorageLocationId, 'fromStorageLocationId', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	LEFT JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = @intFromLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation sub2 ON sub2.intCompanyLocationSubLocationId = td.intFromStorageLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation sub ON sub.intCompanyLocationSubLocationId = td.intFromStorageLocationId
		AND sub.intCompanyLocationId = @intFromLocationId
	WHERE sub2.intCompanyLocationSubLocationId IS NOT NULL
		AND sub.intCompanyLocationSubLocationId IS NULL
		AND td.intFromStorageLocationId IS NOT NULL

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'Invalid To Storage Location ''' + sub2.strSubLocationName + ''' with toStorageLocationId ''' + CAST(td.intToStorageLocationId AS nvarchar(100)) + '''. It''s not set up for the company location ''' + c.strLocationName + ''' with toLocationId ''' + CAST(@intToLocationId AS NVARCHAR(100)) + '''', td.intToStorageLocationId, 'toStorageLocationId', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	LEFT JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = @intToLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation sub2 ON sub2.intCompanyLocationSubLocationId = td.intToStorageLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation sub ON sub.intCompanyLocationSubLocationId = td.intToStorageLocationId
		AND sub.intCompanyLocationId = @intToLocationId
	WHERE sub2.intCompanyLocationSubLocationId IS NOT NULL
		AND sub.intCompanyLocationSubLocationId IS NULL
		AND td.intToStorageLocationId IS NOT NULL

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'Invalid From  Storage Unit ''' + sl2.strName + ''' with fromStorageUnitId ''' + CAST(td.intFromStorageUnitId AS nvarchar(100)) + '''. It''s not set up for the storage location ''' + sub.strSubLocationName + ''' with fromStorageLocationId ''' + CAST(sub.intCompanyLocationSubLocationId AS NVARCHAR(100)) + '''', td.intFromStorageUnitId, 'fromStorageUnitId', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	LEFT JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = @intFromLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation sub ON sub.intCompanyLocationSubLocationId = td.intFromStorageLocationId
		AND sub.intCompanyLocationId = @intFromLocationId
	LEFT JOIN tblICStorageLocation sl2 ON sl2.intStorageLocationId = td.intFromStorageUnitId
	LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = td.intFromStorageUnitId
		AND sl.intSubLocationId = sub.intCompanyLocationSubLocationId
	WHERE sl2.intStorageLocationId IS NOT NULL
		AND sl.intStorageLocationId IS NULL
		AND td.intFromStorageUnitId IS NOT NULL

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'Invalid To Storage Unit ''' + sl2.strName + ''' with toStorageUnitId ''' + CAST(td.intToStorageLocationId AS nvarchar(100)) + '''. It''s not set up for the storage location ''' + sub.strSubLocationName + ''' with toStorageLocationId ''' + CAST(sub.intCompanyLocationSubLocationId AS NVARCHAR(100)) + '''', td.intToStorageUnitId, 'toStorageUnitId', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	LEFT JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = @intToLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation sub ON sub.intCompanyLocationSubLocationId = td.intToStorageLocationId
		AND sub.intCompanyLocationId = @intToLocationId
	LEFT JOIN tblICStorageLocation sl2 ON sl2.intStorageLocationId = td.intToStorageUnitId
	LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = td.intToStorageUnitId
		AND sl.intSubLocationId = sub.intCompanyLocationSubLocationId
	WHERE sl2.intStorageLocationId IS NOT NULL
		AND sl.intStorageLocationId IS NULL
		AND td.intToStorageLocationId IS NOT NULL

	INSERT INTO @Logs(strError, strValue, strField, strLogLevel)
	SELECT 'Invalid lotId.', td.intLotId, 'lotId', 'Error'
	FROM tblApiInventoryTransferDetailStaging td
	OUTER APPLY (
		SELECT l.intLotId
		FROM tblICLot l
		INNER JOIN tblSMCompanyLocationSubLocation sub ON sub.intCompanyLocationSubLocationId = td.intFromStorageLocationId
		INNER JOIN tblICStorageLocation sl ON sl.intSubLocationId = sub.intCompanyLocationSubLocationId
			AND sl.intStorageLocationId = td.intFromStorageUnitId
		WHERE l.intLotId = td.intLotId
			AND l.intStorageLocationId = sl.intStorageLocationId
			AND l.intSubLocationId = sub.intCompanyLocationSubLocationId
	) lot
	WHERE td.intApiInventoryTransferStagingId = @intApiInventoryTransferStagingId
		AND td.intLotId IS NOT NULL
		AND lot.intLotId IS NULL
		
	IF NOT EXISTS(SELECT * FROM @Logs)
	BEGIN
		INSERT INTO tblICInventoryTransferDetail (
			intInventoryTransferId
			, intItemId
			, intItemUOMId
			, dblQuantity
			, intOwnershipType
			, intFromSubLocationId
			, intToSubLocationId
			, intFromStorageLocationId
			, intToStorageLocationId
			, intLotId
			, strNewLotId
			, ysnWeighed
			, dblGross
			, intGrossNetUOMId
			, dblTare
			, dblStandardWeight
			, intNewLotStatusId
			, strLotCondition
			, strComment
			, dblCost
			, dblOriginalAvailableQty
			, intConcurrencyId
		)
		SELECT
			@intInventorTransferId
			, COALESCE(i.intItemId, alternativeItem.intItemId)
			, COALESCE(td.intItemUOMId, alternativeUom.intItemUOMId)
			, td.dblTransferQty
			, td.intOwnershipType
			, td.intFromStorageLocationId
			, td.intToStorageLocationId
			, td.intFromStorageUnitId
			, td.intToStorageUnitId
			, td.intLotId
			, td.strNewLotNo
			, td.ysnWeighed
			, td.dblGross
			, td.intGrossUOMId
			, td.dblTare
			, td.dblStandardWeight
			, s.intLotStatusId
			, td.strLotCondition
			, td.strComment
			, COALESCE(dbo.fnICGetItemRunningCost(
				td.intItemId
				, @intFromLocationId
				, NULLIF(td.intLotId, 0)
				, NULLIF(td.intFromStorageLocationId, 0)
				, NULLIF(td.intFromStorageUnitId, 0)
				, cm.intCommodityId
				, ct.intCategoryId
				, @dtmTransferDate
				, 1), p.dblLastCost, p.dblStandardCost)
			, CASE WHEN td.intLotId IS NULL THEN dbo.fnCalculateQtyBetweenUOM(stockUOM.intItemUOMId, td.intItemUOMId, dbo.fnICGetItemRunningStockQty(
				  td.intItemId
				, @intFromLocationId
				, NULLIF(td.intLotId, 0)
				, NULLIF(td.intFromStorageLocationId, 0)
				, NULLIF(td.intFromStorageUnitId, 0)
				, cm.intCommodityId
				, ct.intCategoryId
				, @dtmTransferDate
				, 1)
			) ELSE lotQty.dblRunningAvailableQty END
			, 1
		FROM tblApiInventoryTransferDetailStaging td
		LEFT JOIN tblICLotStatus s ON s.strPrimaryStatus = td.strNewLotStatus
		LEFT JOIN tblICItem i ON i.intItemId = td.intItemId
		OUTER APPLY (
			SELECT TOP 1 intItemId
			FROM tblICItem
			WHERE strItemNo = td.strItemNo
		) alternativeItem
		LEFT JOIN tblICCategory ct ON ct.intCategoryId = i.intCategoryId
		LEFT JOIN tblICCommodity cm ON cm.intCommodityId = i.intCommodityId
		OUTER APPLY (
			SELECT TOP 1 x2.intItemUOMId
			FROM tblICUnitMeasure x1
			JOIN tblICItemUOM x2 ON x2.intItemId = COALESCE(i.intItemId, alternativeItem.intItemId)
				AND x2.intUnitMeasureId = x1.intUnitMeasureId
			WHERE x1.intUnitMeasureId = td.intUOMId
		) alternativeUom
		LEFT JOIN tblICItemLocation il ON il.intItemId = i.intItemId
			AND il.intLocationId = @intFromLocationId
		LEFT JOIN tblICItemPricing p ON p.intItemId = i.intItemId
			AND p.intItemLocationId = il.intItemLocationId
		OUTER APPLY (
			SELECT TOP 1 intItemUOMId
			FROM tblICItemUOM sm 
			WHERE sm.intItemId = i.intItemId
			AND sm.ysnStockUnit = 1
		) stockUOM
		OUTER APPLY (
			SELECT TOP 1 * 
			FROM dbo.fnICGetItemRunningStockLotQty (
				  td.intItemId
				, @intFromLocationId
				, NULLIF(td.intFromStorageLocationId, 0)
				, NULLIF(td.intFromStorageUnitId, 0)
				, @dtmTransferDate
				, td.intLotId
				, NULL
				, 1
				, 0
			)
		) lotQty
		WHERE td.intApiInventoryTransferStagingId = @intApiInventoryTransferStagingId

		INSERT INTO tblICInventoryTransferCondition (intInventoryTransferId, strName, strDescription, dtmDateCreated, intConcurrencyId)
		SELECT @intInventorTransferId, c.strConditionName, c.strConditionDesc, GETUTCDATE(), 1
		FROM tblCTCondition c
		WHERE c.strType = 'Inventory Transfer'

		DELETE t
		FROM tblICInventoryTransfer t
		WHERE NOT EXISTS(
			SELECT TOP 1 1
			FROM tblICInventoryTransferDetail td
			WHERE td.intInventoryTransferId = t.intInventoryTransferId
		)
			AND t.intInventoryTransferId = @intInventorTransferId

		IF @ysnAutoPost = 1
		BEGIN
			DECLARE @strTransferNo NVARCHAR(50)
			DECLARE @strBatchId NVARCHAR(40)

			SELECT @strTransferNo = strTransferNo 
			FROM tblICInventoryTransfer 
			WHERE intInventoryTransferId = @intInventorTransferId

			IF @strTransferNo IS NOT NULL
			BEGIN
				EXEC dbo.uspApiPostTransferTransaction @strTransferNo, 1, 0, 1, @strBatchId OUTPUT
			END
		END
	END

	FETCH NEXT FROM cur INTO
		  @intApiInventoryTransferStagingId
		, @intFromLocationId
		, @intToLocationId
		, @dtmTransferDate
		, @strDescription
		, @ysnShipmentRequired
		, @intTransferStatus
		, @intShipViaId
		, @intBrokerId
		, @dtmBOLDate
		, @dtmBOLReceiveDate
		, @strBOLNumber
END

Logging:

INSERT INTO @Logs (intLineNumber, dblTotalAmount, strLogLevel, strField)
SELECT t.intInventoryTransferId, SUM(ISNULL(ti.dblQuantity, 0) * ISNULL(ti.dblCost, 1)), 'Ids', t.strTransferNo
FROM tblICInventoryTransfer t
LEFT JOIN tblICInventoryTransferDetail ti ON ti.intInventoryTransferId = t.intInventoryTransferId
WHERE t.guiApiUniqueId = @guiApiUniqueId
GROUP BY t.intInventoryTransferId, t.strTransferNo

INSERT INTO tblApiRESTErrorLog(guiApiUniqueId, strError, strField, strValue, intLineNumber, dblTotalAmount, intLinePosition, strLogLevel)
SELECT @guiApiUniqueId, strError, strField, strValue, intLineNumber, dblTotalAmount, intLinePosition, strLogLevel FROM @Logs

DELETE FROM tblApiInventoryTransferStaging WHERE guiApiUniqueId = @guiApiUniqueId

SELECT * FROM @Logs
