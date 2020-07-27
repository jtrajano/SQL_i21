CREATE PROCEDURE [dbo].[uspICCommodityPositionDetailReport]	
	@ysnGetHeader	bit  = 0,
	@dtmDate		date = null,
	@strLocationName nvarchar(max) = '',
	@intUserId INT = NULL,
	@strPermission nvarchar(max) = ''
AS
BEGIN
	DECLARE @Columns VARCHAR(MAX)
	SELECT @Columns = COALESCE(@Columns + ', ','') + QUOTENAME(strCommodityCode)
	FROM (
		SELECT DISTINCT strCommodityCode 
		FROM   tblICCommodity 
	) AS C
	
	DECLARE @sql AS NVARCHAR(MAX)
	DECLARE @top as nvarchar(20)
	
	SET @top = ''
	SET @strLocationName = LTRIM(RTRIM(ISNULL(@strLocationName, '')))
	SET @strPermission = LTRIM(RTRIM(ISNULL(@strPermission, '')))

	IF @ysnGetHeader= 1
	BEGIN
		SET @top = ' top 1'
		SET @dtmDate = NULL 
	END

	SET @sql = 
	'
	DECLARE @dtmDate AS DATETIME = ' + ISNULL('''' + CAST(@dtmDate AS NVARCHAR(20)) + '''', 'NULL') + '
	
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
					where 
						(dbo.fnDateLessThanEquals(ItemStockUOM.dtmDate,  @dtmDate) = 1 OR @dtmDate IS NULL)'  
						+ ' AND ItemStockUOM.intStorageLocationId is not null 
						'
						+
							case when @strLocationName <> '' then ' and il.intLocationId in ( ' + @strLocationName + ' )'
							else
									''
							end
						+								
							case when @strPermission <> '' then ' and il.intLocationId in ( ' + @strPermission + ' )'
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
						,sl.intLocationId as intLocationId
					from tblICStorageLocation sl
					'
					+
						case when @strLocationName <> '' then ' where sl.intLocationId in ( ' + @strLocationName + ' )'
						else
								''
						end
					+ 
						CASE 
							WHEN @strLocationName <> '' AND @strPermission <> '' THEN ' and '
							WHEN @strLocationName = '' AND @strPermission <> '' THEN ' where '
							ELSE ''
						END 
					+
						case when @strPermission <> '' then 'sl.intLocationId in ( ' + @strPermission + ' )'
						else
								''
						end
					+
					'
					group by sl.intLocationId
			) as total_capacity
				on total_capacity.intLocationId = current_stock.intLocationId
					and total_capacity.dblTotalCapacityPerLocation <> 0
		) b
	'
	EXEC(@sql) 
	
end
