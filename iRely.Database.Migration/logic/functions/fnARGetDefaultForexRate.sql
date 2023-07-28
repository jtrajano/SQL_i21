--liquibase formatted sql

-- changeset Von:fnARGetDefaultForexRate.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnARGetDefaultForexRate]
(
	 @TransactionDate	DATETIME 
	,@CurrencyId		INT
	,@ForexRateTypeId	INT			= NULL
)
RETURNS @returntable TABLE
(
	 [intCurrencyExchangeRateTypeId]	INT
	,[strCurrencyExchangeRateType]		NVARCHAR(20) COLLATE Latin1_General_CI_AS
	,[intCurrencyExchangeRateId]		INT
	,[dblCurrencyExchangeRate]			NUMERIC(18,6)	
)
AS
BEGIN

	IF ISNULL(@ForexRateTypeId, 0) = 0
		SET @ForexRateTypeId = (SELECT TOP 1 [intAccountsReceivableRateTypeId] FROM tblSMMultiCurrency ORDER BY [intMultiCurrencyId])

	DECLARE @FunctionalCurrencyId INT
	SELECT TOP 1 @FunctionalCurrencyId = [intDefaultCurrencyId] FROM tblSMCompanyPreference
	
	INSERT @returntable(
		 [intCurrencyExchangeRateTypeId]
		,[strCurrencyExchangeRateType]
		,[intCurrencyExchangeRateId]
		,[dblCurrencyExchangeRate]
	)
	SELECT TOP 1
		 [intCurrencyExchangeRateTypeId]	= [intCurrencyExchangeRateTypeId]
		,[strCurrencyExchangeRateType]		= [strCurrencyExchangeRateType]
		,[intCurrencyExchangeRateId]		= [intCurrencyExchangeRateId]
		,[dblCurrencyExchangeRate]			= [dblRate]
	FROM 
		vyuSMForex
	WHERE 
		[intFromCurrencyId] = @CurrencyId 
		AND [intCurrencyExchangeRateTypeId] = @ForexRateTypeId 
		AND [intToCurrencyId] = @FunctionalCurrencyId
		AND CAST(@TransactionDate AS DATE) >= CAST([dtmValidFromDate] AS DATE) 
	ORDER BY
		[dtmValidFromDate] DESC


	IF NOT EXISTS(SELECT TOP 1 NULL FROM @returntable ORDER BY [intCurrencyExchangeRateTypeId])
		INSERT @returntable(
			 [intCurrencyExchangeRateTypeId]
			,[strCurrencyExchangeRateType]
			,[intCurrencyExchangeRateId]
			,[dblCurrencyExchangeRate]
		)
		SELECT
			 [intCurrencyExchangeRateTypeId]	= NULL
			,[strCurrencyExchangeRateType]		= ''
			,[intCurrencyExchangeRateId]		= NULL
			,[dblCurrencyExchangeRate]			= 1.000000
		
	RETURN
END



