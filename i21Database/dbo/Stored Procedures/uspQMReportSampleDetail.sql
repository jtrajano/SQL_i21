-- Exec uspQMReportSampleDetail '<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intSampleId</fieldname><condition>EQUAL TO</condition><from>37</from><join /><begingroup /><endgroup /><datatype>Int32</datatype></filter></filters></xmlparam>'
CREATE PROCEDURE uspQMReportSampleDetail
     @xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intSampleId INT
		,@xmlDocumentId INT
	DECLARE @strCompanyName NVARCHAR(100)
		,@strCompanyAddress NVARCHAR(100)
		,@strCity NVARCHAR(25)
		,@strState NVARCHAR(50)
		,@strZip NVARCHAR(12)
		,@strCountry NVARCHAR(25)

	SELECT TOP 1 @strCompanyName = strCompanyName
		,@strCompanyAddress = strAddress
		,@strCity = strCity
		,@strState = strState
		,@strZip = strZip
		,@strCountry = strCountry
	FROM tblSMCompanySetup

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	IF (@xmlParam IS NULL)
	BEGIN
		SELECT 0 intSampleId
			,'' strSampleNumber
			,'' strSampleTypeName
			,'' strContractNumber
			,'' strShipmentNumber
			,'' strContainerNumber
			,'' strItemNo
			,'' strItemDescription
			,'' strPartyName
			,'' strReceiptWONo
			,'' strLotNumber
			,'' strLotStatus
			,'' strCountry
			,'' strSampleQtyUOM
			,'' strRepresentingQtyUOM
			,'' dtmSampleReceivedDate
			,'' strSampleNote
			,'' strSampleStatus
			,'' strRefNo
			,'' strMarks
			,'' strSamplingMethod
			,@strCompanyName AS strCompanyName
			,@strCompanyAddress AS strCompanyAddress
			,@strCity + ', ' + @strState + ', ' + @strZip AS strCityStateZip
			,@strCountry AS strCompanyCountry

		RETURN
	END

	DECLARE @temp_xml_table TABLE (
		[fieldname] NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
		)

	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT
		,@xmlParam

	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) WITH (
			[fieldname] NVARCHAR(50)
			,condition NVARCHAR(20)
			,[from] NVARCHAR(50)
			,[to] NVARCHAR(50)
			,[join] NVARCHAR(10)
			,[begingroup] NVARCHAR(50)
			,[endgroup] NVARCHAR(50)
			,[datatype] NVARCHAR(50)
			)

	SELECT @intSampleId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intSampleId'

	-- To check whether the sample is available
	DECLARE @intOrgSampleId INT

	SELECT @intOrgSampleId = intSampleId
	FROM tblQMSample
	WHERE intSampleId = @intSampleId

	IF (@intOrgSampleId IS NULL)
	BEGIN
		SELECT 0 intSampleId
			,'' strSampleNumber
			,'' strSampleTypeName
			,'' strContractNumber
			,'' strShipmentNumber
			,'' strContainerNumber
			,'' strItemNo
			,'' strItemDescription
			,'' strPartyName
			,'' strReceiptWONo
			,'' strLotNumber
			,'' strLotStatus
			,'' strCountry
			,'' strSampleQtyUOM
			,'' strRepresentingQtyUOM
			,'' dtmSampleReceivedDate
			,'' strSampleNote
			,'' strSampleStatus
			,'' strRefNo
			,'' strMarks
			,'' strSamplingMethod
			,@strCompanyName AS strCompanyName
			,@strCompanyAddress AS strCompanyAddress
			,@strCity + ', ' + @strState + ', ' + @strZip AS strCityStateZip
			,@strCountry AS strCompanyCountry

		RETURN
	END

	SELECT S.intSampleId
		,S.strSampleNumber
		,ST.strSampleTypeName
		,ISNULL(CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq), '') AS strContractNumber
		,ISNULL(L.strLoadNumber, '') AS strShipmentNumber
		,ISNULL(LC.strContainerNumber, '') AS strContainerNumber
		,I.strItemNo
		,I.strDescription AS strItemDescription
		,ISNULL(E.strName, '') AS strPartyName
		,ISNULL(ISNULL(IR.strReceiptNumber, WO.strWorkOrderNo), '') AS strReceiptWONo
		,ISNULL(S.strLotNumber, '') AS strLotNumber
		,ISNULL(LS.strSecondaryStatus, '') AS strLotStatus
		,ISNULL(S.strCountry, '') AS strCountry
		,dbo.fnRemoveTrailingZeroes(ISNULL(S.dblSampleQty, 0)) + ' ' + UM.strUnitMeasure AS strSampleQtyUOM
		,dbo.fnRemoveTrailingZeroes(ISNULL(S.dblRepresentingQty, 0)) + ' ' + UM1.strUnitMeasure AS strRepresentingQtyUOM
		,S.dtmSampleReceivedDate
		,ISNULL(S.strSampleNote, '') AS strSampleNote
		,SS.strStatus AS strSampleStatus
		,ISNULL(S.strRefNo, '') AS strRefNo
		,ISNULL(S.strMarks, '') AS strMarks
		,ISNULL(S.strSamplingMethod, '') AS strSamplingMethod
		,@strCompanyName AS strCompanyName
		,@strCompanyAddress AS strCompanyAddress
		,@strCity + ', ' + @strState + ', ' + @strZip AS strCityStateZip
		,@strCountry AS strCompanyCountry
	FROM tblQMSample S
	JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
		AND S.intSampleId = @intSampleId
	JOIN tblICItem I ON I.intItemId = S.intItemId
	JOIN tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = S.intContractDetailId
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblLGLoad L ON L.intLoadId = S.intLoadId
	LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = S.intLoadContainerId
	LEFT JOIN tblEMEntity E ON E.intEntityId = S.intEntityId
	LEFT JOIN tblICLotStatus LS ON LS.intLotStatusId = S.intLotStatusId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = S.intSampleUOMId
	LEFT JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = S.intRepresentingUOMId
	LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = S.intInventoryReceiptId
	LEFT JOIN tblMFWorkOrder WO ON WO.intWorkOrderId = S.intWorkOrderId
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspQMReportSampleDetail - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
