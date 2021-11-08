CREATE PROCEDURE [dbo].[uspCMSyncCashFlowReportRateType]
(
	@intCashFlowReportId INT,
	@intReportingCurrencyId INT = NULL,
	@intFilterCurrencyId INT = NULL
)
AS

IF (@intReportingCurrencyId IS NULL)
	SELECT @intReportingCurrencyId = intReportingCurrencyId FROM tblCMCashFlowReport WHERE intCashFlowReportId = @intCashFlowReportId
IF (@intFilterCurrencyId IS NULL)
	SELECT @intFilterCurrencyId = intFilterCurrencyId FROM tblCMCashFlowReport WHERE intCashFlowReportId = @intCashFlowReportId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblCMCashFlowReportRateType WHERE intCashFlowReportId = @intCashFlowReportId) -- create new rates
BEGIN
	IF (@intFilterCurrencyId IS NOT NULL)
	BEGIN
		INSERT INTO tblCMCashFlowReportRateType
		SELECT 
			intCashFlowReportId,
			@intFilterCurrencyId,
			intBucket1RateTypeId,
			intBucket2RateTypeId,
			intBucket3RateTypeId,
			intBucket4RateTypeId,
			intBucket5RateTypeId,
			intBucket6RateTypeId,
			intBucket7RateTypeId,
			intBucket8RateTypeId,
			intBucket9RateTypeId,
			1
		FROM tblCMCashFlowReport
		WHERE intCashFlowReportId = @intCashFlowReportId

		INSERT INTO tblCMCashFlowReportRate
		SELECT
			intCashFlowReportId,
			@intFilterCurrencyId,
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket1RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket2RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket3RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket4RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket5RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket6RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket7RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket8RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket9RateTypeId, dtmReportDate),
			1
		FROM tblCMCashFlowReport
		WHERE intCashFlowReportId = @intCashFlowReportId
		
		GOTO EXIT_PROCESS
	END
	ELSE
		GOTO GET_FROM_CURRENCY_EXCHANGE
END
ELSE   -- Update existing rates
BEGIN
	IF (@intFilterCurrencyId IS NOT NULL)
	BEGIN
		DELETE tblCMCashFlowReportRateType WHERE intCashFlowReportId = @intCashFlowReportId
		DELETE tblCMCashFlowReportRate WHERE intCashFlowReportId = @intCashFlowReportId

		INSERT INTO tblCMCashFlowReportRateType
		SELECT 
			intCashFlowReportId,
			@intFilterCurrencyId,
			intBucket1RateTypeId,
			intBucket2RateTypeId,
			intBucket3RateTypeId,
			intBucket4RateTypeId,
			intBucket5RateTypeId,
			intBucket6RateTypeId,
			intBucket7RateTypeId,
			intBucket8RateTypeId,
			intBucket9RateTypeId,
			1
		FROM tblCMCashFlowReport
		WHERE intCashFlowReportId = @intCashFlowReportId

		INSERT INTO tblCMCashFlowReportRate
		SELECT
			intCashFlowReportId,
			@intFilterCurrencyId,
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket1RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket2RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket3RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket4RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket5RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket6RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket7RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket8RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket9RateTypeId, dtmReportDate),
			1
		FROM tblCMCashFlowReport
		WHERE intCashFlowReportId = @intCashFlowReportId
		
		GOTO EXIT_PROCESS
	END
	
	GOTO GET_FROM_CURRENCY_EXCHANGE
END

GET_FROM_CURRENCY_EXCHANGE:

DELETE tblCMCashFlowReportRateType WHERE intCashFlowReportId = @intCashFlowReportId
DELETE tblCMCashFlowReportRate WHERE intCashFlowReportId = @intCashFlowReportId

DECLARE @tblCurrency TABLE (
	intFromCurrencyId INT
)

INSERT INTO @tblCurrency
SELECT DISTINCT intFromCurrencyId
FROM tblSMCurrencyExchangeRate 
WHERE intToCurrencyId = @intReportingCurrencyId

IF EXISTS(SELECT TOP 1 1 FROM @tblCurrency)
BEGIN
	DELETE tblCMCashFlowReportRateType WHERE intCashFlowReportId = @intCashFlowReportId
	DELETE tblCMCashFlowReportRate WHERE intCashFlowReportId = @intCashFlowReportId
