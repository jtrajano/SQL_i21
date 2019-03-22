CREATE VIEW vyuMFGetWorkOrderItem
AS
SELECT W.intWorkOrderId
	,W.strWorkOrderNo
	,W.intItemId
	,I.strItemNo
	,I.strDescription
	,W.intLocationId
FROM tblMFWorkOrder W
JOIN tblICItem I ON I.intItemId = W.intItemId
