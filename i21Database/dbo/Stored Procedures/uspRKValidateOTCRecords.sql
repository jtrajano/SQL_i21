CREATE PROCEDURE [dbo].[uspRKValidateOTCRecords]
	  @intFutOptTransactionIds NVARCHAR(MAX)
	, @strAction NVARCHAR(100) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS ON

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX) = ''
		, @intRecordsWithErr INT = 0
		
	DECLARE @derivativeTable TABLE (intFutOptTransactionId INT NULL)
	DECLARE @validateTable TABLE (intFutOptTransactionId INT NULL
						, strInternalTradeNo NVARCHAR(200)
						, intBankId INT NULL
						, intBankAccountId INT NULL
						, intBuyBankAccountId INT NULL
						, dblExchangeRate NUMERIC(24, 10) NULL
						, dblFinanceForwardRate NUMERIC(24, 10) NULL
						, intCurrencyExchangeRateTypeId INT NULL
						, intBankTransferId INT NULL
						, dblBuyAmount NUMERIC(24, 10) NULL
						, dblSellAmount NUMERIC(24, 10) NULL
						, intFromCurrencyId INT NULL
						, intToCurrencyId INT NULL
						)

	DECLARE @sql_xml XML = Cast('<root><U>'+ Replace(@intFutOptTransactionIds, ',', '</U><U>')+ '</U></root>' AS XML)

	INSERT INTO @derivativeTable (intFutOptTransactionId)
	SELECT intFutOptTransactionId = f.x.value('.', 'INT') 
	FROM @sql_xml.nodes('/root/U') f(x)

	INSERT INTO @validateTable (intFutOptTransactionId
		, strInternalTradeNo
		, intBankId
		, intBankAccountId
		, intBuyBankAccountId
		, dblExchangeRate
		, dblFinanceForwardRate
		, intCurrencyExchangeRateTypeId
		, intBankTransferId
		, intFromCurrencyId
		, intToCurrencyId
		, dblBuyAmount
		, dblSellAmount
	)
	SELECT intFutOptTransactionId
		, strInternalTradeNo
		, intBankId
		, intBankAccountId
		, intBuyBankAccountId
		, dblExchangeRate
		, dblFinanceForwardRate
		, intCurrencyExchangeRateTypeId 
		, intBankTransferId
		, intFromCurrencyId
		, intToCurrencyId
		, dblBuyAmount = dblContractAmount
		, dblSellAmount = dblMatchAmount
	FROM tblRKFutOptTransaction
	WHERE intFutOptTransactionId IN (SELECT intFutOptTransactionId FROM @derivativeTable)
	ORDER BY strInternalTradeNo

	DECLARE @intFutOptTransactionId INT = NULL
			, @strInternalTradeNo NVARCHAR(200) = ''
			, @intBankTransferId INT = NULL
		

	WHILE (EXISTS (SELECT TOP 1 '' FROM @validateTable))
	BEGIN
		SELECT	@intFutOptTransactionId = NULL
			, @strInternalTradeNo = ''
			, @intBankTransferId = NULL

		SELECT TOP 1 @intFutOptTransactionId = intFutOptTransactionId 
				, @strInternalTradeNo = strInternalTradeNo 
				, @intBankTransferId = intBankTransferId FROM @validateTable
								
		IF @strAction = 'POST' 
		BEGIN
			IF ISNULL(@intBankTransferId, 0) <> 0
			BEGIN 
				SELECT @ErrMsg += @strInternalTradeNo + ' already has posted Bank Transfer.' + '<br>'
				SELECT @intRecordsWithErr += 1
				
				DELETE FROM @validateTable
				WHERE intFutOptTransactionId = @intFutOptTransactionId

				CONTINUE;
			END

			-- CHECKING IF NOT YET APPROVED
			IF NOT EXISTS (SELECT TOP 1 '' FROM vyuRKFutOptTranForNotMapping 
							WHERE intFutOptTransactionId = @intFutOptTransactionId 
							AND strApprovalStatus IN ('Approved and Not Posted', 'No Need for Approval') 
						)
			BEGIN 
				SELECT @ErrMsg += @strInternalTradeNo + ' needs to be Approved first.' + '<br>'
				SELECT @intRecordsWithErr += 1
				
				DELETE FROM @validateTable
				WHERE intFutOptTransactionId = @intFutOptTransactionId

				CONTINUE;
			END
		END

		IF @strAction = 'APPROVE' OR @strAction = 'REJECT' 
		BEGIN
			-- CHECKING IF WAITING FOR APPROVAL
			IF NOT EXISTS (SELECT TOP 1 '' FROM vyuRKFutOptTranForNotMapping 
							WHERE intFutOptTransactionId = @intFutOptTransactionId 
							AND strApprovalStatus IN ('Waiting for Approval') 
						)
			BEGIN 
				SELECT @ErrMsg += @strInternalTradeNo + ' is not subject for Approval.' + '<br>'
				SELECT @intRecordsWithErr += 1
				
				DELETE FROM @validateTable
				WHERE intFutOptTransactionId = @intFutOptTransactionId

				CONTINUE;
			END
		END

		-- DO NOT VALIDATE FURTHER IF REJECT
		IF @strAction = 'REJECT' 
		BEGIN
			DELETE FROM @validateTable
			WHERE intFutOptTransactionId = @intFutOptTransactionId

			CONTINUE;
		END
			
		DECLARE @derivativeError NVARCHAR(MAX) = ''
			, @intErrorCounter INT = 0
				
		SELECT @derivativeError += @strInternalTradeNo + ' requires '


		-- CHECK FOR MISSING DETAILS
		IF EXISTS (SELECT TOP 1 '' FROM @validateTable WHERE intFutOptTransactionId = @intFutOptTransactionId AND ISNULL(intBankId, 0) = 0)
		BEGIN
			SET @derivativeError += CASE WHEN @intErrorCounter > 0 THEN ', ' ELSE '' END
			SET @derivativeError += 'Bank'
			SET @intErrorCounter += 1
		END

		IF EXISTS (SELECT TOP 1 '' FROM @validateTable WHERE intFutOptTransactionId = @intFutOptTransactionId AND ISNULL(intBuyBankAccountId, 0) = 0)
		BEGIN
			SET @derivativeError += CASE WHEN @intErrorCounter > 0 THEN ', ' ELSE '' END
			SET @derivativeError += 'Buy Bank Account'
			SET @intErrorCounter += 1
		END

		IF EXISTS (SELECT TOP 1 '' FROM @validateTable WHERE intFutOptTransactionId = @intFutOptTransactionId AND ISNULL(intBankAccountId, 0) = 0)
		BEGIN
			SET @derivativeError += CASE WHEN @intErrorCounter > 0 THEN ', ' ELSE '' END
			SET @derivativeError += 'Sell Bank Account'
			SET @intErrorCounter += 1
		END

		IF EXISTS (SELECT TOP 1 '' FROM @validateTable WHERE intFutOptTransactionId = @intFutOptTransactionId AND ISNULL(intCurrencyExchangeRateTypeId, 0) = 0)
		BEGIN
			SET @derivativeError += CASE WHEN @intErrorCounter > 0 THEN ', ' ELSE '' END
			SET @derivativeError += 'Currency Pair'
			SET @intErrorCounter += 1
		END

		IF EXISTS (SELECT TOP 1 '' FROM @validateTable WHERE intFutOptTransactionId = @intFutOptTransactionId AND ISNULL(dblExchangeRate, 0) = 0)
		BEGIN
			SET @derivativeError += CASE WHEN @intErrorCounter > 0 THEN ', ' ELSE '' END
			SET @derivativeError += 'Forward Rate'
			SET @intErrorCounter += 1
		END

		IF EXISTS (SELECT TOP 1 '' FROM @validateTable WHERE intFutOptTransactionId = @intFutOptTransactionId AND ISNULL(dblFinanceForwardRate, 0) = 0)
		BEGIN
			SET @derivativeError += CASE WHEN @intErrorCounter > 0 THEN ', ' ELSE '' END
			SET @derivativeError += 'Finance Forward Rate'
			SET @intErrorCounter += 1
		END

		IF EXISTS (SELECT TOP 1 '' FROM @validateTable WHERE intFutOptTransactionId = @intFutOptTransactionId AND ISNULL(intFromCurrencyId, 0) = 0)
		BEGIN
			SET @derivativeError += CASE WHEN @intErrorCounter > 0 THEN ', ' ELSE '' END
			SET @derivativeError += 'Buy Currency'
			SET @intErrorCounter += 1
		END
		
		IF EXISTS (SELECT TOP 1 '' FROM @validateTable WHERE intFutOptTransactionId = @intFutOptTransactionId AND ISNULL(intToCurrencyId, 0) = 0)
		BEGIN
			SET @derivativeError += CASE WHEN @intErrorCounter > 0 THEN ', ' ELSE '' END
			SET @derivativeError += 'Sell Currency'
			SET @intErrorCounter += 1
		END
		
		IF EXISTS (SELECT TOP 1 '' FROM @validateTable WHERE intFutOptTransactionId = @intFutOptTransactionId AND ISNULL(dblBuyAmount, 0) <= 0)
		BEGIN
			SET @derivativeError += CASE WHEN @intErrorCounter > 0 THEN ', ' ELSE '' END
			SET @derivativeError += 'Buy Amount be greater than 0'
			SET @intErrorCounter += 1
		END

		IF EXISTS (SELECT TOP 1 '' FROM @validateTable WHERE intFutOptTransactionId = @intFutOptTransactionId AND ISNULL(dblSellAmount, 0) <= 0)
		BEGIN
			SET @derivativeError += CASE WHEN @intErrorCounter > 0 THEN ', ' ELSE '' END
			SET @derivativeError += 'Sell Amount be greater than 0'
			SET @intErrorCounter += 1
		END

		IF (@intErrorCounter > 0)
		BEGIN
			SELECT @ErrMsg += @derivativeError + '<br>'
			SELECT @intRecordsWithErr += 1
		END

		DELETE FROM @validateTable
		WHERE intFutOptTransactionId = @intFutOptTransactionId
	END

	IF (@intRecordsWithErr > 0)
	BEGIN 
		RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
	END		
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = @ErrMsg
	RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH