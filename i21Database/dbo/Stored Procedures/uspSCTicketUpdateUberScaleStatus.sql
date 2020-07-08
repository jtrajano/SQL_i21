CREATE PROCEDURE [dbo].[uspSCTicketUpdateUberScaleStatus]	
	@intTicketId	int,
	@strUberStatusCode nvarchar(3)
AS
	
	IF EXISTS(SELECT TOP 1 1 FROM tblSCTicket WHERE intTicketId = @intTicketId and ISNULL(strTicketStatus, '') <> @strUberStatusCode)
	BEGIN

		DECLARE @ticketStatus AS NVARCHAR(3)
		DECLARE @hasGeneratedTicket AS NVARCHAR(3)
		DECLARE @inAndOutFlag AS NVARCHAR(3)

		SELECT TOP 1 
			@ticketStatus = strTicketStatus,
			@hasGeneratedTicket = ysnHasGeneratedTicketNumber,
			@inAndOutFlag = strInOutFlag
		FROM tblSCTicket WHERE intTicketId = @intTicketId


	
		IF @ticketStatus <> '' AND (@ticketStatus = 'S' OR @ticketStatus = 'I' OR @ticketStatus = 'O') 
		BEGIN
			IF @hasGeneratedTicket = 1 AND (@ticketStatus = 'O' AND 
			   ((@inAndOutFlag = 'I' AND (@strUberStatusCode = 'I' OR @strUberStatusCode = 'S') OR (@inAndOutFlag = 'O' AND @strUberStatusCode = 'S'))) OR 
			   @ticketStatus = 'I' AND @inAndOutFlag = 'O' AND @strUberStatusCode = 'S')
			BEGIN
				DECLARE @strThrow AS NVARCHAR(100) = 'THROW 99999, ''Ticket number has been generated.'', 1'
				EXEC sp_executesql @strThrow
			END
			ELSE
			BEGIN
				UPDATE tblSCTicket set strTicketStatus = @strUberStatusCode where intTicketId = @intTicketId
				INSERT INTO tblSCTicketUberScaleStatusUpdate(intTicketId, dtmTransactionDate, strUberStatusCode)
				SELECT @intTicketId, getdate(), @strUberStatusCode
			END
		END
	END


RETURN 0