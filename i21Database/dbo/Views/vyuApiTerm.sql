CREATE VIEW [dbo].[vyuApiTerm]
AS

SELECT
      t.ysnActive
    , t.ysnAllowEFT
    , t.intBalanceDue
    , t.intDiscountDay
    , t.dblDiscountEP
    , t.intTermID
    , t.strTerm
    , t.strTermCode
    , t.strType
    , created.dtmDate dtmDateCreated
	, COALESCE(updated.dtmDate, created.dtmDate) dtmDateLastUpdated
FROM tblSMTerm t
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = t.intTermID
		AND au.strAction = 'Created'
		AND au.strNamespace = 'i21.view.Term'
) created
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = t.intTermID
		AND au.strAction = 'Updated'
		AND au.strNamespace = 'i21.view.Term'
) updated
