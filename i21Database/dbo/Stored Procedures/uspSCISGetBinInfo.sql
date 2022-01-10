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
	
	select @dblPercentageOutput = round( dbo.fnMultiply( dbo.fnDivide( (dblCapacity - dblAvailable),  dblCapacity) , 100), 2)
		,@dblAvailable = dblAvailable
		,@dblCapacityOutput = dblCapacity
		,@dblOccupiedOutput = dblCapacity - dblAvailable
		from vyuICGetStorageBinDetails 
			where intStorageLocationId = @intStorageLocationId
				and (@intItemId is null or intItemId = @intItemId)
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

	
	select @dblAvailableOutput = @dblAvailable
		, @FinalReadingOutput = @FinalReading
		/**/

end