END
ELSE
BEGIN
	IF (@intFilterCurrencyId IS NULL)
		INSERT INTO @tblCurrency SELECT DISTINCT intCurrencyID FROM tblSMCurrency
	ELSE
	BEGIN
		INSERT INTO tblCMCashFlowReportRateType
		SELECT 
			intCashFlowReportId,
			@intFilterCurrencyId,
			intBucket1RateTypeId,
			intBucket2RateTypeId,
			intBucket3RateTypeId,
			intBucket4RateTypeId,
			intBucket5RateTypeId,
			intBucket6RateTypeId,
			intBucket7RateTypeId,
			intBucket8RateTypeId,
			intBucket9RateTypeId,
			1
		FROM tblCMCashFlowReport
		WHERE intCashFlowReportId = @intCashFlowReportId

		INSERT INTO tblCMCashFlowReportRate
		SELECT
			intCashFlowReportId,
			@intFilterCurrencyId,
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket1RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket2RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket3RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket4RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket5RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket6RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket7RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket8RateTypeId, dtmReportDate),
			[dbo].[fnCMGetForexRateFromCurrency](@intFilterCurrencyId, @intReportingCurrencyId, intBucket9RateTypeId, dtmReportDate),
			1
		FROM tblCMCashFlowReport
		WHERE intCashFlowReportId = @intCashFlowReportId
	END
END

INSERT INTO tblCMCashFlowReportRateType
SELECT DISTINCT 
	@intCashFlowReportId, 
	intFromCurrencyId,
	Report.intBucket1RateTypeId,
	Report.intBucket2RateTypeId,
	Report.intBucket3RateTypeId,
	Report.intBucket4RateTypeId,
	Report.intBucket5RateTypeId,
	Report.intBucket6RateTypeId,
	Report.intBucket7RateTypeId,
	Report.intBucket8RateTypeId,
	Report.intBucket9RateTypeId,
	1
FROM @tblCurrency
OUTER APPLY (
	SELECT 
		intBucket1RateTypeId,
		intBucket2RateTypeId,
		intBucket3RateTypeId,
		intBucket4RateTypeId,
		intBucket5RateTypeId,
		intBucket6RateTypeId,
		intBucket7RateTypeId,
		intBucket8RateTypeId,
		intBucket9RateTypeId
	FROM tblCMCashFlowReport WHERE intCashFlowReportId = @intCashFlowReportId
) Report

INSERT INTO tblCMCashFlowReportRate
SELECT DISTINCT 
	@intCashFlowReportId, 
	intFromCurrencyId,
	[dbo].[fnCMGetForexRateFromCurrency](intFromCurrencyId, @intReportingCurrencyId, Report.intBucket1RateTypeId, Report.dtmReportDate),
	[dbo].[fnCMGetForexRateFromCurrency](intFromCurrencyId, @intReportingCurrencyId, Report.intBucket2RateTypeId, Report.dtmReportDate),
	[dbo].[fnCMGetForexRateFromCurrency](intFromCurrencyId, @intReportingCurrencyId, Report.intBucket3RateTypeId, Report.dtmReportDate),
	[dbo].[fnCMGetForexRateFromCurrency](intFromCurrencyId, @intReportingCurrencyId, Report.intBucket4RateTypeId, Report.dtmReportDate),
	[dbo].[fnCMGetForexRateFromCurrency](intFromCurrencyId, @intReportingCurrencyId, Report.intBucket5RateTypeId, Report.dtmReportDate),
	[dbo].[fnCMGetForexRateFromCurrency](intFromCurrencyId, @intReportingCurrencyId, Report.intBucket6RateTypeId, Report.dtmReportDate),
	[dbo].[fnCMGetForexRateFromCurrency](intFromCurrencyId, @intReportingCurrencyId, Report.intBucket7RateTypeId, Report.dtmReportDate),
	[dbo].[fnCMGetForexRateFromCurrency](intFromCurrencyId, @intReportingCurrencyId, Report.intBucket8RateTypeId, Report.dtmReportDate),
	[dbo].[fnCMGetForexRateFromCurrency](intFromCurrencyId, @intReportingCurrencyId, Report.intBucket9RateTypeId, Report.dtmReportDate),
	1
FROM @tblCurrency
OUTER APPLY (
	SELECT 
		intBucket1RateTypeId,
		intBucket2RateTypeId,
		intBucket3RateTypeId,
		intBucket4RateTypeId,
		intBucket5RateTypeId,
		intBucket6RateTypeId,
		intBucket7RateTypeId,
		intBucket8RateTypeId,
		intBucket9RateTypeId,
		dtmReportDate
	FROM tblCMCashFlowReport WHERE intCashFlowReportId = @intCashFlowReportId
) Report

EXIT_PROCESS:

-- Add reporting currency
DELETE tblCMCashFlowReportRateType WHERE intFilterCurrencyId = @intReportingCurrencyId AND intCashFlowReportId = @intCashFlowReportId
DELETE tblCMCashFlowReportRate WHERE intFilterCurrencyId = @intReportingCurrencyId AND intCashFlowReportId = @intCashFlowReportId

INSERT INTO tblCMCashFlowReportRateType (intCashFlowReportId, intFilterCurrencyId, intConcurrencyId) VALUES (@intCashFlowReportId, @intReportingCurrencyId, 1)
INSERT INTO tblCMCashFlowReportRate VALUES (@intCashFlowReportId, @intReportingCurrencyId, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
