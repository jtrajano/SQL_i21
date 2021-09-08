

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
	strAssetTransaction NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL

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


UPDATE T
SET dblMonth = dblAnnualDep/ intMonthDivisor,
intDaysInFirstMonth= 
DAY(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,DATEADD(MONTH,1, dtmPlacedInService)),0)))
FROM @tblAssetInfo T
WHERE strError IS NULL

UPDATE T
SET 
dblMonth = 

CASE 
WHEN strConvention = 'Actual Days' THEN
	dblMonth * ((intDaysInFirstMonth - DAY(dtmPlacedInService) + 1)/ CAST(intDaysInFirstMonth AS FLOAT))
WHEN strConvention= 'Mid Month' THEN
	dblMonth *.50 
ELSE
	dblMonth
END

FROM @tblAssetInfo T
WHERE strError IS NULL AND intMonth = 1 --First Depreciation

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
	SELECT CAST( CEILING(CAST( DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, (DATEADD(m, 
		CASE WHEN Dep.strTransaction = 'Place in service' THEN 0
		ELSE 1 END, Dep.dtmDepreciationToDate))) + 1, 0)) as float)) as datetime) endDate 
)PrevDepPlusOneMonth
OUTER APPLY(
	SELECT t=
	CASE
	WHEN A.dtmImportedDepThru IS NULL THEN 0
	WHEN Dep.dtmDepreciationToDate IS NULL  THEN 0   
	WHEN A.dtmImportedDepThru > PrevDepPlusOneMonth.endDate	THEN 0
	WHEN A.dtmImportedDepThru = PrevDepPlusOneMonth.endDate
		THEN
			CASE WHEN A.strTransaction = 'Place in service' THEN 0
			ELSE 2
			END
	ELSE 
		1
	END
)Import
WHERE dblImportGAAPDepToDate is not null and isnull(dtmImportedDepThru,0) > 0



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
	strError,
	strTransaction
	)
	SELECT 
	intAssetId,
	CASE WHEN strAssetTransaction IS NULL THEN 0 ELSE dblBasis END,
	CASE WHEN strAssetTransaction IS NULL THEN 0 ELSE dblMonth END,
	CASE WHEN strAssetTransaction IS NULL THEN 0 ELSE dblDepre END,
	ysnFullyDepreciated ,
	strError,
	strTransaction
	FROM @tblAssetInfo 
	RETURN
END