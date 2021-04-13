CREATE PROCEDURE [dbo].[uspApiImportInventoryAdjustmentsFromStaging]
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@intUserId INT = 1
AS
BEGIN

DECLARE @Adjustments TABLE(strAdjustmentNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, intLocationId INT, intAdjustmentType INT, dtmAdjustmentDate DATETIME, 
	strDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strIntegrationDocNo] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL)
INSERT INTO @Adjustments(strAdjustmentNo, intLocationId, intAdjustmentType, dtmAdjustmentDate, strDescription, strIntegrationDocNo)
SELECT a.strAdjustmentNo, c.intCompanyLocationId, a.intAdjustmentType, a.dtmDate, a.strDescription, a.strIntegrationDocNo
FROM tblICStagingAdjustment a
	INNER JOIN tblSMCompanyLocation c ON c.strLocationNumber = a.strLocationName OR c.strLocationName = a.strLocationName

DECLARE @intLocationId INT
DECLARE @intAdjustmentType INT
DECLARE @dtmAdjustmentDate DATETIME
DECLARE @strDescription NVARCHAR(200)
DECLARE @strAdjustmentNo NVARCHAR(200)
DECLARE @strTempAdjustmentNo NVARCHAR(200)
DECLARE @strIntegrationDocNo NVARCHAR(200)
DECLARE @intAdjustmentId INT

DECLARE @Logs TABLE (strError NVARCHAR(500), strField NVARCHAR(100), strValue NVARCHAR(500), intLineNumber INT, intLinePosition INT, strLogLevel NVARCHAR(50))

-- Log Invalid company locations
INSERT INTO @Logs(strError, strValue, strField, intLineNumber, intLinePosition, strLogLevel)
SELECT 'The company location no: ''' + a.strLocationName + ''' does not exists.' strError, a.strLocationName strValue, 'location' strField, a.LineNumber, a.LinePosition, 'Error'
FROM tblSMCompanyLocation c
RIGHT OUTER JOIN tblICStagingAdjustment a ON c.strLocationNumber = a.strLocationName OR c.strLocationName = a.strLocationName
WHERE c.intCompanyLocationId IS NULL 

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
		INNER JOIN tblICItem item ON item.strItemNo = sad.strItemNo
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
		LEFT OUTER JOIN vyuICItemUOM itemUOM ON itemUOM.strUnitMeasure = sad.strUom AND itemUOM.intItemId = item.intItemId
		LEFT OUTER JOIN vyuICItemUOM newItemUOM ON newItemUOM.strUnitMeasure = sad.strNewUom AND itemUOM.intItemId = item.intItemId
		LEFT OUTER JOIN vyuICItemUOM newWeightUOM ON newWeightUOM.strUnitMeasure = sad.strNewWeightUom AND itemUOM.intItemId = item.intItemId
	WHERE sad.strAdjustmentNo = @strTempAdjustmentNo

	UPDATE tblICInventoryAdjustment
	SET strAdjustmentNo = @strAdjustmentNo, guiApiUniqueId = @guiApiUniqueId
	WHERE intInventoryAdjustmentId = @intAdjustmentId

	IF (NOT EXISTS(SELECT TOP 1 1 FROM tblICInventoryAdjustmentDetail WHERE intInventoryAdjustmentId = @intAdjustmentId))
		DELETE FROM tblICInventoryAdjustment WHERE intInventoryAdjustmentId = @intAdjustmentId

	INSERT INTO @Logs(strError, strValue, strField, intLineNumber, intLinePosition, strLogLevel)
	SELECT 'Can''t find the item number: ''' + sad.strItemNo + '''', sad.strItemNo, 'itemNo', sad.LineNumber, sad.LinePosition, 'Error'
	FROM tblICItem item
		RIGHT OUTER JOIN tblICStagingAdjustmentDetail sad ON item.strItemNo = sad.strItemNo
	WHERE sad.strAdjustmentNo = @strTempAdjustmentNo
		AND item.intItemId IS NULL

	FETCH NEXT FROM cur INTO @strTempAdjustmentNo, @intLocationId, @intAdjustmentType, @dtmAdjustmentDate, @strDescription, @strIntegrationDocNo
END

CLOSE cur
DEALLOCATE cur

---- Cleanup staging
DELETE FROM tblICStagingAdjustment
DELETE FROM tblICStagingAdjustmentDetail

SELECT * FROM @Logs

END