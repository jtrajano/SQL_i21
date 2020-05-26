CREATE PROCEDURE [dbo].[uspMFGetBlendProductionAvailableLots] @intParentLotId INT
	,@intItemId INT
	,@intLocationId INT
	,@ysnShowAllPallets BIT
	,@intItemUOMId INT = 0
	,@intManufacturingProcessId INT = 0
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ysnEnableParentLot BIT = 0
DECLARE @strRecipeItemUOM NVARCHAR(50)
DECLARE @strSourceLocationIds NVARCHAR(MAX)

SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0)
FROM tblMFCompanyPreference

SELECT @strRecipeItemUOM = um.strUnitMeasure
FROM tblICItemUOM iu
JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
WHERE iu.intItemUOMId = @intItemUOMId

SELECT @strSourceLocationIds = ISNULL(pa.strAttributeValue, '')
FROM tblMFManufacturingProcessAttribute pa
JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
WHERE intManufacturingProcessId = @intManufacturingProcessId
	AND intLocationId = @intLocationId
	AND at.strAttributeName = 'Source Location'

DECLARE @tblSourceStorageLocation AS TABLE (intStorageLocationId INT)

IF Ltrim(ISNULL(@strSourceLocationIds, '')) <> ''
BEGIN
	INSERT INTO @tblSourceStorageLocation
	SELECT *
	FROM dbo.fnCommaSeparatedValueToTable(@strSourceLocationIds)
END
ELSE
BEGIN
	INSERT INTO @tblSourceStorageLocation
	SELECT intStorageLocationId
	FROM tblICStorageLocation
	WHERE intLocationId = @intLocationId
		AND ISNULL(ysnAllowConsume, 0) = 1
END

DECLARE @tblReservedQty TABLE (
	intLotId INT
	,dblReservedQty NUMERIC(38, 20)
	)

INSERT INTO @tblReservedQty
SELECT sr.intLotId
	,Sum(sr.dblQty) AS dblReservedQty
FROM tblICStockReservation sr
WHERE sr.intItemId = @intItemId
	AND ISNULL(sr.ysnPosted, 0) = 0
GROUP BY sr.intLotId

SELECT l.intLotId
	,l.strLotNumber
	,l.intItemId
	,i.strItemNo
	,i.strDescription
	,ISNULL(l.strLotAlias, '') AS strLotAlias
	,CASE 
		WHEN isnull(l.dblWeight, 0) > 0
			THEN l.dblWeight
		ELSE dbo.fnMFConvertQuantityToTargetItemUOM(l.intItemUOMId, @intItemUOMId, l.dblQty)
		END AS dblPhysicalQty
	,ISNULL(c.dblReservedQty, 0) AS dblReservedQty
	,ISNULL((
			ISNULL(CASE 
					WHEN isnull(l.dblWeight, 0) > 0
						THEN l.dblWeight
					ELSE dbo.fnMFConvertQuantityToTargetItemUOM(l.intItemUOMId, @intItemUOMId, l.dblQty)
					END, 0) - ISNULL(c.dblReservedQty, 0)
			), 0) AS dblAvailableQty
	,ISNULL(l.intWeightUOMId, @intItemUOMId) AS intItemUOMId
	,ISNULL(u.strUnitMeasure, @strRecipeItemUOM) AS strUOM
	,ROUND((
			ISNULL((
					ISNULL(CASE 
							WHEN isnull(l.dblWeight, 0) > 0
								THEN l.dblWeight
							ELSE dbo.fnMFConvertQuantityToTargetItemUOM(l.intItemUOMId, @intItemUOMId, l.dblQty)
							END, 0) - ISNULL(c.dblReservedQty, 0)
					), 0) / CASE 
				WHEN ISNULL(iu1.dblUnitQty, 0) = 0
					THEN 1
				ELSE iu1.dblUnitQty
				END
			), 0) AS dblAvailableUnit
	,l.dblLastCost AS dblUnitCost
	,iu1.dblUnitQty AS dblWeightPerUnit
	,u.strUnitMeasure AS strWeightPerUnitUOM
	,l.intItemUOMId AS intPhysicalItemUOMId
	,l.dtmDateCreated AS dtmReceiveDate
	,l.dtmExpiryDate
	,ISNULL(' ', '') AS strVendorId
	,ISNULL(l.strVendorLotNo, '') AS strVendorLotNo
	,l.strGarden AS strGarden
	,l.intLocationId
	,cl.strLocationName AS strLocationName
	,sbl.strSubLocationName
	,sl.strName AS strStorageLocationName
	,l.strNotes AS strRemarks
	,i.dblRiskScore
	,ISNULL(l.intParentLotId, 0) AS intParentLotId
	,sl.intStorageLocationId
	,ISNULL(pl.strParentLotNumber, '') AS strParentLotNumber
	,i.strLotTracking
	,i.intCategoryId
INTO #tempLot
FROM tblICLot l
LEFT JOIN @tblReservedQty c ON l.intLotId = c.intLotId
JOIN tblICItem i ON l.intItemId = i.intItemId
LEFT JOIN tblICItemUOM iu ON l.intWeightUOMId = iu.intItemUOMId
LEFT JOIN tblICUnitMeasure u ON iu.intUnitMeasureId = u.intUnitMeasureId
JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = l.intLocationId
LEFT JOIN tblSMCompanyLocationSubLocation sbl ON sbl.intCompanyLocationSubLocationId = l.intSubLocationId
LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = l.intStorageLocationId
LEFT JOIN tblICStorageUnitType ut ON sl.intStorageUnitTypeId = ut.intStorageUnitTypeId
	AND ut.strInternalCode <> 'PROD_STAGING'
JOIN @tblSourceStorageLocation tsl ON sl.intStorageLocationId = tsl.intStorageLocationId
JOIN tblICItemUOM iu1 ON l.intItemUOMId = iu1.intItemUOMId
--Left Join vyuAPVendor v on l.intVendorId=v.intVendorId
JOIN tblICLotStatus ls ON l.intLotStatusId = ls.intLotStatusId
LEFT JOIN tblICParentLot pl ON l.intParentLotId = pl.intParentLotId
WHERE l.intItemId = @intItemId
	AND l.dblQty > 0
	AND ls.strPrimaryStatus = 'Active'
	AND l.intLocationId = @intLocationId
	AND ISNULL(sl.ysnAllowConsume, 0) = 1
ORDER BY l.dtmExpiryDate
	,l.dtmDateCreated

IF @ysnEnableParentLot = 0
BEGIN
	SELECT *
	FROM #tempLot
END
ELSE
BEGIN
	IF @ysnShowAllPallets = 0
	BEGIN
		IF @intParentLotId = 0
		BEGIN
			SELECT *
			FROM #tempLot --where intParentLotId=@intParentLotId
		END
		ELSE
		BEGIN
			SELECT *
			FROM #tempLot
			WHERE intParentLotId = @intParentLotId
		END
	END
	ELSE
	BEGIN
		SELECT *
		FROM #tempLot
		WHERE intParentLotId <> 0
	END
END
