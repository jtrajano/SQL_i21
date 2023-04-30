CREATE FUNCTION [dbo].[fnFAComputeMultipleBookDepreciation]
(
    @Id FABookDepreciationTypeTable READONLY
)
RETURNS @tbl TABLE (
	intAssetId INT,
	dblBasis NUMERIC(18,6) NULL, -- Actual Basis
	dblDepreciationBasis NUMERIC(18,6) NULL, -- Basis for depreciation computation
	dblMonth NUMERIC(18,6) NULL,
	dblDepre NUMERIC(18,6) NULL,
	dblFunctionalBasis NUMERIC(18,6) NULL,
	dblFunctionalDepreciationBasis NUMERIC(18,6) NULL,
	dblFunctionalMonth NUMERIC(18,6) NULL,
	dblFunctionalDepre NUMERIC(18,6) NULL,
	dblRate NUMERIC(18,6) NULL,
	ysnMultiCurrency BIT NULL,
	ysnFullyDepreciated BIT NULL,
	strError NVARCHAR(100) NULL,
	strTransaction NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	intBookDepreciationId INT NULL,
	intBookId INT NULL
)
AS
BEGIN
DECLARE @tblAssetInfo TABLE (
	intAssetId INT,
	intBookDepreciationId INT,
	intBookId INT,
	intDepreciationMethodId INT, 
	strConvention NVARCHAR(40),
	dblBasis NUMERIC(18,6) NULL, -- Actual Basis
	
	dblOrigBasis NUMERIC(18,6) NULL, 
	dblAdjustmentBasis NUMERIC(18,6) NULL, 
	dblAdjustmentDepreciation NUMERIC(18,6) NULL,
	dblDepreciationBasis NUMERIC(18,6) NULL, -- Basis for depreciation computation
	ysnAdjustBasis BIT NULL,
	dtmAdjustDate DATETIME NULL,

	dtmPlacedInService DATETIME,
	dtmDepreciationToDate DATETIME,
	dblYear DECIMAL(18,6),
	dblImportGAAPDepToDate DECIMAL(18,6),
	dtmImportedDepThru DATETIME,
	strError NVARCHAR(100),
	intYear INT,
	intMonth INT,
	totalMonths INT,
	intExcessMonth INT,
	intServiceYear INT,
	intMonthDivisor INT,
	dblPercentage DECIMAL(18,6),
	dblAnnualDep	NUMERIC (18,6),
	dblMonth		NUMERIC (18,6),
	intDaysInFirstMonth INT,
	intDaysRemainingFirstMonth INT,
	dblDepre 	DECIMAL (18,6),
	ysnFullyDepreciated BIT NULL,
	strTransaction NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	strAssetTransaction NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	dblQuarterly NUMERIC (18,6),
	dblMidQuarter NUMERIC (18,6),
	dblMidYear NUMERIC (18,6),
	dblRate NUMERIC (18,6),
	ysnMultiCurrency BIT NULL,
	intLedgerId INT NULL
) 

DECLARE 
	@intDefaultCurrencyId INT, 
	@ysnAdjustBasis BIT = NULL,
	@ysnBasisDecreased BIT = NULL,
	@ysnDepreciationAdjustBasis BIT = NULL,
	@dblAdjustment NUMERIC(18, 6), 
	@dblFunctionalAdjustment NUMERIC(18, 6),
	@dblDepreciationAdjustment NUMERIC(18, 6),
	@dblFunctionalDepreciationAdjustment NUMERIC(18, 6),
	@dblOrigBasis NUMERIC(18, 6), 
	@dtmBasisAdjustment DATETIME

SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference 

