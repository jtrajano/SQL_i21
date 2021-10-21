CREATE PROCEDURE [dbo].[uspApiImportInventoryAdjustmentsFromStaging]
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@intUserId INT = 1
AS
BEGIN

DECLARE @Logs TABLE (strError NVARCHAR(500), strField NVARCHAR(100), strValue NVARCHAR(500), intLineNumber INT NULL, dblTotalAmount NUMERIC(18, 6), intLinePosition INT NULL, strLogLevel NVARCHAR(50))

-- Log required company locations
INSERT INTO @Logs(strLogLevel, strField, strValue, strError)
SELECT
	  strLogLevel = 'Error'
	, strField = 'locationId|location'
	, strValue = NULL
	, strError = 'A company location is required.'
FROM tblICStagingAdjustment a
WHERE a.guiApiUniqueId = @guiApiUniqueId
	AND a.intLocationId IS NULL AND a.strLocationName IS NULL

-- Log Invalid company locations
INSERT INTO @Logs(strLogLevel, strField, strValue, strError)
SELECT
	  strLogLevel = 'Error'
	, strField = 'locationId'
	, strValue = CAST(a.intLocationId AS nvarchar(50))
	, strError = 'Invalid locationId. The locationId does not exist.'
FROM tblICStagingAdjustment a
LEFT JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = a.intLocationId
WHERE a.guiApiUniqueId = @guiApiUniqueId
	AND c.intCompanyLocationId IS NULL
	AND a.intLocationId IS NOT NULL

INSERT INTO @Logs(strLogLevel, strField, strValue, strError)
SELECT
	  strLogLevel = 'Error'
	, strField = 'location'
	, strValue = a.strLocationName
	, strError = 'Invalid location. "' + a.strLocationName + '" does not exist.'
FROM tblICStagingAdjustment a
LEFT JOIN tblSMCompanyLocation c ON c.strLocationNumber = a.strLocationName OR c.strLocationName = a.strLocationName
WHERE a.guiApiUniqueId = @guiApiUniqueId
	AND c.intCompanyLocationId IS NULL
	AND a.strLocationName IS NOT NULL
	AND a.intLocationId IS NULL

-- Log required items
INSERT INTO @Logs(strLogLevel, strField, strValue, strError)
SELECT
	  strLogLevel = 'Error'
	, strField = 'itemId|itemNo'
	, strValue = NULL
	, strError = 'An item is required.'
FROM tblICStagingAdjustmentDetail d
JOIN tblICStagingAdjustment a ON a.intStagingAdjustmentId = d.intAdjustmentId
WHERE a.guiApiUniqueId = @guiApiUniqueId
	AND d.intItemId IS NULL AND d.strItemNo IS NULL

-- Log invalid items
INSERT INTO @Logs(strLogLevel, strField, strValue, strError)
SELECT
	  strLogLevel = 'Error'
	, strField = 'itemId'
	, strValue = CAST(d.intItemId AS nvarchar(50))
	, strError = 'Invalid itemId. The itemId does not exist.'
FROM tblICStagingAdjustmentDetail d
JOIN tblICStagingAdjustment a ON a.intStagingAdjustmentId = d.intAdjustmentId
LEFT JOIN tblICItem i ON i.intItemId = d.intItemId
WHERE a.guiApiUniqueId = @guiApiUniqueId
	AND d.intItemId IS NOT NULL
	AND i.intItemId IS NULL

INSERT INTO @Logs(strLogLevel, strField, strValue, strError)
SELECT
	  strLogLevel = 'Error'
	, strField = 'itemNo'
	, strValue = d.strItemNo
	, strError = 'Invalid itemNo. "' + d.strItemNo + '" does not exist.'
FROM tblICStagingAdjustmentDetail d
JOIN tblICStagingAdjustment a ON a.intStagingAdjustmentId = d.intAdjustmentId
LEFT JOIN tblICItem i ON i.strItemNo = d.strItemNo
WHERE a.guiApiUniqueId = @guiApiUniqueId
	AND d.strItemNo IS NOT NULL
	AND d.intItemId IS NULL
	AND i.intItemId IS NULL

