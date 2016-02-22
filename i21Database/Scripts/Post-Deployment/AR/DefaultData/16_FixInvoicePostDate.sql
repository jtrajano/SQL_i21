print('/*******************  BEGIN Update tblARInvoice.dtmDate, dtmPostDate, dtmDueDate, dtmShipDate  *******************/')
GO

BEGIN TRANSACTION

UPDATE ARI
	SET ARI.[dtmPostDate] = ISNULL((SELECT TOP 1 CAST([dtmDate] AS DATE) FROM tblGLDetail WHERE [strTransactionId] = ARI.[strInvoiceNumber] AND [intTransactionId] = ARI.[intInvoiceId]  AND [ysnIsUnposted] = 0),ARI.dtmDate)
FROM
	tblARInvoice ARI
WHERE
	ARI.[ysnPosted] = 1

IF @@ERROR <> 0 GOTO GOTO_ERROR	
	
COMMIT TRANSACTION
GOTO GOTO_EXIT

GOTO_ERROR:
ROLLBACK TRANSACTION

GOTO_EXIT:

GO
print('/*******************  END Update tblARInvoice.dtmDate, dtmPostDate, dtmDueDate, dtmShipDate  *******************/')