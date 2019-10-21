CREATE VIEW vyuMFGetReasonCode
AS
SELECT RC.intReasonCodeId
	,RC.strReasonCode
	,RC.strDescription
	,RC.ysnReduceavailabletime
	,RC.ysnExplanationrequired
	,RC.ysnActive
	,RC.ysnDefault
	,RT.strReasonName
	,ITT.intTransactionTypeId
	,ISNULL(ITT.strName,'') AS strName
FROM dbo.tblMFReasonCode RC
JOIN dbo.tblMFReasonType RT ON RT.intReasonTypeId = RC.intReasonTypeId
LEFT JOIN dbo.tblICInventoryTransactionType ITT ON ITT.intTransactionTypeId = RC.intTransactionTypeId
