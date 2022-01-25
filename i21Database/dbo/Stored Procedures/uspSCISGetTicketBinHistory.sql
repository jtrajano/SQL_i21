CREATE PROCEDURE [dbo].[uspSCISGetTicketBinHistory]
	@intBinSearchId int
	,@ysnGetHeader bit = 0
	,@strTransactionId nvarchar(200) = ''
	,@dtmStartDate date = '1910/01/01'
	,@dtmEndDate date = '1910/01/01'
	
AS
begin

	set @dtmEndDate = DATEADD(day, 1 , @dtmEndDate)

	declare @ysnDefaultBinHistoryEstimate bit
	declare @intStorageLocationId int 


	select 
			@ysnDefaultBinHistoryEstimate = isnull(ysnDefaultBinHistoryEstimate, 0)
			,@intStorageLocationId =  intStorageLocationId
		from tblSCISBinSearch
			where intBinSearchId = @intBinSearchId

	-- Create the temp table for the location filter. 
	IF OBJECT_ID('tempdb..#tmpTransactionIdFilter') IS NULL  
	BEGIN 
		CREATE TABLE #tmpTransactionIdFilter (
			intInventoryValuationKeyId INT NULL 
		)
	END 


	IF LTRIM(RTRIM(ISNULL(@strTransactionId, ''))) <> ''
	BEGIN 
		DECLARE @transactionId_XML AS XML = CAST('<root><ID>' + REPLACE(@strTransactionId, ',', '</ID><ID>') + '</ID></root>' AS XML) 	
		INSERT INTO #tmpTransactionIdFilter (
			intInventoryValuationKeyId
		)
		SELECT f.x.value('.', 'INT') AS id
		FROM @transactionId_XML.nodes('/root/ID') f(x)
	END 

	DELETE FROM #tmpTransactionIdFilter WHERE intInventoryValuationKeyId IS NULL 
	IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpTransactionIdFilter)
	INSERT INTO #tmpTransactionIdFilter (intInventoryValuationKeyId) VALUES (NULL) 



	declare @Columns nvarchar(500)
	set @Columns = ''
	declare @sql_command nvarchar(max)
	set @sql_command = 
		'
			SELECT
					@@TOP@@
					StockMovement.[strTransactionId] AS [strTransactionId], 
					StockMovement.[intLocationId] AS [intLocationId], 
					StockMovement.[strLocationName] AS [strLocationName], 
					StockMovement.[intSubLocationId] AS [intSubLocationId], 
					StockMovement.[strSubLocationName] AS [strSubLocationName], 
					StockMovement.[intStorageLocationId] AS [intStorageLocationId], 
					StockMovement.[strStorageLocationName] AS [strStorageLocationName], 
					StockMovement.intInventoryValuationKeyId as intInventoryValuationKeyId,
					StockMovement.[intItemId] AS [intItemId], 
					StockMovement.[strItemNo] AS [strItemNo], 
					StockMovement.[intCommodityId] AS [intCommodityId], 
					StockMovement.[strCommodity] AS [strCommodity], 
					
					StockMovement.[dtmDate] AS [dtmDate], 
					StockMovement.[dtmDate] AS [dtmStartDate], 
					StockMovement.[dtmDate] AS [dtmEndDate], 
					
					StockMovement.[dblQuantity] AS [dblQuantity], 
					StockMovement.[strUOM] AS [strUOM], 
					StockMovement.[strStockUOM] AS [strStockUOM], 
					StockMovement.[dblQuantityInStockUOM] AS [dblQuantityInStockUOM], 
					StockMovement.[dtmCreated] AS [dtmCreated],
					StockMovement.intInventoryTransactionId
					, InventoryTransaction.strSourceNumber
					, InventoryTransaction.strSourceType
					, BinSearch.intBinSearchId
					, @@REPLACE_WITH_ACTUAL_COLUMNS@@
					
		FROM tblSCISBinSearch BinSearch
			join [dbo].[vyuICGetStockMovement] AS StockMovement
				on BinSearch.intStorageLocationId = StockMovement.intStorageLocationId 
					and ( StockMovement.dtmDate >=''' + cast(@dtmStartDate as nvarchar) + ''' and StockMovement.dtmDate < ''' + cast(@dtmEndDate as nvarchar) + ''')
			join tblICInventoryTransaction InventoryTransaction
				on StockMovement.intInventoryTransactionId = InventoryTransaction.intInventoryTransactionId

			inner join #tmpTransactionIdFilter transactionFilter
				on StockMovement.intInventoryValuationKeyId = transactionFilter.intInventoryValuationKeyId
					or transactionFilter.intInventoryValuationKeyId IS NULL 

			left join (
				@@REPLACE_WITH_PIVOT_QUERY@@			
			) Ticket
				on InventoryTransaction.intTicketId = Ticket.intTicketId


		where BinSearch.intBinSearchId = ' + cast( @intBinSearchId as nvarchar)  + '


		'


	if @ysnGetHeader = 1 
	begin
		set @sql_command = REPLACE(@sql_command, '@@TOP@@', ' top 0 ')
	end
	else
	begin
		set @sql_command = REPLACE(@sql_command, '@@TOP@@', ' ')
	end

	if( @ysnDefaultBinHistoryEstimate ) = 0
	begin
	

		select @Columns = @Columns + replace(strHeader, ' ', '_') + ',' 
			from tblSCISBinDiscountHeader
		IF len(@Columns) > 0 
		begin
			select @Columns = substring(@Columns, 1, len(@Columns) - 1)
		end

		if(isnull(@Columns, '') = '')
		begin
			set @Columns = 'strFiller'	
		end

		set @sql_command  = REPLACE(@sql_command, '@@REPLACE_WITH_ACTUAL_COLUMNS@@', @Columns)
		set @sql_command  = REPLACE(@sql_command, '@@REPLACE_WITH_PIVOT_QUERY@@', 'select * from 
							(	select 			
			
								Ticket.intTicketId, 
								DiscountHeader.strHeader, 
								Discount.dblGradeReading dblGradeReading


									from tblSCTicket Ticket			
			
										join tblSCISBinSearch BinSearch
											on	Ticket.intStorageLocationId = BinSearch.intStorageLocationId
												and BinSearch.intStorageLocationId = Ticket.intStorageLocationId	
			
			

										join tblQMTicketDiscount Discount
											on Ticket.intTicketId = Discount.intTicketId	
				
										join tblGRDiscountScheduleCode DiscountCode
											on Discount.intDiscountScheduleCodeId = DiscountCode.intDiscountScheduleCodeId

										left join tblSCISBinSearchDiscountHeader BinSearchDiscount
											on BinSearch.intBinSearchId = BinSearchDiscount.intBinSearchId
												and BinSearchDiscount.intItemId = DiscountCode.intItemId
										left join tblSCISBinDiscountHeader DiscountHeader
											on BinSearchDiscount.intBinDiscountHeaderId = DiscountHeader.intBinDiscountHeaderId

										left join tblICItem Item
											on DiscountCode.intItemId = Item.intItemId
									where Ticket.intStorageLocationId = '+ cast(@intStorageLocationId as nvarchar) + '
							) F
										PIVOT (
											max(dblGradeReading)
											for strHeader in (' + @Columns + ')

										) as pvt			
								'
							)

		
			exec sp_executesql  @sql_command

	end


	else
	begin

		select @Columns = @Columns + replace(strGrade, ' ', '_') + ',' 
			from tblQMTicketDiscountEstimatedSource 
		IF len(@Columns) > 0 
		begin
			select @Columns = substring(@Columns, 1, len(@Columns) - 1)
		end		
		
		if(isnull(@Columns, '') = '')
		begin
			set @Columns = 'strFiller'	
		end

		set @sql_command  = REPLACE(@sql_command, '@@REPLACE_WITH_ACTUAL_COLUMNS@@', @Columns)
		set @sql_command  = REPLACE(@sql_command, '@@REPLACE_WITH_PIVOT_QUERY@@', 'select * from 
									(	select 

											Ticket.intTicketId, 
											DiscountEstimateSource.strGrade as strHeader, 
											DiscountEstimate.dblGradeReading dblGradeReading
		
										from tblSCTicket Ticket 
											join tblQMTicketDiscountEstimated DiscountEstimate
												on Ticket.intTicketId = DiscountEstimate.intTicketId
											join tblQMTicketDiscountEstimatedSource DiscountEstimateSource
												on DiscountEstimate.intTicketDiscountEstimatedSourceId = DiscountEstimateSource.intTicketDiscountEstimatedSourceId

										where Ticket.intStorageLocationId = '+ cast(@intStorageLocationId as nvarchar) + '
									) F
												PIVOT (
													max(dblGradeReading)
													for strHeader in (' + @Columns + ')

												) as pvt

			
										'

									)

		
			exec sp_executesql  @sql_command


	end

end