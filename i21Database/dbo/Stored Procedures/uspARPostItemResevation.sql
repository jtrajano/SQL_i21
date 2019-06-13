﻿CREATE PROCEDURE [dbo].[uspARPostItemResevation]
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
	ICSR.[ysnPosted] <> ARID.[ysnPost]
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
    ICSR.[ysnPosted] <> ARID.[ysnPost]


WHILE EXISTS(SELECT NULL FROM @InvoiceIds)
BEGIN
    DECLARE @InvoiceId INT, @Post BIT
    SELECT TOP 1 @InvoiceId = [intHeaderId], @Post = [ysnPost] FROM @InvoiceIds

    EXEC    [dbo].[uspICPostStockReservation]
                 @intTransactionId		= @InvoiceId
                ,@intTransactionTypeId	= @TransactionTypeId
                ,@ysnPosted				= @Post

    DELETE FROM @InvoiceIds WHERE [intHeaderId] = @InvoiceId
END

DELETE FROM @InvoiceIds
INSERT INTO @InvoiceIds
    ([intHeaderId]
    ,[ysnPost])
SELECT DISTINCT
     [intHeaderId]  = SO.[intSalesOrderId]
	,[ysnPost]      = ARID.[ysnPost]
FROM
    #ARPostInvoiceDetail ARID
INNER JOIN
    tblSOSalesOrderDetail SOD
		ON ARID.[intSalesOrderDetailId] = SOD.[intSalesOrderDetailId]
		AND ARID.[intInventoryShipmentItemId] IS NULL
INNER JOIN
	tblSOSalesOrder SO
		ON SOD.[intSalesOrderId] = SO.[intSalesOrderId]
INNER JOIN
	tblMFPickList PL
		ON SO.[intSalesOrderId] = PL.[intSalesOrderId]


WHILE EXISTS(SELECT NULL FROM @InvoiceIds)
BEGIN
    DECLARE @OrderId INT, @PostPL BIT
    SELECT TOP 1 @OrderId = [intHeaderId], @PostPL = [ysnPost] FROM @InvoiceIds

    EXEC    [dbo].[uspMFUnReservePickListBySalesOrder]
                 @intSalesOrderId = @OrderId
				 --,@ysnPosted	  = @PostPL

    DELETE FROM @InvoiceIds WHERE [intHeaderId] = @OrderId
END

RETURN 0
