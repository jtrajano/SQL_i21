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
		
BEGIN TRY
	DECLARE @intContractDetailId	INT = 0
		  , @intItemId				INT = 0

	SELECT TOP 1 @intContractDetailId = intContractDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @InvoiceId AND ysnRestricted = 1 AND intContractDetailId IS NOT NULL
	SELECT TOP 1 @intItemId = intItemId FROM tblARInvoiceDetail WHERE intInvoiceId = @InvoiceId AND ysnRestricted = 1 AND intContractDetailId IS NULL

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
		,[intPrepaymentId]					= I.intInvoiceId
		,[intPrepaymentDetailId]			= ID.intInvoiceDetailId
		,[dblPostedAmount]					= @ZeroDecimal
		,[dblPostedDetailAmount]			= @ZeroDecimal
		,[dblAppliedInvoiceAmount]			= @ZeroDecimal
		,[dblAppliedInvoiceDetailAmount]	= @ZeroDecimal
		,[ysnApplied]						= 0
		,[ysnPosted]						= 0
		,[intRowNumber]						= ROW_NUMBER() OVER(ORDER BY I.intInvoiceId ASC)
		,[intConcurrencyId]					= 1
	FROM tblARInvoice I
	CROSS APPLY (SELECT TOP 1 intInvoiceDetailId FROM tblARInvoiceDetail ID
					WHERE ID.intInvoiceId = I.intInvoiceId 
					 AND (ID.ysnRestricted = 0 OR (ID.ysnRestricted = 1 AND ID.intContractDetailId = @intContractDetailId) OR (ID.intContractDetailId IS NULL AND ID.intItemId = @intItemId))
			) AS ID 
	WHERE I.strTransactionType IN ('Customer Prepayment', 'Credit Memo')
	  AND I.ysnPosted = 1
	  AND I.ysnPaid = 0
	  AND I.intEntityCustomerId = @EntityCustomerId
	  AND I.intInvoiceId <> @InvoiceId

END TRY
BEGIN CATCH	
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()	
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber) 	
END CATCH

GO