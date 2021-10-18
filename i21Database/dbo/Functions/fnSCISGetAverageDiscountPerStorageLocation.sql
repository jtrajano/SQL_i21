CREATE FUNCTION [dbo].[fnSCISGetAverageDiscountPerStorageLocation]
(
	@intStorageLocationId	int
	,@intItemId				int
)
returns @ReturnTable table
(
	intItemId int
	,dblAverageReading decimal(18, 2)
)
as 

begin

	
	insert into @ReturnTable(intItemId, dblAverageReading)
	select	Item.intItemId
			,Round(AVG(isnull(Discount.dblGradeReading, 0)), 2)
		from tblSCTicket Ticket			
			
			join tblSCISBinSearch BinSearch
				on	Ticket.intStorageLocationId = BinSearch.intStorageLocationId
					and BinSearch.intStorageLocationId = @intStorageLocationId
			join tblSCISBinSearchDiscountHeader BinSearchDiscount
				on BinSearch.intBinSearchId = BinSearchDiscount.intBinSearchId
					and BinSearchDiscount.intItemId = @intItemId				
			join tblSCISBinDiscountHeader DiscountHeader
				on BinSearchDiscount.intBinDiscountHeaderId = DiscountHeader.intBinDiscountHeaderId

			join tblQMTicketDiscount Discount
				on Ticket.intTicketId = Discount.intTicketId					
			join tblGRDiscountScheduleCode DiscountCode
				on Discount.intDiscountScheduleCodeId = DiscountCode.intDiscountScheduleCodeId
					and BinSearchDiscount.intItemId = DiscountCode.intItemId 

			join tblICItem Item
				on DiscountCode.intItemId = Item.intItemId
		
		 group by Item.intItemId
		 
	return;
end