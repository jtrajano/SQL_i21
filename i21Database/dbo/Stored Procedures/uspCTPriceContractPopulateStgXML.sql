CREATE PROCEDURE [dbo].[uspCTPriceContractPopulateStgXML] @intPriceContractId INT
	,@intToEntityId INT
	,@strToTransactionType NVARCHAR(100)
	,@intToCompanyId INT
	,@strRowState NVARCHAR(100)
	,@ysnReplication BIT = 1
	,@ysnProcessApproverInfo BIT = 0
	,@ysnApproval BIT = 0
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strPriceContractNo NVARCHAR(100)
		,@strPriceContractXML NVARCHAR(MAX)
		,@strPriceContractCondition NVARCHAR(MAX)
		,@strPriceFixationXML NVARCHAR(MAX)
		,@strPriceFixationAllId NVARCHAR(MAX)
		,@strPriceFixationDetailXML NVARCHAR(MAX)
		,@strPriceFixationCondition NVARCHAR(MAX)
		,@intPriceContractStageId INT
		,@intMultiCompanyId INT
		,@strObjectName NVARCHAR(50)
		,@intCompanyId INT
		,@intTransactionId INT
		,@intContractScreenId INT
		,@strApproverXML NVARCHAR(MAX)
		,@strSubmittedByXML NVARCHAR(MAX)
		,@strAdditionalInfo NVARCHAR(MAX)
		,@strLogCondition NVARCHAR(50)
		,@strLogXML NVARCHAR(MAX)
		,@strAuditXML NVARCHAR(MAX)
		,@intLogId INT
		,@intContractHeaderId INT
		,@strContractNumber NVARCHAR(50)
		,@intBookId INT
		,@intSubBookId INT

	SET @intPriceContractStageId = NULL
	SET @strPriceContractNo = NULL
	SET @strPriceContractXML = NULL
	SET @strPriceContractCondition = NULL
	SET @strPriceFixationXML = NULL
	SET @strLogCondition = NULL

	SELECT @intBookId = NULL

	SELECT @intSubBookId = NULL

	IF @strRowState = 'Delete'
	BEGIN
		INSERT INTO tblCTPriceContractStage (
			intPriceContractId
			,strRowState
			,intEntityId
			,strTransactionType
			,intMultiCompanyId
			)
		SELECT intPriceContractId = @intPriceContractId
			,strRowState = @strRowState
			,intEntityId = @intToEntityId
			,strTransactionType = @strToTransactionType
			,intMultiCompanyId = @intToCompanyId

		RETURN
	END

	SELECT @strPriceContractNo = strPriceContractNo
		,@intCompanyId = intCompanyId
	FROM tblCTPriceContract
	WHERE intPriceContractId = @intPriceContractId

	SELECT @intContractHeaderId = intContractHeaderId
	FROM tblCTPriceFixation
	WHERE intPriceContractId = @intPriceContractId

	SELECT @strContractNumber = strContractNumber
		,@intBookId = intBookId
		,@intSubBookId = intSubBookId
	FROM tblCTContractHeader
	WHERE intContractHeaderId = @intContractHeaderId

	SELECT @intContractScreenId = intScreenId
	FROM tblSMScreen
	WHERE strNamespace = 'ContractManagement.view.PriceContracts'

	SELECT @intTransactionId = intTransactionId
	FROM tblSMTransaction
	WHERE intRecordId = @intPriceContractId
		AND intScreenId = @intContractScreenId

	SELECT TOP 1 @intLogId = intLogId
	FROM dbo.tblSMLog
	WHERE intTransactionId = @intTransactionId
	ORDER BY 1 DESC

	-------------------------PriceContract-----------------------------------------------------------
	SELECT @strPriceContractCondition = 'intPriceContractId = ' + LTRIM(@intPriceContractId)

	SELECT @strLogCondition = 'intLogId = ' + LTRIM(@intLogId)

	IF @ysnProcessApproverInfo = 0
	BEGIN
		-------------------------PriceContract-----------------------------------------------------------
		SELECT @strPriceContractCondition = 'intPriceContractId = ' + LTRIM(@intPriceContractId)

		SELECT @strObjectName = NULL

		IF @ysnReplication = 1
			SELECT @strObjectName = 'tblCTPriceContract'
		ELSE
			SELECT @strObjectName = 'vyuIPPriceContract'

		EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
			,@strPriceContractCondition
			,@strPriceContractXML OUTPUT
			,NULL
			,NULL

		SELECT @strAdditionalInfo = '<ysnApproval>' + Ltrim(@ysnApproval) + '</ysnApproval>'

		SELECT @strAdditionalInfo = @strAdditionalInfo + '</vyuIPPriceContract></vyuIPPriceContracts>'

		SELECT @strPriceContractXML = Replace(@strPriceContractXML, '</vyuIPPriceContract></vyuIPPriceContracts>', @strAdditionalInfo)

		---------------------------------------------PriceFixation------------------------------------------
		SET @strPriceFixationXML = NULL

		SELECT @strObjectName = NULL

		IF @ysnReplication = 1
			SELECT @strObjectName = 'tblCTPriceFixation'
		ELSE
			SELECT @strObjectName = 'vyuIPPriceFixation'

		EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
			,@strPriceContractCondition
			,@strPriceFixationXML OUTPUT
			,NULL
			,NULL

		---------------------------------------------PriceFixationDetail-----------------------------------------------
		SET @strPriceFixationDetailXML = NULL
		SET @strPriceFixationCondition = NULL

		SELECT @strPriceFixationAllId = STUFF((
					SELECT DISTINCT ',' + LTRIM(intPriceFixationId)
					FROM tblCTPriceFixation
					WHERE intPriceContractId = @intPriceContractId
					FOR XML PATH('')
					), 1, 1, '')

		SELECT @strPriceFixationCondition = 'intPriceFixationId IN (' + LTRIM(@strPriceFixationAllId) + ')'

		SELECT @strObjectName = NULL

		IF @ysnReplication = 1
			SELECT @strObjectName = 'tblCTPriceFixationDetail'
		ELSE
			SELECT @strObjectName = 'vyuIPPriceFixationDetail'

		EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
			,@strPriceFixationCondition
			,@strPriceFixationDetailXML OUTPUT
			,NULL
			,NULL
	END

	---------------------------------------------Approver------------------------------------------
	SELECT @strApproverXML = NULL
		,@strObjectName = NULL

	SELECT @strObjectName = 'vyuCTPriceContractApproverView'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strPriceContractCondition
		,@strApproverXML OUTPUT
		,NULL
		,NULL

	---------------------------------------------Submitted By------------------------------------------
	SELECT @strSubmittedByXML = NULL
		,@strObjectName = NULL

	SELECT @strObjectName = 'vyuIPPriceContractSubmittedByView'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strPriceContractCondition
		,@strSubmittedByXML OUTPUT
		,NULL
		,NULL

	---------------------------------------------Audit Log------------------------------------------
	IF @strLogCondition IS NOT NULL
	BEGIN
		SELECT @strLogXML = NULL
			,@strObjectName = NULL

		SELECT @strObjectName = 'vyuIPLogView'

		EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
			,@strLogCondition
			,@strLogXML OUTPUT
			,NULL
			,NULL

		---------------------------------------------Audit Log------------------------------------------
		SELECT @strAuditXML = NULL
			,@strObjectName = NULL

		SELECT @strObjectName = 'vyuIPAuditView'

		EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
			,@strLogCondition
			,@strAuditXML OUTPUT
			,NULL
			,NULL
	END

	DECLARE @strSQL NVARCHAR(MAX)
		,@strServerName NVARCHAR(50)
		,@strDatabaseName NVARCHAR(50)

	SELECT @strServerName = strServerName
		,@strDatabaseName = strDatabaseName
	FROM tblIPMultiCompany
	WHERE intCompanyId = @intToCompanyId

	IF EXISTS (
			SELECT 1
			FROM sys.databases
			WHERE name = @strDatabaseName
			)
	BEGIN
		SELECT @strSQL = N'INSERT INTO ' + @strServerName + '.' + @strDatabaseName + 
			'.dbo.tblCTPriceContractStage (
		intPriceContractId
		,strPriceContractNo
		,strPriceContractXML
		,strRowState
		,strPriceFixationXML
		,strPriceFixationDetailXML
		,strApproverXML
		,intEntityId
		,strTransactionType
		,intMultiCompanyId
		,intTransactionId 
		,intCompanyId 
		,strSubmittedByXML
		,strLogXML
		,strAuditXML
		,strContractNumber
		,intBookId
		,intSubBookId
		)
	SELECT intPriceContractId = @intPriceContractId
		,strPriceContractNo = @strPriceContractNo
		,strPriceContractXML = @strPriceContractXML
		,strRowState = @strRowState
		,strPriceFixationXML = @strPriceFixationXML
		,strPriceFixationDetailXML = @strPriceFixationDetailXML
		,strApproverXML=@strApproverXML
		,intEntityId = @intToEntityId
		,strTransactionType = @strToTransactionType
		,intMultiCompanyId = @intToCompanyId
		,intTransactionId =@intTransactionId
		,intCompanyId =@intCompanyId
		,strSubmittedByXML=@strSubmittedByXML
		,strLogXML=@strLogXML
		,strAuditXML=@strAuditXML
		,strContractNumber=@strContractNumber
		,intBookId=@intBookId
		,intSubBookId=@intSubBookId'

		EXEC sp_executesql @strSQL
			,N'@intPriceContractId int, 
			@strPriceContractNo nvarchar(50),
			@strPriceContractXML nvarchar(MAX),
			@strRowState nvarchar(50),
			@strPriceFixationXML nvarchar(MAX),
			@strPriceFixationDetailXML nvarchar(MAX),
			@strApproverXML nvarchar(MAX),
			@intToEntityId int,
			@strToTransactionType nvarchar(50),
			@intToCompanyId int,
			@intTransactionId int,
			@intCompanyId int,
			@strSubmittedByXML nvarchar(MAX),
			@strLogXML nvarchar(MAX),
			@strAuditXML nvarchar(MAX),
			@strContractNumber nvarchar(50),
			@intBookId int,
			@intSubBookId int'
			,@intPriceContractId
			,@strPriceContractNo
			,@strPriceContractXML
			,@strRowState
			,@strPriceFixationXML
			,@strPriceFixationDetailXML
			,@strApproverXML
			,@intToEntityId
			,@strToTransactionType
			,@intToCompanyId
			,@intTransactionId
			,@intCompanyId
			,@strSubmittedByXML
			,@strLogXML
			,@strAuditXML
			,@strContractNumber
			,@intBookId
			,@intSubBookId
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
