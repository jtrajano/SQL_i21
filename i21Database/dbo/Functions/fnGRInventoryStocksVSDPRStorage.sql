CREATE FUNCTION [dbo].[fnGRInventoryStocksVSDPRStorage]
(
	@strLocationName NVARCHAR(500)
	,@strCommodityCode NVARCHAR(500)
	,@intCommodityId INT
)
RETURNS @table TABLE
(
	Inventory_Stock_Quantity DECIMAL(18,6)
	,DPR_CustomerOwned DECIMAL(18,6)
	,DIFF DECIMAL(18,6)
)
AS
BEGIN
	DECLARE @dblRiskStorage DECIMAL(18,6)
	DECLARE @dblInventoryStorage DECIMAL(18,6)

	SELECT @dblInventoryStorage = ISNULL(SUM( 
				dbo.fnCalculateQtyBetweenUOM (
					t.intItemUOMId
					,iu.intItemUOMId
					,t.dblQty 
				)
			),0) 
	FROM tblICInventoryTransactionStorage t 
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
	WHERE c.intCommodityId = @intCommodityId
		AND cl.strLocationName = @strLocationName

	SELECT @dblRiskStorage = ISNULL(sum(ISNULL(dblTotal,0)),0)
	FROM dbo.fnRKGetBucketCustomerOwned(GETDATE(), @intCommodityId, NULL) t
	LEFT JOIN tblSCTicket SC 
		ON t.intTicketId = SC.intTicketId
	WHERE ISNULL(strStorageType, '') <> 'ITR' 
		AND intTypeId IN (1, 3, 4, 5, 8, 9)
		AND strCommodityCode = @strCommodityCode
		AND strLocationName = @strLocationName

	INSERT INTO @table
	SELECT @dblInventoryStorage
		,@dblRiskStorage
		,@dblInventoryStorage - @dblRiskStorage

	RETURN;
END