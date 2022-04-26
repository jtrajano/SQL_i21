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
DECLARE @tblDefaultRateTypesRaw TABLE (
	intRowId INT,
	intFromCurrencyId INT,
	intToCurrencyId INT,
	intCurrencyExchangeRateDetailId INT,
	intCurrencyExchangeRateTypeId INT,
	strBucket NVARCHAR(MAX) NULL,
	dblRate DECIMAL(18, 6) DEFAULT 1,
	dtmValidFromDate DATETIME NULL,
	dtmCreatedDate DATETIME NULL
)

DECLARE @tblDefaultRateTypes TABLE (
	intRowId INT,
	intFromCurrencyId INT,
	intToCurrencyId INT,
	intCurrencyExchangeRateDetailId INT,
	intCurrencyExchangeRateTypeId INT,
	strBucket NVARCHAR(MAX) NULL,
	dblRate DECIMAL(18, 6) DEFAULT 1,
	dtmValidFromDate DATETIME NULL,
	dtmCreatedDate DATETIME NULL
)

DECLARE @tblDefaultRateTypeDuplicates TABLE (
	intRowId INT,
	intFromCurrencyId INT,
	intToCurrencyId INT,
	intCurrencyExchangeRateDetailId INT,
	intCurrencyExchangeRateTypeId INT,
	strBucket NVARCHAR(MAX) NULL,
	dblRate DECIMAL(18, 6) DEFAULT 1,
	dtmValidFromDate DATETIME NULL,
	dtmCreatedDate DATETIME NULL
)

DECLARE 
	@CURRENT NVARCHAR(10)	= 'Current',
	@1_7 NVARCHAR(10)		= '1 - 7',
	@8_14 NVARCHAR(10)		= '8 - 14',
	@15_21 NVARCHAR(10)		= '15 - 21',
	@22_29 NVARCHAR(10)		= '22 - 29',
	@30_60 NVARCHAR(10)		= '30 - 60',
	@61_90 NVARCHAR(10)		= '61 - 90',
	@91_120 NVARCHAR(10)	= '91 - 120',
	@121_ NVARCHAR(10)		= '121+'

-- Clear existing rates
DELETE tblCMCashFlowReportRateType WHERE intCashFlowReportId = @intCashFlowReportId
DELETE tblCMCashFlowReportRate WHERE intCashFlowReportId = @intCashFlowReportId

-- Get all Exchange Rate Details with Cash Flow defined
INSERT INTO @tblDefaultRateTypesRaw
SELECT
	ROW_NUMBER() OVER(ORDER BY RateDetail.dtmValidFromDate DESC),
	Rate.intFromCurrencyId,
	Rate.intToCurrencyId,
	RateDetail.intCurrencyExchangeRateDetailId,
	RateType.intCurrencyExchangeRateTypeId,
	Bucket.Item strBucket,
	ISNULL(RateDetail.dblRate, 1),
	RateDetail.dtmValidFromDate dtmValidFromDate,
	RateDetail.dtmCreatedDate dtmCreatedDate
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
ORDER BY RateDetail.dtmValidFromDate DESC, RateDetail.dtmCreatedDate DESC

-- Get and filter out exchange rate details by most recent Valid From Date
INSERT INTO @tblDefaultRateTypes
SELECT A.* FROM @tblDefaultRateTypesRaw A
INNER JOIN (
	SELECT strBucket, intFromCurrencyId, MAX(dtmValidFromDate) dtmValidFromDate
	FROM @tblDefaultRateTypesRaw
	GROUP BY strBucket, intFromCurrencyId
) G
ON A.strBucket = G.strBucket AND A.dtmValidFromDate = G.dtmValidFromDate AND A.intFromCurrencyId = G.intFromCurrencyId

-- Check and get if have duplicate buckets with same Valid From date
INSERT INTO @tblDefaultRateTypeDuplicates
SELECT * FROM @tblDefaultRateTypes WHERE strBucket IN(
	SELECT strBucket FROM @tblDefaultRateTypes
	GROUP BY strBucket
	HAVING COUNT (*) > 1
)

-- Get and filter out exchange rate details by most recent Created Date
IF EXISTS(SELECT 1 FROM @tblDefaultRateTypeDuplicates)
BEGIN
	-- Remove duplicate buckets with same Valid From date
	DELETE @tblDefaultRateTypes WHERE intRowId IN (SELECT intRowId FROM @tblDefaultRateTypeDuplicates B WHERE B.intRowId = intRowId)

	-- Insert most recent rates using Created Date
	INSERT INTO @tblDefaultRateTypes
	SELECT A.* FROM @tblDefaultRateTypeDuplicates A
	INNER JOIN (
		SELECT strBucket, intFromCurrencyId, MAX(dtmCreatedDate) dtmCreatedDate
		FROM @tblDefaultRateTypesRaw
		GROUP BY strBucket, intFromCurrencyId
	) G
	ON A.strBucket = G.strBucket AND A.dtmCreatedDate = G.dtmCreatedDate AND A.intFromCurrencyId = G.intFromCurrencyId

