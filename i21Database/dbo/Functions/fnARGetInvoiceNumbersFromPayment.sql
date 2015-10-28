CREATE FUNCTION [dbo].[fnARGetInvoiceNumbersFromPayment]
(
	@intPaymentId INT
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @strInvoiceNumbers NVARCHAR(MAX) = NULL

	DECLARE @tmpTable TABLE(intInvoiceId INT)
	INSERT INTO @tmpTable
	SELECT intInvoiceId FROM tblARPaymentDetail WHERE intPaymentId = @intPaymentId
	
	IF EXISTS(SELECT NULL FROM @tmpTable)
		BEGIN
			WHILE EXISTS(SELECT TOP 1 NULL FROM @tmpTable)
			BEGIN
				DECLARE @intInvoiceId INT
				
				SELECT TOP 1 @intInvoiceId = intInvoiceId FROM @tmpTable ORDER BY intInvoiceId
				
				IF (SELECT COUNT(*) FROM @tmpTable) > 1
					SELECT @strInvoiceNumbers = ISNULL(@strInvoiceNumbers, '') + strInvoiceNumber + ', ' FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId
				ELSE
					SELECT @strInvoiceNumbers = ISNULL(@strInvoiceNumbers, '') + strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId

				DELETE FROM @tmpTable WHERE intInvoiceId = @intInvoiceId
			END
		END

	RETURN @strInvoiceNumbers
END