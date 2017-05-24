CREATE FUNCTION [dbo].[fnARGetCustomerReferencesFromInvoice]
(
	@intInvoiceId INT
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @strReferences NVARCHAR(MAX) = NULL

	SELECT @strReferences = COALESCE(@strReferences + ', ', '') + RTRIM(LTRIM(T.strCustomerReference)) 
	FROM dbo.tblSCTicket T WITH(NOLOCK) 		
	WHERE T.intTicketId = @intInvoiceId
	
	RETURN @strReferences
END