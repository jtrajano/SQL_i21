CREATE PROCEDURE [dbo].[uspSCTicketAutoScaleLogHeader]
	@TICKET_ID INT
AS
BEGIN
	PRINT 'HEADER - LOG'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSCTicketAutoScaleLog WHERE intTicketId = @TICKET_ID AND ysnHeader = 1)
	BEGIN
		INSERT INTO tblSCTicketAutoScaleLog(intTicketId, ysnHeader) 
		SELECT @TICKET_ID, 1
	END
END


GO