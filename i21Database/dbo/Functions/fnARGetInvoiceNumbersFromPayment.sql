CREATE FUNCTION [dbo].[fnARGetInvoiceNumbersFromPayment]
(
	@intPaymentId INT
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @strInvoiceNumbers NVARCHAR(MAX) = NULL

	SELECT @strInvoiceNumbers = COALESCE(@strInvoiceNumbers + ', ', '') + RTRIM(LTRIM(I.strInvoiceNumber)) 
	FROM dbo.tblARPaymentDetail P WITH(NOLOCK) 
		INNER JOIN (SELECT intInvoiceId
						 , strInvoiceNumber
					FROM dbo.tblARInvoice WITH (NOLOCK)
		) I ON I.intInvoiceId = P.intInvoiceId	
	WHERE P.intPaymentId = @intPaymentId

	RETURN @strInvoiceNumbers
END