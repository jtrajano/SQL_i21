﻿CREATE PROCEDURE [dbo].[uspARInvoicePopulateStgXML] @intInvoiceId INT
	,@intToEntityId INT
	,@intCompanyLocationId INT
	,@strToTransactionType NVARCHAR(100)
	,@intToCompanyId INT
	,@strRowState NVARCHAR(100)
	,@intToBookId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strInvoiceNumber NVARCHAR(100)
		,@strHeaderXML NVARCHAR(MAX)
		,@strHeaderCondition NVARCHAR(MAX)
		,@strDetailXML NVARCHAR(MAX)
		,@intInvoiceStageId INT
		,@intMultiCompanyId INT
		,@strObjectName NVARCHAR(50)
		,@intEntityId INT
		,@strAdditionalInfo NVARCHAR(MAX)
		,@strAmendmentApprovalXML NVARCHAR(MAX)
		,@intCompanyId INT
		,@intTransactionId INT
		,@intInvoiceScreenId INT

	SET @intInvoiceStageId = NULL
	SET @strInvoiceNumber = NULL
	SET @strHeaderXML = NULL
	SET @strHeaderCondition = NULL
	SET @strDetailXML = NULL

	SELECT @strInvoiceNumber = strInvoiceNumber
		,@intCompanyId = intCompanyId
	FROM tblARInvoice
	WHERE intInvoiceId = @intInvoiceId

	SELECT @intInvoiceScreenId = intScreenId
	FROM tblSMScreen
	WHERE strNamespace = 'AccountsReceivable.view.Invoice'

	SELECT @intTransactionId = intTransactionId
	FROM tblSMTransaction
	WHERE intRecordId = @intInvoiceId
		AND intScreenId = @intInvoiceScreenId

	IF @strRowState = 'Delete'
	BEGIN
		INSERT INTO tblARInvoiceStage (
			intInvoiceId
			,strRowState
			,intEntityId
			,intCompanyLocationId
			,strTransactionType
			,intMultiCompanyId
			,intToBookId
			)
		SELECT intInvoiceId = @intInvoiceId
			,strRowState = @strRowState
			,intEntityId = @intToEntityId
			,intCompanyLocationId = @intCompanyLocationId
			,strTransactionType = @strToTransactionType
			,intMultiCompanyId = @intToCompanyId
			,intToBookId = @intToBookId

		RETURN
	END

	-------------------------Header-----------------------------------------------------------
	SELECT @strHeaderCondition = 'intInvoiceId = ' + LTRIM(@intInvoiceId)

	SELECT @strObjectName = 'vyuIPGetInvoice'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strHeaderXML OUTPUT
		,NULL
		,NULL

	---------------------------------------------Detail------------------------------------------
	SELECT @strDetailXML = NULL
		,@strObjectName = NULL

	SELECT @strObjectName = 'vyuIPGetInvoiceDetail'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strDetailXML OUTPUT
		,NULL
		,NULL

	INSERT INTO tblARInvoiceStage (
		intInvoiceId
		,strInvoiceNumber
		,strHeaderXML
		,strRowState
		,strDetailXML
		,intEntityId
		,intCompanyLocationId
		,strTransactionType
		,intMultiCompanyId
		,intToBookId
		,intTransactionId
		,intCompanyId
		)
	SELECT intContractHeaderId = @intInvoiceId
		,strContractNumber = @strInvoiceNumber
		,strHeaderXML = @strHeaderXML
		,strRowState = @strRowState
		,strDetailXML = @strDetailXML
		,intEntityId = @intToEntityId
		,intCompanyLocationId = @intCompanyLocationId
		,strTransactionType = @strToTransactionType
		,intMultiCompanyId = @intToCompanyId
		,intToBookId = @intToBookId
		,intTransactionId = @intTransactionId
		,intCompanyId = @intCompanyId
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
