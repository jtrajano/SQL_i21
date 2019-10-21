CREATE PROCEDURE uspMFGetWOPickListDetail @intWorkOrderId INT
AS
BEGIN
	SELECT OH.intOrderHeaderId
		,OH.strOrderNo
		,OH.dtmOrderDate
		,OS.strOrderStatus
		,OH.strComment
		,US.strUserName
	FROM tblMFOrderHeader OH
	JOIN tblMFStageWorkOrder SW ON SW.intOrderHeaderId = OH.intOrderHeaderId
	JOIN tblMFOrderStatus OS ON OS.intOrderStatusId = OH.intOrderStatusId
	JOIN tblSMUserSecurity US ON US.intEntityId = OH.intCreatedById
	WHERE SW.intWorkOrderId = @intWorkOrderId
		AND OH.intOrderTypeId = 1 -- WO PROD STAGING
END