-- Invalid item locations
INSERT INTO @Logs(strLogLevel, strField, strValue, strError)
SELECT
	  strLogLevel = 'Error'
	, strField = 'itemId'
	, strValue = CAST(d.intItemId AS nvarchar(50))
	, strError = 'The itemId is not valid for the location "' + c.strLocationName + '" with a locationId of "' + CAST(c.intCompanyLocationId AS nvarchar(50)) + '".'
FROM tblICStagingAdjustmentDetail d
JOIN tblICStagingAdjustment a ON a.intStagingAdjustmentId = d.intAdjustmentId
JOIN tblSMCompanyLocation c ON c.strLocationNumber = a.strLocationName OR c.strLocationName = a.strLocationName OR c.intCompanyLocationId = a.intLocationId
JOIN tblICItem i ON i.intItemId = d.intItemId OR i.strItemNo = d.strItemNo
LEFT JOIN tblICItemLocation il ON il.intLocationId = c.intCompanyLocationId
	AND il.intItemId = i.intItemId
WHERE a.guiApiUniqueId = @guiApiUniqueId
	AND d.intItemId IS NOT NULL
	AND il.intItemLocationId IS NULL

INSERT INTO @Logs(strLogLevel, strField, strValue, strError)
SELECT
	  strLogLevel = 'Error'
	, strField = 'itemNo'
	, strValue = d.strItemNo
	, strError = 'The itemNo is not valid for the location "' + c.strLocationName + '" with a locationId of "' + CAST(c.intCompanyLocationId AS nvarchar(50)) + '".'
FROM tblICStagingAdjustmentDetail d
JOIN tblICStagingAdjustment a ON a.intStagingAdjustmentId = d.intAdjustmentId
JOIN tblSMCompanyLocation c ON c.strLocationNumber = a.strLocationName OR c.strLocationName = a.strLocationName OR c.intCompanyLocationId = a.intLocationId
JOIN tblICItem i ON i.intItemId = d.intItemId OR i.strItemNo = d.strItemNo
LEFT JOIN tblICItemLocation il ON il.intLocationId = c.intCompanyLocationId
	AND il.intItemId = i.intItemId
WHERE a.guiApiUniqueId = @guiApiUniqueId
	AND d.intItemId IS NULL
	AND d.strItemNo IS NOT NULL
	AND il.intItemLocationId IS NULL

-- UOMS
INSERT INTO @Logs(strLogLevel, strField, strValue, strError)
SELECT
	  strLogLevel = 'Error'
	, strField = 'uom'
	, strValue = d.strUom
	, strError = 'Invalid uom. "' + d.strUom + '" does not exist.'
FROM tblICStagingAdjustmentDetail d
JOIN tblICStagingAdjustment a ON a.intStagingAdjustmentId = d.intAdjustmentId
LEFT JOIN tblICUnitMeasure u ON u.strUnitMeasure = d.strUom
WHERE a.guiApiUniqueId = @guiApiUniqueId
	AND d.strUom IS NOT NULL
	AND d.intUomId IS NULL
	AND d.intItemUOMId IS NULL
	AND u.intUnitMeasureId IS NULL

INSERT INTO @Logs(strLogLevel, strField, strValue, strError)
SELECT
	  strLogLevel = 'Error'
	, strField = 'uomId'
	, strValue = CAST(d.intUomId AS nvarchar(50))
	, strError = 'Invalid uomId. "' + CAST(d.intUomId AS nvarchar(50)) + '" does not exist.'
FROM tblICStagingAdjustmentDetail d
JOIN tblICStagingAdjustment a ON a.intStagingAdjustmentId = d.intAdjustmentId
LEFT JOIN tblICUnitMeasure u ON u.intUnitMeasureId = d.intUomId
WHERE a.guiApiUniqueId = @guiApiUniqueId
	AND d.intUomId IS NOT NULL
	AND d.intItemUOMId IS NULL
	AND u.intUnitMeasureId IS NULL

INSERT INTO @Logs(strLogLevel, strField, strValue, strError)
SELECT
	  strLogLevel = 'Error'
	, strField = 'itemUOMId'
	, strValue = CAST(d.intItemUOMId AS nvarchar(50))
	, strError = 'Invalid itemUOMId. "' + CAST(d.intItemUOMId AS nvarchar(50)) + '" does not exist.'
FROM tblICStagingAdjustmentDetail d
JOIN tblICStagingAdjustment a ON a.intStagingAdjustmentId = d.intAdjustmentId
LEFT JOIN tblICItemUOM m ON m.intItemUOMId = d.intItemUOMId
WHERE a.guiApiUniqueId = @guiApiUniqueId
	AND d.intItemUOMId IS NOT NULL
	AND m.intItemUOMId IS NULL

-- Validate item UOMs
INSERT INTO @Logs(strLogLevel, strField, strValue, strError)
SELECT
	  strLogLevel = 'Error'
	, strField = 'itemUOMId'
	, strValue = CAST(d.intItemUOMId AS nvarchar(50))
	, strError = 'The itemUOMId is not valid for the item "' + CAST(i.strItemNo AS nvarchar(50)) + '" with an itemId of "' + CAST(i.intItemId AS nvarchar(50)) + '".'
FROM tblICStagingAdjustmentDetail d
JOIN tblICStagingAdjustment a ON a.intStagingAdjustmentId = d.intAdjustmentId
JOIN tblICItem i ON i.intItemId = d.intItemId OR i.strItemNo = d.strItemNo
JOIN tblICItemUOM mm ON mm.intItemUOMId = d.intItemUOMId
LEFT JOIN tblICItemUOM m ON m.intItemUOMId = d.intItemUOMId
	AND m.intItemId = i.intItemId
WHERE a.guiApiUniqueId = @guiApiUniqueId
	AND d.intItemUOMId IS NOT NULL
	AND m.intItemUOMId IS NULL

INSERT INTO @Logs(strLogLevel, strField, strValue, strError)
SELECT
	  strLogLevel = 'Error'
	, strField = 'uomId'
	, strValue = CAST(d.intUomId AS nvarchar(50))
	, strError = 'The uomId is not valid for the item "' + CAST(i.strItemNo AS nvarchar(50)) + '" with an itemId of "' + CAST(i.intItemId AS nvarchar(50)) + '".'
FROM tblICStagingAdjustmentDetail d
JOIN tblICStagingAdjustment a ON a.intStagingAdjustmentId = d.intAdjustmentId
JOIN tblICItem i ON i.intItemId = d.intItemId OR i.strItemNo = d.strItemNo
JOIN tblICUnitMeasure u ON u.intUnitMeasureId = d.intUomId
LEFT JOIN tblICUnitMeasure m ON m.intUnitMeasureId = d.intUomId
LEFT JOIN tblICItemUOM mm ON mm.intUnitMeasureId = m.intUnitMeasureId
	AND mm.intItemId = i.intItemId
WHERE a.guiApiUniqueId = @guiApiUniqueId
	AND d.intItemUOMId IS NULL
	AND d.intUomId IS NOT NULL
	AND mm.intItemUOMId IS NULL

INSERT INTO @Logs(strLogLevel, strField, strValue, strError)
SELECT
	  strLogLevel = 'Error'
	, strField = 'uom'
	, strValue = d.strUom
	, strError = 'The uom is not valid for the item "' + CAST(i.strItemNo AS nvarchar(50)) + '" with an itemId of "' + CAST(i.intItemId AS nvarchar(50)) + '".'
