

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
	strError NVARCHAR(100) NULL
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
	ysnFullyDepreciated BIT NULL

) 





INSERT INTO  @tblAssetInfo(
	intAssetId,
	intDepreciationMethodId, 
	strConvention,
	dblBasis, 
	dtmPlacedInService,
	dblYear,
	dblImportGAAPDepToDate,
	strError
)
SELECT 
intId,
BD.intDepreciationMethodId,
strConvention,
BD.dblCost - BD.dblSalvageValue,
BD.dtmPlacedInService,
Depreciation.dblDepreciationToDate,
A.dblImportGAAPDepToDate,
NULL
FROM tblFAFixedAsset A join tblFABookDepreciation BD on A.intAssetId = BD.intAssetId 
JOIN tblFADepreciationMethod DM ON BD.intDepreciationMethodId= DM.intDepreciationMethodId AND BD.intBookId =@BookId
JOIN @Id I on I.intId = A.intAssetId
OUTER APPLY(
	SELECT TOP 1 dblDepreciationToDate FROM tblFAFixedAssetDepreciation WHERE [intAssetId] =  A.intAssetId
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
JOIN tblFABookDepreciation BD ON BD.intDepreciationMethodId= M.intDepreciationMethodId AND BD.intBookId =@BookId
OUTER APPLY(
	SELECT COUNT(1) intMonth FROM tblFAFixedAssetDepreciation B
	WHERE B.intAssetId = T.intAssetId and ISNULL(intBookId,1) = @BookId
) D
OUTER APPLY(
	SELECT ISNULL(dblPercentage,1) dblPercentage FROM tblFADepreciationMethodDetail 
		WHERE M.[intDepreciationMethodId] = intDepreciationMethodId and intYear =   CEILING(D.intMonth/12.0)
)E
WHERE strError IS NULL



UPDATE T
SET dblMonth = dblAnnualDep/ intMonthDivisor,
intDaysInFirstMonth= DAY(EOMONTH(dtmPlacedInService))
FROM @tblAssetInfo T
WHERE strError IS NULL

UPDATE T
SET 
dblMonth = 
CASE WHEN dblMonth >= ISNULL( dblImportGAAPDepToDate,0) 
THEN 

	CASE 
	WHEN strConvention = 'Actual Days' THEN
		dblMonth * ((intDaysInFirstMonth - DAY(dtmPlacedInService) + 1)/ CAST(intDaysInFirstMonth AS FLOAT))
	WHEN strConvention= 'Mid Month' THEN
		dblMonth *.50
	ELSE
		dblMonth
	END
ELSE
	dblMonth 
END
FROM @tblAssetInfo T
WHERE strError IS NULL AND intMonth = 1 


UPDATE T
SET
dblPercentage = FirstDep.dblPercentage,
dblMonth = (dblBasis * (FirstDep.dblPercentage *.01))/ 
	CASE 
		WHEN ISNULL( intServiceYear,0) > 0 
			THEN 12 
		ELSE intExcessMonth 
		END
FROM @tblAssetInfo T
OUTER APPLY(
	SELECT TOP 1 dblPercentage FROM tblFADepreciationMethodDetail WHERE T.[intDepreciationMethodId] = intDepreciationMethodId and intYear =  1
) FirstDep
WHERE strError IS NULL AND intMonth > totalMonths 


-- UPDATE T
-- SET ysnFullyDepreciated = 1
-- FROM @tblAssetInfo T
-- WHERE strError IS NULL AND intMonth = totalMonths AND strConvention = 'Full Month'


UPDATE T
SET
dblMonth = dblMonth *
CASE 
	WHEN strConvention = 'Actual Days' THEN
	(DAY(dtmPlacedInService) - 1)/ CAST(intDaysInFirstMonth AS FLOAT)
	WHEN strConvention = 'Mid Month'
		THEN .50
	END
--ysnFullyDepreciated = 1
FROM @tblAssetInfo T
WHERE strError IS NULL AND intMonth > totalMonths 


UPDATE T SET dblDepre = dblMonth  + ISNULL(dblYear, 0)
FROM @tblAssetInfo T
WHERE strError IS NULL 

UPDATE B set ysnFullyDepreciated = 1 FROM @tblAssetInfo B JOIN
tblFABookDepreciation BD ON BD.intAssetId = B.intAssetId and BD.intBookId = @BookId
WHERE dblDepre >= (BD.dblCost - BD.dblSalvageValue)
AND strError IS NULL 


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




   
INSERT INTO @tbl(
	intAssetId,
	dblBasis,
	dblMonth,
	dblDepre,
	ysnFullyDepreciated,
	strError
	)
	SELECT 
	intAssetId,
	dblBasis, 
	dblMonth, 
	dblDepre, 
	ysnFullyDepreciated ,
	strError
	FROM @tblAssetInfo 

	
	
	RETURN
END

