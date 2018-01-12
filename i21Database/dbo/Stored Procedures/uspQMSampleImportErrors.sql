CREATE PROCEDURE uspQMSampleImportErrors
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SELECT intSampleImportErrorId
	,intSampleImportId
	,intConcurrencyId
	--,CONVERT(DATETIME, dtmSampleReceivedDate, 101) dtmSampleReceivedDate
	,dtmSampleReceivedDate AS strSampleReceivedDate
	,strSampleNumber
	,strItemNumber
	,strSampleTypeName
	,strVendorName
	,strContractNumber
	,strContainerNumber
	,strMarks
	,strSampleNote
	,strHeaderComment
	,strWarehouse
	,dblSequenceQuantity
	,strQuantityUOM
	,strSampleStatus
	,strPropertyName
	,strPropertyValue
	,strComment
	,strResult
	,strErrorMsg
	,intCreatedUserId
	,dtmCreated
FROM tblQMSampleImportError