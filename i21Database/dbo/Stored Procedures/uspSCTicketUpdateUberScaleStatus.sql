CREATE PROCEDURE [dbo].[uspSCTicketUpdateUberScaleStatus]	
	@intTicketId	int,
	@strUberStatusCode nvarchar(3)
AS
	
	if exists(select top 1 1 from tblSCTicket where intTicketId = @intTicketId and isnull(strUberStatusCode, '') <> @strUberStatusCode)
	begin
		update tblSCTicket set strUberStatusCode = @strUberStatusCode where intTicketId = @intTicketId
		insert into tblSCTicketUberScaleStatusUpdate(intTicketId, dtmTransactionDate, strUberStatusCode)
		select @intTicketId, getdate(), @strUberStatusCode
	end


RETURN 0
