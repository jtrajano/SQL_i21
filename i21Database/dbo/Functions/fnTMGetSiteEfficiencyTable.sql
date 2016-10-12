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

	DECLARE @tblCurrentSeason TABLE(
		intSiteId INT
		,intDeliveries INT
		,dblSales NUMERIC(18,6)		
		,dblQuantityDelivered NUMERIC(18,6)
		,dblAverageQtyDelivered NUMERIC(18,6)
		,dblAverageSales NUMERIC(18,6)
		,dblEfficiency NUMERIC(18,6)
		,dblAverageBurnRate NUMERIC(18,6)
	)

	DECLARE @tblLastSeason TABLE(
		intSiteId INT
		,intLastDeliveries INT
		,dblLastSales NUMERIC(18,6)		
		,dblLastQuantityDelivered NUMERIC(18,6)
		,dblLastAverageQtyDelivered NUMERIC(18,6)
		,dblLastAverageSales NUMERIC(18,6)
		,dblLastEfficiency NUMERIC(18,6)
		,dblLastAverageBurnRate NUMERIC(18,6)
	)

	DECLARE @tblLast2Season TABLE(
		intSiteId INT
		,intLast2Deliveries INT
		,dblLast2Sales NUMERIC(18,6)		
		,dblLast2QuantityDelivered NUMERIC(18,6)
		,dblLast2AverageQtyDelivered NUMERIC(18,6)
		,dblLast2AverageSales NUMERIC(18,6)
		,dblLast2Efficiency NUMERIC(18,6)
		,dblLast2AverageBurnRate NUMERIC(18,6)
	)


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
		--GEt the total degree and last degree reading date
		SELECT TOP 1 
			@dblDegreeTotal = 1000
		FROM tblTMDegreeDayReading 
		WHERE intClockID = @intClockId ORDER BY dtmDate DESC

		--get the first date reading of the season
		SELECT TOP 1 
			@dtmStartDate = '1/1/' + CAST(YEAR(GETDATE()) AS NVARCHAR(4))
		FROM tblTMDegreeDayReading 
		WHERE intClockID = @intClockId ORDER BY dtmDate ASC

		--Get Efficiency Detail for the current season
		INSERT INTO @tblCurrentSeason(
			intSiteId
			,intDeliveries
			,dblSales
			,dblQuantityDelivered
			,dblAverageQtyDelivered
			,dblAverageSales
			,dblEfficiency
			,dblAverageBurnRate
		)
		SELECT 
			A.intSiteID
			,intDeliveries = COUNT(A.intSiteID)
			,dblSales = SUM(ISNULL(A.dblExtendedAmount,0.0))
			,dblQuantityDelivered = SUM(ISNULL(A.dblQuantityDelivered,0.0))
			,dblAverageQtyDelivered =  AVG(ISNULL(A.dblQuantityDelivered,0.0))
			,dblAverageSales =  AVG(ISNULL(A.dblExtendedAmount,0.0))
			,dblEfficiency = CAST(((CASE WHEN ISNULL(AVG(B.dblTotalCapacity),0) = 0 THEN 1 ELSE (AVG(ISNULL(A.dblQuantityDelivered,0.0))/ AVG(ISNULL(B.dblTotalCapacity, 0.0))) END) * 100) AS NUMERIC(18,6))
			,dblAverageBurnRate =  AVG(A.dblBurnRateAfterDelivery) --CAST(CASE WHEN SUM(ISNULL(A.dblQuantityDelivered,0)) = 0 THEN 0.0 ELSE @dblDegreeTotal/SUM(ISNULL(A.dblQuantityDelivered,0)) END AS NUMERIC(18,6))
		FROM tblTMDeliveryHistory A
		INNER JOIN tblTMSite B
			ON A.intSiteID = B.intSiteID
		WHERE DATEADD(dd, DATEDIFF(dd, 0, A.dtmInvoiceDate), 0) >= DATEADD(dd, DATEDIFF(dd, 0, @dtmStartDate), 0)
			AND A.intSiteID = @intSiteId
		GROUP BY A.intSiteID

		IF(@dtmLastStartDate IS NOT NULL AND @dtmLastEndDate IS NOT NULL)
		BEGIN
			--Get Efficiency Detail for the last season
			INSERT INTO @tblLastSeason(
				intSiteId
				,intLastDeliveries
				,dblLastSales
				,dblLastQuantityDelivered
				,dblLastAverageQtyDelivered
				,dblLastAverageSales
				,dblLastEfficiency
				,dblLastAverageBurnRate
			)
			SELECT 
				A.intSiteID
				,intLastDeliveries = COUNT(A.intSiteID)
				,dblLastSales = SUM(ISNULL(A.dblExtendedAmount,0.0))
				,dblLastQuantityDelivered = SUM(ISNULL(A.dblQuantityDelivered,0.0))
				,dblLastAverageQtyDelivered = AVG(ISNULL(A.dblQuantityDelivered,0.0))
				,dblLastAverageSales = AVG(ISNULL(A.dblExtendedAmount,0.0))
				,dblLastEfficiency = CAST(((CASE WHEN ISNULL(AVG(B.dblTotalCapacity),0) = 0 THEN 1 ELSE (AVG(ISNULL(A.dblQuantityDelivered,0.0))/ AVG(ISNULL(B.dblTotalCapacity, 0.0))) END) * 100) AS NUMERIC(18,6))
				,dblLastAverageBurnRate =  AVG(A.dblBurnRateAfterDelivery) --CAST(CASE WHEN SUM(ISNULL(A.dblQuantityDelivered,0)) = 0 THEN 0.0 ELSE @dblDegreeTotal/SUM(ISNULL(A.dblQuantityDelivered,0)) END AS NUMERIC(18,6))
			FROM tblTMDeliveryHistory A
			INNER JOIN tblTMSite B
				ON A.intSiteID = B.intSiteID
			WHERE DATEADD(dd, DATEDIFF(dd, 0, A.dtmInvoiceDate), 0) >= DATEADD(dd, DATEDIFF(dd, 0, @dtmLastStartDate), 0) AND DATEADD(dd, DATEDIFF(dd, 0, A.dtmInvoiceDate), 0) <= DATEADD(dd, DATEDIFF(dd, 0, @dtmLastEndDate), 0)
				AND A.intSiteID = @intSiteId
			GROUP BY A.intSiteID

			IF(@dtmLast2StartDate IS NOT NULL AND @dtmLast2EndDate IS NOT NULL)
			BEGIN
			--Get Efficiency Detail for the last 2 season
				INSERT INTO @tblLast2Season(
					intSiteId
					,intLast2Deliveries
					,dblLast2Sales
					,dblLast2QuantityDelivered
					,dblLast2AverageQtyDelivered
					,dblLast2AverageSales
					,dblLast2Efficiency
					,dblLast2AverageBurnRate
				)
				SELECT 
					A.intSiteID
					,intLast2Deliveries = COUNT(A.intSiteID)
					,dblLast2Sales = SUM(ISNULL(A.dblExtendedAmount,0.0))
					,dblLast2QuantityDelivered = SUM(ISNULL(A.dblQuantityDelivered,0.0))
					,dblLast2AverageQtyDelivered = AVG(ISNULL(A.dblQuantityDelivered,0.0))
					,dblLast2AverageSales = AVG(ISNULL(A.dblExtendedAmount,0.0))
					,dblLast2Efficiency = CAST(((CASE WHEN ISNULL(AVG(B.dblTotalCapacity),0) = 0 THEN 1 ELSE (AVG(ISNULL(A.dblQuantityDelivered,0.0))/ AVG(ISNULL(B.dblTotalCapacity, 0.0))) END) * 100) AS NUMERIC(18,6))
					,dblLast2AverageBurnRate =  AVG(A.dblBurnRateAfterDelivery) --CAST(CASE WHEN SUM(ISNULL(A.dblQuantityDelivered,0)) = 0 THEN 0.0 ELSE @dblDegreeTotal/SUM(ISNULL(A.dblQuantityDelivered,0)) END AS NUMERIC(18,6))
				FROM tblTMDeliveryHistory A
				INNER JOIN tblTMSite B
					ON A.intSiteID = B.intSiteID
				WHERE DATEADD(dd, DATEDIFF(dd, 0, A.dtmInvoiceDate), 0) >= DATEADD(dd, DATEDIFF(dd, 0, @dtmLast2StartDate), 0) AND DATEADD(dd, DATEDIFF(dd, 0, A.dtmInvoiceDate), 0) <= DATEADD(dd, DATEDIFF(dd, 0, @dtmLast2EndDate), 0)
					AND A.intSiteID = @intSiteId
				GROUP BY A.intSiteID

				
			END

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
				intDeliveries = 0
				,dblSales = 0
				,dblQuantityDelivered = 0
				,dblAverageQtyDelivered =0
				,dblAverageSales =0
				,dblEfficiency= 0
				,dblAverageBurnRate = 0
				,intLastDeliveries = 0
				,dblLastSales = 0
				,dblLastQuantityDelivered = 0
				,dblLastAverageQtyDelivered = 0
				,dblLastAverageSales = 0
				,dblLastEfficiency = 0
				,dblLastAverageBurnRate = 0
				,intLast2Deliveries = 0 
				,dblLast2Sales = 0
				,dblLast2QuantityDelivered = 0
				,dblLast2AverageQtyDelivered = 0
				,dblLast2AverageSales = 0
				,dblLast2Efficiency = 0
				,dblLast2AverageBurnRate = 0
				,dblChangePercent = 0
				,dblLastChangePercent =0
			
			
			UPDATE @tblTableReturn
			SET intDeliveries = A.intDeliveries
				,dblSales = A.dblSales
				,dblQuantityDelivered = A.dblQuantityDelivered
				,dblAverageQtyDelivered = A.dblAverageQtyDelivered
				,dblAverageSales = A.dblAverageSales
				,dblEfficiency= A.dblEfficiency
				,dblAverageBurnRate = A.dblAverageBurnRate
			FROM @tblCurrentSeason A

			UPDATE @tblTableReturn
			SET intLastDeliveries = A.intLastDeliveries
				,dblLastSales = A.dblLastSales
				,dblLastQuantityDelivered = A.dblLastQuantityDelivered
				,dblLastAverageQtyDelivered = A.dblLastAverageQtyDelivered
				,dblLastAverageSales = A.dblLastAverageSales
				,dblLastEfficiency = A.dblLastEfficiency
				,dblLastAverageBurnRate = A.dblLastAverageBurnRate
			FROM @tblLastSeason A
			
			UPDATE @tblTableReturn
			SET intLast2Deliveries = A.intLast2Deliveries
				,dblLast2Sales = A.dblLast2Sales
				,dblLast2QuantityDelivered = A.dblLast2QuantityDelivered
				,dblLast2AverageQtyDelivered = A.dblLast2AverageQtyDelivered
				,dblLast2AverageSales = A.dblLast2AverageSales
				,dblLast2Efficiency = A.dblLast2Efficiency
				,dblLast2AverageBurnRate = A.dblLast2AverageBurnRate
			FROM @tblLast2Season A

			UPDATE @tblTableReturn
			SET dblChangePercent = CAST(((CASE WHEN ISNULL(dblLastQuantityDelivered,0.0) = 0 THEN 0 ELSE (ISNULL(dblQuantityDelivered,0.0) - ISNULL(dblLastQuantityDelivered,0.0))/ISNULL(dblLastQuantityDelivered,0.0) END) * 100) AS NUMERIC(18,6))
				,dblLastChangePercent = CAST(((CASE WHEN ISNULL(dblLast2QuantityDelivered,0.0) = 0 THEN 0 ELSE (ISNULL(dblLastQuantityDelivered,0.0) - ISNULL(dblLast2QuantityDelivered,0.0))/ISNULL(dblLast2QuantityDelivered,0.0) END) * 100) AS NUMERIC(18,6))

			--SELECT 
			--	intDeliveries 
			--	,dblSales
			--	,dblQuantityDelivered
			--	,dblAverageQtyDelivered
			--	,dblAverageSales
			--	,dblEfficiency
			--	,dblAverageBurnRate
			--	,intLastDeliveries 
			--	,dblLastSales
			--	,dblLastQuantityDelivered
			--	,dblLastAverageQtyDelivered
			--	,dblLastAverageSales
			--	,dblLastEfficiency
			--	,dblLastAverageBurnRate
			--	,intLast2Deliveries 
			--	,dblLast2Sales
			--	,dblLast2QuantityDelivered
			--	,dblLast2AverageQtyDelivered
			--	,dblLast2AverageSales
			--	,dblLast2Efficiency
			--	,dblLast2AverageBurnRate
			--	,dblChangePercent = CAST(((CASE WHEN ISNULL(dblLastQuantityDelivered,0.0) = 0 THEN 0 ELSE (ISNULL(dblQuantityDelivered,0.0) - ISNULL(dblLastQuantityDelivered,0.0))/ISNULL(dblLastQuantityDelivered,0.0) END) * 100) AS NUMERIC(18,6))
			--	,dblLastChangePercent = CAST(((CASE WHEN ISNULL(dblLast2QuantityDelivered,0.0) = 0 THEN 0 ELSE (ISNULL(dblLastQuantityDelivered,0.0) - ISNULL(dblLast2QuantityDelivered,0.0))/ISNULL(dblLast2QuantityDelivered,0.0) END) * 100) AS NUMERIC(18,6))
			--FROM @tblCurrentSeason A
			--FULL OUTER JOIN @tblLastSeason B 
			--	ON A.intSiteId = B.intSiteId
			--FULL OUTER JOIN @tblLast2Season
			--	ON A.intSiteId = B.intSiteId
		END
	END
RETURN
END
GO