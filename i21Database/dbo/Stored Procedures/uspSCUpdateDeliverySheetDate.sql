CREATE PROCEDURE [dbo].[uspSCUpdateDeliverySheetDate]
	@intDeliverySheetId		int = null,
	@intTicketId			int =  null,
	@dtmDeliveryDate		datetime =  null,
	@ysnUndistribute		bit = 0
AS
	if @intDeliverySheetId is null and @intTicketId is null
		return 0

	declare @dtmTicketDate datetime
	set @ysnUndistribute = isnull(@ysnUndistribute, 0)
	
	if @intDeliverySheetId is null and @intTicketId is not null
	begin 
		select 

			@intDeliverySheetId = intDeliverySheetId,
			@dtmTicketDate = dtmTicketDateTime
		from tblSCTicket where intTicketId = @intTicketId 
	end
	else if @intDeliverySheetId is not null and @intTicketId is not null
	begin 

		select 			
			@dtmTicketDate = dtmTicketDateTime
		from tblSCTicket 
			where intTicketId = @intTicketId  
			and intDeliverySheetId = @intDeliverySheetId

	end
	

	if @intDeliverySheetId is null
		return 0
	

	if( @ysnUndistribute = 1)	
	begin
		if @intTicketId is not null
		begin
			select 
				top 1
				@dtmTicketDate = dtmTicketDateTime 
			from tblSCTicket 
				where intDeliverySheetId  = @intDeliverySheetId	
				and intTicketId <> @intTicketId
				and strTicketStatus = 'C'
			order by dtmTicketDateTime desc 
			--offset 0 rows fetch next 1 rows only
		end
	end	
	else
	begin
		declare @dtmLargetDate datetime
		select 
			top 1
			@dtmLargetDate = dtmTicketDateTime 
		from tblSCTicket 
		
			where intDeliverySheetId  = @intDeliverySheetId
				and strTicketStatus = 'C'
		order by dtmTicketDateTime desc 
		--offset 0 rows fetch next 1 rows only

		if @dtmLargetDate > @dtmTicketDate
			set @dtmTicketDate = @dtmLargetDate
	end
	update tblSCDeliverySheet 
		
		set dtmDeliverySheetDate = coalesce(@dtmDeliveryDate, @dtmTicketDate, dtmDeliverySheetDate , getdate())

	where intDeliverySheetId = @intDeliverySheetId



RETURN 0