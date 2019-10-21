CREATE VIEW vyuMFGetReasonDowntime
AS
SELECT RD.intReasonCodeDetailId
	,RD.intManufacturingCellId
	,RC.intReasonCodeId
	,RC.strReasonCode
	,RC.strDescription
	,RC.ysnReduceavailabletime
	,RC.ysnExplanationrequired
	,RC.intReasonTypeId
	,RC.ysnActive
FROM tblMFReasonCode RC
JOIN tblMFReasonCodeDetail RD ON RD.intReasonCodeId = RC.intReasonCodeId
