CREATE FUNCTION [dbo].[fnARGetScaleTicketNumbersFromPayment]
(
	@intPaymentId INT
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @strTicketNumbers NVARCHAR(MAX) = NULL

	SELECT @strTicketNumbers = COALESCE(@strTicketNumbers + ', ', '') + RTRIM(LTRIM(T.strTicketNumber)) 
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
		INNER JOIN (SELECT intTicketId
							, strTicketNumber
					FROM dbo.tblSCTicket WITH (NOLOCK)
		) T ON PD.intInvoiceId = T.intTicketId
	WHERE PD.intPaymentId = @intPaymentId AND PD.intInvoiceId IS NOT NULL
		
	RETURN @strTicketNumbers
END