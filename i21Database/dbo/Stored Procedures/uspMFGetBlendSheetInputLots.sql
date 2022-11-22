﻿CREATE PROCEDURE uspMFGetBlendSheetInputLots
	@intWorkOrderId INT
AS

DECLARE @dblRecipeQty NUMERIC(18,6)
	  , @ysnEnableParentLot BIT=0

SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0) 
FROM tblMFCompanyPreference

SELECT TOP 1 @dblRecipeQty = r.dblQuantity 
FROM tblMFRecipe r 
JOIN tblMFRecipeItem ri ON r.intRecipeId = ri.intRecipeId 
JOIN tblMFWorkOrder w ON r.intItemId = w.intItemId AND r.intLocationId=w.intLocationId
WHERE r.ysnActive=1

IF @ysnEnableParentLot=0
BEGIN
	IF (SELECT COUNT(1) FROM tblMFWorkOrderInputLot WHERE intWorkOrderId=@intWorkOrderId) > 0
	BEGIN
		SELECT wi.intWorkOrderInputLotId
			 , wi.intWorkOrderId
			 , wi.intLotId
			 , wi.dblQuantity
			 , wi.intItemUOMId
			 , wi.dblIssuedQuantity
			 , wi.intItemIssuedUOMId
			 , l.dblWeightPerQty AS dblWeightPerUnit
			 , wi.intSequenceNo
			 , wi.dtmCreated
			 , wi.intCreatedUserId
			 , wi.dtmLastModified
			 , wi.intLastModifiedUserId
			 , CAST(0 AS BIT) AS ysnParentLot
			 , l.strLotNumber
			 , i.intItemId
			 , i.strItemNo
			 , i.strDescription
			 , um.strUnitMeasure AS strUOM
			 , um1.strUnitMeasure AS strIssuedUOM
			 , wi.intRecipeItemId
			 , l.dblLastCost AS dblUnitCost
			 , ISNULL(l.strLotAlias,'') AS strLotAlias
			 , l.strGarden AS strGarden
			 , l.intLocationId
			 , cl.strLocationName AS strLocationName
			 , sbl.strSubLocationName
			 , sl.strName AS strStorageLocationName
			 , l.strNotes AS strRemarks
			 , i.dblRiskScore
			 , ri.dblQuantity/@dblRecipeQty AS dblConfigRatio
			 , CAST(ISNULL(q.Density,0) AS DECIMAL) AS dblDensity
			 , CAST(ISNULL(q.Score,0) AS DECIMAL) AS dblScore
			 , i.intCategoryId
			 , LS.strSecondaryStatus
			 , wi.intStorageLocationId
		FROM tblMFWorkOrderInputLot wi 
		JOIN tblMFWorkOrder w ON wi.intWorkOrderId = w.intWorkOrderId
		JOIN tblICItemUOM iu ON wi.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
		JOIN tblICLot l ON wi.intLotId = l.intLotId
		JOIN tblICLotStatus LS ON l.intLotStatusId = LS.intLotStatusId
		JOIN tblICItem i ON l.intItemId = i.intItemId
		JOIN tblICItemUOM iu1 ON wi.intItemIssuedUOMId = iu1.intItemUOMId
		JOIN tblICUnitMeasure um1 ON iu1.intUnitMeasureId = um1.intUnitMeasureId
		JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = l.intLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation sbl ON sbl.intCompanyLocationSubLocationId = l.intSubLocationId
		LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = l.intStorageLocationId
		LEFT JOIN vyuQMGetLotQuality q ON l.intLotId = q.intLotId
		LEFT JOIN tblMFRecipeItem ri ON wi.intRecipeItemId = ri.intRecipeItemId
		WHERE wi.intWorkOrderId = @intWorkOrderId
	END
	ELSE /* When blend sheet created from Sales Order, directly produced in blend production screen, then only consumed lot table will have the values, to show in blend management screen from traceability */
		SELECT wi.intWorkOrderConsumedLotId AS intWorkOrderInputLotId
			 , wi.intWorkOrderId
			 , wi.intLotId
			 , wi.dblQuantity
			 , wi.intItemUOMId
			 , wi.dblIssuedQuantity
			 , wi.intItemIssuedUOMId
			 , l.dblWeightPerQty AS dblWeightPerUnit
			 , wi.intSequenceNo
			 , wi.dtmCreated
			 , wi.intCreatedUserId
			 , wi.dtmLastModified
			 , wi.intLastModifiedUserId
			 , CAST(0 AS BIT) AS ysnParentLot
			 , l.strLotNumber
			 , i.intItemId
			 , i.strItemNo
			 , i.strDescription
			 , um.strUnitMeasure AS strUOM
			 , um1.strUnitMeasure AS strIssuedUOM
			 , wi.intRecipeItemId
			 , l.dblLastCost AS dblUnitCost
			 , ISNULL(l.strLotAlias, '') AS strLotAlias
			 , l.strGarden AS strGarden
			 , l.intLocationId
			 , cl.strLocationName AS strLocationName
			 , sbl.strSubLocationName
			 , sl.strName AS strStorageLocationName
			 , l.strNotes AS strRemarks
			 , i.dblRiskScore
			 , ri.dblQuantity / @dblRecipeQty AS dblConfigRatio
			 , CAST(ISNULL(q.Density,0) AS DECIMAL) AS dblDensity
			 , CAST(ISNULL(q.Score,0) AS DECIMAL) AS dblScore
			 , i.intCategoryId
			 , LS.strSecondaryStatus
			 , wi.intStorageLocationId
		FROM tblMFWorkOrderConsumedLot wi 
		JOIN tblMFWorkOrder w ON wi.intWorkOrderId = w.intWorkOrderId
		JOIN tblICItemUOM iu ON wi.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
		JOIN tblICLot l ON wi.intLotId = l.intLotId
		JOIN tblICLotStatus LS ON l.intLotStatusId = LS.intLotStatusId
		JOIN tblICItem i ON l.intItemId = i.intItemId
		JOIN tblICItemUOM iu1 ON wi.intItemIssuedUOMId = iu1.intItemUOMId
		JOIN tblICUnitMeasure um1 ON iu1.intUnitMeasureId = um1.intUnitMeasureId
		JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = l.intLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation sbl ON sbl.intCompanyLocationSubLocationId = l.intSubLocationId
		LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = l.intStorageLocationId
		LEFT JOIN vyuQMGetLotQuality q ON l.intLotId = q.intLotId
		LEFT JOIN tblMFRecipeItem ri ON wi.intRecipeItemId = ri.intRecipeItemId
		WHERE wi.intWorkOrderId = @intWorkOrderId
