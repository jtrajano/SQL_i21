CREATE PROCEDURE [dbo].[uspRKGetOriginByCommodity] (
	  @intCommodityId INT = NULL
)
AS 
BEGIN
	IF ISNULL(@intCommodityId, 0) <> 0
	BEGIN
		SELECT DISTINCT 
			  intOriginId = c.intCountryID
			, strOrigin = c.strDescription
		FROM tblICItem i
		INNER JOIN tblICCommodityAttribute c
			ON c.intCommodityAttributeId = i.intOriginId
			AND c.strType = 'Origin'
		WHERE i.intOriginId IS NOT NULL
		AND c.intCommodityId = @intCommodityId
		ORDER BY 2
	END
	ELSE
	BEGIN
		SELECT DISTINCT 
			  intOriginId = intCountryID
			, strOrigin = strDescription 
		FROM tblICCommodityAttribute
		WHERE strType = 'Origin'
		ORDER BY 2
	END
END