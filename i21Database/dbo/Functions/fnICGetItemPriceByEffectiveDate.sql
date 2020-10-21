CREATE FUNCTION dbo.fnICGetItemPriceByEffectiveDate(@dtmDate DATETIME, @intItemId INT, @intItemLocationId INT, @ysnGetDefault BIT = 1)
RETURNS TABLE
AS

RETURN 

SELECT TOP 1
	COALESCE(matchedPrice.dblRetailPrice, CASE WHEN @ysnGetDefault = 1 THEN defaultPrice.dblRetailPrice ELSE NULL END) dblRetailPrice,
	COALESCE(matchedPrice.dtmEffectiveRetailPriceDate, defaultPrice.dtmEffectiveRetailPriceDate) dtmEffectiveRetailPriceDate
FROM tblICEffectiveItemPricing p
OUTER APPLY (
	SELECT TOP 1 dblRetailPrice, dtmEffectiveRetailPriceDate
	FROM tblICEffectiveItemPricing
	WHERE intItemId = p.intItemId
		AND intItemLocationId = p.intItemLocationId
	GROUP BY dblRetailPrice, dtmEffectiveRetailPriceDate
	HAVING dtmEffectiveRetailPriceDate <= @dtmDate
	ORDER BY dtmEffectiveRetailPriceDate DESC
) matchedPrice
OUTER APPLY (
	SELECT TOP 1 dblSalePrice dblRetailPrice, @dtmDate dtmEffectiveRetailPriceDate
	FROM tblICItemPricing
	WHERE intItemId = p.intItemId
		AND intItemLocationId = p.intItemLocationId
) defaultPrice
WHERE p.intItemId = @intItemId AND p.intItemLocationId = @intItemLocationId