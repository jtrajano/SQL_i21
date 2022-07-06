CREATE PROCEDURE [dbo].[uspRKOTCForwardPostBankTransfer]
	@strFutOptTransactionIds NVARCHAR(MAX)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX) = NULL
	DECLARE @derivativeTable TABLE (intFutOptTransactionId INT NULL)

	DECLARE @sql_xml XML = Cast('<root><U>'+ Replace(@strFutOptTransactionIds, ',', '</U><U>')+ '</U></root>' AS XML)

	INSERT INTO @derivativeTable (intFutOptTransactionId)
	SELECT intFutOptTransactionId = f.x.value('.', 'INT') 
	FROM @sql_xml.nodes('/root/U') f(x)

	SELECT * 
	INTO #tmpOTCToPost
	FROM tblRKFutOptTransaction
	WHERE intFutOptTransactionId IN (SELECT der.intFutOptTransactionId FROM @derivativeTable der)

	DECLARE @intFutOptTransactionId INT = NULL
	DECLARE @bankTransferRecord CMBankTransferType

	WHILE EXISTS (SELECT TOP 1 '' FROM #tmpOTCToPost)
	BEGIN
		-- CLEAN TABLE
		DELETE FROM @bankTransferRecord

		SELECT TOP 1 @intFutOptTransactionId = intFutOptTransactionId FROM #tmpOTCToPost
		SELECT @intFutOptTransactionId

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
		, intFutOptTransactionId
		, intFutOptTransactionHeaderId
		, strDerivativeId
		, strReferenceFrom
		, strReferenceTo
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
		, intFutOptTransactionId = otc.intFutOptTransactionId
		, intFutOptTransactionHeaderId = otc.intFutOptTransactionHeaderId
		, strDerivativeId = otc.strInternalTradeNo
		, strReferenceFrom = otc.strBrokerTradeNo
		, strReferenceTo = otc.strBrokerTradeNo

		FROM #tmpOTCToPost otc
		LEFT JOIN vyuCMBankAccount buyBA
			ON buyBA.intBankAccountId = otc.intBuyBankAccountId
		LEFT JOIN vyuCMBankAccount sellBA
			ON sellBA.intBankAccountId = otc.intBankAccountId
		WHERE otc.intFutOptTransactionId = @intFutOptTransactionId
		
		DECLARE @intBankTransferId INT

		EXEC uspCMCreateBankTransferForward @bankTransferRecord,  @intBankTransferId out

		UPDATE tblRKFutOptTransaction 
		SET intBankTransferId = @intBankTransferId
		WHERE intFutOptTransactionId = @intFutOptTransactionId

		DELETE FROM #tmpOTCToPost
		WHERE intFutOptTransactionId = @intFutOptTransactionId
	END

	DROP TABLE #tmpOTCToPost

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH