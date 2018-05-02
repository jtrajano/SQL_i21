CREATE PROCEDURE [dbo].[uspCTPriceContractPopulateStgXML]
	 @intPriceContractId    INT
	,@intToEntityId		    INT
	,@strToTransactionType  NVARCHAR(100)
	,@intToCompanyId		INT
	,@strRowState NVARCHAR(100)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE 
		 @ErrMsg					 NVARCHAR(MAX)
		,@strPriceContractNo		 NVARCHAR(100)
		,@strPriceContractXML		 NVARCHAR(MAX)
		,@strPriceContractCondition  NVARCHAR(MAX)
		,@strPriceFixationXML		 NVARCHAR(MAX)
		,@strPriceFixationAllId		 NVARCHAR(MAX)
		,@strPriceFixationDetailXML  NVARCHAR(MAX)
		,@strPriceFixationCondition  NVARCHAR(MAX)
		,@intPriceContractStageId	 INT
		,@intMultiCompanyId			 INT

	SET @intPriceContractStageId    = NULL
	SET @strPriceContractNo		    = NULL
	SET @strPriceContractXML	    = NULL
	SET @strPriceContractCondition  = NULL
	SET @strPriceFixationXML		= NULL

	SELECT @strPriceContractNo = strPriceContractNo
	FROM tblCTPriceContract
	WHERE intPriceContractId = @intPriceContractId

	-------------------------PriceContract-----------------------------------------------------------
	SELECT @strPriceContractCondition = 'intPriceContractId = ' + LTRIM(@intPriceContractId)

	EXEC [dbo].[uspCTGetTableDataInXML] 'tblCTPriceContract'
		,@strPriceContractCondition
		,@strPriceContractXML OUTPUT
		,NULL
		,NULL

	INSERT INTO tblCTPriceContractStage 
	(
		 intPriceContractId
		,strPriceContractNo
		,strPriceContractXML
		,strRowState
	)
	SELECT 
		intPriceContractId   = @intPriceContractId
		,strPriceContractNo  = @strPriceContractNo
		,strPriceContractXML = @strPriceContractXML
		,strRowState		 = @strRowState

	SET @intPriceContractStageId = SCOPE_IDENTITY();
	---------------------------------------------PriceFixation------------------------------------------
	
	SET @strPriceFixationXML = NULL

	EXEC [dbo].[uspCTGetTableDataInXML] 
		 'tblCTPriceFixation'
		 ,@strPriceContractCondition
		 ,@strPriceFixationXML OUTPUT
		 ,NULL
		 ,NULL

	UPDATE tblCTPriceContractStage
	SET		strPriceFixationXML		= ISNULL(strPriceFixationXML, '') + @strPriceFixationXML
	WHERE	intPriceContractStageId = @intPriceContractStageId

	---------------------------------------------PriceFixationDetail-----------------------------------------------
			SET @strPriceFixationDetailXML = NULL
			SET @strPriceFixationCondition = NULL
			SELECT @strPriceFixationAllId = STUFF((
													SELECT DISTINCT ',' + LTRIM(intPriceFixationId)
													FROM tblCTPriceFixation
													WHERE intPriceContractId = @intPriceContractId
													FOR XML PATH('')
													), 1, 1, '')

			SELECT @strPriceFixationCondition = 'intPriceFixationId IN ('+ LTRIM(@strPriceFixationAllId)+')'

			EXEC [dbo].[uspCTGetTableDataInXML] 
				'tblCTPriceFixationDetail'
				,@strPriceFixationCondition
				,@strPriceFixationDetailXML OUTPUT
				,NULL
				,NULL

			UPDATE tblCTPriceContractStage
			SET strPriceFixationDetailXML = ISNULL(strPriceFixationDetailXML, '') + @strPriceFixationDetailXML
			WHERE intPriceContractStageId = @intPriceContractStageId
	


	UPDATE tblCTPriceContractStage
	SET   intEntityId = @intToEntityId
		 ,strTransactionType = @strToTransactionType
		 ,intMultiCompanyId = @intToCompanyId	
	WHERE intPriceContractStageId = @intPriceContractStageId


END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')

END CATCH
