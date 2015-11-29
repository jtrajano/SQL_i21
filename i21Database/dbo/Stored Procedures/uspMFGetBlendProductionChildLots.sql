﻿CREATE PROCEDURE [dbo].[uspMFGetBlendProductionChildLots] @intWorkOrderId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intLocationId INT
DECLARE @intItemId INT
Declare @strLotTracking nvarchar(50)

SELECT @intLocationId = intLocationId, @intItemId=intItemId
FROM tblMFWorkOrder
WHERE intWorkOrderId = @intWorkOrderId

Select @strLotTracking=strLotTracking From tblICItem Where intItemId=@intItemId

DECLARE @tblReservedQty TABLE (
	intLotId INT
	,dblReservedQty NUMERIC(18, 6)
	)

INSERT INTO @tblReservedQty
SELECT cl.intLotId
	,Sum(cl.dblQuantity) AS dblReservedQty
FROM tblMFWorkOrderConsumedLot cl
JOIN tblMFWorkOrder w ON cl.intWorkOrderId = w.intWorkOrderId
JOIN tblICLot l ON l.intLotId = cl.intLotId
WHERE w.intWorkOrderId = @intWorkOrderId
	AND w.intStatusId <> 13
GROUP BY cl.intLotId

--DECLARE @intStorageLocationId INT
--	,@strBlendProductionStagingLocation NVARCHAR(50)

--SELECT @strBlendProductionStagingLocation = strBlendProductionStagingLocation
--FROM dbo.tblMFCompanyPreference

--SELECT @intStorageLocationId = intStorageLocationId
--FROM dbo.tblICStorageLocation
--WHERE strName = @strBlendProductionStagingLocation
--	AND intLocationId = @intLocationId

DECLARE @tblMFStagedLot TABLE (
	intLotId INT
	,dblRequiredQty NUMERIC(18, 6)
	,dblStagedQty NUMERIC(18, 6)
	)
Declare @intBlendProductionStagingUnitId int

	SELECT @intBlendProductionStagingUnitId=intBlendProductionStagingUnitId
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId=@intLocationId

INSERT INTO @tblMFStagedLot
SELECT WC.intLotId
	,(
		SELECT IsNULL(SUM(OL.dblQty), 0)
		FROM dbo.tblWHOrderLineItem OL
		JOIN dbo.tblWHOrderHeader OH ON OH.intOrderHeaderId = OL.intOrderHeaderId
			AND intOrderTypeId = 6
		WHERE OL.intLotId = WC.intLotId
			AND EXISTS (
				SELECT *
				FROM dbo.tblWHOrderManifest OM
				WHERE OM.intOrderLineItemId = OL.intOrderLineItemId
				)
		) AS dblRequiredQty
	,ISNULL(SUM(CASE 
				WHEN IU.intUnitMeasureId = S.intUOMId
					THEN S.dblQty
				ELSE S.dblQty / (
						CASE 
							WHEN S.dblWeightPerUnit = 0
								THEN 1
							ELSE S.dblWeightPerUnit
							END
						)
				END), 0) AS dblStagedQty
FROM dbo.tblMFWorkOrderConsumedLot WC
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = WC.intItemIssuedUOMId
LEFT JOIN dbo.tblWHContainer C ON C.intStorageLocationId = @intBlendProductionStagingUnitId
LEFT JOIN dbo.tblWHSKU S ON S.intContainerId = C.intContainerId
WHERE WC.intWorkOrderId = @intWorkOrderId
GROUP BY WC.intLotId

If @strLotTracking = 'No'
SELECT wcl.intWorkOrderConsumedLotId
	,wcl.intWorkOrderId
	,0 AS intLotId
	,'' strLotNumber
	,i.intItemId
	,i.strItemNo
	,i.strDescription
	,wcl.dblQuantity
	,wcl.intItemUOMId
	,um.strUnitMeasure AS strUOM
	,wcl.dblIssuedQuantity
	,wcl.intItemIssuedUOMId
	,iu2.strUnitMeasure AS strIssuedUOM
	,sl.strName AS strStorageLocationName
	,i.dblRiskScore
	,ISNULL(wcl.ysnStaged, 0) AS ysnStaged
	,(Select TOP 1 ISNULL(sd.dblAvailableQty,0.0) 
		From vyuMFGetItemStockDetail sd 
		Where sd.intItemId=wcl.intItemId 
		AND sd.intLocationId=@intLocationId 
		AND ISNULL(sd.intSubLocationId,0)=ISNULL(wcl.intSubLocationId,0) 
		AND ISNULL(sd.intStorageLocationId,0)=ISNULL(wcl.intStorageLocationId,0)
		AND sd.ysnStockUnit = 1) AS dblAvailableQty
	,0.0 AS dblWeightPerUnit
	,wcl.intRecipeItemId
	,0 AS intParentLotId
	,'' strParentLotNumber
	,0.0 AS dblStagedQty
	,CSL.strSubLocationName
	,CL.strLocationName