INSERT INTO  @tblAssetInfo(
	intAssetId,
	intBookDepreciationId,
	intBookId,
	intDepreciationMethodId, 
	strConvention,
	dblBasis,
	dblDepreciationBasis,
	dtmPlacedInService,
	dtmDepreciationToDate,
	dblYear,
	dblImportGAAPDepToDate,
	dtmImportedDepThru,
	strAssetTransaction,
	dblRate,
	ysnMultiCurrency,
	intLedgerId
)
SELECT 
	  intId
	, BD.intBookDepreciationId
	, BD.intBookId
	, BD.intDepreciationMethodId
	, strConvention
	, ISNULL(Depreciation.dblBasis, BD.dblCost - BD.dblSalvageValue)
	, ISNULL(Depreciation.dblDepreciationBasis, BD.dblCost - BD.dblSalvageValue)
	, CASE WHEN ISNULL(A.ysnImported, 0) = 1 AND A.dtmCreateAssetPostDate IS NOT NULL THEN A.dtmCreateAssetPostDate ELSE BD.dtmPlacedInService END
	, ISNULL(Depreciation.dtmDepreciationToDate, CASE WHEN ISNULL(A.ysnImported, 0) = 1 AND A.dtmCreateAssetPostDate IS NOT NULL THEN A.dtmCreateAssetPostDate ELSE BD.dtmPlacedInService END)
	, Depreciation.dblDepreciationToDate
	, CASE WHEN BD.intBookId = 1 THEN  A.dblImportGAAPDepToDate ELSE A.dblImportTaxDepToDate END
	, ImportedDepThruMonthPeriod.dtmEndDate
	, Depreciation.strTransaction
	, CASE WHEN ISNULL(BD.dblRate, 0) > 0 THEN BD.dblRate ELSE ISNULL(A.dblForexRate, 1) END
	, CASE WHEN ISNULL(BD.intFunctionalCurrencyId, ISNULL(A.intFunctionalCurrencyId, @intDefaultCurrencyId)) = ISNULL(BD.intCurrencyId, A.intCurrencyId) THEN 0 ELSE 1 END
	, BD.intLedgerId
FROM tblFAFixedAsset A 
JOIN tblFABookDepreciation BD ON BD.intAssetId = A.intAssetId 
JOIN tblFADepreciationMethod DM ON BD.intDepreciationMethodId = DM.intDepreciationMethodId
JOIN @Id I ON I.intId = A.intAssetId AND I.intBookDepreciationId = BD.intBookDepreciationId
OUTER APPLY(
	SELECT TOP 1 dblDepreciationToDate, dtmDepreciationToDate, strTransaction, dblDepreciationBasis, dblBasis 
	FROM tblFAFixedAssetDepreciation WHERE [intAssetId] =  A.intAssetId
	AND intBookDepreciationId = BD.intBookDepreciationId AND strTransaction <> 'Place in service'
	ORDER BY intAssetDepreciationId DESC
) Depreciation
OUTER APPLY (
	SELECT dtmEndDate FROM [dbo].[fnFAGetMonthPeriodFromDate](A.dtmImportedDepThru, CASE WHEN BD.intBookId = 1 THEN 1 ELSE 0 END)
) ImportedDepThruMonthPeriod

UPDATE @tblAssetInfo SET dblOrigBasis = dblBasis

-- Check Adjusment to Basis
UPDATE A
SET dblBasis += ISNULL(Adjustments.dblAdjustment, 0),
	dblDepreciationBasis += CASE WHEN(Adjustments.ysnAddToBasis = 1) THEN ISNULL(Adjustments.dblAdjustment, 0) ELSE 0 END,
	dblAdjustmentBasis = ISNULL(Adjustments.dblAdjustment, 0),
	dtmAdjustDate = Adjustments.dtmDate,
	ysnAdjustBasis = Adjustments.ysnAddToBasis
FROM @tblAssetInfo A
OUTER APPLY (
	SELECT ISNULL(SUM(B. dblAdjustment), 0) dblAdjustment, MAX(CAST(B.ysnAddToBasis AS INT)) ysnAddToBasis, MAX(B.dtmDate) dtmDate, B.intBookId, B.intAssetId FROM tblFABasisAdjustment B 
	WHERE B.intAssetId = A.intAssetId AND B.intBookId = A.intBookId
		AND B.dtmDate BETWEEN DATEADD(DAY, 1, A.dtmDepreciationToDate) AND dbo.fnFAGetNextBookDepreciationDate(B.intAssetId, A.intBookDepreciationId) 
		AND B.strAdjustmentType = 'Basis'
	GROUP BY B.intAssetId, B.intBookId, B.ysnAddToBasis
) Adjustments
WHERE A.intAssetId = Adjustments.intAssetId AND A.intBookId = Adjustments.intBookId AND ISNULL(Adjustments.dblAdjustment, 0) <> 0

