CREATE PROCEDURE [dbo].[uspMFDemandPopulateStgXML] @intInvPlngReportMasterID INT
	,@strRowState NVARCHAR(50)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strObjectName NVARCHAR(50)
		,@strHeaderCondition NVARCHAR(50)
		,@strReportMasterXML NVARCHAR(MAX)
		,@strReportMaterialXML NVARCHAR(MAX)
		,@strReportAttributeValueXML NVARCHAR(MAX)
		,@intCompanyId INT
		,@intTransactionId INT
		,@intDemandScreenId INT
		,@strItemSupplyTargetXML NVARCHAR(MAX)
		,@strBook NVARCHAR(50)
		,@strSubBook NVARCHAR(50)
		,@strAdditionalInfo NVARCHAR(MAX) = ''
		,@strItemSupplyTarget NVARCHAR(MAX)
		,@strInvPlngReportName NVARCHAR(150)

	IF @strRowState = 'Delete'
	BEGIN
		INSERT INTO tblMFDemandStage (
			intInvPlngReportMasterID
			,strRowState
			)
		SELECT intInvPlngReportMasterID = @intInvPlngReportMasterID
			,strRowState = @strRowState

		RETURN
	END

	-------------------------Header-----------------------------------------------------------
	SELECT @strHeaderCondition = 'intInvPlngReportMasterID = ' + LTRIM(@intInvPlngReportMasterID)

	SELECT @strObjectName = 'vyuMFInvPlngReportMaster'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strReportMasterXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuMFInvPlngReportMaterial'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strReportMaterialXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuMFInvPlngReportAttributeValue'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strReportAttributeValueXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuMFGetItemSupplyTarget'

	SELECT @intCompanyId = intCompanyId
	FROM tblICItem
	Where IsNUll(intCompanyId,0) >0

	SELECT @strHeaderCondition = 'intCompanyId = ' + LTRIM(@intCompanyId)

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemSupplyTargetXML OUTPUT
		,NULL
		,NULL

	SELECT @strBook = strBook
		,@strSubBook = strSubBook
		,@strInvPlngReportName=strInvPlngReportName
	FROM vyuMFInvPlngReportMaster
	WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID

	SELECT @strAdditionalInfo = @strAdditionalInfo + '<strBook>' + @strBook + '</strBook>'

	IF IsNULL(@strSubBook, '') <> ''
	BEGIN
		SELECT @strAdditionalInfo = @strAdditionalInfo + '<strSubBook>' + @strSubBook + '</strSubBook>'
	END

	SELECT @strAdditionalInfo = @strAdditionalInfo + '</vyuMFGetItemSupplyTargets>'

	SELECT @strItemSupplyTargetXML= Replace(@strItemSupplyTargetXML, '</vyuMFGetItemSupplyTargets>', @strAdditionalInfo)

	SELECT @intDemandScreenId = intScreenId
	FROM tblSMScreen
	WHERE strNamespace = 'Manufacturing.view.DemandAnalysisView'

	SELECT @intTransactionId = intTransactionId
	FROM tblSMTransaction
	WHERE intRecordId = @intInvPlngReportMasterID
		AND intScreenId = @intDemandScreenId

	INSERT INTO tblMFDemandStage (
		intInvPlngReportMasterID
		,strInvPlngReportName
		,strReportMasterXML
		,strReportMaterialXML
		,strReportAttributeValueXML
		,strRowState
		,intTransactionId
		,intCompanyId
		,strItemSupplyTarget
		)
	SELECT intInvPlngReportMasterID = @intInvPlngReportMasterID
		,strInvPlngReportName=@strInvPlngReportName
		,strReportMasterXML = @strReportMasterXML
		,strReportMaterialXML = @strReportMaterialXML
		,strReportAttributeValueXML = @strReportAttributeValueXML
		,strRowState = @strRowState
		,intTransactionId = @intTransactionId
		,intCompanyId = @intCompanyId
		,strItemSupplyTarget = @strItemSupplyTargetXML
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
