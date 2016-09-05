CREATE VIEW vyuMFWastageWorkOrder
AS
-- Work Order
SELECT DISTINCT WO.intWorkOrderId
	,WO.strWorkOrderNo
	,ISNULL(WO.dtmPlannedDate, WO.dtmExpectedDate) AS dtmWorkOrderDate -- 2 days Filter
	,WO.intManufacturingCellId
FROM tblMFWorkOrder WO