-- Check Adjustment to Depreciation
UPDATE A
SET dblDepreciationBasis += CASE WHEN(Adjustments.ysnAddToBasis = 1) THEN ISNULL(Adjustments.dblAdjustment, 0) ELSE 0 END,
	dblAdjustmentDepreciation = ISNULL(Adjustments.dblAdjustment, 0),
	dtmAdjustDate = Adjustments.dtmDate,
	ysnAdjustBasis = Adjustments.ysnAddToBasis
FROM @tblAssetInfo A
OUTER APPLY (
	SELECT ISNULL(SUM(B. dblAdjustment), 0) dblAdjustment, MAX(CAST(B.ysnAddToBasis AS INT)) ysnAddToBasis, MAX(B.dtmDate) dtmDate, B.intBookId, B.intAssetId FROM tblFABasisAdjustment B 
	WHERE B.intAssetId = A.intAssetId AND B.intBookId = A.intBookId
		AND B.dtmDate BETWEEN DATEADD(DAY, 1, A.dtmDepreciationToDate) AND dbo.fnFAGetNextBookDepreciationDate(B.intAssetId, A.intBookDepreciationId) 
		AND B.strAdjustmentType = 'Depreciation'
	GROUP BY B.intAssetId, B.intBookId, B.ysnAddToBasis
) Adjustments
WHERE A.intAssetId = Adjustments.intAssetId AND A.intBookId = Adjustments.intBookId AND ISNULL(Adjustments.dblAdjustment, 0) <> 0

-- If negative adjustment to basis is less than accumulated depreciation
-- Get the depreciation to date before adjustment date and subtract to the dblYear so that it will reset to zero
UPDATE A
	SET dblYear = CASE WHEN @dblOrigBasis > dblBasis THEN A.dblYear - DepBeforeAdjustment.dblDepreciationToDate ELSE A.dblYear END
FROM @tblAssetInfo A
OUTER APPLY (
	SELECT MAX(dblDepreciationToDate) dblDepreciationToDate 
	FROM tblFAFixedAssetDepreciation 
	WHERE dtmDepreciationToDate <= A.dtmAdjustDate AND intAssetId = A.intAssetId AND intBookDepreciationId = A.intBookDepreciationId
) DepBeforeAdjustment
WHERE A.ysnAdjustBasis IS NOT NULL AND A.dblAdjustmentBasis < 0 AND ROUND(dblYear,2) >=  ROUND(dblBasis,2)

UPDATE @tblAssetInfo SET strError =  'Fixed asset should be disposed.' 
	WHERE ROUND(dblYear,2) >=  ROUND(dblBasis,2) AND ISNULL(ysnAdjustBasis, 0) <> 0

IF NOT EXISTS(SELECT TOP 1 1 FROM @tblAssetInfo WHERE strError IS NULL)
	RETURN

UPDATE T 
SET 
intMonthDivisor = CASE WHEN D.intMonth > (M.intServiceYear * 12) AND isnull(M.intMonth,0) > 0 THEN M.intMonth ELSE 12 END,
intMonth = D.intMonth,
totalMonths=ISNULL(M.intServiceYear,0)* 12 + ISNULL(M.intMonth ,0),
intExcessMonth = isnull(M.intMonth,0), 
intServiceYear = ISNULL(M.intServiceYear,0),
intYear = CEILING(D.intMonth/12.0),
dblPercentage = E.dblPercentage,
dblAnnualDep = (E.dblPercentage *.01) *  dblDepreciationBasis
FROM @tblAssetInfo T JOIN
tblFADepreciationMethod  M ON  M.intDepreciationMethodId = T.intDepreciationMethodId
JOIN tblFABookDepreciation BD ON BD.intDepreciationMethodId= M.intDepreciationMethodId AND BD.intBookDepreciationId = T.intBookDepreciationId AND BD.intAssetId = T.intAssetId
OUTER APPLY(
	SELECT COUNT (*) + 1 intMonth
	FROM tblFAFixedAssetDepreciation B
	WHERE B.intAssetId = T.intAssetId AND B.intBookDepreciationId = BD.intBookDepreciationId
	AND strTransaction = 'Depreciation'
) D
OUTER APPLY(
	SELECT ISNULL(dblPercentage,1) dblPercentage FROM tblFADepreciationMethodDetail 
		WHERE M.[intDepreciationMethodId] = intDepreciationMethodId AND
		  intYear = CEILING(
		 	CASE 
			 	WHEN D.intMonth > ISNULL(M.intServiceYear,0)* 12 + ISNULL(M.intMonth ,0) 
			 	THEN ISNULL(M.intServiceYear,0)* 12 + ISNULL(M.intMonth ,0)
		  	ELSE
		  		D.intMonth -- IF MONTH IS OUT OF RANGE, THIS WILL GET THE LAST PERCENTAGE OF MONTH
		  	END/12.0)
)E
WHERE strError IS NULL

