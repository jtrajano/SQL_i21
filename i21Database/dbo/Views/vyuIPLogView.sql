CREATE VIEW vyuIPLogView
AS
SELECT L.intLogId
	,L.dtmDate
	,E.strName
	,L.strRoute
FROM tblSMLog L
JOIN tblEMEntity E on E.intEntityId=L.intEntityId
WHERE L.strType = 'Audit' 
