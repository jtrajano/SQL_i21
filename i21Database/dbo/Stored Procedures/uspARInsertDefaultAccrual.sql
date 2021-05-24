CREATE PROCEDURE [dbo].[uspARInsertDefaultAccrual]
AS

DECLARE @Accruals AS Id

INSERT INTO @Accruals
SELECT DISTINCT
    A.[intInvoiceId]
FROM
    ##ARPostInvoiceHeader A
WHERE
    A.[ysnPost] = 1
	AND A.[intPeriodsToAccrue] > 1
    AND NOT EXISTS(SELECT NULL FROM tblARInvoiceAccrual ARIA WHERE ARIA.[intInvoiceId] = A.[intInvoiceId])

WHILE EXISTS(SELECT NULL FROM @Accruals)
BEGIN
    DECLARE @InvoiceId AS INT
    SELECT TOP 1 @InvoiceId = [intId] FROM @Accruals
    EXEC dbo.uspARUpdateInvoiceAccruals @intInvoiceId = @InvoiceId
    DELETE FROM @Accruals WHERE [intId] = @InvoiceId
END

GO