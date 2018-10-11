CREATE PROCEDURE [dbo].[uspARPostItemResevation]
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE @InvoiceIds AS [InvoiceId]
DECLARE @TransactionTypeId AS INT = 33
SELECT @TransactionTypeId = [intTransactionTypeId] FROM dbo.tblICInventoryTransactionType WHERE [strName] = 'Invoice'

INSERT INTO @InvoiceIds
    ([intHeaderId]
    ,[ysnPost])
SELECT
     [intHeaderId]  = ARID.[intInvoiceId]
    ,[ysnPost]      = ARID.[ysnPost]
FROM
    #ARPostInvoiceDetail ARID
INNER JOIN
    tblICStockReservation ICSR
		ON ARID.[intInvoiceId] = ICSR.[intTransactionId] 
        AND ARID.[strInvoiceNumber] = ICSR.[strTransactionId]
        AND ARID.[intItemId] = ICSR.[intItemId]
WHERE
	ICSR.[ysnPosted] = 0
UNION
SELECT
    [intHeaderId]  = ARID.[intInvoiceId]
    ,[ysnPost]      = ARID.[ysnPost] 
FROM
    #ARPostInvoiceDetail ARID
JOIN tblICItemBundle BDL
    ON BDL.intItemId = ARID.intItemId
INNER JOIN
    tblICStockReservation ICSR
        ON ARID.[intInvoiceId] = ICSR.[intTransactionId] 
        AND ARID.[strInvoiceNumber] = ICSR.[strTransactionId]
        AND BDL.[intBundleItemId] = ICSR.[intItemId]
WHERE
    ICSR.[ysnPosted] = 0


WHILE EXISTS(SELECT NULL FROM @InvoiceIds)
BEGIN
    DECLARE @InvoiceId INT
    SELECT TOP 1 @InvoiceId = [intHeaderId] FROM @InvoiceIds

    EXEC    [dbo].[uspICPostStockReservation]
                 @intTransactionId		= @InvoiceId
                ,@intTransactionTypeId	= @TransactionTypeId
                ,@ysnPosted				= 1

    DELETE FROM @InvoiceIds WHERE [intHeaderId] = @InvoiceId
END

RETURN 0
