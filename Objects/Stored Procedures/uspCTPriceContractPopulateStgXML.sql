CREATE PROCEDURE [dbo].[uspCTPriceContractPopulateStgXML] @intPriceContractId INT
	,@intToEntityId INT
	,@strToTransactionType NVARCHAR(100)
	,@intToCompanyId INT
	,@strRowState NVARCHAR(100)
	,@ysnReplication BIT = 1
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

	SET @intPriceContractStageId = NULL
	SET @strPriceContractNo = NULL
	SET @strPriceContractXML = NULL
	SET @strPriceContractCondition = NULL
	SET @strPriceFixationXML = NULL

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
	FROM tblCTPriceContract
	WHERE intPriceContractId = @intPriceContractId

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

	INSERT INTO tblCTPriceContractStage (
		intPriceContractId
		,strPriceContractNo
		,strPriceContractXML
		,strRowState
		,strPriceFixationXML
		,strPriceFixationDetailXML
		,intEntityId
		,strTransactionType
		,intMultiCompanyId
		)
	SELECT intPriceContractId = @intPriceContractId
		,strPriceContractNo = @strPriceContractNo
		,strPriceContractXML = @strPriceContractXML
		,strRowState = @strRowState
		,strPriceFixationXML = @strPriceFixationXML
		,strPriceFixationDetailXML = @strPriceFixationDetailXML
		,intEntityId = @intToEntityId
		,strTransactionType = @strToTransactionType
		,intMultiCompanyId = @intToCompanyId
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
