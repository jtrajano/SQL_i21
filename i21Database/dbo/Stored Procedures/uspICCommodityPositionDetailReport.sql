CREATE PROCEDURE [dbo].[uspICCommodityPositionDetailReport]	
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
	
	set @top = ''
	set @dtmDate = isnull(@dtmDate, getdate())

	declare @location_filter as nvarchar(max)	

	set @strLocationName = isnull(@strLocationName, '')
	if isnull(@strLocationName, '') <> ''
	begin
		set @location_filter = ' where intLocationId in ( '  + @strLocationName + ' ) '		
	end
	else
	begin
		set @location_filter = ''
	end

	if @ysnGetHeader= 1
	begin
		set @top = ' top 1'
		set @dtmDate = getdate()
		
		select intLocationId = 1, Capacity = 0, PercentFull = 0
		return 
	end

	--Capacity
	--PercentFull
	--' + @location_filter + '
	SET @sql = 
	'
	
	SELECT ' + @top + ' * 
	FROM (
			select 
				total_capacity.intLocationId,
				Capacity = dblTotalCapacityPerLocation,
				PercentFull = round(dbo.fnMultiply( 
					round(dbo.fnDivide( 
						dblTotalStockPerLocation,
						dblTotalCapacityPerLocation
					), 4)
					, 100
				), 2) 
			
			from 

			(					
				select 
						sum(
							isnull(dbo.fnICConvertUOMtoStockUnit(Item.intItemId, ItemStockUOM.intItemUOMId, dblQty), 0) 
						) as dblTotalStockPerLocation, 
						il.intLocationId
				FROM	
					(
						select intItemId, intItemLocationId, t.dblQty, t.intItemUOMId, dtmDate, intStorageLocationId from tblICInventoryTransaction t where t.ysnIsUnposted = 0
							union all
						select intItemId, intItemLocationId, t.dblQty, t.intItemUOMId, dtmDate, intStorageLocationId from tblICInventoryTransactionStorage t where t.ysnIsUnposted = 0					
					)	as ItemStockUOM	


					join tblICItem as Item
						on ItemStockUOM.intItemId = Item.intItemId
					join tblICItemLocation as il
						on il.intItemLocationId = ItemStockUOM.intItemLocationId
					where ItemStockUOM.intStorageLocationId is not null 
						'
						+
							case when @strLocationName <> '' then ' and il.intLocationId in ( ' + @strLocationName + ' )'
							else
									''
							end
						+
						'
					group by il.intLocationId
			) as current_stock

			join 
			(
				select sum(isnull(sl.dblEffectiveDepth,1) * isnull(sl.dblUnitPerFoot,1))  as dblTotalCapacityPerLocation
						,il.intLocationId
					from tblICItemLocation as il
						join tblICStorageLocation as sl
							on il.intLocationId  = sl.intLocationId
					'
					+
						case when @strLocationName <> '' then ' where il.intLocationId in ( ' + @strLocationName + ' )'
						else
								''
						end
					+
					'
					group by il.intLocationId
			) as total_capacity
				on total_capacity.intLocationId = current_stock.intLocationId
					and total_capacity.dblTotalCapacityPerLocation <> 0
			

		) b
	'
	
	EXEC(@sql) 
	
end
