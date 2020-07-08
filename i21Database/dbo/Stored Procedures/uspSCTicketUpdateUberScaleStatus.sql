CREATE PROCEDURE [dbo].[uspSCTicketUpdateUberScaleStatus]	
	@intTicketId	int,
	@strUberStatusCode nvarchar(3)
AS
	
	IF EXISTS(SELECT TOP 1 1 FROM tblSCTicket WHERE intTicketId = @intTicketId and ISNULL(strTicketStatus, '') <> @strUberStatusCode)
	BEGIN

		DECLARE @ticketStatus AS NVARCHAR(3)
		DECLARE @hasGeneratedTicket AS NVARCHAR(3)

		SELECT TOP 1 
			@ticketStatus = strTicketStatus,
			@hasGeneratedTicket = ysnHasGeneratedTicketNumber
		FROM tblSCTicket WHERE intTicketId = @intTicketId

		IF @ticketStatus <> '' AND (@ticketStatus = 'S' OR @ticketStatus = 'I' OR @ticketStatus = 'O') 
		BEGIN
			IF @hasGeneratedTicket = 0
			BEGIN
				UPDATE tblSCTicket set strTicketStatus = @strUberStatusCode where intTicketId = @intTicketId
				INSERT INTO tblSCTicketUberScaleStatusUpdate(intTicketId, dtmTransactionDate, strUberStatusCode)
				SELECT @intTicketId, getdate(), @strUberStatusCode
			END
			ELSE
				THROW 99999, 'Ticket number has been generated.', 1;  
		END
	END


RETURN 0