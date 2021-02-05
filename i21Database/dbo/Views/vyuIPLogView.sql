CREATE VIEW vyuIPLogView
AS
SELECT L.intLogId
	,L.dtmDate
	,L.intEntityId
	,L.strRoute
FROM tblSMLog L
WHERE L.strType = 'Audit' 
