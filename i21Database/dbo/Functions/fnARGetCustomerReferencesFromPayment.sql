CREATE FUNCTION [dbo].[fnARGetCustomerReferencesFromPayment]
(
	@intPaymentId INT
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @strReferences NVARCHAR(MAX) = NULL

	SELECT @strReferences = COALESCE(@strReferences + ', ', '') + RTRIM(LTRIM(T.strCustomerReference)) 
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
		INNER JOIN (SELECT intTicketId
						 , strCustomerReference
					FROM dbo.tblSCTicket WITH (NOLOCK)
		) T ON PD.intInvoiceId = T.intTicketId
	WHERE PD.intPaymentId = @intPaymentId AND PD.intInvoiceId IS NOT NULL

	RETURN @strReferences
END
