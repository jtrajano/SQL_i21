CREATE VIEW vyuQMCompanyPreference
AS
SELECT CP.intCompanyPreferenceId
	,CP.intConcurrencyId
	,CP.intNumberofDecimalPlaces
	,CP.ysnEnableParentLot
	,CP.ysnIsSamplePrintEnable
	,CP.intApproveLotStatus
	,CP.intRejectLotStatus
	,CP.ysnAllowReversalSampleEntry
	,CP.ysnChangeLotStatusOnApproveforPreSanitizeLot
	,CP.ysnRejectLGContainer
	,CP.intUserSampleApproval
	,CP.ysnFilterContractByERPPONumber
	,CP.ysnEnableSampleTypeByUserRole
	,CP.ysnShowSampleFromAllLocation
	,CP.ysnValidateMultipleValuesInTestResult
	,CP.strTestReportComments
	,CP.strSampleImportDateTimeFormat
	,CP.ysnCaptureItemInProperty
	,LS.strSecondaryStatus AS strApprovalLotStatus
	,LS1.strSecondaryStatus AS strRejectionLotStatus
FROM tblQMCompanyPreference CP
LEFT JOIN tblICLotStatus LS ON LS.intLotStatusId = CP.intApproveLotStatus
LEFT JOIN tblICLotStatus LS1 ON LS1.intLotStatusId = CP.intRejectLotStatus
