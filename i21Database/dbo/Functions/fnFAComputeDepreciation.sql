
CREATE FUNCTION [dbo].[fnFAComputeDepreciation]
(
 @intAssetId INT,
 @intYear INT,
 @intMonth INT,
 @totalMonths INT
 
 )
RETURNS @tbl TABLE (
	dblBasis NUMERIC(18,6) NULL,
	dblMonth NUMERIC(18,6) NULL,
	dblDepre NUMERIC(18,6) NULL
)
AS
BEGIN
DECLARE @intDepreciationMethodId INT, @strConvention NVARCHAR(40)
DECLARE @dblBasis NUMERIC (18,6), @dtmPlacedInService DATETIME 




SELECT 
@dblBasis = dblCost - A.dblSalvageValue,
@strConvention = strConvention,
@intDepreciationMethodId = A.intDepreciationMethodId,
@dtmPlacedInService = dtmDateInService
from tblFAFixedAsset A join tblFADepreciationMethod B on A.intDepreciationMethodId = B.intDepreciationMethodId
where intAssetId = @intAssetId



-- Service Year Percentage
DECLARE @dblPercentage	INT = (SELECT ISNULL(dblPercentage,1) as dblPercentage FROM tblFADepreciationMethodDetail A 
										WHERE A.[intDepreciationMethodId] = @intDepreciationMethodId and intYear =  @intYear)

-- Running Balance
DECLARE @dblYear NUMERIC (18,6) = (SELECT TOP 1 dblDepreciationToDate FROM tblFAFixedAssetDepreciation A WHERE A.[intAssetId] =@intAssetId
ORDER BY intAssetDepreciationId DESC)

-- Computation

	DECLARE @dblAnnualDep	NUMERIC (18,6)	= (@dblBasis * (@dblPercentage * .01))
	DECLARE @dblMonth		NUMERIC (18,6)	= (@dblAnnualDep / 12)								--NEED TO VERIFY IF ITS REALLY 12

	IF @strConvention = 'Mid Month'
	BEGIN
		IF @intMonth = 1 OR @intMonth > @totalMonths
			SELECT @dblMonth = @dblMonth /2
	END
	IF @strConvention = 'Actual Days'
	BEGIN
		DECLARE @intDaysInFirstMonth INT = DAY(EOMONTH(@dtmPlacedInService))
		DECLARE @intDaysRemainingFirstMonth INT =  @intDaysInFirstMonth - DAY(@dtmPlacedInService)
		IF @intMonth = 1 
		BEGIN
			SET @dblMonth =  @dblMonth * (@intDaysRemainingFirstMonth/ CAST(@intDaysInFirstMonth AS FLOAT))
		END
		IF @intMonth > @totalMonths
		BEGIN
			DECLARE @intDaysRemainingLastMonth INT = @intDaysInFirstMonth - @intDaysRemainingFirstMonth
			SET @dblMonth =  @dblMonth * (@intDaysRemainingLastMonth/CAST(@intDaysInFirstMonth AS FLOAT))  
		END
	END
	IF @strConvention = 'Half Year'
	BEGIN
		IF @intMonth BETWEEN 1 AND 12
			OR @intMonth BETWEEN    @totalMonths - 11 AND @totalMonths
			SELECT @dblMonth = @dblMonth / 2
		
	END

	IF @strConvention = 'Mid Quarter'
	BEGIN
		IF @intMonth BETWEEN 1 AND 3
			OR @intMonth BETWEEN    @totalMonths -1 AND @totalMonths+1 -- 12 -2 == 10 October , November , December
			SELECT @dblMonth = @dblMonth /2  --- half of quarter
		
	END

	DECLARE @dblDepre		NUMERIC (18,6)	= (@dblMonth ) + ISNULL(@dblYear,0)				--NEED TO VERIFY IF ITS REALLY 2


	
	

	INSERT INTO @tbl(
	dblBasis,
	dblMonth,
	dblDepre
	 )
	SELECT 
	@dblBasis, @dblMonth, @dblDepre

	RETURN



END

GO

