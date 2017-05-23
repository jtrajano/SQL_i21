CREATE FUNCTION [dbo].[fnARGetScaleTicketNumbersFromInvoice]
(
	@intInvoiceId INT
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @strTicketNumbers NVARCHAR(MAX) = NULL

	SELECT @strTicketNumbers = COALESCE(@strTicketNumbers + ', ', '') + RTRIM(LTRIM(T.strTicketNumber)) 
	FROM dbo.tblSCTicket T WITH(NOLOCK) 		
	WHERE T.intTicketId = @intInvoiceId
	
	RETURN @strTicketNumbers
END