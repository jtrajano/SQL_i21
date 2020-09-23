CREATE PROCEDURE [dbo].[uspICCommodityPositionReport]	
	@ysnGetHeader	bit  = 0,
	@dtmDate		date = null,
	@strLocationName nvarchar(max) = '',
	@ysnLocationLicensed bit = null
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
	declare @licensed_filter as nvarchar(100)

	
	--due to some implementation of deliverysheet, we need to determine which part of the old transaction is affected by the new implementation
	declare @intInventoryTransactionStorageId int
	select top 1 @intInventoryTransactionStorageId = intInventoryTransactionStorageId from tblGRCompanyPreference
	set @intInventoryTransactionStorageId = isnull(@intInventoryTransactionStorageId, 0)


	if isnull(@strLocationName, '') <> ''
	begin
		set @location_filter = ' and intCompanyLocationId in ( '  + @strLocationName + ' ) '		
	end
	else
	begin
		set @location_filter = ''
	end

	set @licensed_filter = ' '

	if(@ysnLocationLicensed is not null)
	begin
		set @licensed_filter = ' and ysnLicensed = ' + cast(@ysnLocationLicensed as nvarchar) + ' '
	end

	set @top = ''
	set @dtmDate = isnull(@dtmDate, getdate())
		
	if @ysnGetHeader = 1
	begin
		set @top = ' top 1'
		set @dtmDate = NULL 
		set @licensed_filter = ''
	end

	SET @sql = 
	'
	DECLARE @dtmDate AS DATETIME = ' + ISNULL('''' + CAST(@dtmDate AS NVARCHAR(20)) + '''', 'NULL') + '

	SELECT ' + @top + ' * 
	FROM (
		SELECT ' + @top + '
			com.strCommodityCode
			,cl.intCompanyLocationId
			,cl.strLocationName 
			, dblQty = ROUND(dbo.fnICConvertUOMtoStockUnit(t.intItemId, t.intItemUOMId, t.dblQty), ISNULL(com.intDecimalDPR,2))
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
					
					
					
						select intItemId, intItemLocationId, isnull(Cleansed.dblQty, Storage.dblQty) as dblQty, intItemUOMId, 
								case when strTransactionForm = ''Storage Settlement''  then dtmCreated else dtmDate end as dtmDate from 
						(	
							select sum(dblQty) as dblQty, strTransactionForm, intTransactionId, intItemLocationId, intItemId, ysnIsUnposted, dtmDate, convert(nvarchar,dtmCreated , 111) dtmCreated, intItemUOMId
								from tblICInventoryTransactionStorage 
									where strTransactionForm = ''Inventory Adjustment''
									group by strTransactionForm, intTransactionId, intItemLocationId, intItemId, ysnIsUnposted, dtmDate, convert(nvarchar,dtmCreated , 111), intItemUOMId
							union all
							select dblQty, strTransactionForm, intTransactionId, intItemLocationId, intItemId, ysnIsUnposted, dtmDate, convert(nvarchar,dtmCreated , 111) dtmCreated, intItemUOMId
								from tblICInventoryTransactionStorage 
									where strTransactionForm <> ''Inventory Adjustment''
	
	
						) as Storage

						outer apply (
	
						select sum((DeliverySheetSplit.dblSplitPercent / 100) * dblNewQuantity)  as dblQty
						from tblICInventoryAdjustmentDetail AdjustmentDetail
							join tblICInventoryAdjustment Adjustment
								on AdjustmentDetail.intInventoryAdjustmentId = Adjustment.intInventoryAdjustmentId
									and Adjustment.intSourceTransactionTypeId = 53
									and Adjustment.intInventoryAdjustmentId <= ' + cast(@intInventoryTransactionStorageId as nvarchar) + ' -- this is hardcoded but will be moved to a company preference of grain
							join tblSCDeliverySheetSplit DeliverySheetSplit
								on DeliverySheetSplit.intDeliverySheetId = Adjustment.intSourceId
									and DeliverySheetSplit.strDistributionOption <> ''DP''
							where Adjustment.intInventoryAdjustmentId = Storage.intTransactionId and Storage.strTransactionForm = ''Inventory Adjustment''
		
						group by Adjustment.intInventoryAdjustmentId
						) Cleansed
						where (strTransactionForm = ''Storage Settlement'' or (ysnIsUnposted = 0 and strTransactionForm <> ''Storage Settlement'') )






				)			
				 t
				on t.intItemId = i.intItemId
				and t.intItemLocationId = il.intItemLocationId 
		WHERE 
			(dbo.fnDateLessThanEquals(t.dtmDate,  @dtmDate) = 1 OR @dtmDate IS NULL)'  
			+ @location_filter + '

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
	--print(@sql) 	
	EXEC(@sql) 	
end
GO