END
ELSE
BEGIN
	SELECT wi.intWorkOrderInputParentLotId AS intWorkOrderInputLotId
	, wi.intWorkOrderId
	, wi.intParentLotId AS intLotId
	, wi.dblQuantity
	, wi.intItemUOMId
	, wi.dblIssuedQuantity
	, wi.intItemIssuedUOMId
	, wi.dblWeightPerUnit
	, wi.intSequenceNo
	, wi.dtmCreated
	, wi.intCreatedUserId
	, wi.dtmLastModified
	, wi.intLastModifiedUserId
	, CAST(1 AS BIT) AS ysnParentLot
	, pl.strParentLotNumber AS strLotNumber
	, i.intItemId
	, i.strItemNo
	, i.strDescription
	, um.strUnitMeasure AS strUOM
	, um1.strUnitMeasure AS strIssuedUOM
	, wi.intRecipeItemId,CAST(0 AS NUMERIC(18,6)) AS dblUnitCost
	, ISNULL(pl.strParentLotAlias, '') AS strLotAlias
	, CONVERT(NVARCHAR(MAX),'') AS strGarden
	, wi.intLocationId
	, cl.strLocationName AS strLocationName
	, sbl.strSubLocationName
	, sl.strName AS strStorageLocationName
	, CONVERT(NVARCHAR(MAX),'') AS strRemarks
	, i.dblRiskScore
	, ri.dblQuantity / @dblRecipeQty AS dblConfigRatio
	, CAST(ISNULL(q.Density,0) AS DECIMAL) AS dblDensity
	, CAST(ISNULL(q.Score,0) AS DECIMAL) AS dblScore
	, i.intCategoryId
	, wi.intStorageLocationId 
    , LS.strSecondaryStatus
	INTO #tblWorkOrderInputParent
	FROM tblMFWorkOrderInputParentLot wi 
	JOIN tblMFWorkOrder w ON wi.intWorkOrderId = w.intWorkOrderId
	JOIN tblICItemUOM iu ON wi.intItemUOMId = iu.intItemUOMId
	JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
	JOIN tblICParentLot pl ON wi.intParentLotId = pl.intParentLotId
	JOIN tblICLotStatus LS ON pl.intLotStatusId  =  LS.intLotStatusId
	JOIN tblICItem i ON pl.intItemId = i.intItemId
	JOIN tblICItemUOM iu1 ON wi.intItemIssuedUOMId = iu1.intItemUOMId
	JOIN tblICUnitMeasure um1 ON iu1.intUnitMeasureId = um1.intUnitMeasureId
	JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = wi.intLocationId
	LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = wi.intStorageLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation sbl ON sbl.intCompanyLocationSubLocationId = sl.intSubLocationId
	LEFT JOIN vyuQMGetLotQuality q ON pl.intParentLotId = q.intLotId
	LEFT JOIN tblMFRecipeItem ri ON wi.intRecipeItemId = ri.intRecipeItemId
	WHERE wi.intWorkOrderId = @intWorkOrderId

	--Update wi Set wi.dblUnitCost=l.dblLastCost,wi.strGarden=ISNULL(l.strGarden,''),wi.strRemarks=l.strNotes
	--From #tblWorkOrderInputParent wi Join tblICLot l on wi.intLotId=l.intParentLotId

	UPDATE wi 
	SET wi.dblUnitCost = t.dblLastCost
	  , wi.strGarden   = ISNULL(t.strGarden, '')
	  , wi.strRemarks  = ISNULL(t.strNotes, '')
	FROM #tblWorkOrderInputParent wi
	OUTER APPLY (SELECT TOP 1 l.dblLastCost
							, l.strGarden
							, l.strNotes
				 FROM tblICLot l
				 WHERE l.intParentLotId = wi.intLotId
				 ORDER BY l.intLotId DESC) t
	SELECT * FROM #tblWorkOrderInputParent
END