END

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
			intRateTypeIdBucket1 = MAX(CASE WHEN strBucket = @CURRENT	THEN intCurrencyExchangeRateTypeId END),
			intRateTypeIdBucket2 = MAX(CASE WHEN strBucket = @1_7		THEN intCurrencyExchangeRateTypeId END),
			intRateTypeIdBucket3 = MAX(CASE WHEN strBucket = @8_14		THEN intCurrencyExchangeRateTypeId END),
			intRateTypeIdBucket4 = MAX(CASE WHEN strBucket = @15_21		THEN intCurrencyExchangeRateTypeId END),
			intRateTypeIdBucket5 = MAX(CASE WHEN strBucket = @22_29		THEN intCurrencyExchangeRateTypeId END),
			intRateTypeIdBucket6 = MAX(CASE WHEN strBucket = @30_60		THEN intCurrencyExchangeRateTypeId END),
			intRateTypeIdBucket7 = MAX(CASE WHEN strBucket = @61_90		THEN intCurrencyExchangeRateTypeId END),
			intRateTypeIdBucket8 = MAX(CASE WHEN strBucket = @91_120	THEN intCurrencyExchangeRateTypeId END),
			intRateTypeIdBucket9 = MAX(CASE WHEN strBucket = @121_		THEN intCurrencyExchangeRateTypeId END)
		FROM @tblDefaultRateTypes A
		WHERE intFromCurrencyId = @intFilterCurrencyId
		AND dtmValidFromDate = (
			SELECT MAX(dtmValidFromDate) FROM @tblDefaultRateTypes
			WHERE 
				intFromCurrencyId = A.intFromCurrencyId
				AND intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId
				AND intCurrencyExchangeRateDetailId = A.intCurrencyExchangeRateDetailId
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
			dblRateBucket1 = MAX(CASE WHEN strBucket = @CURRENT	THEN dblRate END),
			dblRateBucket2 = MAX(CASE WHEN strBucket = @1_7		THEN dblRate END),
			dblRateBucket3 = MAX(CASE WHEN strBucket = @8_14	THEN dblRate END),
			dblRateBucket4 = MAX(CASE WHEN strBucket = @15_21	THEN dblRate END),
			dblRateBucket5 = MAX(CASE WHEN strBucket = @22_29	THEN dblRate END),
			dblRateBucket6 = MAX(CASE WHEN strBucket = @30_60	THEN dblRate END),
			dblRateBucket7 = MAX(CASE WHEN strBucket = @61_90	THEN dblRate END),
			dblRateBucket8 = MAX(CASE WHEN strBucket = @91_120	THEN dblRate END),
			dblRateBucket9 = MAX(CASE WHEN strBucket = @121_	THEN dblRate END)
		FROM @tblDefaultRateTypes A
		WHERE intFromCurrencyId = @intFilterCurrencyId
		AND dtmValidFromDate = (
			SELECT MAX(dtmValidFromDate) FROM @tblDefaultRateTypes
			WHERE 
				intFromCurrencyId = A.intFromCurrencyId
				AND intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId
				AND intCurrencyExchangeRateDetailId = A.intCurrencyExchangeRateDetailId
				AND strBucket = A.strBucket
		)
	) DefaultRate
		
	GOTO EXIT_PROCESS
END
ELSE
	GOTO GET_FROM_CURRENCY_EXCHANGE

GET_FROM_CURRENCY_EXCHANGE:

DECLARE @tblCurrency TABLE (
	intFromCurrencyId INT
)

INSERT INTO @tblCurrency
SELECT DISTINCT intFromCurrencyId
FROM tblSMCurrencyExchangeRate 
WHERE intToCurrencyId = @intReportingCurrencyId

