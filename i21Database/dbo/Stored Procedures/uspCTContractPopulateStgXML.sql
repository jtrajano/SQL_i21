CREATE PROCEDURE [dbo].[uspCTContractPopulateStgXML] @ContractHeaderId INT
	,@intToEntityId INT
	,@intCompanyLocationId INT
	,@strToTransactionType NVARCHAR(100)
	,@intToCompanyId INT
	,@strRowState NVARCHAR(100)
	,@ysnReplication BIT = 1
	,@intToBookId INT = NULL
	,@ysnApproval BIT = 1
	,@ysnPopulateERPInfo BIT = 0
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strContractNumber NVARCHAR(100)
		,@strHeaderXML NVARCHAR(MAX)
		,@strHeaderCondition NVARCHAR(MAX)
		,@strDetailXML NVARCHAR(MAX)
		,@strContractDetailAllId NVARCHAR(MAX)
		,@strCostXML NVARCHAR(MAX)
		,@strDocumentXML NVARCHAR(MAX)
		,@strConditionXML NVARCHAR(MAX)
		,@strCertificationXML NVARCHAR(MAX)
		,@strCostCondition NVARCHAR(MAX)
		,@strApproverXML NVARCHAR(MAX)
		,@intContractStageId INT
		,@intMultiCompanyId INT
		,@strObjectName NVARCHAR(50)
		,@intSContractDetailId INT
		,@intPContractDetailId INT
		--,@intPContractHeaderId INT
		,@strExternalContractNumber NVARCHAR(50)
		,@strExternalEntity NVARCHAR(100)
		,@intEntityId INT
		,@strAdditionalInfo NVARCHAR(MAX)
		,@strAmendmentApprovalXML NVARCHAR(MAX)
		,@intCompanyId INT
		,@intTransactionId INT
		,@intContractScreenId INT
		,@strSubmittedByXML NVARCHAR(MAX)
		,@intPContractSeq INT
		,@strApprovalStatus NVARCHAR(150)
		,@strSQL NVARCHAR(MAX)
		,@strServerName NVARCHAR(50)
		,@strDatabaseName NVARCHAR(50)
		,@strLogCondition NVARCHAR(50)
		,@strLogXML NVARCHAR(MAX)
		,@strAuditXML NVARCHAR(MAX)
		,@intLogId INT

	SET @intContractStageId = NULL
	SET @strContractNumber = NULL
	SET @strHeaderXML = NULL
	SET @strHeaderCondition = NULL
	SET @strDetailXML = NULL
	SET @strLogCondition = NULL

	SELECT @strContractNumber = strContractNumber
		,@intCompanyId = intCompanyId
	FROM tblCTContractHeader
	WHERE intContractHeaderId = @ContractHeaderId

	SELECT @intContractScreenId = intScreenId
	FROM tblSMScreen
	WHERE strNamespace = 'ContractManagement.view.Contract'

	SELECT @intTransactionId = intTransactionId
		,@strApprovalStatus = strApprovalStatus
	FROM tblSMTransaction
	WHERE intRecordId = @ContractHeaderId
		AND intScreenId = @intContractScreenId

	SELECT TOP 1 @intLogId = intLogId
	FROM dbo.tblSMLog
	WHERE intTransactionId = @intTransactionId
	ORDER BY intLogId DESC

	IF @strRowState = 'Delete'
	BEGIN
		INSERT INTO tblCTContractStage (
			intContractHeaderId
			,strRowState
			,intEntityId
			,intCompanyLocationId
			,strTransactionType
			,intMultiCompanyId
			,intToBookId
			)
		SELECT intContractHeaderId = @ContractHeaderId
			,strRowState = @strRowState
			,intEntityId = @intToEntityId
			,intCompanyLocationId = @intCompanyLocationId
			,strTransactionType = @strToTransactionType
			,intMultiCompanyId = @intToCompanyId
			,intToBookId = @intToBookId

		RETURN
	END

	IF @ysnPopulateERPInfo = 1
	BEGIN
		SELECT @strDetailXML = NULL
			,@strObjectName = NULL

		SELECT @strHeaderCondition = 'intContractHeaderId = ' + LTRIM(@ContractHeaderId)

		SELECT @strObjectName = 'vyuIPContractDetailERPInfoView'

		EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
			,@strHeaderCondition
			,@strDetailXML OUTPUT
			,NULL
			,NULL

		SELECT @strServerName = strServerName
			,@strDatabaseName = strDatabaseName
		FROM tblIPMultiCompany
		WHERE ysnParent = 1
	END
	ELSE
	BEGIN
		-------------------------Header-----------------------------------------------------------
		SELECT @strHeaderCondition = 'intContractHeaderId = ' + LTRIM(@ContractHeaderId)

		SELECT @strLogCondition = 'intLogId = ' + LTRIM(@intLogId)

		IF @ysnReplication = 1
			SELECT @strObjectName = 'tblCTContractHeader'
		ELSE
			SELECT @strObjectName = 'vyuIPContractHeaderView'

		EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
			,@strHeaderCondition
			,@strHeaderXML OUTPUT
			,NULL
			,NULL

		SELECT @strAdditionalInfo = '<ysnApproval>' + Ltrim(@ysnApproval) + '</ysnApproval><strApprovalStatus>' + @strApprovalStatus + '</strApprovalStatus>'

		SELECT @strAdditionalInfo = @strAdditionalInfo + '</vyuIPContractHeaderView></vyuIPContractHeaderViews>'

		SELECT @strHeaderXML = Replace(@strHeaderXML, '</vyuIPContractHeaderView></vyuIPContractHeaderViews>', @strAdditionalInfo)

		SELECT @strExternalContractNumber = IsNULL(@strExternalContractNumber, '') + strContractNumber + '/' + Ltrim(CD.intContractSeq) + ','
			,@intEntityId = CH.intEntityId
		FROM tblCTContractDetail CD
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		WHERE CD.intContractDetailId IN (
				SELECT intPContractDetailId
				FROM tblLGAllocationDetail
				WHERE intSContractDetailId IN (
						SELECT intContractDetailId
						FROM tblCTContractDetail
						WHERE intContractHeaderId = @ContractHeaderId
						)
				)

		IF Len(@strExternalContractNumber) > 0
		BEGIN
			SELECT @strExternalContractNumber = Left(@strExternalContractNumber, len(@strExternalContractNumber) - 1)
		END

		SELECT @strExternalEntity = strName
		FROM tblEMEntity
		WHERE intEntityId = @intEntityId

		IF @strExternalContractNumber IS NOT NULL
		BEGIN
			SELECT @strAdditionalInfo = NULL

			SELECT @strAdditionalInfo = '<strExternalContractNumber>' + @strExternalContractNumber + '</strExternalContractNumber>'

			SELECT @strAdditionalInfo = @strAdditionalInfo + '<strExternalEntity>' + [dbo].[fnEscapeXML](@strExternalEntity) + '</strExternalEntity>'

			SELECT @strAdditionalInfo = @strAdditionalInfo + '</vyuIPContractHeaderView></vyuIPContractHeaderViews>'

			IF @strAdditionalInfo <> ''
				SELECT @strHeaderXML = Replace(@strHeaderXML, '</vyuIPContractHeaderView></vyuIPContractHeaderViews>', @strAdditionalInfo)
		END

		SET @intContractStageId = SCOPE_IDENTITY();

		---------------------------------------------Detail------------------------------------------
		SELECT @strDetailXML = NULL
			,@strObjectName = NULL

		IF @ysnReplication = 1
			SELECT @strObjectName = 'tblCTContractDetail'
		ELSE
			SELECT @strObjectName = 'vyuIPContractDetailView'

		EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
			,@strHeaderCondition
			,@strDetailXML OUTPUT
			,NULL
			,NULL

		---------------------------------------------Cost-----------------------------------------------
		SET @strCostXML = NULL
		SET @strCostCondition = NULL

		SELECT @strContractDetailAllId = STUFF((
					SELECT DISTINCT ',' + LTRIM(intContractDetailId)
					FROM tblCTContractDetail
					WHERE intContractHeaderId = @ContractHeaderId
					FOR XML PATH('')
					), 1, 1, '')

		SELECT @strCostCondition = 'intContractDetailId IN (' + LTRIM(@strContractDetailAllId) + ')'

		SELECT @strObjectName = NULL

		IF @ysnReplication = 1
			SELECT @strObjectName = 'tblCTContractCost'
		ELSE
			SELECT @strObjectName = 'vyuIPContractCostView'

		IF @strCostCondition IS NOT NULL
		BEGIN
			EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
				,@strCostCondition
				,@strCostXML OUTPUT
				,NULL
				,NULL
		END

		-------------------------------------------------------------Document----------------------------------------
		SELECT @strDocumentXML = NULL

		SELECT @strObjectName = NULL

		IF @ysnReplication = 1
			SELECT @strObjectName = 'tblCTContractDocument'
		ELSE
			SELECT @strObjectName = 'vyuIPContractDocumentView'

		EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
			,@strHeaderCondition
			,@strDocumentXML OUTPUT
			,NULL
			,NULL

		-------------------------------------------------------------Condition----------------------------------------
		SELECT @strConditionXML = NULL

		SELECT @strObjectName = NULL

		IF @ysnReplication = 1
			SELECT @strObjectName = 'tblCTContractCondition'
		ELSE
			SELECT @strObjectName = 'vyuCTContractConditionView'

		EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
			,@strHeaderCondition
			,@strConditionXML OUTPUT
			,NULL
			,NULL

		-------------------------------------------------------------Certification----------------------------------------
		SELECT @strCertificationXML = NULL

		SELECT @strObjectName = NULL

		IF @ysnReplication = 1
			SELECT @strObjectName = 'tblCTContractCertification'
		ELSE
			SELECT @strObjectName = 'vyuIPContractCertification'

		EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
			,@strCostCondition
			,@strCertificationXML OUTPUT
			,NULL
			,NULL

		---------------------------------------------Approver------------------------------------------
		SELECT @strApproverXML = NULL
			,@strObjectName = NULL

		SELECT @strObjectName = 'vyuCTContractApproverView'

		SELECT @strHeaderCondition = 'strContractNumber = ''' + @strContractNumber + ''''

		EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
			,@strHeaderCondition
			,@strApproverXML OUTPUT
			,NULL
			,NULL

		---------------------------------------------Amendment Approval------------------------------------------
		SELECT @strAmendmentApprovalXML = NULL
			,@strObjectName = NULL

		SELECT @strObjectName = 'vyuIPAmendmentApproval'

		EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
			,NULL
			,@strAmendmentApprovalXML OUTPUT
			,NULL
			,NULL

		---------------------------------------------Submitted By------------------------------------------
		SELECT @strSubmittedByXML = NULL
			,@strObjectName = NULL

		SELECT @strObjectName = 'vyuIPContractSubmittedByView'

		EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
			,@strHeaderCondition
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

		SELECT @strServerName = strServerName
			,@strDatabaseName = strDatabaseName
		FROM tblIPMultiCompany
		WHERE intBookId = @intToBookId
	END

	IF EXISTS (
			SELECT 1
			FROM sys.databases
			WHERE name = @strDatabaseName
			)
	BEGIN
		SELECT @strSQL = N'INSERT INTO ' + @strServerName + '.' + @strDatabaseName + 
			'.dbo.tblCTContractStage (
		intContractHeaderId
		,strContractNumber
		,strHeaderXML
		,strRowState
		,strDetailXML
		,strCostXML
		,strDocumentXML
		,strConditionXML
		,strCertificationXML
		,intEntityId
		,intCompanyLocationId
		,strTransactionType
		,intMultiCompanyId
		,intToBookId
		,strApproverXML
		,strAmendmentApprovalXML
		,intTransactionId 
		,intCompanyId 
		,strSubmittedByXML
		,strLogXML
		,strAuditXML
		)
	SELECT intContractHeaderId = @ContractHeaderId
		,strContractNumber = @strContractNumber
		,strHeaderXML = @strHeaderXML
		,strRowState = @strRowState
		,strDetailXML = @strDetailXML
		,strCostXML = @strCostXML
		,strDocumentXML = @strDocumentXML
		,strConditionXML = @strConditionXML
		,strCertificationXML = @strCertificationXML
		,intEntityId = @intToEntityId
		,intCompanyLocationId = @intCompanyLocationId
		,strTransactionType = @strToTransactionType
		,intMultiCompanyId = @intToCompanyId
		,intToBookId = @intToBookId
		,strApproverXML = @strApproverXML
		,strAmendmentApprovalXML=@strAmendmentApprovalXML
		,intTransactionId =@intTransactionId
		,intCompanyId =@intCompanyId
		,strSubmittedByXML=@strSubmittedByXML
		,strLogXML=@strLogXML
		,strAuditXML=@strAuditXML'

		EXEC sp_executesql @strSQL
			,N'@ContractHeaderId int, 
			@strContractNumber nvarchar(50),
			@strHeaderXML nvarchar(MAX),
			@strRowState nvarchar(MAX),
			@strDetailXML nvarchar(MAX),
			@strCostXML nvarchar(MAX),
			@strDocumentXML nvarchar(MAX),
			@strConditionXML nvarchar(MAX),
			@strCertificationXML nvarchar(MAX),
			@intToEntityId int,
			@intCompanyLocationId int,
			@strToTransactionType nvarchar(MAX),
			@intToCompanyId int,
			@intToBookId int,
			@strApproverXML nvarchar(MAX),
			@strAmendmentApprovalXML nvarchar(MAX),
			@intTransactionId int,
			@intCompanyId int,
			@strSubmittedByXML nvarchar(MAX),
			@strLogXML nvarchar(MAX),
			@strAuditXML nvarchar(MAX)'
			,@ContractHeaderId
			,@strContractNumber
			,@strHeaderXML
			,@strRowState
			,@strDetailXML
			,@strCostXML
			,@strDocumentXML
			,@strConditionXML
			,@strCertificationXML
			,@intToEntityId
			,@intCompanyLocationId
			,@strToTransactionType
			,@intToCompanyId
			,@intToBookId
			,@strApproverXML
			,@strAmendmentApprovalXML
			,@intTransactionId
			,@intCompanyId
			,@strSubmittedByXML
			,@strLogXML
			,@strAuditXML
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