FROM tblMFWorkOrderConsumedLot wcl
JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = wcl.intWorkOrderId
JOIN tblICItem i ON wcl.intItemId = i.intItemId
JOIN tblICCategory C ON C.intCategoryId = i.intCategoryId
JOIN tblICItemUOM iu ON wcl.intItemUOMId = iu.intItemUOMId
JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
JOIN tblICItemUOM iu1 ON wcl.intItemIssuedUOMId = iu1.intItemUOMId
JOIN tblICUnitMeasure iu2 ON iu1.intUnitMeasureId = iu2.intUnitMeasureId
LEFT JOIN tblICStorageLocation sl ON wcl.intStorageLocationId = sl.intStorageLocationId
LEFT JOIN tblSMCompanyLocationSubLocation CSL ON wcl.intSubLocationId=CSL.intCompanyLocationSubLocationId
JOIN tblSMCompanyLocation CL ON W.intLocationId=CL.intCompanyLocationId
--LEFT JOIN @tblReservedQty rq ON l.intLotId = rq.intLotId
WHERE wcl.intWorkOrderId = @intWorkOrderId
Else
SELECT wcl.intWorkOrderConsumedLotId
	,wcl.intWorkOrderId
	,l.intLotId
	,l.strLotNumber
	,i.intItemId
	,i.strItemNo
	,i.strDescription
	,wcl.dblQuantity
	,wcl.intItemUOMId
	,um.strUnitMeasure AS strUOM
	,wcl.dblIssuedQuantity
	,wcl.intItemIssuedUOMId
	,iu2.strUnitMeasure AS strIssuedUOM
	,sl.strName AS strStorageLocationName
	,i.dblRiskScore
	,ISNULL(wcl.ysnStaged, 0) AS ysnStaged
	,(ISNULL(l.dblWeight, 0) - ISNULL(rq.dblReservedQty, 0)) AS dblAvailableQty
	,ISNULL(l.dblWeightPerQty, 0) AS dblWeightPerUnit
	,wcl.intRecipeItemId
	,l.intParentLotId
	,pl.strParentLotNumber
	,(
		CASE 
			WHEN C.ysnWarehouseTracked = 0
				THEN wcl.dblIssuedQuantity
			ELSE (
					SELECT ISNULL(SUM(dblQty), 0)
					FROM (
						SELECT CASE 
								WHEN ISNULL(SUM(CASE 
												WHEN S.intWeightPerUnitUOMId = S.intUOMId
													THEN S.dblQty / (
															CASE 
																WHEN S.dblWeightPerUnit = 0
																	THEN 1
																ELSE S.dblWeightPerUnit
																END
															)
												ELSE S.dblQty
												END), 0) >= wcl.dblIssuedQuantity
									THEN isnull(wcl.dblIssuedQuantity, 0)
								ELSE ISNULL(SUM(CASE 
												WHEN S.intWeightPerUnitUOMId = S.intUOMId
													THEN S.dblQty / (
															CASE 
																WHEN S.dblWeightPerUnit = 0
																	THEN 1
																ELSE S.dblWeightPerUnit
																END
															)
												ELSE S.dblQty
												END), 0)
								END AS dblQty
						FROM dbo.tblWHSKU S
						JOIN dbo.tblWHContainer C ON C.intContainerId = S.intContainerId
							AND C.intStorageLocationId = @intBlendProductionStagingUnitId
						JOIN dbo.tblWHOrderManifest RM ON RM.intSKUId = S.intSKUId
						WHERE S.intLotId = wcl.intLotId
							AND RM.intOrderHeaderId = W.intOrderHeaderId
						
						UNION ALL
						
						SELECT (
								CASE 
									WHEN dblStagedQty - dblRequiredQty > 0
										THEN dblStagedQty - dblRequiredQty
									ELSE 0
									END
								)
						FROM @tblMFStagedLot SM
						WHERE SM.intLotId = wcl.intLotId
						) AS DT
					)
			END
		) dblStagedQty
FROM tblMFWorkOrderConsumedLot wcl
JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = wcl.intWorkOrderId
JOIN tblICLot l ON wcl.intLotId = l.intLotId
JOIN tblICItem i ON l.intItemId = i.intItemId
JOIN tblICCategory C ON C.intCategoryId = i.intCategoryId
JOIN tblICItemUOM iu ON wcl.intItemUOMId = iu.intItemUOMId
JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
JOIN tblICItemUOM iu1 ON wcl.intItemIssuedUOMId = iu1.intItemUOMId
JOIN tblICUnitMeasure iu2 ON iu1.intUnitMeasureId = iu2.intUnitMeasureId
LEFT JOIN tblICStorageLocation sl ON l.intStorageLocationId = sl.intStorageLocationId
LEFT JOIN tblICParentLot pl ON l.intParentLotId = pl.intParentLotId
LEFT JOIN @tblReservedQty rq ON l.intLotId = rq.intLotId
WHERE wcl.intWorkOrderId = @intWorkOrderId