IF NOT EXISTS(SELECT TOP 1 1 FROM @tblCurrency)
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
				intRateTypeIdBucket1 = MAX(CASE WHEN strBucket = @CURRENT	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket2 = MAX(CASE WHEN strBucket = @1_7		THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket3 = MAX(CASE WHEN strBucket = @8_14		THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket4 = MAX(CASE WHEN strBucket = @15_21		THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket5 = MAX(CASE WHEN strBucket = @22_29		THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket6 = MAX(CASE WHEN strBucket = @30_60		THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket7 = MAX(CASE WHEN strBucket = @61_90		THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket8 = MAX(CASE WHEN strBucket = @91_120	THEN intCurrencyExchangeRateTypeId END),
				intRateTypeIdBucket9 = MAX(CASE WHEN strBucket = @121_		THEN intCurrencyExchangeRateTypeId END)
			FROM @tblDefaultRateTypes A
			WHERE intFromCurrencyId = @intFilterCurrencyId
				AND intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId
				AND intCurrencyExchangeRateDetailId = A.intCurrencyExchangeRateDetailId
				AND strBucket = A.strBucket
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
				dblRateBucket1 = MAX(CASE WHEN strBucket = @CURRENT	THEN dblRate END),
				dblRateBucket2 = MAX(CASE WHEN strBucket = @1_7		THEN dblRate END),
				dblRateBucket3 = MAX(CASE WHEN strBucket = @8_14	THEN dblRate END),
				dblRateBucket4 = MAX(CASE WHEN strBucket = @15_21	THEN dblRate END),
				dblRateBucket5 = MAX(CASE WHEN strBucket = @22_29	THEN dblRate END),
				dblRateBucket6 = MAX(CASE WHEN strBucket = @30_60	THEN dblRate END),
				dblRateBucket7 = MAX(CASE WHEN strBucket = @61_90	THEN dblRate END),
				dblRateBucket8 = MAX(CASE WHEN strBucket = @91_120	THEN dblRate END),
				dblRateBucket9 = MAX(CASE WHEN strBucket = @121_	THEN dblRate END)
			FROM @tblDefaultRateTypes A
			WHERE intFromCurrencyId = @intFilterCurrencyId
				AND intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId
				AND intCurrencyExchangeRateDetailId = A.intCurrencyExchangeRateDetailId
				AND strBucket = A.strBucket
		) DefaultRate
	END

	GOTO EXIT_PROCESS
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
		intRateTypeIdBucket1 = MAX(CASE WHEN strBucket = @CURRENT	THEN intCurrencyExchangeRateTypeId END),
		intRateTypeIdBucket2 = MAX(CASE WHEN strBucket = @1_7		THEN intCurrencyExchangeRateTypeId END),
		intRateTypeIdBucket3 = MAX(CASE WHEN strBucket = @8_14		THEN intCurrencyExchangeRateTypeId END),
		intRateTypeIdBucket4 = MAX(CASE WHEN strBucket = @15_21		THEN intCurrencyExchangeRateTypeId END),
		intRateTypeIdBucket5 = MAX(CASE WHEN strBucket = @22_29		THEN intCurrencyExchangeRateTypeId END),
		intRateTypeIdBucket6 = MAX(CASE WHEN strBucket = @30_60		THEN intCurrencyExchangeRateTypeId END),
		intRateTypeIdBucket7 = MAX(CASE WHEN strBucket = @61_90		THEN intCurrencyExchangeRateTypeId END),
		intRateTypeIdBucket8 = MAX(CASE WHEN strBucket = @91_120	THEN intCurrencyExchangeRateTypeId END),
		intRateTypeIdBucket9 = MAX(CASE WHEN strBucket = @121_		THEN intCurrencyExchangeRateTypeId END)
	FROM @tblDefaultRateTypes A
	WHERE intFromCurrencyId = C.intFromCurrencyId
			AND intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId
			AND intCurrencyExchangeRateDetailId = A.intCurrencyExchangeRateDetailId
			AND strBucket = A.strBucket
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
		dblRateBucket1 = MAX(CASE WHEN strBucket = @CURRENT	THEN dblRate END),
		dblRateBucket2 = MAX(CASE WHEN strBucket = @1_7		THEN dblRate END),
		dblRateBucket3 = MAX(CASE WHEN strBucket = @8_14	THEN dblRate END),
		dblRateBucket4 = MAX(CASE WHEN strBucket = @15_21	THEN dblRate END),
		dblRateBucket5 = MAX(CASE WHEN strBucket = @22_29	THEN dblRate END),
		dblRateBucket6 = MAX(CASE WHEN strBucket = @30_60	THEN dblRate END),
		dblRateBucket7 = MAX(CASE WHEN strBucket = @61_90	THEN dblRate END),
		dblRateBucket8 = MAX(CASE WHEN strBucket = @91_120	THEN dblRate END),
		dblRateBucket9 = MAX(CASE WHEN strBucket = @121_	THEN dblRate END)
	FROM @tblDefaultRateTypes A
	WHERE intFromCurrencyId = C.intFromCurrencyId
			AND intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId
			AND intCurrencyExchangeRateDetailId = A.intCurrencyExchangeRateDetailId
			AND strBucket = A.strBucket
) DefaultRateType

EXIT_PROCESS:

-- Add reporting currency
DELETE tblCMCashFlowReportRateType WHERE intFilterCurrencyId = @intReportingCurrencyId AND intCashFlowReportId = @intCashFlowReportId
DELETE tblCMCashFlowReportRate WHERE intFilterCurrencyId = @intReportingCurrencyId AND intCashFlowReportId = @intCashFlowReportId

INSERT INTO tblCMCashFlowReportRateType (intCashFlowReportId, intFilterCurrencyId, intConcurrencyId) VALUES (@intCashFlowReportId, @intReportingCurrencyId, 1)
INSERT INTO tblCMCashFlowReportRate VALUES (@intCashFlowReportId, @intReportingCurrencyId, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