FROM tblICStagingAdjustmentDetail d
JOIN tblICStagingAdjustment a ON a.intStagingAdjustmentId = d.intAdjustmentId
JOIN tblICItem i ON i.intItemId = d.intItemId OR i.strItemNo = d.strItemNo
JOIN tblICUnitMeasure u ON u.strUnitMeasure = d.strUom
LEFT JOIN tblICUnitMeasure m ON m.strUnitMeasure = d.strUom
LEFT JOIN tblICItemUOM mm ON mm.intUnitMeasureId = m.intUnitMeasureId
	AND mm.intItemId = i.intItemId
WHERE a.guiApiUniqueId = @guiApiUniqueId
	AND d.intItemUOMId IS NULL
	AND d.intUomId IS NULL
	AND d.strUom IS NOT NULL
	AND mm.intItemUOMId IS NULL

-- Validate based on adjustment type
INSERT INTO @Logs(strLogLevel, strField, strValue, strError)
SELECT
	  strLogLevel = 'Error'
	, strField = CASE WHEN d.intItemUOMId IS NOT NULL THEN 'itemUOMId' ELSE CASE WHEN d.intUomId IS NOT NULL THEN 'uomId' ELSE 'uom' END END
	, strValue = NULL
	, strError = 'A unit of measure is required when the adjustment type is "Quantity".'
FROM tblICStagingAdjustmentDetail d
JOIN tblICStagingAdjustment a ON a.intStagingAdjustmentId = d.intAdjustmentId
WHERE a.guiApiUniqueId = @guiApiUniqueId
	AND d.intItemUOMId IS NULL AND d.intUomId IS NULL AND d.strUom IS NULL
	AND a.intAdjustmentType = 1

-- INSERT INTO @Logs(strLogLevel, strField, strValue, strError)
-- SELECT TOP 1
-- 	  strLogLevel = 'Error'
-- 	, strField = CASE WHEN d.intItemUOMId IS NOT NULL THEN 'itemUOMId'
-- 		ELSE CASE WHEN d.intUomId IS NOT NULL THEN 'uomId' ELSE 'uom' END END
-- 	, strValue = CASE WHEN d.intItemUOMId IS NOT NULL THEN CAST(d.intItemUOMId AS nvarchar(50))
-- 		ELSE CASE WHEN d.intUomId IS NOT NULL THEN CAST(d.intUomId AS NVARCHAR(50)) ELSE d.strUom END END
-- 	, strError = 'The "' + uom.strUnitMeasure + '" is not available for adjusting the quantity of the item "' + uom.strItemNo  + '".'
-- FROM tblICStagingAdjustmentDetail d
-- JOIN tblICStagingAdjustment a ON a.intStagingAdjustmentId = d.intAdjustmentId
-- OUTER APPLY (
-- 	SELECT TOP 1 COALESCE(a1.intItemUOMId, a2.intItemUOMId, a3.intItemUOMId) intItemUOMId
-- 		, COALESCE(aa1.strUnitMeasure, a2.strUnitMeasure, a3.strUnitMeasure) strUnitMeasure
-- 		, COALESCE(aa1.intUnitMeasureId, a2.intUnitMeasureId, a3.intUnitMeasureId) intUnitMeasureId
-- 		, i.strItemNo
-- 	FROM tblICItem i
-- 	LEFT JOIN tblICItemUOM a1 ON a1.intItemUOMId = d.intItemUOMId
-- 	LEFT JOIN tblICUnitMeasure aa1 ON aa1.intUnitMeasureId = a1.intUnitMeasureId
-- 	OUTER APPLY (
-- 		SELECT TOP 1 b1.strUnitMeasure, b1.intUnitMeasureId, bb1.intItemUOMId
-- 		FROM tblICUnitMeasure b1
-- 		JOIN tblICItemUOM bb1 ON bb1.intUnitMeasureId = b1.intUnitMeasureId
-- 			AND bb1.intItemId = i.intItemId
-- 		WHERE b1.intUnitMeasureId = d.intUomId
-- 	) a2
-- 	OUTER APPLY (
-- 		SELECT TOP 1 c1.strUnitMeasure, c1.intUnitMeasureId, cc1.intItemUOMId
-- 		FROM tblICUnitMeasure c1
-- 		LEFT JOIN tblICItemUOM cc1 ON cc1.intUnitMeasureId = c1.intUnitMeasureId
-- 			AND cc1.intItemId = i.intItemId
-- 		WHERE c1.strUnitMeasure = d.strUom
-- 	) a3
-- 	WHERE i.intItemId = d.intItemId OR i.strItemNo = d.strItemNo
-- ) uom
-- OUTER APPLY (
-- 	SELECT *
-- 	FROM dbo.fnICGetItemUOMFromRunningStock(d.intItemId
-- 		, a.intLocationId
-- 		, NULL
-- 		, NULL
-- 		, a.dtmDate
-- 		, d.intOwnershipType
-- 	)
-- 	WHERE intItemUOMId = uom.intItemUOMId
-- ) balance
-- WHERE a.guiApiUniqueId = @guiApiUniqueId
-- 	AND a.intAdjustmentType = 1
-- 	AND uom.strItemNo IS NOT NULL
-- 	AND balance.intItemUOMId IS NULL

