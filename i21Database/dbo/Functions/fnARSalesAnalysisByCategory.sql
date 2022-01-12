CREATE FUNCTION [dbo].[fnARSalesAnalysisByCategory]()
RETURNS @returntable TABLE
(
	strCategory				NVARCHAR(50) NOT NULL,
	strCategoryDescription	NVARCHAR(500) NOT NULL,
	dblCurrentYear			NUMERIC(18,6) NOT NULL,
	dblPeriodCurrentYear	NUMERIC(18,6) NOT NULL,
	dblLastYear				NUMERIC(18,6) NOT NULL,
	dblPeriodLastYear		NUMERIC(18,6) NOT NULL,
	dblVarianceYear			NUMERIC(18,6) NOT NULL,
	dblVariancePeriod		NUMERIC(18,6) NOT NULL
)
AS
BEGIN
	INSERT INTO @returntable(strCategory, strCategoryDescription, dblCurrentYear, dblPeriodCurrentYear, dblLastYear, dblPeriodLastYear, dblVarianceYear, dblVariancePeriod)
	SELECT 
		 strCategoryName
		,strCategoryDescription
		,dblCurrentYear = ISNULL(SUM(CY.dblTotal), 0)
		,dblPeriodCurrentYear = ISNULL(SUM(PCY.dblTotal), 0)
		,dblLastYear = ISNULL(SUM(LY.dblTotal), 0)
		,dblPeriodLastYear = ISNULL(SUM(PLY.dblTotal), 0)
		,dblVarianceYear = ISNULL(SUM(CY.dblTotal), 0) - ISNULL(SUM(LY.dblTotal), 0)
		,dblVariancePeriod = ISNULL(SUM(PCY.dblTotal), 0) - ISNULL(SUM(PLY.dblTotal), 0)
	FROM vyuARSalesAnalysisReport ARSAR
	OUTER APPLY(
		SELECT dblTotal
		FROM vyuARSalesAnalysisReport
		WHERE intCategoryId = ARSAR.intCategoryId
		AND YEAR(dtmDate) = YEAR(GETDATE())
	) CY
	OUTER APPLY(
		SELECT dblTotal
		FROM vyuARSalesAnalysisReport
		WHERE intCategoryId = ARSAR.intCategoryId
		AND YEAR(dtmDate) = YEAR(GETDATE())
		AND dtmDate <= CAST(GETDATE() AS DATE)
	) PCY
	OUTER APPLY(
		SELECT dblTotal
		FROM vyuARSalesAnalysisReport
		WHERE intCategoryId = ARSAR.intCategoryId
		AND YEAR(dtmDate) = YEAR(GETDATE()) - 1
	) LY
	OUTER APPLY(
		SELECT dblTotal
		FROM vyuARSalesAnalysisReport
		WHERE intCategoryId = ARSAR.intCategoryId
		AND YEAR(dtmDate) = YEAR(GETDATE()) - 1
		AND dtmDate <= DATEADD(YEAR, 1 * -1, DATEADD(DAY, 0, GETDATE()))
	) PLY
	WHERE intCategoryId IS NOT NULL
	GROUP BY intCategoryId, strCategoryName, strCategoryDescription
	ORDER BY strCategoryName
	
	RETURN
END