CREATE PROCEDURE [dbo].[uspARUpdatePrepaidForInvoice]  
	 @InvoiceId		INT	
	,@UserId		INT
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  


DECLARE @EntityCustomerId	INT
		,@Posted				BIT
		,@ZeroDecimal		NUMERIC(18, 6)
SELECT
	 @EntityCustomerId	= [intEntityCustomerId]
	,@Posted			= [ysnPosted]
FROM
	tblARInvoice
WHERE
	[intInvoiceId] = @InvoiceId

IF 	@Posted = 1 RETURN;

SET @ZeroDecimal = 0.000000

DECLARE @ErrorSeverity	INT
		,@ErrorNumber	INT
		,@ErrorState	INT
		,@ErrorMessage	NVARCHAR(MAX)
		
BEGIN TRY	
	DELETE FROM
		tblARPrepaidAndCredit
	WHERE
		tblARPrepaidAndCredit.[intInvoiceId] = @InvoiceId
		AND (NOT EXISTS(SELECT NULL FROM vyuARPrepaidAndCredit WHERE vyuARPrepaidAndCredit.[intPrepaymentId] = tblARPrepaidAndCredit.[intPrepaymentId])
			OR
			NOT EXISTS(SELECT NULL FROM vyuARPrepaidAndCredit WHERE vyuARPrepaidAndCredit.[intPrepaymentDetailId] = tblARPrepaidAndCredit.[intPrepaymentDetailId]))
END TRY
BEGIN CATCH	
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()	
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber) 	
END CATCH		
		
BEGIN TRY	
	UPDATE
		tblARPrepaidAndCredit
	SET
		 tblARPrepaidAndCredit.[intInvoiceId]					= ARPAC.[intInvoiceId]
		,tblARPrepaidAndCredit.[intInvoiceDetailId]				= ARPAC.[intInvoiceDetailId]
		,tblARPrepaidAndCredit.[intPrepaymentId]				= ARPAC.[intPrepaymentId]
		,tblARPrepaidAndCredit.[intPrepaymentDetailId]			= ARPAC.[intPrepaymentDetailId]
		,tblARPrepaidAndCredit.[dblPostedAmount]				= @ZeroDecimal
		,tblARPrepaidAndCredit.[dblPostedDetailAmount]			= @ZeroDecimal
		,tblARPrepaidAndCredit.[dblAppliedInvoiceAmount]		= @ZeroDecimal
		,tblARPrepaidAndCredit.[dblAppliedInvoiceDetailAmount]	= @ZeroDecimal
		,tblARPrepaidAndCredit.[ysnApplied]						= 0
		,tblARPrepaidAndCredit.[ysnPosted]						= 0
		,tblARPrepaidAndCredit.[intConcurrencyId]				= tblARPrepaidAndCredit.[intConcurrencyId] + 1
	FROM
		vyuARPrepaidAndCredit ARPAC
	INNER JOIN
		tblARInvoice ARI
		ON ARPAC.[intInvoiceId] = ARI.[intInvoiceId] 
		AND ARI.ysnPosted = 0
	WHERE
		tblARPrepaidAndCredit.[intPrepaidAndCreditId] = ARPAC.[intPrepaidAndCreditId]
		AND tblARPrepaidAndCredit.[intInvoiceId] = @InvoiceId
END TRY
BEGIN CATCH	
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()	
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber) 	
END CATCH



BEGIN TRY	
	INSERT INTO tblARPrepaidAndCredit
		([intInvoiceId]
		,[intInvoiceDetailId]
		,[intPrepaymentId]
		,[intPrepaymentDetailId]
		,[dblPostedAmount]
		,[dblPostedDetailAmount]
		,[dblAppliedInvoiceAmount]
		,[dblAppliedInvoiceDetailAmount]
		,[ysnApplied]
		,[ysnPosted]
		,[intConcurrencyId])
	SELECT DISTINCT
		 [intInvoiceId]						= @InvoiceId
		,[intInvoiceDetailId]				= NULL
		,[intPrepaymentId]					= ARPAC.[intPrepaymentId]
		,[intPrepaymentDetailId]			= ARPAC.[intPrepaymentDetailId]
		,[dblPostedAmount]					= @ZeroDecimal
		,[dblPostedDetailAmount]			= @ZeroDecimal
		,[dblAppliedInvoiceAmount]			= @ZeroDecimal
		,[dblAppliedInvoiceDetailAmount]	= @ZeroDecimal
		,[ysnApplied]						= 0
		,[ysnPosted]						= 0
		,[intConcurrencyId]					= 1
	FROM
		vyuARPrepaidAndCredit ARPAC
	WHERE
		ARPAC.[dblInvoiceBalance] <> 0
		AND ISNULL(ARPAC.[intInvoiceId],0) <> @InvoiceId
		AND ARPAC.[intEntityCustomerId] = @EntityCustomerId
		AND ARPAC.[dblInvoiceBalance] <> 0
		AND NOT EXISTS(SELECT NULL FROM vyuARPrepaidAndCredit WHERE vyuARPrepaidAndCredit.[intEntityCustomerId] =  ARPAC.[intEntityCustomerId] AND vyuARPrepaidAndCredit.[intPrepaymentId] =  ARPAC.[intPrepaymentId] AND vyuARPrepaidAndCredit.[intInvoiceId] = @InvoiceId)
		

END TRY
BEGIN CATCH	
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()	
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber) 	
END CATCH


GO