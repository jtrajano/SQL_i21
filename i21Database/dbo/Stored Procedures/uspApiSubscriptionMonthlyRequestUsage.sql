CREATE PROCEDURE [dbo].[uspApiSubscriptionMonthlyRequestUsage] (@intYear INT, @ysnExcludeZeroCount BIT)
AS

DECLARE @Subscriptions TABLE (guiSubscriptionId UNIQUEIDENTIFIER, strName NVARCHAR(200))
INSERT INTO @Subscriptions (guiSubscriptionId, strName)
SELECT DISTINCT u.guiSubscriptionId, u.strName
FROM tblApiMonthlyRequestUsage u

SELECT
	  s.guiSubscriptionId
	, s.strName
	, m.intMonth
	, m.strMonth
	, ISNULL(usage.intCount, 0) intCount
	, ISNULL(usage.intYear, @intYear) intYear
FROM (
	SELECT months.*, 
		DATENAME(MONTH,DATEADD(MM, months.intMonth -1,DATEADD(YY, DATEDIFF(YY, 0, DATEPART(YEAR, GETDATE()) - 1900), 0))) strMonth
	FROM (
		SELECT 1 AS intMonth UNION ALL
		SELECT 2 UNION ALL
		SELECT 3 UNION ALL
		SELECT 4 UNION ALL
		SELECT 5 UNION ALL
		SELECT 6 UNION ALL
		SELECT 7 UNION ALL
		SELECT 8 UNION ALL
		SELECT 9 UNION ALL
		SELECT 10 UNION ALL
		SELECT 11 UNION ALL
		SELECT 12
	) months
) m
CROSS JOIN @Subscriptions s
OUTER APPLY (
	SELECT SUM(rc.intCount) intCount, rc.intMonth, rc.intYear
	FROM tblApiMonthlyRequestUsage rc
	WHERE rc.guiSubscriptionId = s.guiSubscriptionId
		AND rc.intMonth = m.intMonth
		AND rc.intYear = rc.intYear
	GROUP BY rc.intMonth, rc.intYear
) usage
WHERE ISNULL(usage.intYear, @intYear) = @intYear
	AND ((usage.intCount > 0 AND @ysnExcludeZeroCount = 1) OR @ysnExcludeZeroCount = 0)