CREATE PROCEDURE uspICImportAdjustmentsFromStaging
	@intUserId INT = 1
AS
BEGIN

DECLARE @Adjustments TABLE(strAdjustmentNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, intLocationId INT, intAdjustmentType INT, dtmAdjustmentDate DATETIME, strDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL)
INSERT INTO @Adjustments(strAdjustmentNo, intLocationId, intAdjustmentType, dtmAdjustmentDate, strDescription)
SELECT a.strAdjustmentNo, c.intCompanyLocationId, a.intAdjustmentType, a.dtmDate, a.strDescription
FROM tblICStagingAdjustment a
	INNER JOIN tblSMCompanyLocation c ON c.strLocationName = a.strLocationName

DECLARE @intLocationId INT
DECLARE @intAdjustmentType INT
DECLARE @dtmAdjustmentDate DATETIME
DECLARE @strDescription NVARCHAR(200)
DECLARE @strAdjustmentNo NVARCHAR(200)
DECLARE @strTempAdjustmentNo NVARCHAR(200)
DECLARE @intAdjustmentId INT

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
SELECT strAdjustmentNo, intLocationId, intAdjustmentType, dtmAdjustmentDate, strDescription FROM @Adjustments

OPEN cur

FETCH NEXT FROM cur INTO @strTempAdjustmentNo, @intLocationId, @intAdjustmentType, @dtmAdjustmentDate, @strDescription

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC dbo.uspSMGetStartingNumber 30, @strAdjustmentNo OUTPUT, @intLocationId
	
	INSERT INTO tblICInventoryAdjustment(strAdjustmentNo, intLocationId, intAdjustmentType, dtmAdjustmentDate, strDescription, intCreatedByUserId, dtmDateCreated, strDataSource)
	VALUES(@strTempAdjustmentNo, @intLocationId, @intAdjustmentType, @dtmAdjustmentDate, @strDescription, @intUserId, GETDATE(),  'JSON Import')
	
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
	SET strAdjustmentNo = @strAdjustmentNo
	WHERE intInventoryAdjustmentId = @intAdjustmentId

	FETCH NEXT FROM cur INTO @strTempAdjustmentNo, @intLocationId, @intAdjustmentType, @dtmAdjustmentDate, @strDescription
END

CLOSE cur
DEALLOCATE cur

---- Cleanup staging
DELETE FROM tblICStagingAdjustment
DELETE FROM tblICStagingAdjustmentDetail

END