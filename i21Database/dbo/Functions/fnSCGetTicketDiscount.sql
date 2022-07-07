CREATE FUNCTION [dbo].[fnSCGetTicketDiscount](
	@intTicketId int

)	
returns nvarchar(max)
as
begin
	declare @a nvarchar(max) = ''
	select @a = @a + Item.strShortName + ':' + cast(cast(isnull(TicketDiscount.dblGradeReading,0) as decimal(18,2))  as nvarchar) + ' | ' from tblQMTicketDiscount TicketDiscount
		join tblGRDiscountScheduleCode  DiscountCode
			on TicketDiscount.intDiscountScheduleCodeId = DiscountCode.intDiscountScheduleCodeId
		join tblICItem Item
			on DiscountCode.intItemId = Item.intItemId
		where TicketDiscount.intTicketId = @intTicketId

	return @a
end
