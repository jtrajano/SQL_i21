CREATE FUNCTION dbo.fnICGetItemCostByEffectiveDate(
	@dtmDate DATETIME
	, @intItemId INT
	, @intItemLocationId INT
	, @ysnGetDefault BIT = 1
)
RETURNS TABLE
AS

RETURN 

SELECT TOP 1
	COALESCE(matchedCost.dblCost, CASE WHEN @ysnGetDefault = 1 THEN defaultCost.dblCost ELSE NULL END) dblCost,
	COALESCE(matchedCost.dtmEffectiveCostDate, defaultCost.dtmEffectiveCostDate) dtmEffectiveCostDate
FROM 
	tblICEffectiveItemCost p
	OUTER APPLY (
		SELECT TOP 1 
			dblCost
			, dtmEffectiveCostDate
		FROM 
			tblICEffectiveItemCost
		WHERE 
			intItemId = p.intItemId
			AND intItemLocationId = p.intItemLocationId
		GROUP BY 
			dblCost
			, dtmEffectiveCostDate
		HAVING 
			dtmEffectiveCostDate <= @dtmDate
		ORDER BY 
			dtmEffectiveCostDate DESC
	) matchedCost
	OUTER APPLY (
		SELECT TOP 1 
			dblLastCost dblCost
			, @dtmDate dtmEffectiveCostDate
		FROM 
			tblICItemPricing
		WHERE 
			intItemId = p.intItemId
			AND intItemLocationId = p.intItemLocationId
	) defaultCost
WHERE 
	p.intItemId = @intItemId 
	AND p.intItemLocationId = @intItemLocationId