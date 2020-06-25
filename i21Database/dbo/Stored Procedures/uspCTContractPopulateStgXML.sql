Create PROCEDURE [dbo].[uspCTContractPopulateStgXML] @ContractHeaderId INT
	,@intToEntityId INT
	,@intCompanyLocationId INT
	,@strToTransactionType NVARCHAR(100)
	,@intToCompanyId INT
	,@strRowState NVARCHAR(100)
	,@ysnReplication BIT = 1
	,@intToBookId INT = NULL
	,@ysnApproval BIT=1
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
		,@intPContractHeaderId INT
		,@strExternalContractNumber NVARCHAR(50)
		,@strExternalEntity NVARCHAR(100)
		,@intEntityId INT
		,@strAdditionalInfo NVARCHAR(MAX)
		,@strAmendmentApprovalXML NVARCHAR(MAX)
		,@intCompanyId int
		,@intTransactionId int
		,@intContractScreenId int
		,@strSubmittedByXML NVARCHAR(MAX)
		,@intPContractSeq int

	SET @intContractStageId = NULL
	SET @strContractNumber = NULL
	SET @strHeaderXML = NULL
	SET @strHeaderCondition = NULL
	SET @strDetailXML = NULL

	SELECT @strContractNumber = strContractNumber,@intCompanyId=intCompanyId 
	FROM tblCTContractHeader
	WHERE intContractHeaderId = @ContractHeaderId

	SELECT	@intContractScreenId	=	intScreenId FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Contract'

	Select @intTransactionId=intTransactionId 
	from tblSMTransaction
	Where intRecordId =@ContractHeaderId
	and intScreenId =@intContractScreenId

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

	-------------------------Header-----------------------------------------------------------
	SELECT @strHeaderCondition = 'intContractHeaderId = ' + LTRIM(@ContractHeaderId)

	IF @ysnReplication = 1
		SELECT @strObjectName = 'tblCTContractHeader'
	ELSE
		SELECT @strObjectName = 'vyuIPContractHeaderView'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strHeaderXML OUTPUT
		,NULL
		,NULL

		SELECT @strAdditionalInfo = '<ysnApproval>' + Ltrim(@ysnApproval) + '</ysnApproval>'

		SELECT @strAdditionalInfo = @strAdditionalInfo + '</vyuIPContractHeaderView></vyuIPContractHeaderViews>'

	SELECT @strHeaderXML = Replace(@strHeaderXML, '</vyuIPContractHeaderView></vyuIPContractHeaderViews>', @strAdditionalInfo)
	

	SELECT @intPContractDetailId = intPContractDetailId
	FROM tblLGAllocationDetail
	WHERE intSContractDetailId IN (
			SELECT intContractDetailId
			FROM tblCTContractDetail
			WHERE intContractHeaderId = @ContractHeaderId
			)

	SELECT @intPContractHeaderId = intContractHeaderId,@intPContractSeq=intContractSeq
	FROM tblCTContractDetail
	WHERE intContractDetailId = @intPContractDetailId

	SELECT @strExternalContractNumber = strContractNumber +' / '+Ltrim(@intPContractSeq)
		,@intEntityId = intEntityId
	FROM tblCTContractHeader
	WHERE intContractHeaderId = @intPContractHeaderId

	SELECT @strExternalEntity = strName
	FROM tblEMEntity
	WHERE intEntityId = @intEntityId

	IF @strExternalContractNumber IS NOT NULL
	BEGIN
		SELECT @strAdditionalInfo = NULL
		SELECT @strAdditionalInfo = '<strExternalContractNumber>' + @strExternalContractNumber + '</strExternalContractNumber>'

		SELECT @strAdditionalInfo = @strAdditionalInfo + '<strExternalEntity>' + @strExternalEntity + '</strExternalEntity>'

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
		SELECT @strObjectName = 'vyuCTContractCostView'

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
		SELECT @strObjectName = 'vyuCTContractDocumentView'

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
		SELECT @strObjectName = 'vyuCTContractCertification'

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

	INSERT INTO tblCTContractStage (
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
