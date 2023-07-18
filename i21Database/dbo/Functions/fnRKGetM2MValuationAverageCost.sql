CREATE FUNCTION [dbo].[fnRKGetM2MValuationAverageCost]
(
	  @intItemId INT 
	, @intItemLocation INT 
	, @dtmAsOfDate DATETIME
	, @intToCommodityUOMId INT
	, @intCurrencyId INT
	, @intMarkToMarketRateTypeId INT
)
RETURNS NUMERIC(38,20)
AS
BEGIN 
	DECLARE @dblAverageCost AS NUMERIC(38, 20) 

	SELECT @dblAverageCost = CASE WHEN dblQty <> 0 THEN (dblValue / dblQty) ELSE 0 END 
	FROM
	(
		SELECT dblQty = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(cuom.intCommodityUnitMeasureId
									, CASE WHEN ISNULL(@intToCommodityUOMId, 0) = 0 
											THEN cuom.intCommodityUnitMeasureId
											ELSE @intToCommodityUOMId END
									, t.dblQty))
			, dblValue = SUM(((t.dblQty * t.dblCost) + (t.dblValue)) 
									* ISNULL(dbo.fnRKGetCurrencyConvertion(
											CASE WHEN ISNULL(c.ysnSubCurrency, 0) = 1 
												THEN c.intMainCurrencyId 
												ELSE t.intCurrencyId END
											, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
							)
		FROM tblICInventoryTransaction t
		JOIN tblICItem i
			ON t.intItemId = i.intItemId
		LEFT JOIN tblICItemUOM iuom
			ON iuom.intItemUOMId = t.intItemUOMId
		LEFT JOIN tblICCommodityUnitMeasure cuom
			ON cuom.intCommodityId = i.intCommodityId 
			AND cuom.intUnitMeasureId = iuom.intUnitMeasureId
		LEFT JOIN tblSMCurrency c
			ON c.intCurrencyID = t.intCurrencyId
		WHERE t.intItemId = @intItemId
		AND t.intItemLocationId = ISNULL(@intItemLocation, t.intItemLocationId)
		AND dbo.fnDateLessThanEquals(t.dtmDate, @dtmAsOfDate) = 1
	) z

	RETURN @dblAverageCost
END 
