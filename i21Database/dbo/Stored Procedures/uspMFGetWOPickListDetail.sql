CREATE PROCEDURE uspMFGetWOPickListDetail @intWorkOrderId INT
AS
BEGIN
	SELECT OH.intOrderHeaderId
		,OH.strOrderNo
		,OH.dtmOrderDate
		,OS.strOrderStatus
		,OH.strComment
	FROM tblMFOrderHeader OH
	JOIN tblMFStageWorkOrder SW ON SW.intOrderHeaderId = OH.intOrderHeaderId
	JOIN tblMFOrderStatus OS ON OS.intOrderStatusId = OH.intOrderStatusId
	WHERE SW.intWorkOrderId = @intWorkOrderId
		AND OH.intOrderTypeId = 1 -- WO PROD STAGING
END
