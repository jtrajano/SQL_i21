CREATE VIEW vyuIPAmendmentApproval
AS
SELECT strDataIndex
	,IsNULL(ysnApproval, 0) AS ysnApproval
FROM tblCTAmendmentApproval
