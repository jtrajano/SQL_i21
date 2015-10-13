CREATE PROCEDURE dbo.uspMFGetWorkOrderByLot (@intLotId INT) 
AS
BEGIN
	
	SELECT W.intWorkOrderId
		,W.strWorkOrderNo
		,W.dtmOrderDate
		,W.dtmExpectedDate
		,WL.intLotId
		,WL.intCreatedUserId
		,US.strUserName
		,WS.intStatusId
		,WS.strName
		,WL.dblQuantity
		,U1.intUnitMeasureId AS intWeightUnitMeasureId
		,U1.strUnitMeasure AS strWeightUnitMeasure
		,WL.dblIssuedQuantity
		,U.intUnitMeasureId
		,U.strUnitMeasure
		,W.intOrderHeaderId
		,W.strBOLNo AS strPickNo
		,ISNULL(OS.strOrderStatus, WS.strName) AS strPickStatus
	FROM dbo.tblMFWorkOrder W
	JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
	JOIN dbo.tblMFWorkOrderInputLot WL ON WL.intWorkOrderId = W.intWorkOrderId
	JOIN dbo.tblSMUserSecurity US ON US.[intEntityUserSecurityId] = W.intCreatedUserId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = WL.intItemUOMId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = WL.intItemIssuedUOMId
	JOIN dbo.tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU1.intUnitMeasureId
	LEFT JOIN dbo.tblWHOrderHeader OH ON OH.intOrderHeaderId = W.intOrderHeaderId
	LEFT JOIN dbo.tblWHOrderStatus OS ON OS.intOrderStatusId = OH.intOrderStatusId
	WHERE WL.intLotId=@intLotId
	ORDER BY W.dtmOrderDate
END
