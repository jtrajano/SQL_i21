CREATE FUNCTION [dbo].[fnGRValuationSummaryVsDPRCompanyOwned]
(
	@strLocationName NVARCHAR(500)
	,@strCommodityCode NVARCHAR(500)
	,@intCommodityId INT
)
RETURNS @table TABLE
(
	Valuation_Stock_Quantity DECIMAL(18,6)
	,DPR_CompanyOwned DECIMAL(18,6)
	,DIFF DECIMAL(18,6)
)
AS
BEGIN
	DECLARE @dblRiskCompanyOwned DECIMAL(18,6)
	DECLARE @dblValuationSummary DECIMAL(18,6)

	SELECT @dblValuationSummary = ISNULL(SUM( 
				dbo.fnCalculateQtyBetweenUOM (
					t.intItemUOMId
					,iu.intItemUOMId
					,t.dblQty 
				)
			),0)
	FROM tblICInventoryTransaction t 
	INNER JOIN tblICItem i 
		ON t.intItemId = i.intItemId
	INNER JOIN tblICItemLocation il
		ON il.intItemId = i.intItemId
			AND il.intItemLocationId = t.intItemLocationId
	INNER JOIN tblICCommodity c		
		ON c.intCommodityId = i.intCommodityId 
	INNER JOIN tblSMCompanyLocation cl 
		ON cl.intCompanyLocationId = il.intLocationId 
	LEFT JOIN tblICItemUOM iu
		ON iu.intItemId = i.intItemId 
			AND iu.ysnStockUnit = 1 
	WHERE c.strCommodityCode = @strCommodityCode
		AND cl.strLocationName = @strLocationName
		AND t.intInTransitSourceLocationId IS NULL

	SELECT @dblRiskCompanyOwned = ISNULL(sum(ISNULL(l.dblOrigQty,0)),0)
	FROM [vyuRKGetSummaryLog] l
	WHERE strBucketType = 'Company Owned'
		AND strCommodityCode = @strCommodityCode
		AND strLocationName = @strLocationName

	INSERT INTO @table
	SELECT @dblValuationSummary
		,@dblRiskCompanyOwned
		,@dblRiskCompanyOwned - @dblValuationSummary

	RETURN;
END