---- END OF Validation

IF EXISTS(SELECT * FROM @Logs)
	GOTO _Exit

DECLARE @Adjustments TABLE(strAdjustmentNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, intLocationId INT, intAdjustmentType INT, dtmAdjustmentDate DATETIME, 
	strDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strIntegrationDocNo] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL)
INSERT INTO @Adjustments(strAdjustmentNo, intLocationId, intAdjustmentType, dtmAdjustmentDate, strDescription, strIntegrationDocNo)
SELECT a.strAdjustmentNo, c.intCompanyLocationId, a.intAdjustmentType, a.dtmDate, a.strDescription, a.strIntegrationDocNo
FROM tblICStagingAdjustment a
CROSS APPLY (
	SELECT TOP 1 ic.intCompanyLocationId
	FROM tblSMCompanyLocation ic
	WHERE (a.intLocationId = ic.intCompanyLocationId) OR
		((ic.strLocationNumber = a.strLocationName OR ic.strLocationName = a.strLocationName) AND a.intLocationId IS NULL)
) c
WHERE a.guiApiUniqueId = @guiApiUniqueId

DECLARE @intLocationId INT
DECLARE @intAdjustmentType INT
DECLARE @dtmAdjustmentDate DATETIME
DECLARE @strDescription NVARCHAR(200)
DECLARE @strAdjustmentNo NVARCHAR(200)
DECLARE @strTempAdjustmentNo NVARCHAR(200)
DECLARE @strIntegrationDocNo NVARCHAR(200)
DECLARE @intAdjustmentId INT

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
SELECT strAdjustmentNo, intLocationId, intAdjustmentType, dtmAdjustmentDate, strDescription, strIntegrationDocNo FROM @Adjustments

OPEN cur