-- Set Quarterly and Mid Quarter Depreciation take for Mid Quarter Convention
UPDATE @tblAssetInfo
SET dblQuarterly = dblAnnualDep / 4, dblMidQuarter = (dblAnnualDep/4)/2
WHERE strConvention = 'Mid Quarter' AND strError IS NULL

-- Mid Year Depreciation Take for Mid Year Convention
UPDATE @tblAssetInfo
SET dblMidYear = dblAnnualDep / 2
WHERE strConvention = 'Mid Year' AND strError IS NULL

-- Add Section 179 and Bonus Depreciation to Tax if any on the 1st month of depreciation
UPDATE A
SET 
	A.dblDepre = ISNULL(A.dblDepre, 0) + ISNULL(BD.dblSection179, 0) + ISNULL(BD.dblBonusDepreciation, 0),
	A.dblMonth = ISNULL(A.dblMonth, 0) + ISNULL(BD.dblSection179, 0) + ISNULL(BD.dblBonusDepreciation, 0)
FROM  @tblAssetInfo A
JOIN tblFABookDepreciation BD ON A.intAssetId = BD.intAssetId AND BD.intBookDepreciationId = A.intBookDepreciationId
JOIN @Id I ON I.intId = A.intAssetId
WHERE A.intAssetId = I.intId AND BD.intBookId <> 1 AND A.intMonth = 1

-- If sum of Section179 and BonusDepreciation (current dblDepre) is greater than or equal to the basis, skip monthly depreciation
IF EXISTS(SELECT TOP 1 1 FROM  @tblAssetInfo A JOIN @Id I ON I.intId = A.intAssetId 
			JOIN tblFABookDepreciation BD ON A.intAssetId = BD.intAssetId 
			WHERE A.intAssetId = I.intId AND BD.intBookId <> 1 AND A.intMonth = 1 AND dblDepreciationBasis <= dblDepre)
BEGIN
	GOTO Skip_Tax_Monthly_Depreciation
END

UPDATE T 
SET 
	dblPercentage = F.dblPercentage,
	dblAnnualDep = (F.dblPercentage *.01) * dblDepreciationBasis,
	intYear = F.intYear
FROM @tblAssetInfo T
OUTER APPLY (
	SELECT TOP 1 intYear, dblPercentage, strConvention FROM tblFADepreciationMethodDetail A 
	JOIN tblFADepreciationMethod B ON A.intDepreciationMethodId = B.intDepreciationMethodId
	WHERE A.intDepreciationMethodId = T.intDepreciationMethodId
	ORDER BY intYear DESC
) F
WHERE intMonth > totalMonths
AND F.strConvention <> 'Full Month'

-- Update monthly depreciation computation per convention using fiscal year period
UPDATE T  
SET dblMonth = dblAnnualDep/ intMonthDivisor,  
intDaysInFirstMonth = MonthPeriod.intDays  
FROM @tblAssetInfo T  
OUTER APPLY (  
	SELECT intDays FROM [dbo].[fnFAGetMonthPeriodFromDate](T.dtmPlacedInService, CASE WHEN T.intBookId = 1 THEN 1 ELSE 0 END)  
) MonthPeriod  
WHERE strError IS NULL  AND T.intBookId = 1

