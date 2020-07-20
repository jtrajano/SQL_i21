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

	SELECT @intDemandScreenId = intScreenId
	FROM tblSMScreen
	WHERE strNamespace = 'Manufacturing.view.DemandAnalysisView'

	SELECT @intTransactionId = intTransactionId
	FROM tblSMTransaction
	WHERE intRecordId = @intInvPlngReportMasterID
		AND intScreenId = @intDemandScreenId

	IF @strRowState = 'Delete'
	BEGIN
		INSERT INTO tblMFDemandStage (
			intInvPlngReportMasterID
			,strRowState
			,intTransactionId
			,intCompanyId
			)
		SELECT intInvPlngReportMasterID = @intInvPlngReportMasterID
			,strRowState = @strRowState
			,intTransactionId = @intTransactionId
			,intCompanyId = @intCompanyId

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
	WHERE IsNUll(intCompanyId, 0) > 0

	SELECT @strHeaderCondition = 'intCompanyId = ' + LTRIM(@intCompanyId)

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemSupplyTargetXML OUTPUT
		,NULL
		,NULL

	SELECT @strBook = strBook
		,@strSubBook = strSubBook
		,@strInvPlngReportName = strInvPlngReportName
	FROM vyuMFInvPlngReportMaster
	WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID

	SELECT @strAdditionalInfo = @strAdditionalInfo + '<strBook>' + @strBook + '</strBook>'

	IF IsNULL(@strSubBook, '') <> ''
	BEGIN
		SELECT @strAdditionalInfo = @strAdditionalInfo + '<strSubBook>' + @strSubBook + '</strSubBook>'
	END

	SELECT @strAdditionalInfo = @strAdditionalInfo + '</vyuMFGetItemSupplyTargets>'

	SELECT @strItemSupplyTargetXML = Replace(@strItemSupplyTargetXML, '</vyuMFGetItemSupplyTargets>', @strAdditionalInfo)

	DECLARE @strSQL NVARCHAR(MAX)
		,@strServerName NVARCHAR(50)
		,@strDatabaseName NVARCHAR(50)

	SELECT @strServerName = strServerName
		,@strDatabaseName = strDatabaseName
	FROM tblIPMultiCompany
	WHERE ysnParent = 1

	IF EXISTS (
			SELECT 1
			FROM master.dbo.sysdatabases
			WHERE name = @strDatabaseName
			)
	BEGIN
		SELECT @strSQL = N'INSERT INTO ' + @strServerName + '.' + @strDatabaseName + '.dbo.tblMFDemandStage (
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
		,strInvPlngReportName = @strInvPlngReportName
		,strReportMasterXML = @strReportMasterXML
		,strReportMaterialXML = @strReportMaterialXML
		,strReportAttributeValueXML = @strReportAttributeValueXML
		,strRowState = @strRowState
		,intTransactionId = @intTransactionId
		,intCompanyId = @intCompanyId
		,strItemSupplyTarget = @strItemSupplyTargetXML'

		EXEC sp_executesql @strSQL
			,N'@intInvPlngReportMasterID int
		,@strInvPlngReportName nvarchar(50)
		,@strReportMasterXML nvarchar(MAX)
		,@strReportMaterialXML nvarchar(MAX)
		,@strReportAttributeValueXML nvarchar(MAX)
		,@strRowState  nvarchar(50)
		,@intTransactionId int
		,@intCompanyId int
		,@strItemSupplyTargetXML nvarchar(MAX)'
			,@intInvPlngReportMasterID
			,@strInvPlngReportName
			,@strReportMasterXML
			,@strReportMaterialXML
			,@strReportAttributeValueXML
			,@strRowState
			,@intTransactionId
			,@intCompanyId
			,@strItemSupplyTargetXML
	END
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
