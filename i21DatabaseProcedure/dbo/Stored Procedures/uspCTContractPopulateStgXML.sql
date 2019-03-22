CREATE PROCEDURE [dbo].[uspCTContractPopulateStgXML]
	 @ContractHeaderId INT
	,@intToEntityId INT
	,@intCompanyLocationId INT
	,@strToTransactionType NVARCHAR(100)
	,@intToCompanyId INT
	,@strRowState NVARCHAR(100)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE 
		 @ErrMsg				 NVARCHAR(MAX)
		,@strContractNumber		 NVARCHAR(100)
		,@strHeaderXML			 NVARCHAR(MAX)
		,@strHeaderCondition	 NVARCHAR(MAX)
		,@strDetailXML			 NVARCHAR(MAX)
		,@strContractDetailAllId NVARCHAR(MAX)
		,@strCostXML			 NVARCHAR(MAX)
		,@strDocumentXML		 NVARCHAR(MAX)
		,@strConditionXML		 NVARCHAR(MAX)
		,@strCertificationXML	 NVARCHAR(MAX)
		,@strCostCondition		 NVARCHAR(MAX)
		,@intContractStageId	 INT
		,@intMultiCompanyId		 INT

	SET @intContractStageId = NULL
	SET @strContractNumber  = NULL
	SET @strHeaderXML		= NULL
	SET @strHeaderCondition = NULL
	SET @strDetailXML		= NULL

	SELECT @strContractNumber = strContractNumber
	FROM tblCTContractHeader
	WHERE intContractHeaderId = @ContractHeaderId

	-------------------------Header-----------------------------------------------------------
	SELECT @strHeaderCondition = 'intContractHeaderId = ' + LTRIM(@ContractHeaderId)

	EXEC [dbo].[uspCTGetTableDataInXML] 
		'tblCTContractHeader'
		,@strHeaderCondition
		,@strHeaderXML OUTPUT
		,NULL
		,NULL

	INSERT INTO tblCTContractStage 
	(
		intContractHeaderId
		,strContractNumber
		,strHeaderXML
		,strRowState
	)
	SELECT 
		 intContractHeaderId = @ContractHeaderId
		,strContractNumber   = @strContractNumber
		,strHeaderXML        = @strHeaderXML
		,strRowState		 = @strRowState

	SET @intContractStageId = SCOPE_IDENTITY();
	---------------------------------------------Detail------------------------------------------
	SET @strDetailXML = NULL

	EXEC [dbo].[uspCTGetTableDataInXML] 
		'tblCTContractDetail'
		,@strHeaderCondition
		,@strDetailXML OUTPUT
		,NULL
		,NULL

	UPDATE tblCTContractStage
	SET strDetailXML = ISNULL(strDetailXML, '') + @strDetailXML
	WHERE intContractStageId = @intContractStageId

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

	EXEC [dbo].[uspCTGetTableDataInXML] 
		'tblCTContractCost'
		,@strCostCondition
		,@strCostXML OUTPUT
		,NULL
		,NULL

	UPDATE tblCTContractStage
	SET strCostXML = ISNULL(strCostXML, '') + @strCostXML
	WHERE intContractStageId = @intContractStageId

	-------------------------------------------------------------Document----------------------------------------
	SELECT @strDocumentXML = NULL

	EXEC [dbo].[uspCTGetTableDataInXML] 
		'tblCTContractDocument'
		,@strHeaderCondition
		,@strDocumentXML OUTPUT
		,NULL
		,NULL

	UPDATE tblCTContractStage
	SET strDocumentXML = ISNULL(strDocumentXML, '') + @strDocumentXML
	WHERE intContractStageId = @intContractStageId
	-------------------------------------------------------------Condition----------------------------------------
	SELECT @strConditionXML = NULL
	
	EXEC [dbo].[uspCTGetTableDataInXML] 
		'tblCTContractCondition'
		,@strHeaderCondition
		,@strConditionXML OUTPUT
		,NULL
		,NULL

	UPDATE tblCTContractStage
	SET strConditionXML = ISNULL(strConditionXML, '') + @strConditionXML
	WHERE intContractStageId = @intContractStageId

	-------------------------------------------------------------Certification----------------------------------------
	SELECT @strCertificationXML = NULL
	
	EXEC [dbo].[uspCTGetTableDataInXML] 
		'tblCTContractCertification'
		,@strCostCondition
		,@strCertificationXML OUTPUT
		,NULL
		,NULL

	UPDATE tblCTContractStage
	SET strCertificationXML = ISNULL(strCertificationXML, '') + @strCertificationXML
	WHERE intContractStageId = @intContractStageId


	UPDATE  tblCTContractStage
	SET		intEntityId			 = @intToEntityId
		   ,intCompanyLocationId = @intCompanyLocationId
		   ,strTransactionType   = @strToTransactionType
		   ,intMultiCompanyId    = @intToCompanyId
	WHERE  intContractStageId    = @intContractStageId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')

END CATCH
