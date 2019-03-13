CREATE PROCEDURE uspICImportCountsFromStaging
	@intUserId INT = 1
AS
BEGIN

DECLARE @Count TABLE (strCountNo NVARCHAR(100), intLocationId INT, dtmCountDate DATETIME, ysnCountByLots BIT)

INSERT INTO @Count(strCountNo, intLocationId, dtmCountDate, ysnCountByLots)
SELECT sc.strCountNo, c.intCompanyLocationId, sc.dtmDate, sc.ysnCountByLots
FROM tblICStagingCount sc
	INNER JOIN tblSMCompanyLocation c ON c.strLocationName = sc.strLocation

DECLARE @strCountNo NVARCHAR(100)
DECLARE @strTempCountNo NVARCHAR(100)
DECLARE @intLocationId INT
DECLARE @dtmCountDate DATETIME
DECLARE @ysnCountByLots BIT
DECLARE @intCountId INT

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
SELECT strCountNo, intLocationId, dtmCountDate, ysnCountByLots FROM @Count

OPEN cur

FETCH NEXT FROM cur INTO @strTempCountNo, @intLocationId, @dtmCountDate, @ysnCountByLots

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC dbo.uspSMGetStartingNumber 76, @strCountNo OUTPUT, @intLocationId

	INSERT INTO tblICInventoryCount(strCountNo, intLocationId, dtmCountDate, ysnCountByLots, intCreatedByUserId, dtmDateCreated)
	VALUES(@strTempCountNo, @intLocationId, @dtmCountDate, @ysnCountByLots, @intUserId, GETDATE())

	SET @intCountId = SCOPE_IDENTITY()

	INSERT INTO tblICInventoryCountDetail(intInventoryCountId, intItemId, intItemLocationId, intSubLocationId, intStorageLocationId, intCountGroupId, intLotId, strLotNo, strLotAlias
		, intParentLotId, strParentLotNo, strParentLotAlias, intStockUOMId, dblSystemCount, dblLastCost, dblPallets, dblQtyPerPallet, dblPhysicalCount
		, intItemUOMId, intWeightUOMId, dblWeightQty, dblNetQty, ysnRecount, intEntityUserSecurityId
		, intCreatedByUserId, dtmDateCreated, strCountLine)
	SELECT @intCountId, item.intItemId, il.intItemLocationId, sub.intCompanyLocationSubLocationId, sl.intStorageLocationId, cg.intCountGroupId
		, lot.intLotId, sd.strLotNo, sd.strLotAlias, pLot.intParentLotId, ISNULL(pLot.strParentLotNumber, sd.strParentLotNo), ISNULL(pLot.strParentLotAlias, sd.strParentLotAlias)
		, stockUom.intItemUOMId, dbo.fnICGetItemRunningStockQty(item.intItemId, @intLocationId, lot.intLotId, sub.intCompanyLocationSubLocationId, sl.intStorageLocationId, item.intCommodityId, item.intCategoryId, @dtmCountDate, 0)
		, COALESCE(sd.dblLastCost, dbo.fnICGetItemRunningCost(item.intItemId, @intLocationId, lot.intLotId, sub.intCompanyLocationSubLocationId, sl.intStorageLocationId, item.intCommodityId, item.intCategoryId, @dtmCountDate, 0), pricing.dblLastCost)
		, sd.dblPallets, sd.dblQtyPerPallet, sd.dblPhysicalCount
		, itemUom.intItemUOMId, weightUom.intItemUOMId, sd.dblWeightQty, sd.dblWeightQty, ISNULL(sd.ysnRecount, 0)
		, @intUserId, @intUserId, GETDATE()
		, @strCountNo + '-' + CAST(ROW_NUMBER() OVER(PARTITION BY sd.intStagingCountDetailId ORDER BY sd.intStagingCountDetailId ASC) AS NVARCHAR(50))
	FROM tblICStagingCountDetail sd
		INNER JOIN tblICItem item ON item.strItemNo = sd.strItemNo
		INNER JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = @intLocationId
		INNER JOIN tblICItemLocation il ON il.intItemId = item.intItemId
			AND il.intLocationId = c.intCompanyLocationId
		LEFT OUTER JOIN tblSMCompanyLocationSubLocation sub ON sub.strSubLocationName = sd.strStorageLocation
		LEFT OUTER JOIN tblICStorageLocation sl ON sl.strName = sd.strStorageUnit
		LEFT OUTER JOIN tblICCountGroup cg ON cg.strCountGroup = sd.strCountGroup
		LEFT OUTER JOIN tblICLot lot ON lot.intItemId = item.intItemId
			AND lot.strLotNumber = sd.strLotNo
		LEFT OUTER JOIN tblICParentLot pLot ON pLot.strParentLotNumber = sd.strParentLotNo
			AND pLot.intItemId = item.intItemId
		LEFT OUTER JOIN vyuICItemUOM stockUom ON stockUom.intItemId = item.intItemId
			AND stockUom.ysnStockUnit = 1
		LEFT OUTER JOIN vyuICItemUOM itemUom ON itemUom.intItemId = item.intItemId
			AND itemUom.strUnitMeasure = sd.strCountUom
		LEFT OUTER JOIN vyuICItemUOM weightUom ON weightUom.intItemId = item.intItemId
			AND weightUom.strUnitMeasure = sd.strWeightUom
		LEFT OUTER JOIN tblICItemPricing pricing ON pricing.intItemId = item.intItemId AND pricing.intItemLocationId = il.intItemLocationId
	WHERE sd.strCountNo = @strTempCountNo

	UPDATE tblICInventoryCount
	SET strCountNo = @strCountNo
	WHERE intInventoryCountId = @intCountId

	FETCH NEXT FROM cur INTO @strTempCountNo, @intLocationId, @dtmCountDate, @ysnCountByLots
END

CLOSE cur
DEALLOCATE cur

END