UPDATE T  
SET dblMonth = (ISNULL(dblAnnualDep,0) - ISNULL(BD.dblBonusDepreciation,0) )/ intMonthDivisor,    
intDaysInFirstMonth = MonthPeriod.intDays  
FROM @tblAssetInfo T  
JOIN tblFABookDepreciation BD ON T.intAssetId = BD.intAssetId AND BD.intBookDepreciationId = T.intBookDepreciationId  
OUTER APPLY (  
	SELECT intDays FROM [dbo].[fnFAGetMonthPeriodFromDate](T.dtmPlacedInService, CASE WHEN T.intBookId = 1 THEN 1 ELSE 0 END)  
) MonthPeriod  
WHERE strError IS NULL  AND T.intBookId <> 1 AND intMonth <> 1


UPDATE T
SET 
dblMonth = 
	CASE 
	WHEN strConvention = 'Actual Days'
		THEN dblMonth * ((intDaysInFirstMonth - (DATEDIFF(DAY, MonthPeriod.dtmStartDate, dtmPlacedInService) + 1) + 1)/ CAST(intDaysInFirstMonth AS FLOAT))
	WHEN strConvention= 'Mid Month' 
		THEN dblMonth *.50
	ELSE
		dblMonth
	END
FROM @tblAssetInfo T
OUTER APPLY (
	SELECT dtmStartDate FROM [dbo].[fnFAGetMonthPeriodFromDate](T.dtmPlacedInService, CASE WHEN T.intBookId = 1 THEN 1 ELSE 0 END)
) MonthPeriod
WHERE strError IS NULL AND intMonth = 1 --First Depreciation

-- Mid Quarter Convention -> Compute Mid Quarter depreciation take on the Quarter that the PlacedInService falls into.
IF EXISTS(SELECT TOP 1 1 FROM @tblAssetInfo WHERE strConvention = 'Mid Quarter' AND strError IS NULL)
BEGIN
	UPDATE T SET dblMonth = dblMidQuarter / B.intRemainingMonthsInQuarter
	FROM @tblAssetInfo T
	OUTER APPLY (
		SELECT [dbo].[fnFACountRemainingMonthsInQuarter](T.dtmPlacedInService, CASE WHEN T.intBookId = 1 THEN 1 ELSE 0 END) intRemainingMonthsInQuarter
	) B
	WHERE strError IS NULL AND intMonth BETWEEN 1 AND B.intRemainingMonthsInQuarter -- From the month of PlacedInService up to the last month of the quarter of the PlacedInService date
	AND strConvention = 'Mid Quarter'
END

-- Mid Year Convention -> Compute Mid Year depreciation take on the year that PlacedInService falls into.
IF EXISTS(SELECT TOP 1 1 FROM @tblAssetInfo WHERE strConvention = 'Mid Year' AND strError IS NULL)
BEGIN
	UPDATE T
	SET dblMonth = dblMidYear / B.intRemainingMonthsInYear 
	FROM @tblAssetInfo T
	OUTER APPLY (
		SELECT [dbo].[fnFACountRemainingMonthsInYear](T.dtmPlacedInService, CASE WHEN T.intBookId = 1 THEN 1 ELSE 0 END) intRemainingMonthsInYear
	) B
	WHERE strError IS NULL AND intMonth BETWEEN 1 AND B.intRemainingMonthsInYear --from month of PlacedInService up to the last month of year of the PlacedInService date
	AND strConvention = 'Mid Year'
END

-- Validate Adjustment to Depreciation
-- Adjust monthly depreciation between current depreciation date and upcoming depreciation date 
UPDATE T SET dblMonth += ISNULL(dblAdjustmentDepreciation, 0)
FROM @tblAssetInfo T
JOIN tblFABasisAdjustment B ON B.intAssetId = T.intAssetId AND B.intBookId = T.intBookId
OUTER APPLY (
	SELECT MAX(dtmDepreciationToDate) dtmDepreciationToDate FROM tblFAFixedAssetDepreciation 
	WHERE intAssetId = T.intAssetId AND intBookId = T.intBookId AND intBookDepreciationId = T.intBookDepreciationId AND strTransaction = 'Depreciation'
) Depreciation
WHERE B.dtmDate BETWEEN Depreciation.dtmDepreciationToDate AND dbo.fnFAGetNextBookDepreciationDate(B.intAssetId, T.intBookDepreciationId) 
	AND B.strAdjustmentType = 'Depreciation' AND T.ysnAdjustBasis = 0

