CREATE FUNCTION [dbo].[fnTMGetSiteEfficiencyTable](
	@intSiteId INT
)
RETURNS @tblTableReturn TABLE(
	intDeliveries INT
	,dblSales NUMERIC(18,6)		
	,dblQuantityDelivered NUMERIC(18,6)
	,dblAverageQtyDelivered NUMERIC(18,6)
	,dblAverageSales NUMERIC(18,6)
	,dblEfficiency NUMERIC(18,6)
	,dblAverageBurnRate NUMERIC(18,6)
	,intLastDeliveries INT
	,dblLastSales NUMERIC(18,6)		
	,dblLastQuantityDelivered NUMERIC(18,6)
	,dblLastAverageQtyDelivered NUMERIC(18,6)
	,dblLastAverageSales NUMERIC(18,6)
	,dblLastEfficiency NUMERIC(18,6)
	,dblLastAverageBurnRate NUMERIC(18,6)
	,intLast2Deliveries INT
	,dblLast2Sales NUMERIC(18,6)		
	,dblLast2QuantityDelivered NUMERIC(18,6)
	,dblLast2AverageQtyDelivered NUMERIC(18,6)
	,dblLast2AverageSales NUMERIC(18,6)
	,dblLast2Efficiency NUMERIC(18,6)
	,dblLast2AverageBurnRate NUMERIC(18,6)
	,dblChangePercent NUMERIC(18,6)
	,dblLastChangePercent NUMERIC(18,6)
)
AS
BEGIN 
	DECLARE @intClockId INT
	DECLARE @intLastSeasonResetId INT
	DECLARE @intLast2SeasonResetId INT

	DECLARE @dtmEndDate DATETIME
	DECLARE @dtmStartDate DATETIME
	DECLARE @dblDegreeTotal NUMERIC(18,6)

	DECLARE @dtmLastEndDate DATETIME
	DECLARE @dtmLastStartDate DATETIME
	DECLARE @dblLastDegreeTotal NUMERIC(18,6)

	DECLARE @dtmLast2EndDate DATETIME
	DECLARE @dtmLast2StartDate DATETIME
	DECLARE @dblLast2DegreeTotal NUMERIC(18,6)

	DECLARE @intDeliveries INT
	DECLARE @dblSales NUMERIC(18,6)		
	DECLARE @dblQuantityDelivered NUMERIC(18,6)
	DECLARE @dblAverageQtyDelivered NUMERIC(18,6)
	DECLARE @dblAverageSales NUMERIC(18,6)
	DECLARE @dblEfficiency NUMERIC(18,6)
	DECLARE @dblAverageBurnRate NUMERIC(18,6)
	
	DECLARE @intLastDeliveries INT
	DECLARE @dblLastSales NUMERIC(18,6)		
	DECLARE @dblLastQuantityDelivered NUMERIC(18,6)
	DECLARE @dblLastAverageQtyDelivered NUMERIC(18,6)
	DECLARE @dblLastAverageSales NUMERIC(18,6)
	DECLARE @dblLastEfficiency NUMERIC(18,6)
	DECLARE @dblLastAverageBurnRate NUMERIC(18,6)

	DECLARE @intLast2Deliveries INT
	DECLARE @dblLast2Sales NUMERIC(18,6)		
	DECLARE @dblLast2QuantityDelivered NUMERIC(18,6)
	DECLARE @dblLast2AverageQtyDelivered NUMERIC(18,6)
	DECLARE @dblLast2AverageSales NUMERIC(18,6)
	DECLARE @dblLast2Efficiency NUMERIC(18,6)
	DECLARE @dblLast2AverageBurnRate NUMERIC(18,6)


	--DECLARE @tblCurrentSeason TABLE(
	--	intSiteId INT
	--	,intDeliveries INT
	--	,dblSales NUMERIC(18,6)		
	--	,dblQuantityDelivered NUMERIC(18,6)
	--	,dblAverageQtyDelivered NUMERIC(18,6)
	--	,dblAverageSales NUMERIC(18,6)
	--	,dblEfficiency NUMERIC(18,6)
	--	,dblAverageBurnRate NUMERIC(18,6)
	--)

	--DECLARE @tblLastSeason TABLE(
	--	intSiteId INT
	--	,intLastDeliveries INT
	--	,dblLastSales NUMERIC(18,6)		
	--	,dblLastQuantityDelivered NUMERIC(18,6)
	--	,dblLastAverageQtyDelivered NUMERIC(18,6)
	--	,dblLastAverageSales NUMERIC(18,6)
	--	,dblLastEfficiency NUMERIC(18,6)
	--	,dblLastAverageBurnRate NUMERIC(18,6)
	--)

	--DECLARE @tblLast2Season TABLE(
	--	intSiteId INT
	--	,intLast2Deliveries INT
	--	,dblLast2Sales NUMERIC(18,6)		
	--	,dblLast2QuantityDelivered NUMERIC(18,6)
	--	,dblLast2AverageQtyDelivered NUMERIC(18,6)
	--	,dblLast2AverageSales NUMERIC(18,6)
	--	,dblLast2Efficiency NUMERIC(18,6)
	--	,dblLast2AverageBurnRate NUMERIC(18,6)
	--)


	SET @dtmEndDate = '12/31/' + CAST(YEAR(GETDATE()) AS NVARCHAR(4))
	SET @dtmStartDate = '1/1/' + CAST(YEAR(GETDATE()) AS NVARCHAR(4))
	SET @dblDegreeTotal = NULL

	SET @dtmLastEndDate = '12/31/' + CAST((YEAR(GETDATE()) - 1) AS NVARCHAR(4))
	SET @dtmLastStartDate = '1/1/' + CAST((YEAR(GETDATE())- 1) AS NVARCHAR(4))
	SET @dblLastDegreeTotal = NULL

	SET @dtmLast2EndDate = '12/31/' + CAST((YEAR(GETDATE()) - 2) AS NVARCHAR(4))
	SET @dtmLast2StartDate = '1/1/' + CAST((YEAR(GETDATE())- 2) AS NVARCHAR(4))
	SET @dblLast2DegreeTotal = NULL


	--- GEt Clock Id of the Site
	SET @intClockId = (SELECT TOP 1 intClockID FROM tblTMSite WHERE intSiteID = @intSiteId)

	IF(ISNULL(@intClockId,0) <> 0)
	BEGIN
		
		SELECT
			@intDeliveries = COUNT(A.intSiteID)
			,@dblSales = SUM(ISNULL(A.dblExtendedAmount,0.0))
			,@dblQuantityDelivered = SUM(ISNULL(A.dblQuantityDelivered,0.0))
			,@dblAverageQtyDelivered =  AVG(ISNULL(A.dblQuantityDelivered,0.0))
			,@dblAverageSales =  AVG(ISNULL(A.dblExtendedAmount,0.0))
			,@dblEfficiency = CAST(((CASE WHEN ISNULL(AVG(B.dblTotalCapacity),0) = 0 THEN 1 ELSE (AVG(ISNULL(A.dblQuantityDelivered,0.0))/ AVG(ISNULL(B.dblTotalCapacity, 0.0))) END) * 100) AS NUMERIC(18,6))
			,@dblAverageBurnRate =  AVG(A.dblBurnRateAfterDelivery)
		FROM tblTMDeliveryHistory A
		INNER JOIN tblTMSite B
			ON A.intSiteID = B.intSiteID
		OUTER APPLY (
			SELECT TOP 1 intSeasonYear FROM dbo.fnTMGetSeasonYear(A.dtmInvoiceDate,B.intClockID)
		)Z
		OUTER APPLY (
			SELECT TOP 1 intSeasonYear FROM dbo.fnTMGetSeasonYear(GETDATE(),B.intClockID)
		)X
		WHERE A.intSiteID = @intSiteId
		AND  X.intSeasonYear = Z.intSeasonYear
		GROUP BY A.intSiteID 

	
		SELECT 
			@intLastDeliveries = COUNT(A.intSiteID)
			,@dblLastSales = SUM(ISNULL(A.dblExtendedAmount,0.0))
			,@dblLastQuantityDelivered = SUM(ISNULL(A.dblQuantityDelivered,0.0))
			,@dblLastAverageQtyDelivered = AVG(ISNULL(A.dblQuantityDelivered,0.0))
			,@dblLastAverageSales = AVG(ISNULL(A.dblExtendedAmount,0.0))
			,@dblLastEfficiency = CAST(((CASE WHEN ISNULL(AVG(B.dblTotalCapacity),0) = 0 THEN 1 ELSE (AVG(ISNULL(A.dblQuantityDelivered,0.0))/ AVG(ISNULL(B.dblTotalCapacity, 0.0))) END) * 100) AS NUMERIC(18,6))
			,@dblLastAverageBurnRate =  AVG(A.dblBurnRateAfterDelivery)
		FROM tblTMDeliveryHistory A
		INNER JOIN tblTMSite B
			ON A.intSiteID = B.intSiteID
		OUTER APPLY (
			SELECT TOP 1 intSeasonYear FROM dbo.fnTMGetSeasonYear(A.dtmInvoiceDate,B.intClockID)
		)Z
		OUTER APPLY (
			SELECT TOP 1 intSeasonYear FROM dbo.fnTMGetSeasonYear(GETDATE(),B.intClockID)
		)X
		WHERE A.intSiteID = @intSiteId
		AND  (X.intSeasonYear - 1) = Z.intSeasonYear
		GROUP BY A.intSiteID 

			
		SELECT 
			@intLast2Deliveries = COUNT(A.intSiteID)
			,@dblLast2Sales = SUM(ISNULL(A.dblExtendedAmount,0.0))
			,@dblLast2QuantityDelivered = SUM(ISNULL(A.dblQuantityDelivered,0.0))
			,@dblLast2AverageQtyDelivered = AVG(ISNULL(A.dblQuantityDelivered,0.0))
			,@dblLast2AverageSales = AVG(ISNULL(A.dblExtendedAmount,0.0))
			,@dblLast2Efficiency = CAST(((CASE WHEN ISNULL(AVG(B.dblTotalCapacity),0) = 0 THEN 1 ELSE (AVG(ISNULL(A.dblQuantityDelivered,0.0))/ AVG(ISNULL(B.dblTotalCapacity, 0.0))) END) * 100) AS NUMERIC(18,6))
			,@dblLast2AverageBurnRate =  AVG(A.dblBurnRateAfterDelivery)
		FROM tblTMDeliveryHistory A
		INNER JOIN tblTMSite B
			ON A.intSiteID = B.intSiteID
		OUTER APPLY (
			SELECT TOP 1 intSeasonYear FROM dbo.fnTMGetSeasonYear(A.dtmInvoiceDate,B.intClockID)
		)Z
		OUTER APPLY (
			SELECT TOP 1 intSeasonYear FROM dbo.fnTMGetSeasonYear(GETDATE(),B.intClockID)
		)X
		WHERE A.intSiteID = @intSiteId
		AND  (X.intSeasonYear - 2) = Z.intSeasonYear
		GROUP BY A.intSiteID 

				
			

		INSERT INTO @tblTableReturn(
			intDeliveries 
			,dblSales
			,dblQuantityDelivered
			,dblAverageQtyDelivered
			,dblAverageSales
			,dblEfficiency
			,dblAverageBurnRate
			,intLastDeliveries 
			,dblLastSales
			,dblLastQuantityDelivered
			,dblLastAverageQtyDelivered
			,dblLastAverageSales
			,dblLastEfficiency
			,dblLastAverageBurnRate
			,intLast2Deliveries 
			,dblLast2Sales
			,dblLast2QuantityDelivered
			,dblLast2AverageQtyDelivered
			,dblLast2AverageSales
			,dblLast2Efficiency
			,dblLast2AverageBurnRate
			,dblChangePercent
			,dblLastChangePercent
		)
		SELECT 
			ISNULL(@intDeliveries,0)
			,ISNULL(@dblSales,0.0)
			,ISNULL(@dblQuantityDelivered,0.0)
			,ISNULL(@dblAverageQtyDelivered,0.0)
			,ISNULL(@dblAverageSales,0.0)
			,ISNULL(@dblEfficiency,0.0)
			,ISNULL(@dblAverageBurnRate,0.0)
			,ISNULL(@intLastDeliveries,0)
			,ISNULL(@dblLastSales,0.0)
			,ISNULL(@dblLastQuantityDelivered,0.0)
			,ISNULL(@dblLastAverageQtyDelivered,0.0)
			,ISNULL(@dblLastAverageSales,0.0)
			,ISNULL(@dblLastEfficiency,0.0)
			,ISNULL(@dblLastAverageBurnRate,0.0)
			,ISNULL(@intLast2Deliveries,0)
			,ISNULL(@dblLast2Sales,0.0)
			,ISNULL(@dblLast2QuantityDelivered,0.0)
			,ISNULL(@dblLast2AverageQtyDelivered,0.0)
			,ISNULL(@dblLast2AverageSales,0.0)
			,ISNULL(@dblLast2Efficiency,0.0)
			,ISNULL(@dblLast2AverageBurnRate,0.0)
			,dblChangePercent = ISNULL(CAST(((CASE WHEN ISNULL(@dblLastQuantityDelivered,0.0) = 0 THEN 0 ELSE (ISNULL(@dblQuantityDelivered,0.0) - ISNULL(@dblLastQuantityDelivered,0.0))/ISNULL(@dblLastQuantityDelivered,0.0) END) * 100) AS NUMERIC(18,6)), 0.0)
			,dblLastChangePercent = ISNULL(CAST(((CASE WHEN ISNULL(@dblLast2QuantityDelivered,0.0) = 0 THEN 0 ELSE (ISNULL(@dblLastQuantityDelivered,0.0) - ISNULL(@dblLast2QuantityDelivered,0.0))/ISNULL(@dblLast2QuantityDelivered,0.0) END) * 100) AS NUMERIC(18,6)), 0.0)
		

	END
RETURN
END
GO