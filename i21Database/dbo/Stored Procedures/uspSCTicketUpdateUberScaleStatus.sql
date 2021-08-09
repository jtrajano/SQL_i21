CREATE PROCEDURE [dbo].[uspSCTicketUpdateUberScaleStatus]	
	@intTicketId	int,
	@strUberStatusCode nvarchar(3)
AS
	
	IF EXISTS(SELECT TOP 1 1 FROM tblSCTicket WHERE intTicketId = @intTicketId and ISNULL(strTicketStatus, '') <> @strUberStatusCode)
	BEGIN

		DECLARE @ticketStatus AS NVARCHAR(3) = (SELECT TOP 1 strTicketStatus FROM tblSCTicket WHERE intTicketId = @intTicketId)

		IF @ticketStatus <> '' AND (@ticketStatus = 'S' OR @ticketStatus = 'I')
		BEGIN
			UPDATE tblSCTicket set strTicketStatus = @strUberStatusCode, dtmDateModifiedUtc = GETUTCDATE() where intTicketId = @intTicketId
			INSERT INTO tblSCTicketUberScaleStatusUpdate(intTicketId, dtmTransactionDate, strUberStatusCode)
			SELECT @intTicketId, getdate(), @strUberStatusCode
		END
	END


RETURN 0