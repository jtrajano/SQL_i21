CREATE PROCEDURE [dbo].[uspMFGetBlendProductionChildLots] @intWorkOrderId INT,@intLocationId INT = NULL,@intItemId INT = NULL,@dblQtyToProduce NUMERIC(38,20),@strRecipeXml nvarchar(max)=''
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--DECLARE @intLocationId INT
--DECLARE @intItemId INT

If ISNULL(@intWorkOrderId,0)>0
SELECT @intLocationId = intLocationId, @intItemId=intItemId
FROM tblMFWorkOrder
WHERE intWorkOrderId = @intWorkOrderId

DECLARE @tblReservedQty TABLE (
	intLotId INT
	,dblReservedQty NUMERIC(38,20)
	)

If ISNULL(@intWorkOrderId,0)>0
Begin
INSERT INTO @tblReservedQty
SELECT cl.intLotId
	,Sum(cl.dblQuantity) AS dblReservedQty
FROM tblMFWorkOrderConsumedLot cl
JOIN tblMFWorkOrder w ON cl.intWorkOrderId = w.intWorkOrderId
JOIN tblICLot l ON l.intLotId = cl.intLotId
WHERE w.intWorkOrderId = @intWorkOrderId
	AND w.intStatusId <> 13
GROUP BY cl.intLotId

DECLARE @tblMFStagedLot TABLE (
	intLotId INT
	,dblRequiredQty NUMERIC(38,20)
	,dblStagedQty NUMERIC(38,20)
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

SELECT wcl.intWorkOrderConsumedLotId
	,wcl.intWorkOrderId
	,0 AS intLotId
	,'' strLotNumber
	,'' strLotAlias
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
	,'' AS strLotStatus
	,CSL.strSubLocationName
	,CL.strLocationName
	,i.strLotTracking
	,i.intCategoryId
    ,wcl.intSubLocationId
    ,wcl.intStorageLocationId
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
WHERE wcl.intWorkOrderId = @intWorkOrderId AND i.strLotTracking='No'
UNION
SELECT wcl.intWorkOrderConsumedLotId
	,wcl.intWorkOrderId
	,l.intLotId
	,l.strLotNumber
	,ISNULL(l.strLotAlias,'') AS strLotAlias
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
	,(ISNULL(CASE WHEN isnull(l.dblWeight,0)>0 Then l.dblWeight Else dbo.fnMFConvertQuantityToTargetItemUOM(l.intItemUOMId,wcl.intItemUOMId,l.dblQty) End, 0) 
	- ISNULL(rq.dblReservedQty, 0)) AS dblAvailableQty
	,CASE WHEN wcl.intItemUOMId=wcl.intItemIssuedUOMId THEN 1 ELSE ISNULL(l.dblWeightPerQty, 1) END AS dblWeightPerUnit
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
		) dblStagedQty,
		ls.strSecondaryStatus AS strLotStatus
		,CSL.strSubLocationName
		,CL.strLocationName
		,i.strLotTracking
		,i.intCategoryId
		,wcl.intSubLocationId
		,wcl.intStorageLocationId
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
LEFT JOIN tblICLotStatus ls on l.intLotStatusId=ls.intLotStatusId
LEFT JOIN tblSMCompanyLocationSubLocation CSL ON wcl.intSubLocationId=CSL.intCompanyLocationSubLocationId
JOIN tblSMCompanyLocation CL ON W.intLocationId=CL.intCompanyLocationId
WHERE wcl.intWorkOrderId = @intWorkOrderId
End
Else
Begin
	Declare @tblPickedLots AS table
	( 
		intWorkOrderInputLotId int,
		intLotId int,
		strLotNumber nvarchar(50) COLLATE Latin1_General_CI_AS,
		strItemNo nvarchar(50) COLLATE Latin1_General_CI_AS,
		strDescription nvarchar(200) COLLATE Latin1_General_CI_AS,
		dblQuantity numeric(38,20),
		intItemUOMId int,
		strUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
		dblIssuedQuantity numeric(38,20),
		intItemIssuedUOMId int,
		strIssuedUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
		intItemId int,
		intRecipeItemId int,
		dblUnitCost numeric(38,20),
		dblDensity numeric(38,20),
		dblRequiredQtyPerSheet numeric(38,20),
		dblWeightPerUnit numeric(38,20),
		dblRiskScore numeric(38,20),
		intStorageLocationId int,
		strStorageLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
		strLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
		intLocationId int,
		strSubLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
		intSubLocationId int,
		strLotAlias nvarchar(50) COLLATE Latin1_General_CI_AS,
		ysnParentLot bit,
		strRowState nvarchar(50) COLLATE Latin1_General_CI_AS
	)

	Insert Into @tblPickedLots
	Exec uspMFAutoBlendSheetFIFO @intLocationId,0,@dblQtyToProduce,@strRecipeXml,1,'','',@intItemId

	Select tpl.intWorkOrderInputLotId AS intWorkOrderConsumedLotId,
	0 AS intWorkOrderId,
	tpl.intLotId,
	tpl.strLotNumber,
	ISNULL(tpl.strLotAlias,'') AS strLotAlias,
	tpl.intItemId,
	tpl.strItemNo,
	tpl.strDescription,
	tpl.dblQuantity,
	tpl.intItemUOMId,
	tpl.strUOM,
	tpl.dblIssuedQuantity,
	tpl.intItemIssuedUOMId,
	tpl.strIssuedUOM,
	tpl.strStorageLocationName,
	tpl.dblRiskScore,
	CAST (0 AS BIT) AS ysnStaged,
	CASE WHEN i.strLotTracking = 'No' THEN (Select TOP 1 ISNULL(sd.dblAvailableQty,0.0) 
		From vyuMFGetItemStockDetail sd 
		Where sd.intItemId=tpl.intItemId 
		AND sd.intLocationId=@intLocationId 
		AND ISNULL(sd.intSubLocationId,0)=ISNULL(tpl.intSubLocationId,0) 
		AND ISNULL(sd.intStorageLocationId,0)=ISNULL(tpl.intStorageLocationId,0)
		AND sd.ysnStockUnit = 1)
	Else (ISNULL(CASE WHEN isnull(l.dblWeight,0)>0 Then l.dblWeight Else dbo.fnMFConvertQuantityToTargetItemUOM(l.intItemUOMId,tpl.intItemUOMId,l.dblQty) End, 0) 
	- ISNULL((Select ISNULL(SUM(ISNULL(dblQty,0)),0) From tblICStockReservation Where intLotId=tpl.intLotId AND ysnPosted=0), 0)) 
	End AS dblAvailableQty,
	CASE WHEN tpl.intItemUOMId=tpl.intItemIssuedUOMId THEN 1 ELSE ISNULL(tpl.dblWeightPerUnit, 1) END AS dblWeightPerUnit,
	tpl.intRecipeItemId,
	l.intParentLotId,
	pl.strParentLotNumber,
	0.0 AS dblStagedQty,
	ls.strSecondaryStatus AS strLotStatus,
	tpl.strSubLocationName,
	tpl.strLocationName,
	i.strLotTracking,
	i.intCategoryId,
    tpl.intSubLocationId,
    tpl.intStorageLocationId,
	ISNULL(i.ysnHandAddIngredient,0) AS ysnHandAddIngredient
	From @tblPickedLots tpl 
	Left Join tblICLot l on tpl.intLotId=l.intLotId
	Left Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId
	Left Join tblICLotStatus ls on l.intLotStatusId=ls.intLotStatusId
	Join tblICItem i on tpl.intItemId=i.intItemId
End