-- Set upcoming depreciation to date
UPDATE T SET dblDepre = dblMonth  + ISNULL(dblYear, 0)
FROM @tblAssetInfo T
WHERE strError IS NULL 

-- Add Bonus Depreciation and Section 179 to monthly depreciation on the first month only
UPDATE A
SET 
	A.dblDepre =  ((ISNULL(A.dblBasis,0)  + ISNULL(BD.dblSection179, 0) - ISNULL(BD.dblBonusDepreciation, 0)) / intMonthDivisor) + ISNULL(BD.dblBonusDepreciation, 0),
	A.dblMonth = ((ISNULL(A.dblBasis,0)  + ISNULL(BD.dblSection179, 0) - ISNULL(BD.dblBonusDepreciation, 0)) / intMonthDivisor) + ISNULL(BD.dblBonusDepreciation, 0)
FROM  @tblAssetInfo A
JOIN tblFABookDepreciation BD ON A.intAssetId = BD.intAssetId AND BD.intBookDepreciationId = A.intBookDepreciationId
JOIN @Id I ON I.intId = A.intAssetId
WHERE A.intAssetId = I.intId AND BD.intBookId <> 1 AND A.intMonth = 1

IF EXISTS(SELECT TOP 1 1 FROM @tblAssetInfo WHERE dblDepreciationBasis < dblDepre)
	GOTO Basis_Limit_Reached

Basis_Limit_Reached:

UPDATE @tblAssetInfo set ysnFullyDepreciated = 1 WHERE dblDepre >= dblBasis AND strError IS NULL

UPDATE B 
SET 
	dblDepre = dblBasis, 
	dblMonth = dblBasis - U.dblDepreciationToDate
FROM @tblAssetInfo B 
JOIN tblFABookDepreciation BD 
	ON BD.intAssetId = B.intAssetId AND BD.intBookDepreciationId = B.intBookDepreciationId
OUTER APPLY(
	SELECT MAX (dblDepreciationToDate) dblDepreciationToDate 
	FROM tblFAFixedAssetDepreciation 
	WHERE intAssetId = B.intAssetId AND intBookDepreciationId = B.intBookDepreciationId
) U
WHERE 
	dblDepre > dblBasis AND 
	strError IS NULL

-- Imported Assets
UPDATE 
A
SET dblDepre =
CASE 
	WHEN Import.t = 0 THEN 0
	WHEN Import.t = 1 THEN dblDepre
	WHEN Import.t = 2 THEN dblImportGAAPDepToDate
END,
dblMonth =
CASE
	WHEN Import.t = 0 THEN 0
	WHEN Import.t = 1 THEN dblMonth
	WHEN Import.t = 2 THEN dblImportGAAPDepToDate
END,
strTransaction =
CASE
	WHEN Import.t = 2 THEN 'Imported'
	ELSE NULL
END
FROM
@tblAssetInfo A 
OUTER APPLY
(
	SELECT TOP 1
		  dtmDepreciationToDate
		, dblDepreciationToDate
		, strTransaction
	FROM tblFAFixedAssetDepreciation
	WHERE intAssetId = A.intAssetId
	AND intBookDepreciationId = A.intBookDepreciationId
	ORDER BY dtmDepreciationToDate DESC
)Dep
OUTER APPLY(
	SELECT TOP 1 D.dtmEndDate FROM (
		SELECT dtmEndDate, 'A' src  FROM dbo.fnFAGetMonthPeriodFromDate(A.dtmPlacedInService, CASE WHEN A.intBookId = 1 THEN 1 ELSE 0 END) -- get end date of current month
		UNION ALL
		SELECT dtmEndDate, 'B' src  FROM dbo.fnFAGetNextMonthPeriodFromDate(Dep.dtmDepreciationToDate, CASE WHEN A.intBookId = 1 THEN 1 ELSE 0 END) -- get end date of next month
	) D
	WHERE src = CASE WHEN Dep.strTransaction = 'Place in service' OR Dep.strTransaction IS NULL THEN 'A' ELSE 'B' END
)PrevDepPlusOneMonth
OUTER APPLY(
	SELECT t=
	CASE
	WHEN A.dtmImportedDepThru IS NULL THEN 0
	WHEN A.dtmImportedDepThru > PrevDepPlusOneMonth.dtmEndDate THEN 0
	WHEN A.dtmImportedDepThru = PrevDepPlusOneMonth.dtmEndDate
		THEN
			CASE WHEN A.strTransaction = 'Place in service' OR A.strTransaction IS NULL THEN 0
			ELSE 2
			END
	ELSE 
		1
	END
)Import
WHERE dblImportGAAPDepToDate IS NOT NULL AND ISNULL(dtmImportedDepThru,0) > 0

