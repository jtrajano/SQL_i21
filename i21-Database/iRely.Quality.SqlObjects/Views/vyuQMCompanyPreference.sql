CREATE VIEW vyuQMCompanyPreference
AS
SELECT CP.*
	,LS.strSecondaryStatus AS strApprovalLotStatus
	,LS1.strSecondaryStatus AS strRejectionLotStatus
FROM tblQMCompanyPreference CP
LEFT JOIN tblICLotStatus LS ON LS.intLotStatusId = CP.intApproveLotStatus
LEFT JOIN tblICLotStatus LS1 ON LS1.intLotStatusId = CP.intRejectLotStatus
