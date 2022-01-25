CREATE PROCEDURE [dbo].[uspSCISBinSearch]
	@strStorageLocation nvarchar(100) = ''
	,@strCommodity nvarchar(100) = ''
	,@strStorageUnitName nvarchar(100) = ''
	,@strItemNo nvarchar(100) = ''
	,@strBinType1 nvarchar(100) = ''
	,@strBinType2 nvarchar(100) = ''
	,@strBinNotes nvarchar(100) = ''
	
as
begin
	declare @Columns nvarchar(500)
	set @Columns = ''
	select @Columns = @Columns + replace(strHeader, ' ', '_') + ',' 
		from tblSCISBinDiscountHeader

	IF len(@Columns) > 0 
	begin
		select @Columns = substring(@Columns, 1, len(@Columns) - 1)
	end

	declare @sql nvarchar(max)



	-- Create the temp table for the location filter. 
	IF OBJECT_ID('tempdb..#tmpLocationFilter') IS NULL  
	BEGIN 
		CREATE TABLE #tmpLocationFilter (
			intStorageLocationId INT NULL 
		)
	END 

	IF LTRIM(RTRIM(ISNULL(@strStorageLocation, ''))) <> ''
	BEGIN 
		DECLARE @locationFilter_XML AS XML = CAST('<root><ID>' + REPLACE(@strStorageLocation, ',', '</ID><ID>') + '</ID></root>' AS XML) 	
		INSERT INTO #tmpLocationFilter (
			intStorageLocationId
		)
		SELECT f.x.value('.', 'INT') AS id
		FROM @locationFilter_XML.nodes('/root/ID') f(x)
	END 

	DELETE FROM #tmpLocationFilter WHERE intStorageLocationId IS NULL 
	IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpLocationFilter)
	INSERT INTO #tmpLocationFilter (intStorageLocationId) VALUES (NULL) 

	-- Create the temp table for the commodity filter. 
	IF OBJECT_ID('tempdb..#tmpCommodityFilter') IS NULL  
	BEGIN 
		CREATE TABLE #tmpCommodityFilter (
			intCommodityId INT NULL 
		)
	END 

	IF LTRIM(RTRIM(ISNULL(@strCommodity, ''))) <> ''
	BEGIN 
		DECLARE @commodityFilter_XML AS XML = CAST('<root><ID>' + REPLACE(@strCommodity, ',', '</ID><ID>') + '</ID></root>' AS XML) 	
		INSERT INTO #tmpCommodityFilter (
			intCommodityId
		)
		SELECT f.x.value('.', 'INT') AS id
		FROM @commodityFilter_XML.nodes('/root/ID') f(x)
	END 

	DELETE FROM #tmpCommodityFilter WHERE intCommodityId IS NULL 
	IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpCommodityFilter)
	INSERT INTO #tmpCommodityFilter (intCommodityId) VALUES (NULL) 


	IF OBJECT_ID('tempdb..#tmpStorageUnit') IS NULL  
	BEGIN 
		CREATE TABLE #tmpStorageUnit (
			intStorageUnitId INT NULL 
		)
	END 

	IF LTRIM(RTRIM(ISNULL(@strStorageUnitName, ''))) <> ''
	BEGIN 
		DECLARE @storageUnitName_XML AS XML = CAST('<root><ID>' + REPLACE(@strStorageUnitName, ',', '</ID><ID>') + '</ID></root>' AS XML) 	
		INSERT INTO #tmpStorageUnit (
			intStorageUnitId
		)
		SELECT f.x.value('.', 'INT') AS id
		FROM @storageUnitName_XML.nodes('/root/ID') f(x)
	END 

	DELETE FROM #tmpStorageUnit WHERE intStorageUnitId IS NULL 
	IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpStorageUnit)
	INSERT INTO #tmpStorageUnit (intStorageUnitId) VALUES (NULL) 


	IF OBJECT_ID('tempdb..#tmpItem') IS NULL  
	BEGIN 
		CREATE TABLE #tmpItem (
			intItemId INT NULL 
		)
	END 

	IF LTRIM(RTRIM(ISNULL(@strItemNo, ''))) <> ''
	BEGIN 
		DECLARE @item_XML AS XML = CAST('<root><ID>' + REPLACE(@strItemNo, ',', '</ID><ID>') + '</ID></root>' AS XML) 	
		INSERT INTO #tmpItem (
			intItemId
		)
		SELECT f.x.value('.', 'INT') AS id
		FROM @item_XML.nodes('/root/ID') f(x)
	END 

	DELETE FROM #tmpItem WHERE intItemId IS NULL 
	IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpItem)
	INSERT INTO #tmpItem (intItemId) VALUES (NULL) 



	set @sql = N'
		select * 
			From
			(
				select Bin.intBinSearchId
						, Bin.intStorageLocationId
						, SubLocation.strSubLocationName as strStorageLocationName
						, StorageLocation.strName as strStorageUnitName
						, Commodity.strCommodityCode
						, isnull(BinDetails.strItemNo, '''') as strItemNo
						, replace(DiscountHeader.strHeader, '' '', ''_'') as strHeader
						, Bin.strBinType
						, Bin.strBinType2
						, Bin.strBinNotes
						, Bin.strBinNotesColor
						, Bin.strBinNotesBackgroundColor
						, AverageDiscount.dblAverageReading
						, BinDetails.dblPercentageFull
						, case when Bin.intUnitMeasureId is not null and Bin.intUnitMeasureId != BinDetails.intUnitMeasureId then 
								dbo.fnGRConvertQuantityToTargetItemUOM(
									BinDetails.intItemId
									, BinDetails.intUnitMeasureId
									, Bin.intUnitMeasureId
									, BinDetails.dblAvailable) 
							else 
								BinDetails.dblAvailable
							end  as dblSpaceAvailable
						, case when Bin.intUnitMeasureId is not null and Bin.intUnitMeasureId != BinDetails.intUnitMeasureId then 
								dbo.fnGRConvertQuantityToTargetItemUOM(
									BinDetails.intItemId
									, BinDetails.intUnitMeasureId
									, Bin.intUnitMeasureId
									, BinDetails.dblQuantity) 
							else 
								BinDetails.dblQuantity
							end as dblQuantity
						, case when Bin.intUnitMeasureId is not null and Bin.intUnitMeasureId != BinDetails.intUnitMeasureId then 
								dbo.fnGRConvertQuantityToTargetItemUOM(
									BinDetails.intItemId
									, BinDetails.intUnitMeasureId
									, Bin.intUnitMeasureId
									, BinDetails.dblCapacity) 
							else 
								BinDetails.dblCapacity
							end as dblCapacity
						, Bin.strComBinNotesColor
						, Bin.strComBinNotesBackgroundColor
						,dtmTrackingDate
					from tblSCISBinSearch Bin 
						left join tblSCISBinSearchDiscountHeader BinDiscount
							on Bin.intBinSearchId = BinDiscount.intBinSearchId
						left join tblSCISBinDiscountHeader DiscountHeader
							on BinDiscount.intBinDiscountHeaderId = DiscountHeader.intBinDiscountHeaderId
						
						left join tblICStorageLocation StorageLocation
							on Bin.intStorageLocationId = StorageLocation.intStorageLocationId
						left join tblSMCompanyLocationSubLocation SubLocation
							on StorageLocation.intSubLocationId = SubLocation.intCompanyLocationSubLocationId
						left join tblICCommodity Commodity
							on Bin.intCommodityId = Commodity.intCommodityId
						outer apply dbo.fnSCISGetAverageDiscountPerStorageLocation(Bin.intStorageLocationId, BinDiscount.intItemId) AverageDiscount
						outer apply (
							select round( dbo.fnMultiply( dbo.fnDivide( ( StorageBinDetails.dblCapacity -  StorageBinDetails.dblAvailable),   StorageBinDetails.dblCapacity) , 100), 2) as dblPercentageFull
								, StorageBinDetails.dblAvailable
								/*,dblCapacity
								,(dblCapacity - dblAvailable) as dblOccupiedOutput */
								, StorageBinDetails.dblStock as dblQuantity
								, StorageBinDetails.dblCapacity
								, StorageBinDetails.strItemNo
								, ItemUOM.intUnitMeasureId
								, StorageBinDetails.intItemId
							from vyuICGetStorageBinDetails StorageBinDetails
								join tblICItemUOM ItemUOM
									on StorageBinDetails.intItemUOMId = ItemUOM.intItemUOMId
								where StorageBinDetails.intStorageLocationId = Bin.intStorageLocationId
						)BinDetails
						
						inner join #tmpLocationFilter locationFilter
							on SubLocation.intCompanyLocationSubLocationId = locationFilter.intStorageLocationId
							or locationFilter.intStorageLocationId IS NULL 
						inner join #tmpCommodityFilter commodityFilter
							on Commodity.intCommodityId = commodityFilter.intCommodityId
							or commodityFilter.intCommodityId IS NULL

						inner join #tmpStorageUnit storageUnitFilter
							on Bin.intStorageLocationId = storageUnitFilter.intStorageUnitId
							or storageUnitFilter.intStorageUnitId IS NULL

						inner join #tmpItem itemFilter
							on BinDetails.intItemId = itemFilter.intItemId
							or itemFilter.intItemId IS NULL


					where 
						((@strBinType1 = '''' or @strBinType1 is null) or Bin.strBinType like ''%'' + @strBinType1 + ''%'')
						and ((@strBinType2 = '''' or @strBinType2 is null)  or Bin.strBinType2 like ''%'' + @strBinType2 + ''%'')
						and ((@strBinNotes = '''' or @strBinNotes is null)  or Bin.strBinNotes like ''%'' + @strBinNotes + ''%'')
			) F
		'
	if @Columns <> ''
	begin
		set @sql = @sql +  N'
				PIVOT(
					max(dblAverageReading)
					for strHeader in (
						' + @Columns + ' 
					)		
				) as pvt

			'
	end
	
	
	
	--SELECT @sql
	--select @strBinType1 
	--		, @strBinType2 
	--		, @strBinNotes
	exec sp_executesql  @sql
	,N'@strBinType1 nvarchar(100),@strBinType2 nvarchar(100),@strBinNotes nvarchar(100)'
	,@strBinType1 = @strBinType1 , @strBinType2 = @strBinType2, @strBinNotes = @strBinNotes


end