--Add Depreciaition Import FA-489

UPDATE T0 
SET T0.dblDepre = 0 , T0.dblMonth = 0
FROM @tblAssetInfo T0
INNER JOIN  tblFABookDepreciation T1 
ON T0.intBookId = T1.intBookId AND T0.intAssetId = T1.intAssetId
WHERE YEAR(dtmImportDepThruDate) = YEAR(dtmDepreciationToDate)
AND MONTH(dtmDepreciationToDate) + 1 < MONTH(dtmImportDepThruDate) 

UPDATE T0 
SET T0.dblDepre = T0.dblDepre + ISNULL(dblImportDepreciationToDate,0)
FROM @tblAssetInfo T0
INNER JOIN  tblFABookDepreciation T1 
ON T0.intBookId = T1.intBookId AND T0.intAssetId = T1.intAssetId
WHERE YEAR(dtmDepreciationToDate) > YEAR(dtmImportDepThruDate)
AND MONTH(dtmDepreciationToDate) + 1 > MONTH(dtmImportDepThruDate) 

UPDATE T0 
SET T0.dblDepre = (T0.dblDepre + ISNULL(dblImportDepreciationToDate,0)) - T0.dblMonth , T0.dblMonth = 0
FROM @tblAssetInfo T0
INNER JOIN  tblFABookDepreciation T1 
ON T0.intBookId = T1.intBookId AND T0.intAssetId = T1.intAssetId
WHERE YEAR(dtmDepreciationToDate) = YEAR(dtmImportDepThruDate)
AND MONTH(dtmDepreciationToDate) + 1 = MONTH(dtmImportDepThruDate) 


Skip_Tax_Monthly_Depreciation:

UPDATE B set dblDepre = dblBasis,
	dblMonth = dblBasis - U.dblDepreciationToDate
FROM @tblAssetInfo B 
JOIN tblFABookDepreciation BD 
	ON BD.intAssetId = B.intAssetId AND BD.intBookDepreciationId = B.intBookDepreciationId
OUTER APPLY(
	SELECT MAX(dblDepreciationToDate) dblDepreciationToDate 
	FROM tblFAFixedAssetDepreciation WHERE intAssetId = B.intAssetId AND intBookDepreciationId = B.intBookDepreciationId
) U
WHERE dblDepre < dblBasis 
AND intMonth > totalMonths
AND strConvention NOT IN ('Full Month', 'Mid Quarter', 'Mid Year')
AND ISNULL(BD.ysnFullyDepreciated, 0) = 0

--ROUND OFF TO NEAREAST HUNDREDTHS
UPDATE @tblAssetInfo
SET dblMonth = ROUND(dblMonth, 2),
dblDepre =  ROUND(dblDepre, 2)
   
INSERT INTO @tbl(
	  intAssetId
	, dblBasis
	, dblDepreciationBasis
	, dblMonth
	, dblDepre
	, dblFunctionalBasis
	, dblFunctionalDepreciationBasis
	, dblFunctionalMonth
	, dblFunctionalDepre
	, dblRate
	, ysnMultiCurrency
	, ysnFullyDepreciated
	, strError
	, strTransaction
	, intBookDepreciationId
	, intBookId
)
SELECT 
	  intAssetId
	, dblBasis
	, dblDepreciationBasis
	, dblMonth
	, dblDepre
	, dblBasis * dblRate
	, dblDepreciationBasis * dblRate
	, dblMonth * dblRate
	, dblDepre * dblRate
	, dblRate
	, ysnMultiCurrency
	, ysnFullyDepreciated
	, strError
	, strTransaction
	, intBookDepreciationId
	, intBookId
FROM @tblAssetInfo 

RETURN
END