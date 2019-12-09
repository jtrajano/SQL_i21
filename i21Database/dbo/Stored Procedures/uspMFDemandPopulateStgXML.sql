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
		,@intCompanyId int
        ,@intTransactionId int
		,@intDemandScreenId int

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

	 SELECT    @intDemandScreenId    =    intScreenId 
	 FROM tblSMScreen 
	 WHERE strNamespace = 'Manufacturing.view.DemandAnalysisView'

    Select @intTransactionId=intTransactionId 
    from tblSMTransaction
    Where intRecordId =@intInvPlngReportMasterID
    and intScreenId =@intDemandScreenId

	INSERT INTO tblMFDemandStage (
		intInvPlngReportMasterID
		,strReportMasterXML
		,strReportMaterialXML
		,strReportAttributeValueXML
		,strRowState
		,intTransactionId 
        ,intCompanyId 
		)
	SELECT intInvPlngReportMasterID = @intInvPlngReportMasterID
		,strReportMasterXML = @strReportMasterXML
		,strReportMaterialXML = @strReportMaterialXML
		,strReportAttributeValueXML = @strReportAttributeValueXML
		,strRowState = @strRowState
		,intTransactionId=@intTransactionId
        ,intCompanyId=@intCompanyId
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

