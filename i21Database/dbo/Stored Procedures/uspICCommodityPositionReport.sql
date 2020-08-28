CREATE PROCEDURE [dbo].[uspICCommodityPositionReport]	
	@ysnGetHeader	bit  = 0,
	@dtmDate		date = null,
	@strLocationName nvarchar(max) = '',
	@ysnLocationLicensed bit = null,
	@intUserId INT = NULL,
	@strPermission nvarchar(max) = ''
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
	DECLARE @location_filter as nvarchar(max)
	DECLARE @licensed_filter as nvarchar(100)
	DECLARE @permission_filter as nvarchar(max)

	IF ISNULL(@strLocationName, '') <> ''
	BEGIN
		SET @location_filter = ' AND intCompanyLocationId in ( '  + @strLocationName + ' ) '		
	END
	ELSE
	BEGIN
		SET @location_filter = ''
	END

	IF ISNULL(@strPermission, '') <> ''
	BEGIN
		SET @permission_filter = ' AND intCompanyLocationId in ( '  + @strPermission + ' ) '		
	END
	ELSE
	BEGIN
		SET @permission_filter = ''
	END

	SET @licensed_filter = ' '
	IF (@ysnLocationLicensed is not null)
	BEGIN
		SET @licensed_filter = ' and ysnLicensed = ' + cast(@ysnLocationLicensed as nvarchar) + ' '
	END

	SET @top = ''

	IF @ysnGetHeader = 1
	BEGIN
		SET @top = ' top 1'
		SET @dtmDate = NULL 
		SET @licensed_filter = ''
	END
	SET @sql = 
	'
	DECLARE @dtmDate AS DATETIME = ' + ISNULL('''' + CAST(@dtmDate AS NVARCHAR(20)) + '''', 'NULL') + '
	
	SELECT ' + @top + ' * 
	FROM (
		SELECT ' + @top + ' 			
			com.strCommodityCode
			,cl.intCompanyLocationId
			,cl.strLocationName 
			, dblQty = CAST( ROUND(dbo.fnICConvertUOMtoStockUnit(t.intItemId, t.intItemUOMId, t.dblQty), ISNULL(com.intDecimalDPR,2)) AS NUMERIC(28, 2)) 
			, dtmDate = @dtmDate
			, ysnLicensed = cl.ysnLicensed
		FROM 
			tblICItem i inner join tblICItemLocation il
				on i.intItemId = il.intItemId
			inner join tblSMCompanyLocation cl
				on cl.intCompanyLocationId = il.intLocationId ' + @licensed_filter + '
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
		WHERE 
			(dbo.fnDateLessThanEquals(t.dtmDate,  @dtmDate) = 1 OR @dtmDate IS NULL)'  
			+ @location_filter + @permission_filter + '
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
	ORDER BY PVT.strLocationName 
	'	
	EXEC(@sql) 
	
end