﻿CREATE PROCEDURE [dbo].[uspCMSyncCashFlowReportRateType]
(
	@intCashFlowReportId INT,
	@intReportingCurrencyId INT = NULL,
	@intFilterCurrencyId INT = NULL
)
AS

IF (@intReportingCurrencyId IS NULL)
	SELECT @intReportingCurrencyId = intReportingCurrencyId FROM tblCMCashFlowReport WHERE intCashFlowReportId = @intCashFlowReportId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblCMCashFlowReportRateType WHERE intCashFlowReportId = @intCashFlowReportId) -- create new rates
BEGIN
	IF (@intFilterCurrencyId IS NOT NULL)
	BEGIN
		INSERT INTO tblCMCashFlowReportRateType (intCashFlowReportId, intFilterCurrencyId) VALUES (@intCashFlowReportId, @intFilterCurrencyId)
		INSERT INTO tblCMCashFlowReportRate (
			intCashFlowReportId, 
			intFilterCurrencyId,
			dblRateBucket1,
			dblRateBucket2,
			dblRateBucket3,
			dblRateBucket4,
			dblRateBucket5,
			dblRateBucket6,
			dblRateBucket7,
			dblRateBucket8,
			dblRateBucket9
		) 
		VALUES (@intCashFlowReportId, @intFilterCurrencyId, 1, 1, 1, 1, 1, 1, 1, 1, 1)
		
		GOTO EXIT_PROCESS
	END
	ELSE
		GOTO GET_FROM_CURRENCY_EXCHANGE
END
ELSE   -- Update existing rates
BEGIN
	IF (@intFilterCurrencyId IS NOT NULL)
	BEGIN

		IF ((SELECT COUNT(1) intCount FROM tblCMCashFlowReportRateType WHERE intFilterCurrencyId = @intFilterCurrencyId) = 1)
		BEGIN
			UPDATE tblCMCashFlowReportRateType
			SET intFilterCurrencyId = @intFilterCurrencyId

			WHERE intCashFlowReportId = @intCashFlowReportId

			UPDATE tblCMCashFlowReportRate
			SET intFilterCurrencyId = @intFilterCurrencyId
			WHERE intCashFlowReportId = @intCashFlowReportId
			
			GOTO EXIT_PROCESS
		END
		ELSE
		BEGIN
			DELETE tblCMCashFlowReportRateType WHERE intCashFlowReportId = @intCashFlowReportId
			DELETE tblCMCashFlowReportRate WHERE intCashFlowReportId = @intCashFlowReportId

			INSERT INTO tblCMCashFlowReportRateType (intCashFlowReportId, intFilterCurrencyId) VALUES (@intCashFlowReportId, @intFilterCurrencyId)
			INSERT INTO tblCMCashFlowReportRate (
				intCashFlowReportId, 
				intFilterCurrencyId,
				dblRateBucket1,
				dblRateBucket2,
				dblRateBucket3,
				dblRateBucket4,
				dblRateBucket5,
				dblRateBucket6,
				dblRateBucket7,
				dblRateBucket8,
				dblRateBucket9
			) 
			VALUES (@intCashFlowReportId, @intFilterCurrencyId, 1, 1, 1, 1, 1, 1, 1, 1, 1)
			GOTO EXIT_PROCESS
		END
	END
	
	GOTO GET_FROM_CURRENCY_EXCHANGE
END

GET_FROM_CURRENCY_EXCHANGE:

DECLARE @tblCurrency TABLE (
	intFromCurrencyId INT
)

INSERT INTO @tblCurrency
SELECT intFromCurrencyId
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
		INSERT INTO @tblCurrency SELECT intCurrencyID FROM tblSMCurrency WHERE intCurrencyID <> @intReportingCurrencyId
	ELSE
	BEGIN
		INSERT INTO tblCMCashFlowReportRateType (intCashFlowReportId, intFilterCurrencyId) VALUES (@intCashFlowReportId, @intFilterCurrencyId)
		INSERT INTO tblCMCashFlowReportRate (
				intCashFlowReportId, 
				intFilterCurrencyId,
				dblRateBucket1,
				dblRateBucket2,
				dblRateBucket3,
				dblRateBucket4,
				dblRateBucket5,
				dblRateBucket6,
				dblRateBucket7,
				dblRateBucket8,
				dblRateBucket9
			) 
		VALUES (@intCashFlowReportId, @intFilterCurrencyId, 1, 1, 1, 1, 1, 1, 1, 1, 1)
	END
END

INSERT INTO tblCMCashFlowReportRateType (intCashFlowReportId, intFilterCurrencyId, intConcurrencyId)
SELECT @intCashFlowReportId, intFromCurrencyId, 1
FROM @tblCurrency

INSERT INTO tblCMCashFlowReportRate
SELECT @intCashFlowReportId, intFromCurrencyId, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
FROM @tblCurrency


EXIT_PROCESS:
