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

-- Default Rate and Rate Types per bucket
DECLARE @tblDefaultRateTypes TABLE (
	intFromCurrencyId INT,
	intToCurrencyId INT,
	intCurrencyExchangeRateDetailId INT,
	intCurrencyExchangeRateTypeId INT,
	strBucket NVARCHAR(MAX) NULL,
	dblRate DECIMAL(18, 6) DEFAULT 1,
	dtmValidFromDate DATETIME NULL
)

INSERT INTO @tblDefaultRateTypes
SELECT
	Rate.intFromCurrencyId,
	Rate.intToCurrencyId,
	RateDetail.intCurrencyExchangeRateDetailId,
	RateType.intCurrencyExchangeRateTypeId,
	Bucket.Item strBucket,
	ISNULL(RateDetail.dblRate, 1),
	RateDetail.dtmValidFromDate
FROM tblSMCurrencyExchangeRate Rate
JOIN tblSMCurrencyExchangeRateDetail RateDetail
	ON RateDetail.intCurrencyExchangeRateId = Rate.intCurrencyExchangeRateId
JOIN  tblSMCurrencyExchangeRateType RateType
	ON RateType.intCurrencyExchangeRateTypeId = RateDetail.intRateTypeId
OUTER APPLY (
	SELECT Item FROM [dbo].[fnSplitStringWithTrim](RateType.strCashFlows, ',')
) Bucket
WHERE 
	RTRIM(LTRIM(strCashFlows)) IS NOT NULL 
	AND NULLIF(strCashFlows, '') IS NOT NULL
	AND Rate.intToCurrencyId = @intReportingCurrencyId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblCMCashFlowReportRateType WHERE intCashFlowReportId = @intCashFlowReportId) -- create new rates
BEGIN
	IF (@intFilterCurrencyId IS NOT NULL)
	BEGIN
		INSERT INTO tblCMCashFlowReportRateType
		SELECT
			@intCashFlowReportId,
			@intFilterCurrencyId,
			intRateTypeIdBucket1,
			intRateTypeIdBucket2,
			intRateTypeIdBucket3,
			intRateTypeIdBucket4,
			intRateTypeIdBucket5,
			intRateTypeIdBucket6,
			intRateTypeIdBucket7,
			intRateTypeIdBucket8,
			intRateTypeIdBucket9,
			1
		FROM (
			SELECT
				intRateTypeIdBucket1 = MAX(CASE WHEN strBucket = 'Current'	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket2 = MAX(CASE WHEN strBucket = '1 - 7'	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket3 = MAX(CASE WHEN strBucket = '8 - 14'	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket4 = MAX(CASE WHEN strBucket = '15 - 21'	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket5 = MAX(CASE WHEN strBucket = '22 - 29'	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket6 = MAX(CASE WHEN strBucket = '30 - 60'	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket7 = MAX(CASE WHEN strBucket = '60 - 90'	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket8 = MAX(CASE WHEN strBucket = '90 - 120' THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket9 = MAX(CASE WHEN strBucket = '120+'		THEN intCurrencyExchangeRateTypeId END)
			FROM @tblDefaultRateTypes A
			WHERE intFromCurrencyId = @intFilterCurrencyId
			AND dtmValidFromDate = (
				SELECT MAX(dtmValidFromDate) FROM @tblDefaultRateTypes
				WHERE 
					intFromCurrencyId = A.intFromCurrencyId
					AND intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId
					AND strBucket = A.strBucket
			)
		) DefaultRateType

		INSERT INTO tblCMCashFlowReportRate 
		SELECT
			@intCashFlowReportId,
			@intFilterCurrencyId,
			ISNULL(dblRateBucket1, 1),
			ISNULL(dblRateBucket2, 1),
			ISNULL(dblRateBucket3, 1),
			ISNULL(dblRateBucket4, 1),
			ISNULL(dblRateBucket5, 1),
			ISNULL(dblRateBucket6, 1),
			ISNULL(dblRateBucket7, 1),
			ISNULL(dblRateBucket8, 1),
			ISNULL(dblRateBucket9, 1),
			1
		FROM (
			SELECT
				dblRateBucket1 = MAX(CASE WHEN strBucket = 'Current'	THEN dblRate END),
				dblRateBucket2 = MAX(CASE WHEN strBucket = '1 - 7'		THEN dblRate END),
				dblRateBucket3 = MAX(CASE WHEN strBucket = '8 - 14'		THEN dblRate END),
				dblRateBucket4 = MAX(CASE WHEN strBucket = '15 - 21'	THEN dblRate END),
				dblRateBucket5 = MAX(CASE WHEN strBucket = '22 - 29'	THEN dblRate END),
				dblRateBucket6 = MAX(CASE WHEN strBucket = '30 - 60'	THEN dblRate END),
				dblRateBucket7 = MAX(CASE WHEN strBucket = '60 - 90'	THEN dblRate END),
				dblRateBucket8 = MAX(CASE WHEN strBucket = '90 - 120'	THEN dblRate END),
				dblRateBucket9 = MAX(CASE WHEN strBucket = '120+'		THEN dblRate END)
			FROM @tblDefaultRateTypes A
			WHERE intFromCurrencyId = @intFilterCurrencyId
			AND dtmValidFromDate = (
				SELECT MAX(dtmValidFromDate) FROM @tblDefaultRateTypes
				WHERE 
					intFromCurrencyId = A.intFromCurrencyId
					AND intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId
					AND strBucket = A.strBucket
			)
		) DefaultRate
		
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
			@intCashFlowReportId,
			@intFilterCurrencyId,
			intRateTypeIdBucket1,
			intRateTypeIdBucket2,
			intRateTypeIdBucket3,
			intRateTypeIdBucket4,
			intRateTypeIdBucket5,
			intRateTypeIdBucket6,
			intRateTypeIdBucket7,
			intRateTypeIdBucket8,
			intRateTypeIdBucket9,
			1
		FROM (
			SELECT
				intRateTypeIdBucket1 = MAX(CASE WHEN strBucket = 'Current'	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket2 = MAX(CASE WHEN strBucket = '1 - 7'	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket3 = MAX(CASE WHEN strBucket = '8 - 14'	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket4 = MAX(CASE WHEN strBucket = '15 - 21'	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket5 = MAX(CASE WHEN strBucket = '22 - 29'	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket6 = MAX(CASE WHEN strBucket = '30 - 60'	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket7 = MAX(CASE WHEN strBucket = '60 - 90'	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket8 = MAX(CASE WHEN strBucket = '90 - 120' THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket9 = MAX(CASE WHEN strBucket = '120+'		THEN intCurrencyExchangeRateTypeId END)
			FROM @tblDefaultRateTypes A
			WHERE intFromCurrencyId = @intFilterCurrencyId
			AND dtmValidFromDate = (
				SELECT MAX(dtmValidFromDate) FROM @tblDefaultRateTypes
				WHERE 
					intFromCurrencyId = A.intFromCurrencyId
					AND intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId
					AND strBucket = A.strBucket
			)
		) DefaultRateType

		INSERT INTO tblCMCashFlowReportRate 
		SELECT
			@intCashFlowReportId,
			@intFilterCurrencyId,
			ISNULL(dblRateBucket1, 1),
			ISNULL(dblRateBucket2, 1),
			ISNULL(dblRateBucket3, 1),
			ISNULL(dblRateBucket4, 1),
			ISNULL(dblRateBucket5, 1),
			ISNULL(dblRateBucket6, 1),
			ISNULL(dblRateBucket7, 1),
			ISNULL(dblRateBucket8, 1),
			ISNULL(dblRateBucket9, 1),
			1
		FROM (
			SELECT
				dblRateBucket1 = MAX(CASE WHEN strBucket = 'Current'	THEN dblRate END),
				dblRateBucket2 = MAX(CASE WHEN strBucket = '1 - 7'		THEN dblRate END),
				dblRateBucket3 = MAX(CASE WHEN strBucket = '8 - 14'		THEN dblRate END),
				dblRateBucket4 = MAX(CASE WHEN strBucket = '15 - 21'	THEN dblRate END),
				dblRateBucket5 = MAX(CASE WHEN strBucket = '22 - 29'	THEN dblRate END),
				dblRateBucket6 = MAX(CASE WHEN strBucket = '30 - 60'	THEN dblRate END),
				dblRateBucket7 = MAX(CASE WHEN strBucket = '60 - 90'	THEN dblRate END),
				dblRateBucket8 = MAX(CASE WHEN strBucket = '90 - 120'	THEN dblRate END),
				dblRateBucket9 = MAX(CASE WHEN strBucket = '120+'		THEN dblRate END)
			FROM @tblDefaultRateTypes A
			WHERE intFromCurrencyId = @intFilterCurrencyId
			AND dtmValidFromDate = (
				SELECT MAX(dtmValidFromDate) FROM @tblDefaultRateTypes
				WHERE 
					intFromCurrencyId = A.intFromCurrencyId
					AND intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId
					AND strBucket = A.strBucket
			)
		) DefaultRate
		
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
			@intCashFlowReportId,
			@intFilterCurrencyId,
			intRateTypeIdBucket1,
			intRateTypeIdBucket2,
			intRateTypeIdBucket3,
			intRateTypeIdBucket4,
			intRateTypeIdBucket5,
			intRateTypeIdBucket6,
			intRateTypeIdBucket7,
			intRateTypeIdBucket8,
			intRateTypeIdBucket9,
			1
		FROM (
			SELECT
				intRateTypeIdBucket1 = MAX(CASE WHEN strBucket = 'Current'	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket2 = MAX(CASE WHEN strBucket = '1 - 7'	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket3 = MAX(CASE WHEN strBucket = '8 - 14'	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket4 = MAX(CASE WHEN strBucket = '15 - 21'	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket5 = MAX(CASE WHEN strBucket = '22 - 29'	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket6 = MAX(CASE WHEN strBucket = '30 - 60'	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket7 = MAX(CASE WHEN strBucket = '60 - 90'	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket8 = MAX(CASE WHEN strBucket = '90 - 120' THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket9 = MAX(CASE WHEN strBucket = '120+'		THEN intCurrencyExchangeRateTypeId END)
			FROM @tblDefaultRateTypes A
			WHERE intFromCurrencyId = @intFilterCurrencyId
			AND dtmValidFromDate = (
				SELECT MAX(dtmValidFromDate) FROM @tblDefaultRateTypes
				WHERE 
					intFromCurrencyId = A.intFromCurrencyId
					AND intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId
					AND strBucket = A.strBucket
			)
		) DefaultRateType

		INSERT INTO tblCMCashFlowReportRate 
		SELECT
			@intCashFlowReportId,
			@intFilterCurrencyId,
			ISNULL(dblRateBucket1, 1),
			ISNULL(dblRateBucket2, 1),
			ISNULL(dblRateBucket3, 1),
			ISNULL(dblRateBucket4, 1),
			ISNULL(dblRateBucket5, 1),
			ISNULL(dblRateBucket6, 1),
			ISNULL(dblRateBucket7, 1),
			ISNULL(dblRateBucket8, 1),
			ISNULL(dblRateBucket9, 1),
			1
		FROM (
			SELECT
				dblRateBucket1 = MAX(CASE WHEN strBucket = 'Current'	THEN dblRate END),
				dblRateBucket2 = MAX(CASE WHEN strBucket = '1 - 7'		THEN dblRate END),
				dblRateBucket3 = MAX(CASE WHEN strBucket = '8 - 14'		THEN dblRate END),
				dblRateBucket4 = MAX(CASE WHEN strBucket = '15 - 21'	THEN dblRate END),
				dblRateBucket5 = MAX(CASE WHEN strBucket = '22 - 29'	THEN dblRate END),
				dblRateBucket6 = MAX(CASE WHEN strBucket = '30 - 60'	THEN dblRate END),
				dblRateBucket7 = MAX(CASE WHEN strBucket = '60 - 90'	THEN dblRate END),
				dblRateBucket8 = MAX(CASE WHEN strBucket = '90 - 120'	THEN dblRate END),
				dblRateBucket9 = MAX(CASE WHEN strBucket = '120+'		THEN dblRate END)
			FROM @tblDefaultRateTypes A
			WHERE intFromCurrencyId = @intFilterCurrencyId
			AND dtmValidFromDate = (
				SELECT MAX(dtmValidFromDate) FROM @tblDefaultRateTypes
				WHERE 
					intFromCurrencyId = A.intFromCurrencyId
					AND intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId
					AND strBucket = A.strBucket
			)
		) DefaultRate
	END
END

INSERT INTO tblCMCashFlowReportRateType
SELECT DISTINCT 
	@intCashFlowReportId, 
	intFromCurrencyId, 
	intRateTypeIdBucket1,
	intRateTypeIdBucket2,
	intRateTypeIdBucket3,
	intRateTypeIdBucket4,
	intRateTypeIdBucket5,
	intRateTypeIdBucket6,
	intRateTypeIdBucket7,
	intRateTypeIdBucket8,
	intRateTypeIdBucket9,
	1
FROM @tblCurrency C
OUTER APPLY (
	SELECT
		intRateTypeIdBucket1 = MAX(CASE WHEN strBucket = 'Current'	THEN intCurrencyExchangeRateTypeId END),
		intRateTypeIdBucket2 = MAX(CASE WHEN strBucket = '1 - 7'	THEN intCurrencyExchangeRateTypeId END),
		intRateTypeIdBucket3 = MAX(CASE WHEN strBucket = '8 - 14'	THEN intCurrencyExchangeRateTypeId END),
		intRateTypeIdBucket4 = MAX(CASE WHEN strBucket = '15 - 21'	THEN intCurrencyExchangeRateTypeId END),
		intRateTypeIdBucket5 = MAX(CASE WHEN strBucket = '22 - 29'	THEN intCurrencyExchangeRateTypeId END),
		intRateTypeIdBucket6 = MAX(CASE WHEN strBucket = '30 - 60'	THEN intCurrencyExchangeRateTypeId END),
		intRateTypeIdBucket7 = MAX(CASE WHEN strBucket = '60 - 90'	THEN intCurrencyExchangeRateTypeId END),
		intRateTypeIdBucket8 = MAX(CASE WHEN strBucket = '90 - 120' THEN intCurrencyExchangeRateTypeId END),
		intRateTypeIdBucket9 = MAX(CASE WHEN strBucket = '120+'		THEN intCurrencyExchangeRateTypeId END)
	FROM @tblDefaultRateTypes A
	WHERE intFromCurrencyId = C.intFromCurrencyId
	AND dtmValidFromDate = (
		SELECT MAX(dtmValidFromDate) FROM @tblDefaultRateTypes
		WHERE 
			intFromCurrencyId = A.intFromCurrencyId
			AND intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId
			AND strBucket = A.strBucket
	)
) DefaultRateType


INSERT INTO tblCMCashFlowReportRate
SELECT DISTINCT 
	@intCashFlowReportId, 
	intFromCurrencyId,
	ISNULL(dblRateBucket1, 1),
	ISNULL(dblRateBucket2, 1),
	ISNULL(dblRateBucket3, 1),
	ISNULL(dblRateBucket4, 1),
	ISNULL(dblRateBucket5, 1),
	ISNULL(dblRateBucket6, 1),
	ISNULL(dblRateBucket7, 1),
	ISNULL(dblRateBucket8, 1),
	ISNULL(dblRateBucket9, 1),
	1
FROM @tblCurrency C
OUTER APPLY (
	SELECT
		dblRateBucket1 = MAX(CASE WHEN strBucket = 'Current'	THEN dblRate END),
		dblRateBucket2 = MAX(CASE WHEN strBucket = '1 - 7'		THEN dblRate END),
		dblRateBucket3 = MAX(CASE WHEN strBucket = '8 - 14'		THEN dblRate END),
		dblRateBucket4 = MAX(CASE WHEN strBucket = '15 - 21'	THEN dblRate END),
		dblRateBucket5 = MAX(CASE WHEN strBucket = '22 - 29'	THEN dblRate END),
		dblRateBucket6 = MAX(CASE WHEN strBucket = '30 - 60'	THEN dblRate END),
		dblRateBucket7 = MAX(CASE WHEN strBucket = '60 - 90'	THEN dblRate END),
		dblRateBucket8 = MAX(CASE WHEN strBucket = '90 - 120'	THEN dblRate END),
		dblRateBucket9 = MAX(CASE WHEN strBucket = '120+'		THEN dblRate END)
	FROM @tblDefaultRateTypes A
	WHERE intFromCurrencyId = C.intFromCurrencyId
	AND dtmValidFromDate = (
		SELECT MAX(dtmValidFromDate) FROM @tblDefaultRateTypes
		WHERE 
			intFromCurrencyId = A.intFromCurrencyId
			AND intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId
			AND strBucket = A.strBucket
	)
) DefaultRateType

EXIT_PROCESS:

-- Add reporting currency
DELETE tblCMCashFlowReportRateType WHERE intFilterCurrencyId = @intReportingCurrencyId AND intCashFlowReportId = @intCashFlowReportId
DELETE tblCMCashFlowReportRate WHERE intFilterCurrencyId = @intReportingCurrencyId AND intCashFlowReportId = @intCashFlowReportId

INSERT INTO tblCMCashFlowReportRateType (intCashFlowReportId, intFilterCurrencyId, intConcurrencyId) VALUES (@intCashFlowReportId, @intReportingCurrencyId, 1)
INSERT INTO tblCMCashFlowReportRate VALUES (@intCashFlowReportId, @intReportingCurrencyId, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
