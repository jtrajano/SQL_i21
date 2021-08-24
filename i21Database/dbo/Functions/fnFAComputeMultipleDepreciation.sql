

CREATE FUNCTION [dbo].[fnFAComputeMultipleDepreciation]
(
    @Id Id READONLY,
	@BookId INT = 1
)
RETURNS @tbl TABLE (
	intAssetId INT ,
	dblBasis NUMERIC(18,6) NULL,
	dblMonth NUMERIC(18,6) NULL,
	dblDepre NUMERIC(18,6) NULL,
	ysnFullyDepreciated BIT NULL,
	dtmDepreciateToDate DATETIME,
	strError NVARCHAR(100) NULL,
	strTransaction NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
)
AS
BEGIN
DECLARE @tblAssetInfo TABLE (
	intAssetId INT,
	intDepreciationMethodId INT, 
	strConvention NVARCHAR(40),
	dblBasis DECIMAL (18,6), 
	dtmPlacedInService DATETIME,
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
	dtmDepreciateToDate DATETIME

) 

INSERT INTO  @tblAssetInfo(
	intAssetId,
	intDepreciationMethodId, 
	strConvention,
	dblBasis, 
	dtmPlacedInService,
	dblYear,
	dblImportGAAPDepToDate,
	dtmImportedDepThru,
	strAssetTransaction,
	strError
)
SELECT 
intId,
BD.intDepreciationMethodId,
strConvention,
BD.dblCost - BD.dblSalvageValue,
BD.dtmPlacedInService,
Depreciation.dblDepreciationToDate,
CASE WHEN @BookId = 1 THEN  A.dblImportGAAPDepToDate ELSE A.dblImportTaxDepToDate END,
DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, (dtmImportedDepThru)) + 1, 0)),
Depreciation.strTransaction,
NULL
FROM tblFAFixedAsset A join tblFABookDepreciation BD on A.intAssetId = BD.intAssetId 
JOIN tblFADepreciationMethod DM ON BD.intDepreciationMethodId= DM.intDepreciationMethodId AND BD.intBookId =@BookId
JOIN @Id I on I.intId = A.intAssetId
OUTER APPLY(
	SELECT TOP 1 dblDepreciationToDate, strTransaction FROM tblFAFixedAssetDepreciation WHERE [intAssetId] =  A.intAssetId
	AND ISNULL(intBookId,1) = @BookId
	ORDER BY intAssetDepreciationId DESC
)Depreciation


UPDATE @tblAssetInfo SET strError =  'Fixed asset should be disposed' 
	WHERE ROUND(dblYear,2) >=  ROUND(dblBasis,2)

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
dblAnnualDep = (E.dblPercentage *.01) * dblBasis
FROM @tblAssetInfo T JOIN
tblFADepreciationMethod  M ON  M.intDepreciationMethodId = T.intDepreciationMethodId
JOIN tblFABookDepreciation BD ON BD.intDepreciationMethodId= M.intDepreciationMethodId AND BD.intBookId =@BookId  and BD.intAssetId = T.intAssetId
OUTER APPLY(
	SELECT COUNT (*) + 1 intMonth
	FROM tblFAFixedAssetDepreciation B
	WHERE B.intAssetId = T.intAssetId and ISNULL(intBookId,1) = @BookId
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
		SET A.dblDepre = ISNULL(A.dblDepre, 0) + ISNULL(BD.dblSection179, 0) + ISNULL(BD.dblBonusDepreciation, 0)
		FROM  @tblAssetInfo A
		JOIN tblFABookDepreciation BD ON A.intAssetId = BD.intAssetId
		JOIN @Id I ON I.intId = A.intAssetId
		WHERE A.intAssetId = I.intId AND BD.intBookId = 2 AND A.intMonth = 1

	-- If sum of Section179 and BonusDepreciation (current dblDepre) is greater than or equal to the basis, skip monthly depreciation
	IF EXISTS(SELECT TOP 1 1 FROM  @tblAssetInfo A JOIN @Id I ON I.intId = A.intAssetId 
				JOIN tblFABookDepreciation BD ON A.intAssetId = BD.intAssetId 
				WHERE A.intAssetId = I.intId AND BD.intBookId = 2 AND A.intMonth = 1 AND dblBasis <= dblDepre)
		BEGIN
			GOTO Skip_Tax_Monthly_Depreciation
		END
END

UPDATE T SET 
dblPercentage = F.dblPercentage,
dblAnnualDep = (F.dblPercentage *.01) * dblBasis,
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

DECLARE
	@dtmPlacedInService DATETIME,
	@dtmMonthStartDate DATETIME,
	@intDays INT

SELECT @dtmPlacedInService = dtmPlacedInService FROM @tblAssetInfo WHERE strError IS NULL
SELECT @dtmMonthStartDate = dtmStartDate, @intDays = intDays
FROM dbo.fnFAGetMonthPeriodFromDate(@dtmPlacedInService, CASE WHEN @BookId = 1 THEN 1 ELSE 0 END)


UPDATE T
SET dblMonth = dblAnnualDep/ intMonthDivisor,
intDaysInFirstMonth = @intDays
FROM @tblAssetInfo T
WHERE strError IS NULL

UPDATE T
SET 
dblMonth = 

CASE 
WHEN strConvention = 'Actual Days' THEN
	dblMonth * ((intDaysInFirstMonth - (DATEDIFF(DAY, @dtmMonthStartDate, dtmPlacedInService) + 1) + 1)/ CAST(intDaysInFirstMonth AS FLOAT))
WHEN strConvention= 'Mid Month' THEN
	dblMonth *.50
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

UPDATE T SET dblDepre = dblMonth  + ISNULL(dblYear, 0)
FROM @tblAssetInfo T
WHERE strError IS NULL 


IF (@BookId = 2)
BEGIN
	UPDATE A
	SET A.dblDepre = ISNULL(A.dblDepre, 0) + ISNULL(BD.dblSection179, 0) + ISNULL(BD.dblBonusDepreciation, 0)
	FROM  @tblAssetInfo A
	JOIN tblFABookDepreciation BD ON A.intAssetId = BD.intAssetId
	JOIN @Id I ON I.intId = A.intAssetId
	WHERE A.intAssetId = I.intId AND BD.intBookId = 2 AND A.intMonth = 1

	IF EXISTS(SELECT TOP 1 1 FROM @tblAssetInfo WHERE dblBasis < dblDepre)
		GOTO Basis_Limit_Reached
END

UPDATE B set ysnFullyDepreciated = 1 FROM @tblAssetInfo B JOIN
tblFABookDepreciation BD ON BD.intAssetId = B.intAssetId and BD.intBookId = @BookId
WHERE dblDepre >= (BD.dblCost - BD.dblSalvageValue)
AND strError IS NULL 

Basis_Limit_Reached:

UPDATE B set dblDepre = BD.dblCost - BD.dblSalvageValue ,
dblMonth = (BD.dblCost - BD.dblSalvageValue) - U.dblDepreciationToDate
FROM @tblAssetInfo B JOIN
tblFABookDepreciation BD 
ON BD.intAssetId = B.intAssetId and BD.intBookId = @BookId
OUTER APPLY(
	SELECT MAX (dblDepreciationToDate) dblDepreciationToDate from 
	tblFAFixedAssetDepreciation WHERE intAssetId = B.intAssetId AND intBookId = @BookId

) U
WHERE dblDepre > (BD.dblCost - BD.dblSalvageValue)
AND strError IS NULL 




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
	ORDER BY dtmDepreciationToDate DESC
)Dep
OUTER APPLY(
	SELECT t=
	CASE
	WHEN (A.dtmImportedDepThru >  DATEADD(m, 1, Dep.dtmDepreciationToDate) AND ISNULL(A.dtmImportedDepThru,0) >0 ) OR 
	Dep.dtmDepreciationToDate IS NULL
		THEN 0 
	WHEN 
		dbo.fnFAGetPreviousMonthPeriodEndDateFromDate(A.dtmImportedDepThru, CASE WHEN @BookId = 1 THEN 1 ELSE 0 END)
		= Dep.dtmDepreciationToDate  and isnull(A.dtmImportedDepThru,0) > 0
		THEN
			CASE 
				WHEN Dep.strTransaction = 'Place in service'  
				THEN 0
			ELSE		
				 CASE when ISNULL(dblImportGAAPDepToDate,0) = 0 then 1
				 ELSE 2
				 END
			END
	ELSE 
		1
	END
)Import
WHERE dblImportGAAPDepToDate is not null and isnull(dtmImportedDepThru,0) > 0

Skip_Tax_Monthly_Depreciation:

UPDATE B set dblDepre = BD.dblCost - BD.dblSalvageValue ,
dblMonth = (BD.dblCost - BD.dblSalvageValue) - U.dblDepreciationToDate
FROM @tblAssetInfo B JOIN
tblFABookDepreciation BD 
ON BD.intAssetId = B.intAssetId and BD.intBookId = @BookId
OUTER APPLY(
	SELECT MAX (dblDepreciationToDate) dblDepreciationToDate from 
	tblFAFixedAssetDepreciation WHERE intAssetId = B.intAssetId AND intBookId = @BookId

) U
WHERE dblDepre < (BD.dblCost - BD.dblSalvageValue)
AND intMonth > totalMonths
AND strConvention <> 'Full Month'
AND ISNULL(BD.ysnFullyDepreciated,0) = 0

--ROUND OFF TO NEAREAST HUNDREDTHS
UPDATE @tblAssetInfo
set dblMonth = ROUND(dblMonth, 2),
dblDepre =  ROUND(dblDepre, 2)

   
INSERT INTO @tbl(
	intAssetId,
	dblBasis,
	dblMonth,
	dblDepre,
	ysnFullyDepreciated,
	dtmDepreciateToDate,
	strError,
	strTransaction
	)
	SELECT 
	intAssetId,
	CASE WHEN strAssetTransaction IS NULL THEN 0 ELSE dblBasis END,
	CASE WHEN strAssetTransaction IS NULL THEN 0 ELSE dblMonth END,
	CASE WHEN strAssetTransaction IS NULL THEN 0 ELSE dblDepre END,
	ysnFullyDepreciated,
	dbo.fnFAGetNextDepreciationDate(intAssetId, @BookId),
	strError,
	strTransaction
	FROM @tblAssetInfo 
	RETURN
END