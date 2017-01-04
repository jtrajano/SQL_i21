CREATE FUNCTION [dbo].[fnARGetScaleTicketNumbersFromInvoice]
(
	@intInvoiceId INT
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @strTicketNumbers NVARCHAR(MAX) = NULL

	DECLARE @tmpTable TABLE(intTicketId INT)
	INSERT INTO @tmpTable
	SELECT intTicketId FROM tblARInvoiceDetail WHERE intInvoiceId = @intInvoiceId AND ISNULL(intTicketId, 0) > 0
	
	IF EXISTS(SELECT NULL FROM @tmpTable)
		BEGIN
			WHILE EXISTS(SELECT TOP 1 NULL FROM @tmpTable)
			BEGIN
				DECLARE @intTicketId INT
				
				SELECT TOP 1 @intTicketId = intTicketId FROM @tmpTable ORDER BY intTicketId
				
				IF (SELECT COUNT(*) FROM @tmpTable) > 1
					SELECT @strTicketNumbers = ISNULL(@strTicketNumbers, '') + strTicketNumber + ', ' FROM tblSCTicket WHERE intTicketId = @intTicketId
				ELSE
					SELECT @strTicketNumbers = ISNULL(@strTicketNumbers, '') + strTicketNumber FROM tblSCTicket WHERE intTicketId = @intTicketId

				DELETE FROM @tmpTable WHERE intTicketId = @intTicketId
			END
		END

	RETURN @strTicketNumbers
END