FETCH NEXT FROM cur INTO @strTempAdjustmentNo, @intLocationId, @intAdjustmentType, @dtmAdjustmentDate, @strDescription, @strIntegrationDocNo

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC dbo.uspSMGetStartingNumber 30, @strAdjustmentNo OUTPUT, @intLocationId
	
	INSERT INTO tblICInventoryAdjustment(strAdjustmentNo, intLocationId, intAdjustmentType, dtmAdjustmentDate, strDescription, intCreatedByUserId, dtmDateCreated, strDataSource, strIntegrationDocNo, guiApiUniqueId)
	VALUES(@strTempAdjustmentNo, @intLocationId, @intAdjustmentType, @dtmAdjustmentDate, @strDescription, @intUserId, GETDATE(),  'JSON Import', @strIntegrationDocNo, @guiApiUniqueId)
	
	SET @intAdjustmentId = SCOPE_IDENTITY()

	INSERT INTO tblICInventoryAdjustmentDetail(intInventoryAdjustmentId, intItemId, intNewItemId, dblAdjustByQuantity, intLotId
		, intNewLotId, intSubLocationId, intStorageLocationId, dblNewQuantity, dblNewSplitLotQuantity, dblNewCost, dtmNewExpiryDate, intNewLocationId, intNewItemUOMId
		, intNewWeightUOMId, intItemUOMId, intNewSubLocationId, intNewStorageLocationId, intOwnershipType, dblQuantity, intCreatedByUserId, dtmDateCreated)
	SELECT @intAdjustmentId, item.intItemId, newItem.intItemId, 
		CASE WHEN sad.dblNewQuantity IS NOT NULL THEN sad.dblNewQuantity - ISNULL(balance.dblRunningAvailableQty, 0) ELSE sad.dblAdjustQtyBy END, 
		lot.intLotId, newLot.intLotId, sub.intCompanyLocationSubLocationId, su.intStorageLocationId
		, CASE WHEN sad.dblAdjustQtyBy IS NOT NULL 
			THEN ISNULL(balance.dblRunningAvailableQty, 0) + sad.dblAdjustQtyBy
			ELSE ISNULL(balance.dblRunningAvailableQty, 0)
			END, 
		sad.dblNewLotQty
		, COALESCE(sad.dblNewUnitCost, dbo.fnICGetItemRunningCost(item.intItemId, @intLocationId, lot.intLotId, sub.intCompanyLocationSubLocationId, su.intStorageLocationId, item.intCommodityId, item.intCategoryId, @dtmAdjustmentDate, 0), pricing.dblLastCost)
		, sad.dtmNewExpiryDate
		, newLoc.intCompanyLocationId, newItemUOM.intItemUOMId, newWeightUOM.intItemUOMId, itemUOM.intItemUOMId
		, newSub.intCompanyLocationSubLocationId, newSu.intStorageLocationId, ISNULL(sad.intOwnershipType,  1)
		, dbo.fnICGetItemRunningStockQty(item.intItemId, @intLocationId, lot.intLotId, sub.intCompanyLocationSubLocationId, su.intStorageLocationId, item.intCommodityId, item.intCategoryId, @dtmAdjustmentDate, 0)
		, @intUserId, GETDATE()
	FROM tblICStagingAdjustmentDetail sad
		CROSS APPLY (
			SELECT TOP 1 i.intItemId, i.intCommodityId, i.intCategoryId
			FROM tblICItem i 
			WHERE i.intItemId = sad.intItemId OR (i.strItemNo = sad.strItemNo)
		) item
		LEFT OUTER JOIN tblICItem newItem ON newItem.strItemNo = sad.strNewItemNo
		LEFT OUTER JOIN tblICLot lot ON lot.strLotNumber = sad.strLotNo AND lot.intItemId = item.intItemId
		LEFT OUTER JOIN tblICLot newLot ON newLot.strLotNumber = sad.strNewLotNo AND lot.intItemId = item.intItemId
		LEFT OUTER JOIN tblSMCompanyLocationSubLocation sub ON sub.strSubLocationName = sad.strStorageLocation
		LEFT OUTER JOIN tblICStorageLocation su ON su.strName = sad.strStorageUnit
		LEFT OUTER JOIN tblSMCompanyLocationSubLocation newSub ON newSub.strSubLocationName = sad.strNewStorageLocation
		LEFT OUTER JOIN tblICStorageLocation newSu ON newSu.strName = sad.strNewStorageUnit
		LEFT OUTER JOIN tblSMCompanyLocation newLoc ON newLoc.strLocationName = sad.strNewLocation
		LEFT OUTER JOIN tblICItemLocation il ON il.intItemId = item.intItemId AND il.intLocationId = @intLocationId
		LEFT OUTER JOIN tblICItemPricing pricing ON pricing.intItemId = item.intItemId AND pricing.intItemLocationId = il.intItemLocationId
		OUTER APPLY (
			SELECT TOP 1 COALESCE(a1.intItemUOMId, a2.intItemUOMId, a3.intItemUOMId) intItemUOMId
				, COALESCE(aa1.strUnitMeasure, a2.strUnitMeasure, a3.strUnitMeasure) strUnitMeasure
				, i.strItemNo
				, i.intItemId
			FROM tblICItem i
			LEFT JOIN tblICItemUOM a1 ON a1.intItemUOMId = sad.intItemUOMId
			LEFT JOIN tblICUnitMeasure aa1 ON aa1.intUnitMeasureId = a1.intUnitMeasureId
			OUTER APPLY (
				SELECT TOP 1 b1.strUnitMeasure, b1.intUnitMeasureId, bb1.intItemUOMId
				FROM tblICUnitMeasure b1
				JOIN tblICItemUOM bb1 ON bb1.intUnitMeasureId = b1.intUnitMeasureId
					AND bb1.intItemId = i.intItemId
				WHERE b1.intUnitMeasureId = sad.intUomId
			) a2
			OUTER APPLY (
				SELECT TOP 1 c1.strUnitMeasure, c1.intUnitMeasureId, cc1.intItemUOMId
				FROM tblICUnitMeasure c1
				JOIN tblICItemUOM cc1 ON cc1.intUnitMeasureId = c1.intUnitMeasureId
					AND cc1.intItemId = i.intItemId
				WHERE c1.strUnitMeasure = sad.strUom
			) a3
			WHERE i.intItemId = sad.intItemId OR i.strItemNo = sad.strItemNo
		) itemUOM
		LEFT OUTER JOIN vyuICItemUOM newItemUOM ON (newItemUOM.intItemUOMId = sad.intNewItemUOMId OR newItemUOM.strUnitMeasure = sad.strNewUom) AND itemUOM.intItemId = item.intItemId
		LEFT OUTER JOIN vyuICItemUOM newWeightUOM ON (newWeightUOM.intItemUOMId = sad.intNewWeightUomId OR newWeightUOM.strUnitMeasure = sad.strNewWeightUom) AND itemUOM.intItemId = item.intItemId
		OUTER APPLY (
			SELECT *
			FROM dbo.fnICGetItemUOMFromRunningStock(
				  itemUOM.intItemId
				, @intLocationId
				, NULL
				, NULL
				, @dtmAdjustmentDate
				, ISNULL(sad.intOwnershipType, 1)
			)
			WHERE intItemUOMId = itemUOM.intItemUOMId
		) balance
	WHERE sad.strAdjustmentNo = @strTempAdjustmentNo

	UPDATE tblICInventoryAdjustment
	SET strAdjustmentNo = @strAdjustmentNo, guiApiUniqueId = @guiApiUniqueId
	WHERE intInventoryAdjustmentId = @intAdjustmentId

	IF (NOT EXISTS(SELECT TOP 1 1 FROM tblICInventoryAdjustmentDetail WHERE intInventoryAdjustmentId = @intAdjustmentId))
		DELETE FROM tblICInventoryAdjustment WHERE intInventoryAdjustmentId = @intAdjustmentId

	FETCH NEXT FROM cur INTO @strTempAdjustmentNo, @intLocationId, @intAdjustmentType, @dtmAdjustmentDate, @strDescription, @strIntegrationDocNo
END

CLOSE cur
DEALLOCATE cur

_Exit:

---- Cleanup staging
DELETE d
FROM tblICStagingAdjustmentDetail d
JOIN tblICStagingAdjustment a ON a.intStagingAdjustmentId = d.intAdjustmentId
WHERE a.guiApiUniqueId = @guiApiUniqueId

DELETE FROM tblICStagingAdjustment WHERE guiApiUniqueId = @guiApiUniqueId

SELECT * FROM @Logs

END