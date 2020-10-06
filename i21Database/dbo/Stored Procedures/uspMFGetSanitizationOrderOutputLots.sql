CREATE PROCEDURE uspMFGetSanitizationOrderOutputLots @intLocationId INT
	,@intWorkOrderId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SELECT WP.intWorkOrderProducedLotId
	,IL.intLotId AS intInputLotId
	,IL.strLotNumber AS strInputLotNumber
	,L.intLotId
	,L.strLotNumber
	,I.strType
	,I.intItemId
	,I.strItemNo
	,I.strDescription
	,WP.intUnitPerLayer
	,WP.intLayerPerPallet
	,WL.dblQuantity
	,U.intUnitMeasureId AS intWeightUnitMeasureId
	,U.strUnitMeasure AS strWeightUnitMeasure
	,WP.dblPhysicalCount
	,U1.intUnitMeasureId
	,U1.strUnitMeasure
	,WP.dblWeightPerUnit
	,SL.intStorageLocationId
	,SL.intSubLocationId
	,SL.strName
	,Convert(INT, Ceiling(WP.dblPhysicalCount / (WP.intUnitPerLayer * WP.intLayerPerPallet))) AS intNoOfPallet
	,WP.intBatchId
FROM dbo.tblMFWorkOrderProducedLot WP
JOIN dbo.tblICLot L ON L.intLotId = WP.intLotId
	AND WP.intWorkOrderId = @intWorkOrderId
JOIN dbo.tblMFWorkOrderConsumedLot WL ON WL.intLotId = WP.intInputLotId
JOIN dbo.tblICLot IL ON IL.intLotId = WL.intLotId
JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = WP.intItemUOMId
JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = WP.intPhysicalItemUOMId
JOIN dbo.tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU1.intUnitMeasureId
JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
ORDER BY WP.intBatchId
