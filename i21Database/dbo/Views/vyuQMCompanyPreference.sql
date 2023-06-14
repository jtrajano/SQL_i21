CREATE VIEW vyuQMCompanyPreference
AS
SELECT CP.intCompanyPreferenceId
	 , CP.intConcurrencyId
	 , CP.intNumberofDecimalPlaces
	 , CP.ysnEnableParentLot
	 , CP.ysnIsSamplePrintEnable
	 , CP.intApproveLotStatus
	 , CP.intRejectLotStatus
	 , CP.ysnAllowReversalSampleEntry
	 , CP.ysnChangeLotStatusOnApproveforPreSanitizeLot
	 , CP.ysnRejectLGContainer
	 , CP.intUserSampleApproval
	 , CP.ysnFilterContractByERPPONumber
	 , CP.ysnEnableSampleTypeByUserRole
	 , CP.ysnShowSampleFromAllLocation
	 , CP.ysnValidateMultipleValuesInTestResult
	 , CP.strTestReportComments
	 , CP.strSampleImportDateTimeFormat
	 , CP.ysnCaptureItemInProperty
	 , CP.ysnEnableAssignContractsInSample
	 , LS.strSecondaryStatus AS strApprovalLotStatus
	 , LS1.strSecondaryStatus AS strRejectionLotStatus
	 , CP.ysnEnableContractSequencesTabInSampleSearchScreen
	 , CP.strSampleInstructionReport
	 , CP.intDefaultSampleStatusId
	 , QMSS.strStatus AS strDefaultSampleStatus
	 , ISNULL(CP.intDefaultSampleStatusId, QMSS1.intSampleStatusId) AS intBlankDefaultSampleStatusId
	 , ISNULL(QMSS.strStatus, QMSS1.strStatus) AS strBlankDefaultSampleStatus
	 , CP.ysnSetDefaultReceivedDateInSampleScreen
	 , CP.intCuppingSessionLimit
	 , ISNULL(CP.intSamplePrintEmailTemplate, 0) AS intSamplePrintEmailTemplate
	 , CASE WHEN ISNULL(CP.intSamplePrintEmailTemplate, 0) = 0 THEN 
				'Default'
			ELSE
				'Strauss Template 01'
	   END AS strSamplePrintEmailTemplate
	 , CP.ysnAllowEditingAfterSampleApproveReject
	 , CP.ysnAllowEditingTheItemNo
	 , CP.ysnAllowEditingTheOrigin
	 , CP.ysnValidateLotNo
	 , CP.ysnFilterSupplierByLocation
	 , CP.ysnCreateBatchOnSampleSave
	 , CP.ysnValidateSampleQty
FROM tblQMCompanyPreference CP
LEFT JOIN tblICLotStatus LS ON LS.intLotStatusId = CP.intApproveLotStatus
LEFT JOIN tblICLotStatus LS1 ON LS1.intLotStatusId = CP.intRejectLotStatus
LEFT JOIN tblQMSampleStatus QMSS ON CP.intDefaultSampleStatusId = QMSS.intSampleStatusId
OUTER APPLY (SELECT TOP 1 intSampleStatusId, strStatus
			 FROM tblQMSampleStatus
			 WHERE strStatus = 'Received') QMSS1