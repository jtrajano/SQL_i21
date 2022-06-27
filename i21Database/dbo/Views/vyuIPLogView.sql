CREATE VIEW vyuIPLogView
AS
SELECT L.intLogId
	,L.dtmDate
	,E.strName
	,L.strRoute COLLATE Latin1_General_CI_AS AS strRoute
FROM tblSMLog L
JOIN tblEMEntity E on E.intEntityId=L.intEntityId
WHERE L.strType = 'Audit' 
