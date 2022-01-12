CREATE PROCEDURE [dbo].[uspSCISGetBinInfo]
	@intStorageLocationId int
	,@intItemId int = null
	,@dblAvailableOutput decimal(20,2) = null output 
	,@dblCapacityOutput decimal(20,2) = null output
	,@dblOccupiedOutput decimal(20,2) = null output
	,@dblPercentageOutput decimal(20, 2) = null output
	,@FinalReadingOutput nvarchar(max) = null output  
	,@StorageLocation nvarchar(100) = null output
as
begin
	declare @dblAvailable decimal(20,2)
	declare @FinalReading nvarchar(max) = ''	
	declare @intBinDetailUnitMeasureId int
	declare @intBinUnitMeasureId int
	
	select @dblPercentageOutput = round( dbo.fnMultiply( dbo.fnDivide( (BinDetails.dblCapacity - BinDetails.dblAvailable),  BinDetails.dblCapacity) , 100), 2)
		,@dblAvailable = BinDetails.dblAvailable
		,@dblCapacityOutput = BinDetails.dblCapacity
		,@dblOccupiedOutput = BinDetails.dblCapacity - BinDetails.dblAvailable
		,@intBinDetailUnitMeasureId = ItemUOM.intUnitMeasureId
		,@intBinUnitMeasureId = Bin.intUnitMeasureId


		from vyuICGetStorageBinDetails BinDetails
			join tblSCISBinSearch Bin 
				on BinDetails.intStorageLocationId = Bin.intStorageLocationId			
			join tblICItemUOM ItemUOM
				on BinDetails.intItemUOMId = ItemUOM.intItemUOMId

			



			where BinDetails.intStorageLocationId = @intStorageLocationId
				and (@intItemId is null or BinDetails.intItemId = @intItemId)


	select @StorageLocation = strName 
		from tblICStorageLocation 
			where intStorageLocationId = @intStorageLocationId

	declare @FinalResult table (
		strShortName nvarchar(50)
		,dblAverageReading decimal(18,2)

	)
	insert into @FinalResult
	select	Item.strShortName
			,Round(AVG(isnull(Discount.dblGradeReading, 0)), 2)
		from tblSCTicket Ticket
			join tblQMTicketDiscount Discount
				on Ticket.intTicketId = Discount.intTicketId
			join tblGRDiscountScheduleCode DiscountCode
				on Discount.intDiscountScheduleCodeId = DiscountCode.intDiscountScheduleCodeId
			join tblICItem Item
				on DiscountCode.intItemId = Item.intItemId
			join tblSCISBinSearch BinSearch
				on Ticket.intStorageLocationId = BinSearch.intStorageLocationId
					and (BinSearch.dtmTrackingDate is null or Ticket.dtmTicketDateTime >= BinSearch.dtmTrackingDate) 
			join tblSCISBinSearchDiscountTracking DiscountTracking
				on Item.intItemId = DiscountTracking.intItemId
					and BinSearch.intBinSearchId = DiscountTracking.intBinSearchId
		where Ticket.intStorageLocationId = @intStorageLocationId
			and ( strShortName is not null or strShortName <> '')	
		 group by Item.strShortName

	select @FinalReading = @FinalReading + strShortName + ':'+ cast(dblAverageReading as nvarchar) + '| ' from @FinalResult	

	
	if @intBinDetailUnitMeasureId is not null 
		and @intBinUnitMeasureId is not null 
		and @intItemId is not null
		and @intBinDetailUnitMeasureId <> @intBinUnitMeasureId
	begin
		select @dblAvailable = round(dbo.fnGRConvertQuantityToTargetItemUOM(@intItemId, @intBinDetailUnitMeasureId, @intBinUnitMeasureId, @dblAvailable), 2)
			, @dblCapacityOutput = round(dbo.fnGRConvertQuantityToTargetItemUOM(@intItemId, @intBinDetailUnitMeasureId, @intBinUnitMeasureId, @dblCapacityOutput), 2)
			, @dblOccupiedOutput = round(dbo.fnGRConvertQuantityToTargetItemUOM(@intItemId, @intBinDetailUnitMeasureId, @intBinUnitMeasureId, @dblOccupiedOutput), 2)
	end
	
	select @dblAvailableOutput = @dblAvailable
		, @FinalReadingOutput = @FinalReading
		/**/

end