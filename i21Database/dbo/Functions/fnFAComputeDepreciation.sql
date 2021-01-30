
CREATE FUNCTION [dbo].[fnFAComputeDepreciation]
(
    @intAssetId INT
)
RETURNS @tbl TABLE (
	dblBasis NUMERIC(18,6) NULL,
	dblMonth NUMERIC(18,6) NULL,
	dblDepre NUMERIC(18,6) NULL,
	ysnFullyDepreciated BIT NULL,
	strError NVARCHAR(100) NULL
)
AS
BEGIN
DECLARE @intDepreciationMethodId INT, @strConvention NVARCHAR(40)
DECLARE @dblBasis NUMERIC (18,6), @dtmPlacedInService DATETIME , @ysnFullyDepreciated BIT = 0

SELECT 
@dblBasis = dblCost - A.dblSalvageValue,
@strConvention = strConvention,
@intDepreciationMethodId = B.intDepreciationMethodId,
@dtmPlacedInService = dtmDateInService
FROM tblFAFixedAsset A join tblFADepreciationMethod B on A.intAssetId = B.intAssetId
WHERE A.intAssetId = @intAssetId

-- Running Balance
DECLARE @dblYear NUMERIC (18,6) = (SELECT TOP 1 dblDepreciationToDate FROM tblFAFixedAssetDepreciation A WHERE A.[intAssetId] =@intAssetId
ORDER BY intAssetDepreciationId DESC)

IF ROUND(@dblYear,2) >=  ROUND(@dblBasis,2)
BEGIN
	INSERT INTO @tbl(strError,ysnFullyDepreciated) select 'Fixed asset should be disposed' , 1
	RETURN  
END  


DECLARE @intYear INT, @intMonth INT, @totalMonths INT ,@intExcessMonth INT,@intServiceYear INT, @intMonthDivisor INT = 12
SELECT @intMonth = COUNT(1) FROM tblFAFixedAssetDepreciation WHERE intAssetId = @intAssetId 
select @intYear = ceiling(@intMonth/12.0)


SELECT 
@totalMonths=ISNULL(intServiceYear,0)* 12 + ISNULL(intMonth ,0),
@intExcessMonth = isnull(intMonth,0), 
@intServiceYear = ISNULL(intServiceYear,0)
FROM tblFADepreciationMethod where  @intAssetId = intAssetId	
		
IF (@intMonth > (@intServiceYear * 12) AND @intExcessMonth > 0)
    SET @intMonthDivisor = @intExcessMonth


-- Service Year Percentage
DECLARE @dblPercentage	INT = (SELECT ISNULL(dblPercentage,1) as dblPercentage FROM tblFADepreciationMethodDetail A 
										WHERE A.[intDepreciationMethodId] = @intDepreciationMethodId and intYear =  @intYear)



	DECLARE @dblAnnualDep	NUMERIC (18,6)	= (@dblBasis * (@dblPercentage * .01))
	DECLARE @dblMonth		NUMERIC (18,6)	= (@dblAnnualDep / @intMonthDivisor)
	DECLARE @intDaysInFirstMonth INT = DAY(EOMONTH(@dtmPlacedInService)) --31
 
    IF @intMonth = 1 
    BEGIN
        IF @strConvention = 'Actual Days'
	    BEGIN
            DECLARE @intDaysRemainingFirstMonth INT =  @intDaysInFirstMonth - DAY(@dtmPlacedInService)
            SET @dblMonth =  @dblMonth * (@intDaysRemainingFirstMonth/ CAST(@intDaysInFirstMonth AS FLOAT))
        END
        IF @strConvention = 'Mid Month'
	    BEGIN
            SET @dblMonth =  @dblMonth * .50
        END

    END
    IF @intMonth > @totalMonths
    BEGIN
		SELECT @dblPercentage = dblPercentage FROM tblFADepreciationMethodDetail A WHERE A.[intDepreciationMethodId] = @intDepreciationMethodId and intYear =  1
		SELECT @dblAnnualDep = (@dblBasis * (@dblPercentage * .01))
		SELECT @dblMonth =@dblAnnualDep  / case when ISNULL( @intServiceYear,0) > 0 THEN 12 ELSE @intExcessMonth END
        IF @strConvention = 'Actual Days'
	    BEGIN
            DECLARE @intDaysRemainingLastMonth INT =  DAY(@dtmPlacedInService)
            SELECT @dblMonth =  @dblMonth * (@intDaysRemainingLastMonth/CAST(@intDaysInFirstMonth AS FLOAT)) , @ysnFullyDepreciated = 1
        END
        IF @strConvention = 'Mid Month'
	    BEGIN
            SELECT @dblMonth =  @dblMonth * .50
        END

    END
	DECLARE @dblDepre		NUMERIC (18,6)	= (@dblMonth ) + ISNULL(@dblYear,0)	

	INSERT INTO @tbl(
	dblBasis,
	dblMonth,
	dblDepre,
	ysnFullyDepreciated
	 )
	SELECT 
	@dblBasis, @dblMonth, @dblDepre, @ysnFullyDepreciated

	RETURN

END

