﻿CREATE PROCEDURE [dbo].[uspARUpdatePrepaidForInvoice]  
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
		
	UPDATE
		tblARInvoice
	SET
		[dblPayment] = @ZeroDecimal
	WHERE
		[intInvoiceId] = @InvoiceId 
		
	EXEC [dbo].uspARReComputeInvoiceAmounts @InvoiceId = @InvoiceId
END TRY
BEGIN CATCH	
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()	
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber) 	
END CATCH		
		
--BEGIN TRY	
--	UPDATE
--		tblARPrepaidAndCredit
--	SET
--		 tblARPrepaidAndCredit.[intInvoiceId]					= ARPAC.[intInvoiceId]
--		,tblARPrepaidAndCredit.[intInvoiceDetailId]				= ARPAC.[intInvoiceDetailId]
--		,tblARPrepaidAndCredit.[intPrepaymentId]				= ARPAC.[intPrepaymentId]
--		,tblARPrepaidAndCredit.[intPrepaymentDetailId]			= ARPAC.[intPrepaymentDetailId]
--		,tblARPrepaidAndCredit.[dblPostedAmount]				= @ZeroDecimal
--		,tblARPrepaidAndCredit.[dblPostedDetailAmount]			= @ZeroDecimal
--		,tblARPrepaidAndCredit.[dblAppliedInvoiceAmount]		= @ZeroDecimal
--		,tblARPrepaidAndCredit.[dblAppliedInvoiceDetailAmount]	= @ZeroDecimal
--		,tblARPrepaidAndCredit.[ysnApplied]						= 0
--		,tblARPrepaidAndCredit.[ysnPosted]						= 0
--		,tblARPrepaidAndCredit.[intConcurrencyId]				= tblARPrepaidAndCredit.[intConcurrencyId] + 1
--	FROM
--		vyuARPrepaidAndCredit ARPAC
--	INNER JOIN
--		tblARInvoice ARI
--		ON ARPAC.[intInvoiceId] = ARI.[intInvoiceId] 
--		AND ARI.ysnPosted = 0
--	WHERE
--		tblARPrepaidAndCredit.[intPrepaidAndCreditId] = ARPAC.[intPrepaidAndCreditId]
--		AND tblARPrepaidAndCredit.[intInvoiceId] = @InvoiceId
--END TRY
--BEGIN CATCH	
--	SET @ErrorSeverity = ERROR_SEVERITY()
--	SET @ErrorNumber   = ERROR_NUMBER()
--	SET @ErrorMessage  = ERROR_MESSAGE()
--	SET @ErrorState    = ERROR_STATE()	
--	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber) 	
--END CATCH



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
		,[intRowNumber]
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
		,[intRowNumber]						= ROW_NUMBER() OVER (PARTITION BY [intPrepaymentId] ORDER BY [intInvoiceDetailId])
		,[intConcurrencyId]					= 1
	FROM
		vyuARPrepaidAndCredit ARPAC
	WHERE
		ARPAC.[dblInvoiceDetailBalance] <> 0
		AND ISNULL(ARPAC.[intInvoiceId],0) <> @InvoiceId
		AND ARPAC.[intEntityCustomerId] = @EntityCustomerId
		AND ARPAC.[dblInvoiceBalance] <> 0
		AND NOT EXISTS(SELECT NULL FROM vyuARPrepaidAndCredit WHERE vyuARPrepaidAndCredit.[intEntityCustomerId] =  ARPAC.[intEntityCustomerId] AND vyuARPrepaidAndCredit.[intPrepaymentId] =  ARPAC.[intPrepaymentId] AND vyuARPrepaidAndCredit.[intInvoiceId] = @InvoiceId)
		AND (ISNULL(ARPAC.[ysnRestricted],0) = 0
			OR
			(ISNULL(ARPAC.[ysnRestricted],0) = 1 AND EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID WHERE ARID.[intContractDetailId] = ARPAC.[intContractDetailId] AND ARID.[intInvoiceId] = @InvoiceId))
			)
		

END TRY
BEGIN CATCH	
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()	
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber) 	
END CATCH


GO