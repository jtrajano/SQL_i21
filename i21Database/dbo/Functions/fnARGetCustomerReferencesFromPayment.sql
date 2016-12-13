﻿CREATE FUNCTION [dbo].[fnARGetCustomerReferencesFromPayment]
(
	@intPaymentId INT
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @strReferences NVARCHAR(MAX) = NULL

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
					SELECT @strReferences = ISNULL(@strReferences, '') + dbo.fnARGetCustomerReferencesFromInvoice(@intInvoiceId) + ', '
				ELSE
					SELECT @strReferences = ISNULL(@strReferences, '') + dbo.fnARGetCustomerReferencesFromInvoice(@intInvoiceId)

				DELETE FROM @tmpTable WHERE intInvoiceId = @intInvoiceId
			END
		END

	RETURN @strReferences
END
