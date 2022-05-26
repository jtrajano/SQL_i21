CREATE FUNCTION [dbo].[fnFAComputeMultipleDepreciation]
(
    @Id FixedAssetLedgerTypeTable READONLY,
	@BookId INT = 1
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
	intLedgerId INT NULL
)
AS
BEGIN
DECLARE @tblAssetInfo TABLE (
	intAssetId INT,
	intDepreciationMethodId INT, 
	strConvention NVARCHAR(40),
	dblBasis NUMERIC(18,6) NULL, -- Actual Basis
	dblDepreciationBasis NUMERIC(18,6) NULL, -- Basis for depreciation computation
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

DECLARE @intDefaultCurrencyId INT, @dblAdjustment NUMERIC(18, 6), @dblFunctionalAdjustment NUMERIC(18, 6), @ysnAdjustBasis BIT = NULL,
	@dblDepreciationAdjustment NUMERIC(18, 6), @dblFunctionalDepreciationAdjustment NUMERIC(18, 6), @ysnDepreciationAdjustBasis BIT = NULL, @dblDepreciationBasisComputation NUMERIC(18, 6),
	@dblOrigBasis NUMERIC(18, 6), @ysnBasisDecreased BIT = NULL, @dtmBasisAdjustment DATETIME

SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference 

INSERT INTO  @tblAssetInfo(
	intAssetId,
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
	intLedgerId,
	strError
)
SELECT 
	intId,
	BD.intDepreciationMethodId,
	strConvention,
	ISNULL(Depreciation.dblBasis, BD.dblCost - BD.dblSalvageValue),
	ISNULL(Depreciation.dblDepreciationBasis, BD.dblCost - BD.dblSalvageValue),
	CASE WHEN ISNULL(A.ysnImported, 0) = 1 AND A.dtmCreateAssetPostDate IS NOT NULL THEN A.dtmCreateAssetPostDate ELSE BD.dtmPlacedInService END,
	ISNULL(Depreciation.dtmDepreciationToDate, CASE WHEN ISNULL(A.ysnImported, 0) = 1 AND A.dtmCreateAssetPostDate IS NOT NULL THEN A.dtmCreateAssetPostDate ELSE BD.dtmPlacedInService END),
	Depreciation.dblDepreciationToDate,
	CASE WHEN @BookId = 1 THEN  A.dblImportGAAPDepToDate ELSE A.dblImportTaxDepToDate END,
	ImportedDepThruMonthPeriod.dtmEndDate,
	Depreciation.strTransaction,
	CASE WHEN ISNULL(BD.dblRate, 0) > 0 THEN BD.dblRate ELSE ISNULL(A.dblForexRate, 1) END,
	CASE WHEN ISNULL(BD.intFunctionalCurrencyId, ISNULL(A.intFunctionalCurrencyId, @intDefaultCurrencyId)) = ISNULL(BD.intCurrencyId, A.intCurrencyId) THEN 0 ELSE 1 END,
	BD.intLedgerId,
	NULL
FROM tblFAFixedAsset A join tblFABookDepreciation BD on A.intAssetId = BD.intAssetId 
JOIN tblFADepreciationMethod DM ON BD.intDepreciationMethodId= DM.intDepreciationMethodId AND BD.intBookId = @BookId
JOIN @Id I on I.intId = A.intAssetId
OUTER APPLY(
	SELECT TOP 1 dblDepreciationToDate, dtmDepreciationToDate, strTransaction, dblDepreciationBasis, dblBasis FROM tblFAFixedAssetDepreciation WHERE [intAssetId] =  A.intAssetId
	AND ISNULL(intBookId,1) = @BookId AND strTransaction <> 'Place in service' AND intLedgerId = BD.intLedgerId
	ORDER BY intAssetDepreciationId DESC
)Depreciation
OUTER APPLY (
	SELECT dtmEndDate FROM [dbo].[fnFAGetMonthPeriodFromDate](A.dtmImportedDepThru, CASE WHEN @BookId = 1 THEN 1 ELSE 0 END)
) ImportedDepThruMonthPeriod


SELECT @dblDepreciationBasisComputation = dblBasis, @dblOrigBasis = dblBasis FROM @tblAssetInfo

-- Check Adjusment to Basis
SELECT @dblAdjustment = ISNULL(SUM(dblAdjustment), 0), @dblFunctionalAdjustment = ISNULL(SUM(dblFunctionalAdjustment), 0), @ysnAdjustBasis = B.ysnAddToBasis, @dtmBasisAdjustment = MAX(B.dtmDate)
FROM @tblAssetInfo A 
JOIN tblFABasisAdjustment B ON B.intAssetId = A.intAssetId AND B.intBookId = @BookId
WHERE B.dtmDate BETWEEN A.dtmDepreciationToDate AND dbo.fnFAGetNextDepreciationDate(B.intAssetId, @BookId, A.intLedgerId) AND (B.strAdjustmentType IS NULL OR B.strAdjustmentType = 'Basis')
GROUP BY B.ysnAddToBasis

IF (@dblAdjustment <> 0)
BEGIN
	UPDATE @tblAssetInfo 
	SET 
		dblBasis += @dblAdjustment, 
		dblDepreciationBasis += CASE WHEN(@ysnAdjustBasis = 1) THEN @dblAdjustment ELSE 0 END
END

-- Check Adjustment to Depreciation
SELECT @dblDepreciationAdjustment = ISNULL(SUM(dblAdjustment), 0), @dblFunctionalDepreciationAdjustment = ISNULL(SUM(dblFunctionalAdjustment), 0), @ysnDepreciationAdjustBasis = B.ysnAddToBasis
FROM @tblAssetInfo A 
JOIN tblFABasisAdjustment B ON B.intAssetId = A.intAssetId AND B.intBookId = @BookId
WHERE B.dtmDate BETWEEN A.dtmDepreciationToDate AND dbo.fnFAGetNextDepreciationDate(B.intAssetId, @BookId, A.intLedgerId) AND (B.strAdjustmentType IS NULL OR B.strAdjustmentType = 'Depreciation')
GROUP BY B.ysnAddToBasis

IF (@dblDepreciationAdjustment <> 0)
BEGIN
	IF (@ysnDepreciationAdjustBasis = 1)
		UPDATE @tblAssetInfo SET dblDepreciationBasis += @dblDepreciationAdjustment
END

-- If negative adjustment to basis is less than accumulated depreciation
SELECT @ysnBasisDecreased = CASE WHEN @dblOrigBasis > dblBasis THEN 1 ELSE 0 END
FROM @tblAssetInfo WHERE @ysnAdjustBasis IS NOT NULL AND @dblAdjustment < 0 AND ROUND(dblYear,2) >=  ROUND(dblBasis,2)

-- Get the depreciation to date before adjustment date and subtract to the dblYear so that it will reset to zero
IF(@ysnBasisDecreased = 1)
BEGIN
	UPDATE A
		SET dblYear -= DepBeforeAdjustment.dblDepreciationToDate
	FROM @tblAssetInfo A
	OUTER APPLY (
		SELECT MAX(dblDepreciationToDate) dblDepreciationToDate FROM tblFAFixedAssetDepreciation 
		WHERE dtmDepreciationToDate <= @dtmBasisAdjustment AND intAssetId = A.intAssetId and intBookId = @BookId AND intLedgerId = A.intLedgerId
	) DepBeforeAdjustment
END

UPDATE @tblAssetInfo SET strError =  'Fixed asset should be disposed' 
	WHERE ROUND(dblYear,2) >=  ROUND(dblBasis,2) AND ISNULL(@ysnAdjustBasis, 0) <> 0

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
JOIN tblFABookDepreciation BD ON BD.intDepreciationMethodId= M.intDepreciationMethodId AND BD.intBookId =@BookId  and BD.intAssetId = T.intAssetId
OUTER APPLY(
	SELECT COUNT (*) + 1 intMonth
	FROM tblFAFixedAssetDepreciation B
	WHERE B.intAssetId = T.intAssetId and ISNULL(intBookId,1) = @BookId AND B.intLedgerId = T.intLedgerId
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
IF (@BookId = 2)
BEGIN
		UPDATE A
		SET 
			A.dblDepre = ISNULL(A.dblDepre, 0) + ISNULL(BD.dblSection179, 0) + ISNULL(BD.dblBonusDepreciation, 0),
			A.dblMonth = ISNULL(A.dblMonth, 0) + ISNULL(BD.dblSection179, 0) + ISNULL(BD.dblBonusDepreciation, 0)
		FROM  @tblAssetInfo A
		JOIN tblFABookDepreciation BD ON A.intAssetId = BD.intAssetId AND BD.intLedgerId = A.intLedgerId
		JOIN @Id I ON I.intId = A.intAssetId
		WHERE A.intAssetId = I.intId AND BD.intBookId = 2 AND A.intMonth = 1

	-- If sum of Section179 and BonusDepreciation (current dblDepre) is greater than or equal to the basis, skip monthly depreciation
	IF EXISTS(SELECT TOP 1 1 FROM  @tblAssetInfo A JOIN @Id I ON I.intId = A.intAssetId 
				JOIN tblFABookDepreciation BD ON A.intAssetId = BD.intAssetId 
				WHERE A.intAssetId = I.intId AND BD.intBookId = 2 AND A.intMonth = 1 AND dblDepreciationBasis <= dblDepre)
		BEGIN
			GOTO Skip_Tax_Monthly_Depreciation
		END
END

UPDATE T SET 
dblPercentage = F.dblPercentage,
dblAnnualDep = (F.dblPercentage *.01) * dblDepreciationBasis,
intYear = F.intYear
FROM
@tblAssetInfo T
outer apply(
	select TOP 1 intYear, dblPercentage, strConvention from tblFADepreciationMethodDetail A 
	JOIN tblFADepreciationMethod B on A.intDepreciationMethodId = B.intDepreciationMethodId
	WHERE A.intDepreciationMethodId = T.intDepreciationMethodId
	order by intYear desc
)F
WHERE intMonth > totalMonths
and F.strConvention <> 'Full Month'

-- Update monthly depreciation computation per convention using fiscal year period
DECLARE
	@dtmPlacedInService DATETIME,
	@dtmMonthStartDate DATETIME,
	@intDays INT

SELECT @dtmPlacedInService = dtmPlacedInService FROM @tblAssetInfo WHERE strError IS NULL
SELECT @dtmMonthStartDate = dtmStartDate, @intDays = intDays
FROM [dbo].[fnFAGetMonthPeriodFromDate](@dtmPlacedInService, CASE WHEN @BookId = 1 THEN 1 ELSE 0 END)

UPDATE T
SET dblMonth = dblAnnualDep/ intMonthDivisor,
intDaysInFirstMonth = @intDays
FROM @tblAssetInfo T
WHERE strError IS NULL

UPDATE T
SET 
dblMonth = 
	CASE 
	WHEN strConvention = 'Actual Days'
		THEN dblMonth * ((intDaysInFirstMonth - (DATEDIFF(DAY, @dtmMonthStartDate, dtmPlacedInService) + 1) + 1)/ CAST(intDaysInFirstMonth AS FLOAT))
	WHEN strConvention= 'Mid Month' 
		THEN dblMonth *.50
	ELSE
		dblMonth
	END
FROM @tblAssetInfo T
WHERE strError IS NULL AND intMonth = 1 --First Depreciation

-- Mid Quarter Convention -> Compute Mid Quarter depreciation take on the Quarter that the PlacedInService falls into.
IF EXISTS(SELECT TOP 1 1 FROM @tblAssetInfo WHERE strConvention = 'Mid Quarter' AND strError IS NULL)
BEGIN
	DECLARE 
		@intRemainingMonthsInQuarter INT

	SELECT @intRemainingMonthsInQuarter = [dbo].[fnFACountRemainingMonthsInQuarter](dtmPlacedInService, CASE WHEN @BookId = 1 THEN 1 ELSE 0 END)
	FROM @tblAssetInfo WHERE strError IS NULL

	UPDATE T SET dblMonth = dblMidQuarter / @intRemainingMonthsInQuarter
	FROM @tblAssetInfo T
	WHERE strError IS NULL AND intMonth BETWEEN 1 AND @intRemainingMonthsInQuarter -- From the month of PlacedInService up to the last month of the quarter of the PlacedInService date
END

-- Mid Year Convention -> Compute Mid Year depreciation take on the year that PlacedInService falls into.
IF EXISTS(SELECT TOP 1 1 FROM @tblAssetInfo WHERE strConvention = 'Mid Year' AND strError IS NULL)
BEGIN
	DECLARE 
		@intRemainingMonthsInYear INT

	SELECT @intRemainingMonthsInYear = [dbo].[fnFACountRemainingMonthsInYear](dtmPlacedInService, CASE WHEN @BookId = 1 THEN 1 ELSE 0 END)
	FROM @tblAssetInfo WHERE strError IS NULL
	UPDATE @tblAssetInfo
	SET dblMonth = dblMidYear/ @intRemainingMonthsInYear 
	WHERE strError IS NULL AND intMonth BETWEEN 1 AND @intRemainingMonthsInYear --from month of PlacedInService up to the last month of year of the PlacedInService date
END

-- Validate Adjustment to Depreciation
IF (@ysnDepreciationAdjustBasis = 0) -- Adjust monthly depreciation between current depreciation date and upcoming depreciation date 
	UPDATE T SET dblMonth += @dblDepreciationAdjustment
	FROM @tblAssetInfo T
	JOIN tblFABasisAdjustment B ON B.intAssetId = T.intAssetId AND B.intBookId = @BookId
	OUTER APPLY (
		SELECT MAX(dtmDepreciationToDate) dtmDepreciationToDate FROM tblFAFixedAssetDepreciation WHERE intAssetId = T.intAssetId AND intBookId = @BookId AND strTransaction = 'Depreciation' AND intLedgerId = T.intLedgerId
	) Depreciation
	WHERE B.dtmDate BETWEEN Depreciation.dtmDepreciationToDate AND dbo.fnFAGetNextDepreciationDate(B.intAssetId, @BookId, T.intLedgerId) AND B.strAdjustmentType = 'Depreciation'

-- Set upcoming depreciation to date
UPDATE T SET dblDepre = dblMonth  + ISNULL(dblYear, 0)
FROM @tblAssetInfo T
WHERE strError IS NULL 


IF (@BookId = 2)
BEGIN
	UPDATE A
	SET 
		A.dblDepre = ISNULL(A.dblDepre, 0) + ISNULL(BD.dblSection179, 0) + ISNULL(BD.dblBonusDepreciation, 0),
		A.dblMonth = ISNULL(A.dblMonth, 0) + ISNULL(BD.dblSection179, 0) + ISNULL(BD.dblBonusDepreciation, 0)
	FROM  @tblAssetInfo A
	JOIN tblFABookDepreciation BD ON A.intAssetId = BD.intAssetId
	JOIN @Id I ON I.intId = A.intAssetId
	WHERE A.intAssetId = I.intId AND BD.intBookId = 2 AND A.intMonth = 1 AND BD.intLedgerId = A.intLedgerId

	IF EXISTS(SELECT TOP 1 1 FROM @tblAssetInfo WHERE dblDepreciationBasis < dblDepre)
		GOTO Basis_Limit_Reached
END

Basis_Limit_Reached:

UPDATE @tblAssetInfo set ysnFullyDepreciated = 1 WHERE dblDepre >= dblBasis AND strError IS NULL

UPDATE B 
SET 
	dblDepre = dblBasis, 
	dblMonth = dblBasis - U.dblDepreciationToDate
FROM @tblAssetInfo B 
JOIN tblFABookDepreciation BD 
	ON BD.intAssetId = B.intAssetId and BD.intBookId = @BookId AND BD.intLedgerId = B.intLedgerId
OUTER APPLY(
	SELECT MAX (dblDepreciationToDate) dblDepreciationToDate from 
	tblFAFixedAssetDepreciation WHERE intAssetId = B.intAssetId AND intBookId = @BookId AND intLedgerId = B.intLedgerId
) U
WHERE 
	dblDepre > dblBasis AND 
	strError IS NULL 


--imported assets
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
	dtmDepreciationToDate,
	dblDepreciationToDate,
	strTransaction
	FROM tblFAFixedAssetDepreciation
	WHERE intAssetId = A.intAssetId
	AND intBookId = @BookId
	AND intLedgerId = A.intLedgerId
	ORDER BY dtmDepreciationToDate DESC
)Dep
OUTER APPLY(
	SELECT TOP 1 D.dtmEndDate FROM (
		SELECT dtmEndDate, 'A' src  FROM dbo.fnFAGetMonthPeriodFromDate(A.dtmPlacedInService, CASE WHEN @BookId = 1 THEN 1 ELSE 0 END) -- get end date of current month
		UNION ALL
		SELECT dtmEndDate, 'B' src  FROM dbo.fnFAGetNextMonthPeriodFromDate(Dep.dtmDepreciationToDate, CASE WHEN @BookId = 1 THEN 1 ELSE 0 END) -- get end date of next month
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
			CASE WHEN A.strTransaction = 'Place in service' THEN 0
			ELSE 2
			END
	ELSE 
		1
	END
)Import
WHERE dblImportGAAPDepToDate is not null and isnull(dtmImportedDepThru,0) > 0

Skip_Tax_Monthly_Depreciation:

UPDATE B set dblDepre = dblBasis,
	dblMonth = dblBasis - U.dblDepreciationToDate
	FROM @tblAssetInfo B JOIN
	tblFABookDepreciation BD 
	ON BD.intAssetId = B.intAssetId and BD.intBookId = @BookId AND BD.intLedgerId = B.intLedgerId
	OUTER APPLY(
		SELECT MAX (dblDepreciationToDate) dblDepreciationToDate from 
		tblFAFixedAssetDepreciation WHERE intAssetId = B.intAssetId AND intBookId = @BookId AND intLedgerId = B.intLedgerId
	) U
	WHERE dblDepre < dblBasis 
	AND intMonth > totalMonths
	AND strConvention NOT IN ('Full Month', 'Mid Quarter', 'Mid Year')
	AND ISNULL(BD.ysnFullyDepreciated,0) = 0

--ROUND OFF TO NEAREAST HUNDREDTHS
UPDATE @tblAssetInfo
set dblMonth = ROUND(dblMonth, 2),
dblDepre =  ROUND(dblDepre, 2)
   
INSERT INTO @tbl(
	intAssetId,
	dblBasis,
	dblDepreciationBasis,
	dblMonth,
	dblDepre,
	dblFunctionalBasis,
	dblFunctionalDepreciationBasis,
	dblFunctionalMonth,
	dblFunctionalDepre,
	dblRate,
	ysnMultiCurrency,
	ysnFullyDepreciated,
	strError,
	strTransaction,
	intLedgerId
	)
	SELECT 
	intAssetId,
	dblBasis,
	dblDepreciationBasis,
	dblMonth,
	dblDepre,
	dblBasis * dblRate,
	dblDepreciationBasis * dblRate,
	dblMonth * dblRate,
	dblDepre * dblRate,
	dblRate,
	ysnMultiCurrency,
	ysnFullyDepreciated,
	strError,
	strTransaction,
	intLedgerId
	FROM @tblAssetInfo 
	RETURN
END