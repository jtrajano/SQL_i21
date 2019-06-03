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
	SET @sql = 
	'
	
	SELECT ' + @top + ' * 
	FROM (
		SELECT		
			sl.intLocationId				
			,Capacity = SUM(ISNULL(sl.dblEffectiveDepth,0) *  ISNULL(sl.dblUnitPerFoot, 0))				
			,PercentFull = 
					CASE 
						WHEN SUM(round(ISNULL(sl.dblEffectiveDepth,0) *  ISNULL(sl.dblUnitPerFoot, 0), 2)) <> 0 THEN 
							dbo.fnMultiply (
								round(dbo.fnDivide(
									(
										SUM(round(ISNULL(sl.dblEffectiveDepth,0) *  ISNULL(sl.dblUnitPerFoot, 0), 2))
										- SUM(ISNULL(dblOnHand, 0)) 
										- SUM(ISNULL(dblUnitStorage, 0))
									)
									, SUM(round(ISNULL(sl.dblEffectiveDepth,0) *  ISNULL(sl.dblUnitPerFoot, 0), 2))
								), 2)
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
			' + @location_filter + '					
			GROUP BY sl.intLocationId	
		) b
	'
	
	EXEC(@sql) 
	
end
