CREATE PROCEDURE [dbo].[uspRKOTCForwardPostBankTransfer]
	@intFutOptTransactionId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX) = NULL

	--SET @ErrMsg = 'Error Message'
	--RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
	--RETURN

	SELECT * 
	INTO #tmpOTCToPost
	FROM tblRKFutOptTransaction
	WHERE intFutOptTransactionId = @intFutOptTransactionId

	DECLARE @bankTransferRecord CMBankTransferType

	INSERT INTO @bankTransferRecord 
	(
	  intEntityId
	, strDescription
	, intBankAccountIdFrom
	, intBankAccountIdTo
	, intGLAccountIdFrom
	, intGLAccountIdTo
	, intCurrencyExchangeRateTypeId
	, dtmAccrual
	, dtmDate
	, dblAmountForeignFrom
	, dblAmountForeignTo
	)

	SELECT 
		intEntityId = 1
	, strDescription = otc.strReference -- Notes
	, intBankAccountIdFrom = otc.intBuyBankAccountId
	, intBankAccountIdTo = otc.intBankAccountId 
	, intGLAccountIdFrom = buyBA.intGLAccountId
	, intGLAccountIdTo = sellBA.intGLAccountId
	, intCurrencyExchangeRateTypeId = otc.intCurrencyExchangeRateTypeId -- Currency Pair
	, dtmAccrual = otc.dtmTransactionDate
	, dtmDate = otc.dtmMaturityDate
	, dblAmountForeignFrom = otc.dblContractAmount -- Buy Amount
	, dblAmountForeignTo = otc.dblContractAmount * otc.dblExchangeRate -- Buy Amount * Forward Rate

	FROM #tmpOTCToPost otc
	LEFT JOIN vyuCMBankAccount buyBA
		ON buyBA.intBankAccountId = otc.intBuyBankAccountId
	LEFT JOIN vyuCMBankAccount sellBA
		ON sellBA.intBankAccountId = otc.intBankAccountId
	
	DECLARE @intBankTransferId INT

	EXEC uspCMCreateBankTransferForward @bankTransferRecord,  @intBankTransferId out

	UPDATE tblRKFutOptTransaction 
	SET intBankTransferId = @intBankTransferId
	WHERE intFutOptTransactionId = @intFutOptTransactionId

	DROP TABLE #tmpOTCToPost

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH