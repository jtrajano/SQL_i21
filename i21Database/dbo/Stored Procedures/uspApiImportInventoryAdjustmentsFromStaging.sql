CREATE PROCEDURE [dbo].[uspApiImportInventoryAdjustmentsFromStaging]
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@intUserId INT = 1
AS
BEGIN

DECLARE @Logs TABLE (strError NVARCHAR(500), strField NVARCHAR(100), strValue NVARCHAR(500), intLineNumber INT NULL, dblTotalAmount NUMERIC(18, 6), intLinePosition INT NULL, strLogLevel NVARCHAR(50))

-- Log Invalid company locations
INSERT INTO @Logs(strError, strValue, strField, intLineNumber, intLinePosition, strLogLevel)
SELECT 'The location/locationId is required.' strError, null strValue, 'location/locationId' strField, a.LineNumber, a.LinePosition, 'Error'
FROM tblICStagingAdjustment a
WHERE a.intLocationId IS NULL AND NULLIF(a.strLocationName, '') IS NULL

INSERT INTO @Logs(strError, strValue, strField, intLineNumber, intLinePosition, strLogLevel)
SELECT 'The location "' + a.strLocationName + '" does not exist.' strError, a.strLocationName strValue, 'location' strField, a.LineNumber, a.LinePosition, 'Error'
FROM tblICStagingAdjustment a
OUTER APPLY (
	SELECT TOP 1 ic.intCompanyLocationId
	FROM tblSMCompanyLocation ic
	WHERE (ic.strLocationNumber = a.strLocationName OR ic.strLocationName = a.strLocationName)
) c
WHERE c.intCompanyLocationId IS NULL
	AND NULLIF(a.intLocationId, 0) IS NULL
	AND NULLIF(a.strLocationName, '') IS NOT NULL

INSERT INTO @Logs(strError, strValue, strField, intLineNumber, intLinePosition, strLogLevel)
SELECT 'The locationId "' + CAST(a.intLocationId AS NVARCHAR(50)) + '" does not exist.' strError, CAST(a.intLocationId AS NVARCHAR(50)) strValue, 'locationId' strField, a.LineNumber, a.LinePosition, 'Error'
FROM tblICStagingAdjustment a
OUTER APPLY (
	SELECT TOP 1 ic.intCompanyLocationId
	FROM tblSMCompanyLocation ic
	WHERE ic.intCompanyLocationId = a.intLocationId
) c
WHERE c.intCompanyLocationId IS NULL
	AND a.intLocationId IS NOT NULL
	AND NULLIF(a.strLocationName, '') IS NULL

INSERT INTO @Logs(strError, strValue, strField, intLineNumber, intLinePosition, strLogLevel)
SELECT 'The itemNo/itemId is required.' strError, null strValue, 'itemNo/itemId' strField, ad.LineNumber, ad.LinePosition, 'Error'
FROM tblICStagingAdjustmentDetail ad
WHERE NULLIF(ad.intItemId, 0) IS NULL AND NULLIF(ad.strItemNo, '') IS NULL

INSERT INTO @Logs(strError, strValue, strField, intLineNumber, intLinePosition, strLogLevel)
SELECT 'The itemNo "' + ad.strItemNo + '" does not exist.' strError, ad.strItemNo strValue, 'itemNo' strField, ad.LineNumber, ad.LinePosition, 'Error'
FROM tblICStagingAdjustmentDetail ad
LEFT OUTER JOIN tblICItem ic ON ic.strItemNo = ad.strItemNo
WHERE ic.intItemId IS NULL
	AND NULLIF(ad.strItemNo, '') IS NOT NULL
	AND ad.intItemId IS NULL

INSERT INTO @Logs(strError, strValue, strField, intLineNumber, intLinePosition, strLogLevel)
SELECT 'The itemId "' + CAST(ad.intItemId AS NVARCHAR(50)) + '" does not exist.' strError, CAST(ad.intItemId AS NVARCHAR(50)) strValue, 'itemId' strField, ad.LineNumber, ad.LinePosition, 'Error'
FROM tblICStagingAdjustmentDetail ad
LEFT OUTER JOIN tblICItem ic ON ic.intItemId = ad.intItemId
WHERE ic.intItemId IS NULL
	AND NULLIF(ad.strItemNo, '') IS NULL
	AND ad.intItemId IS NOT NULL

INSERT INTO @Logs(strError, strValue, strField, intLineNumber, intLinePosition, strLogLevel)
SELECT 'The itemId "' + CAST(ad.intItemId AS NVARCHAR(50)) + '" is not set up for the location "'
	 + c.strLocationName + '" with a locationId "' + CAST(c.intCompanyLocationId AS NVARCHAR(50)) + '".' strError, 
	CAST(i.intItemId AS NVARCHAR(50)) strValue, 'itemId' strField, ad.LineNumber, ad.LinePosition, 'Error'
FROM tblICStagingAdjustmentDetail ad
LEFT JOIN tblICStagingAdjustment a ON a.intStagingAdjustmentId = ad.intAdjustmentId
LEFT OUTER JOIN tblICItem i ON i.intItemId = ad.intItemId
OUTER APPLY (
	SELECT TOP 1 ic.intCompanyLocationId, ic.strLocationName
	FROM tblSMCompanyLocation ic
	WHERE ic.intCompanyLocationId = a.intLocationId
) c
OUTER APPLY (
	SELECT TOP 1 ic.intCompanyLocationId, ic.strLocationName
	FROM tblSMCompanyLocation ic
	JOIN tblICItemLocation il ON il.intLocationId = ic.intCompanyLocationId
		AND il.intItemId = ad.intItemId
	WHERE ic.intCompanyLocationId = a.intLocationId
) cl
WHERE cl.intCompanyLocationId IS NULL
	AND NULLIF(ad.strItemNo, '') IS NULL
	AND ad.intItemId IS NOT NULL

INSERT INTO @Logs(strError, strValue, strField, intLineNumber, intLinePosition, strLogLevel)
SELECT 'The itemNo "' + ISNULL(CAST(ad.strItemNo AS NVARCHAR(50)), '') + '" is not set up for the location "'
	 + ISNULL(c.strLocationName, '') + '".' strError, 
	CAST(i.strItemNo AS NVARCHAR(50)) strValue, 'itemNo' strField, ad.LineNumber, ad.LinePosition, 'Error'
FROM tblICStagingAdjustmentDetail ad
LEFT JOIN tblICStagingAdjustment a ON a.intStagingAdjustmentId = ad.intAdjustmentId
LEFT OUTER JOIN tblICItem i ON i.strItemNo = ad.strItemNo
OUTER APPLY (
	SELECT TOP 1 ic.intCompanyLocationId, ic.strLocationName
	FROM tblSMCompanyLocation ic
	WHERE (ic.strLocationNumber = a.strLocationName OR ic.strLocationName = a.strLocationName)
) c
OUTER APPLY (
	SELECT TOP 1 ic.intCompanyLocationId, ic.strLocationName
	FROM tblSMCompanyLocation ic
	INNER JOIN tblICItemLocation il ON il.intLocationId = ic.intCompanyLocationId
		AND il.intItemId = i.intItemId
	WHERE (ic.strLocationNumber = a.strLocationName OR ic.strLocationName = a.strLocationName)
) cl
WHERE cl.intCompanyLocationId IS NULL
AND NULLIF(ad.strItemNo, '') IS NOT NULL
	AND ad.intItemId IS NULL

INSERT INTO @Logs(strError, strValue, strField, intLineNumber, intLinePosition, strLogLevel)
SELECT 'The uom "' + CAST(ad.strUom AS NVARCHAR(50)) +  '" does not exist.' strError, 
	CAST(ad.strUom AS NVARCHAR(50)) strValue, 'uom' strField, ad.LineNumber, ad.LinePosition, 'Error'
FROM tblICStagingAdjustmentDetail ad
LEFT JOIN tblICUnitMeasure u ON u.strUnitMeasure = ad.strUom
WHERE u.intUnitMeasureId IS NULL
	AND ad.strUom IS NOT NULL

INSERT INTO @Logs(strError, strValue, strField, intLineNumber, intLinePosition, strLogLevel)
SELECT 'The itemUOMId "' + CAST(ad.intItemUOMId AS NVARCHAR(50)) +  '" does not exist.' strError, 
	CAST(ad.intItemUOMId AS NVARCHAR(50)) strValue, 'itemUOMId' strField, ad.LineNumber, ad.LinePosition, 'Error'
FROM tblICStagingAdjustmentDetail ad
LEFT JOIN tblICItemUOM um ON um.intItemUOMId = ad.intItemUOMId
WHERE um.intItemUOMId IS NULL
	AND ad.intItemUOMId IS NOT NULL

INSERT INTO @Logs(strError, strValue, strField, intLineNumber, intLinePosition, strLogLevel)
SELECT 'The itemUOMId "' + CAST(ad.intItemUOMId AS NVARCHAR(50)) + '" is not valid for the item "' + ic.strItemNo + '".' strError, 
	CAST(ad.intItemUOMId AS NVARCHAR(50)) strValue, 'itemUOMId' strField, ad.LineNumber, ad.LinePosition, 'Error'
FROM tblICStagingAdjustmentDetail ad
LEFT JOIN tblICItem ic ON ic.intItemId = ad.intItemId
LEFT JOIN tblICItemUOM um ON um.intItemUOMId = ad.intItemUOMId AND um.intItemId = ic.intItemId
WHERE um.intItemUOMId IS NULL
	AND ad.intItemUOMId IS NOT NULL

INSERT INTO @Logs(strError, strValue, strField, intLineNumber, intLinePosition, strLogLevel)
SELECT 'The uom "' + CAST(ad.strUom AS NVARCHAR(50)) + '" is not valid for the item "' + ic.strItemNo + '".' strError, 
	CAST(ad.strUom AS NVARCHAR(50)) strValue, 'uom' strField, ad.LineNumber, ad.LinePosition, 'Error'
