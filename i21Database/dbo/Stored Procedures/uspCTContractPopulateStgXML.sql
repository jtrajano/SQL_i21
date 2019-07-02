﻿CREATE PROCEDURE [dbo].[uspCTContractPopulateStgXML] @ContractHeaderId INT
	,@intToEntityId INT
	,@intCompanyLocationId INT
	,@strToTransactionType NVARCHAR(100)
	,@intToCompanyId INT
	,@strRowState NVARCHAR(100)
	,@ysnReplication BIT = 1
	,@intToBookId int=NULL
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
		,@strApproverXML  NVARCHAR(MAX)
		,@intContractStageId INT
		,@intMultiCompanyId INT
		,@strObjectName NVARCHAR(50)

	SET @intContractStageId = NULL
	SET @strContractNumber = NULL
	SET @strHeaderXML = NULL
	SET @strHeaderCondition = NULL
	SET @strDetailXML = NULL

	SELECT @strContractNumber = strContractNumber
	FROM tblCTContractHeader
	WHERE intContractHeaderId = @ContractHeaderId

	-------------------------Header-----------------------------------------------------------
	SELECT @strHeaderCondition = 'intContractHeaderId = ' + LTRIM(@ContractHeaderId)

	IF @ysnReplication = 1
		SELECT @strObjectName = 'tblCTContractHeader'
	ELSE
		SELECT @strObjectName = 'vyuCTContractHeaderView'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strHeaderXML OUTPUT
		,NULL
		,NULL

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

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strCostCondition
		,@strCostXML OUTPUT
		,NULL
		,NULL

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

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strApproverXML OUTPUT
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
		,intToBookId=@intToBookId
		,strApproverXML=@strApproverXML
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
