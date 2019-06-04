﻿CREATE PROCEDURE [dbo].[uspICCommodityPositionReport]
	
	@ysnGetHeader	bit  = 0,
	@dtmDate		date = null,
	@strLocationName nvarchar(max) = ''
as
begin
	DECLARE @Columns VARCHAR(MAX)
	SELECT @Columns = COALESCE(@Columns + ', ','') + QUOTENAME(strCommodityCode)
	FROM
	   (
		SELECT DISTINCT strCommodityCode 
		FROM   tblICCommodity 
	   ) AS C

	--select @Columns
	
	DECLARE @sql AS NVARCHAR(MAX)
	DECLARE @top as nvarchar(20)
	declare @location_filter as nvarchar(max)

	if isnull(@strLocationName, '') <> ''
	begin
		set @location_filter = ' and intCompanyLocationId in ( '  + @strLocationName + ' ) '		
	end
	else
	begin
		set @location_filter = ''
	end


	set @top = ''
	set @dtmDate = isnull(@dtmDate, getdate())

	
	if @ysnGetHeader= 1
	begin
		set @top = ' top 1'
		set @dtmDate = getdate()
	end
	SET @sql = 
	'
	
	SELECT ' + @top + ' * 
	FROM (
		SELECT 
			com.strCommodityCode
			,cl.intCompanyLocationId
			,cl.strLocationName 
			, dblQty = ROUND(dbo.fnICConvertUOMtoStockUnit(t.intItemId, t.intItemUOMId, t.dblQty), ISNULL(com.intDecimalDPR,2))
			, dtmDate = ''' + cast(@dtmDate as nvarchar) + '''
		FROM 
			tblICItem i inner join tblICItemLocation il
				on i.intItemId = il.intItemId
			inner join tblSMCompanyLocation cl
				on cl.intCompanyLocationId = il.intLocationId
			inner join tblICCommodity com
				on com.intCommodityId = i.intCommodityId
			inner join 
				(
					select intItemId, intItemLocationId, t.dblQty, t.intItemUOMId, dtmDate from tblICInventoryTransaction t where t.ysnIsUnposted = 0
						union all
					select intItemId, intItemLocationId, t.dblQty, t.intItemUOMId, dtmDate from tblICInventoryTransactionStorage t where t.ysnIsUnposted = 0					
				)			
				 t
				on t.intItemId = i.intItemId
				and t.intItemLocationId = il.intItemLocationId 
		WHERE t.dtmDate <= ''' + cast(@dtmDate as nvarchar) + ''''  + @location_filter + '

	) AS s	
	/*outer apply (
			SELECT						
					Capacity = SUM(ISNULL(sl.dblEffectiveDepth,0) *  ISNULL(sl.dblUnitPerFoot, 0))				
					,PercentFull = 
							CASE 
								WHEN SUM(ISNULL(sl.dblEffectiveDepth,0) *  ISNULL(sl.dblUnitPerFoot, 0)) <> 0 THEN 
									dbo.fnMultiply (
										dbo.fnDivide(
											(
												SUM(ISNULL(sl.dblEffectiveDepth,0) *  ISNULL(sl.dblUnitPerFoot, 0))
												- SUM(ISNULL(dblOnHand, 0)) 
												- SUM(ISNULL(dblUnitStorage, 0))
											)
											, SUM(ISNULL(sl.dblEffectiveDepth,0) *  ISNULL(sl.dblUnitPerFoot, 0))
										)
										, 100
									)
								ELSE 
									NULL 
							END
				
					FROM	tblICItemStockUOM ItemStockUOM 
						join tblICItem Item
							on ItemStockUOM.intItemId = Item.intItemId			
						JOIN tblICStorageLocation sl
							ON sl.intStorageLocationId = ItemStockUOM.intStorageLocationId
					where intLocationId = s.intCompanyLocationId
					GROUP BY 
							sl.intLocationId
							--,Item.intCategoryId

	) AS LocationStat */
	PIVOT (
		SUM( dblQty)
		FOR strCommodityCode IN (' + @Columns + ')
	) AS PVT
	
	--WHERE 
	--	[Canola] IS NOT NULL 	
	ORDER BY strLocationName 
	'	
	EXEC(@sql) 
	
end