FROM tblICStagingAdjustmentDetail ad
LEFT JOIN tblICItem ic ON ic.intItemId = ad.intItemId OR ic.strItemNo = ad.strItemNo
LEFT JOIN tblICItemUOM um ON um.intItemId = ic.intItemId
LEFT JOIN tblICUnitMeasure u ON u.intUnitMeasureId = um.intUnitMeasureId
WHERE um.intItemUOMId IS NULL
	AND ad.strUom IS NOT NULL

INSERT INTO @Logs(strError, strValue, strField, intLineNumber, intLinePosition, strLogLevel)
SELECT 'The newItemUOMId "' + CAST(ad.intNewItemUOMId AS NVARCHAR(50)) +  '" does not exist.' strError, 
	CAST(ad.intNewItemUOMId AS NVARCHAR(50)) strValue, 'newItemUOMId' strField, ad.LineNumber, ad.LinePosition, 'Error'
FROM tblICStagingAdjustmentDetail ad
LEFT JOIN tblICItemUOM um ON um.intItemUOMId = ad.intNewItemUOMId
WHERE um.intItemUOMId IS NULL
	AND ad.intNewItemUOMId IS NOT NULL

INSERT INTO @Logs(strError, strValue, strField, intLineNumber, intLinePosition, strLogLevel)
SELECT 'The newItemUOMId "' + CAST(ad.intNewItemUOMId AS NVARCHAR(50)) + '" is not valid for the item "' + ic.strItemNo + '".' strError, 
	CAST(ad.intNewItemUOMId AS NVARCHAR(50)) strValue, 'newItemUOMId' strField, ad.LineNumber, ad.LinePosition, 'Error'
FROM tblICStagingAdjustmentDetail ad
LEFT JOIN tblICItem ic ON ic.strItemNo = ad.strItemNo OR ic.intItemId = ad.intItemId
LEFT JOIN tblICItemUOM um ON um.intItemUOMId = ad.intNewItemUOMId AND um.intItemId = ic.intItemId
WHERE um.intItemUOMId IS NULL
	AND ad.intNewItemUOMId IS NOT NULL

INSERT INTO @Logs(strError, strValue, strField, intLineNumber, intLinePosition, strLogLevel)
SELECT 'The newWeightUOMId "' + CAST(ad.intNewWeightUomId AS NVARCHAR(50)) +  '" does not exist.' strError, 
	CAST(ad.intNewWeightUomId AS NVARCHAR(50)) strValue, 'newWeightUOMId' strField, ad.LineNumber, ad.LinePosition, 'Error'
FROM tblICStagingAdjustmentDetail ad
LEFT JOIN tblICItemUOM um ON um.intItemUOMId = ad.intNewWeightUomId
WHERE um.intItemUOMId IS NULL
	AND ad.intNewWeightUomId IS NOT NULL
	
INSERT INTO @Logs(strError, strValue, strField, intLineNumber, intLinePosition, strLogLevel)
SELECT 'The newWeightUOMId "' + CAST(ad.intNewWeightUomId AS NVARCHAR(50)) + '" is not valid for the item "' + ic.strItemNo + '".' strError, 
	CAST(ad.intNewWeightUomId AS NVARCHAR(50)) strValue, 'newWeightUOMId' strField, ad.LineNumber, ad.LinePosition, 'Error'
FROM tblICStagingAdjustmentDetail ad
LEFT JOIN tblICItem ic ON ic.strItemNo = ad.strItemNo OR ic.intItemId = ad.intItemId
LEFT JOIN tblICItemUOM um ON um.intItemUOMId = ad.intNewWeightUomId AND um.intItemId = ic.intItemId
WHERE um.intItemUOMId IS NULL
	AND ad.intNewWeightUomId IS NOT NULL

---- END OF Validation

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
	SELECT @intAdjustmentId, item.intItemId, newItem.intItemId, sad.dblAdjustQtyBy, lot.intLotId, newLot.intLotId, sub.intCompanyLocationSubLocationId, su.intStorageLocationId
		, sad.dblNewQuantity, sad.dblNewLotQty
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
		LEFT OUTER JOIN vyuICItemUOM itemUOM ON (itemUOM.intItemUOMId = sad.intItemUOMId OR itemUOM.strUnitMeasure = sad.strUom) AND itemUOM.intItemId = item.intItemId
		LEFT OUTER JOIN vyuICItemUOM newItemUOM ON (newItemUOM.intItemUOMId = sad.intNewItemUOMId OR newItemUOM.strUnitMeasure = sad.strNewUom) AND itemUOM.intItemId = item.intItemId
		LEFT OUTER JOIN vyuICItemUOM newWeightUOM ON (newWeightUOM.intItemUOMId = sad.intNewWeightUomId OR newWeightUOM.strUnitMeasure = sad.strNewWeightUom) AND itemUOM.intItemId = item.intItemId
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

---- Cleanup staging
DELETE FROM tblICStagingAdjustment
DELETE FROM tblICStagingAdjustmentDetail

SELECT * FROM @Logs

END