CREATE FUNCTION [dbo].[fnARGetCustomerReferencesFromInvoice]
(
	@intInvoiceId INT
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @strReferences NVARCHAR(MAX) = NULL

	SELECT @strReferences = COALESCE(@strReferences + ', ', '') + RTRIM(LTRIM(T.strCustomerReference))
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
		INNER JOIN (SELECT intTicketId
						 , strCustomerReference 
					FROM dbo.tblSCTicket WITH(NOLOCK)
		) T ON ID.intTicketId = T.intTicketId
	GROUP BY intInvoiceId, ID.intTicketId, T.strCustomerReference
	HAVING ID.intInvoiceId = @intInvoiceId
	
	RETURN @strReferences
END