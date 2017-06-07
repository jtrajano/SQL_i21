CREATE PROCEDURE uspMFGetProductionDetail (@intWorkOrderId INT)
AS
BEGIN
	SELECT W.intWorkOrderProducedLotId
		,L.intLotId
		,L.strLotNumber
		,I.strItemNo
		,I.strDescription
		,CASE 
			WHEN IU.ysnStockUnit = 1
				THEN W.dblQuantity
			ELSE W.dblPhysicalCount
			END AS dblQuantity
		,CASE 
			WHEN IU.ysnStockUnit = 1
				THEN IU.intItemUOMId
			ELSE IU1.intItemUOMId
			END AS intItemUOMId
		,CASE 
			WHEN IU.ysnStockUnit = 1
				THEN U.intUnitMeasureId
			ELSE U1.intUnitMeasureId
			END AS intUnitMeasureId
		,CASE 
			WHEN IU.ysnStockUnit = 1
				THEN U.strUnitMeasure
			ELSE U1.strUnitMeasure
			END AS strUnitMeasure
		,W.dtmProductionDate As dtmCreated
		,W.intCreatedUserId
		,US.strUserName
		,W.intWorkOrderId
		,SL.intStorageLocationId
		,SL.strName AS strStorageLocationName
		,W.ysnProductionReversed
		,W.strReferenceNo
		,C.intContainerId
		,C.strContainerId
		,S.intShiftId
		,S.strShiftName
		,W.intBatchId
		,L.intParentLotId
		,W.strBatchId
		,W.ysnFillPartialPallet
		,I.intCategoryId
		,LS.strSecondaryStatus AS strLotStatus
		,PL.strParentLotNumber
		,L1.strLotNumber AS strSpecialPalletId
	FROM dbo.tblMFWorkOrderProducedLot W
	LEFT JOIN dbo.tblICLot L ON L.intLotId = W.intLotId
	LEFT JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = W.intPhysicalItemUOMId
	JOIN dbo.tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU1.intUnitMeasureId
	JOIN dbo.tblSMUserSecurity US ON US.[intEntityId] = W.intCreatedUserId
	LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = W.intStorageLocationId
	LEFT JOIN dbo.tblICContainer C ON C.intContainerId = W.intContainerId
	LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intShiftId
	LEFT JOIN tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
	LEFT JOIN dbo.tblICLot L1 ON L1.intLotId = W.intSpecialPalletLotId
	WHERE intWorkOrderId = @intWorkOrderId
	ORDER BY W.intWorkOrderProducedLotId
END
