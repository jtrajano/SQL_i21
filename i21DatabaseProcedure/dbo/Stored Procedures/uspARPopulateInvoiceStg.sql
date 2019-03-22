CREATE PROCEDURE uspARPopulateInvoiceStg 
	@intInvoiceId INT
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intMulticompanyId INT
	DECLARE @intToCompanyLocationId INT
	DECLARE @intToBookId INT
	DECLARE @strTransactionType NVARCHAR(100)
	DECLARE @strFromTransactionType NVARCHAR(100)
	DECLARE @intFromCompanyId INT
	DECLARE @intFromProfitCenterId INT
	DECLARE @strToTransactionType NVARCHAR(100)
	DECLARE @intToCompanyId INT
	DECLARE @intToProfitCenterId INT
	DECLARE @strInsert NVARCHAR(20)
	DECLARE @strUpdate NVARCHAR(20)
	DECLARE @intToSubBookId INT
	DECLARE @intLoadId INT
	DECLARE @intLoadSourceType INT

	SELECT @intLoadId = L.intLoadId, 
		   @intLoadSourceType = L.intSourceType
	FROM tblARInvoice I
	JOIN tblLGLoad L ON L.intLoadId = I.intLoadId
	WHERE I.intInvoiceId = @intInvoiceId

	IF(@intLoadSourceType = 7)
		RETURN;

	IF NOT EXISTS (
			SELECT TOP 1 1
			FROM tblARInvoice
			WHERE intInvoiceId = @intInvoiceId
			)
		RETURN

	SELECT @strFromTransactionType = CTTF.strTransactionType
		,@intFromCompanyId = intFromCompanyId
		,@intFromProfitCenterId = intFromBookId
		,@strToTransactionType = CTTT.strTransactionType
		,@intToCompanyId = intToCompanyId
		,@intToProfitCenterId = intToBookId
		,@strInsert = strInsert
		,@strUpdate = strUpdate
		,@intToCompanyLocationId = intCompanyLocationId
		,@intToBookId = intToBookId
	FROM tblSMInterCompanyTransactionConfiguration CTC
	JOIN [tblSMInterCompanyTransactionType] CTTF ON CTC.[intFromTransactionTypeId] = CTTF.intInterCompanyTransactionTypeId
	JOIN [tblSMInterCompanyTransactionType] CTTT ON CTC.[intToTransactionTypeId] = CTTT.intInterCompanyTransactionTypeId
	WHERE CTTF.strTransactionType = 'Sales Invoice'


	IF EXISTS (
			SELECT TOP 1 1
			FROM tblSMInterCompanyTransactionConfiguration CTC
			JOIN [tblSMInterCompanyTransactionType] CTTF ON CTC.[intFromTransactionTypeId] = CTTF.intInterCompanyTransactionTypeId
			JOIN [tblSMInterCompanyTransactionType] CTTT ON CTC.[intToTransactionTypeId] = CTTT.intInterCompanyTransactionTypeId
			WHERE CTTF.strTransactionType = 'Sales Invoice'
			)
		BEGIN
			INSERT INTO tblARIntrCompanyInvoiceStg (
				intInvoiceId
				,strInvoiceNumber
				,intLoadId
				,intLoadRefId
				,strLoadNumber
				,strRowState
				,strFeedStatus
				,dtmFeedDate
				,strMessage
				,intMultiCompanyId
				,intToCompanyLocationId
				,intToBookId
				,strTransactionType
				)
			SELECT I.intInvoiceId
				,I.strInvoiceNumber
				,I.intLoadId
				,L.intLoadRefId
				,L.strLoadNumber
				,'Added'
				,NULL
				,GETDATE()
				,NULL
				,@intToCompanyId
				,@intToCompanyLocationId
				,@intToBookId
				,@strToTransactionType
			FROM tblARInvoice I
			JOIN tblLGLoad L ON L.intLoadId = I.intLoadId
			WHERE I.intInvoiceId = @intInvoiceId
		END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH