--liquibase formatted sql

-- changeset Von:fnARGetScaleTicketNumbersFromPayment.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnARGetScaleTicketNumbersFromPayment]
(
	@intPaymentId INT
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @strTicketNumbers NVARCHAR(MAX) = NULL

	DECLARE @tmpTable TABLE(intInvoiceId INT)
	INSERT INTO @tmpTable
	SELECT intInvoiceId FROM tblARPaymentDetail WHERE intPaymentId = @intPaymentId AND intInvoiceId IS NOT NULL
	
	IF EXISTS(SELECT NULL FROM @tmpTable)
		BEGIN
			WHILE EXISTS(SELECT TOP 1 NULL FROM @tmpTable)
			BEGIN
				DECLARE @intInvoiceId INT
				
				SELECT TOP 1 @intInvoiceId = intInvoiceId FROM @tmpTable ORDER BY intInvoiceId
				
				IF (SELECT COUNT(*) FROM @tmpTable) > 1
					SELECT @strTicketNumbers = ISNULL(@strTicketNumbers, '') + dbo.fnARGetScaleTicketNumbersFromInvoice(@intInvoiceId) + ', '
				ELSE
					SELECT @strTicketNumbers = ISNULL(@strTicketNumbers, '') + dbo.fnARGetScaleTicketNumbersFromInvoice(@intInvoiceId)

				DELETE FROM @tmpTable WHERE intInvoiceId = @intInvoiceId
			END
		END

	RETURN @strTicketNumbers
END



