﻿CREATE PROCEDURE [dbo].[uspICCommodityPositionReport]
	
	@ysnGetHeader	bit  = 0,
	@dtmDate		date = null
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
			, dblQty = dbo.fnICConvertUOMtoStockUnit(t.intItemId, t.intItemUOMId, t.dblQty)
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
					select intItemId, intItemLocationId, t.dblQty, t.intItemUOMId, dtmDate from tblICInventoryTransaction t
						union all
					select intItemId, intItemLocationId, t.dblQty, t.intItemUOMId, dtmDate from tblICInventoryTransactionStorage t					
				)			
				 t
				on t.intItemId = i.intItemId
				and t.intItemLocationId = il.intItemLocationId 
		WHERE t.dtmDate <= ''' + cast(@dtmDate as nvarchar) + '''

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