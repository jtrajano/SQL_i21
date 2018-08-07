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


DECLARE @AppliedInvoices TABLE(
	intPrepaymentId INT,
	intInvoiceId INT,
	dblAppliedInvoiceDetailAmount NUMERIC(18, 6)
)		
BEGIN TRY

	INSERT INTO @AppliedInvoices(intPrepaymentId, intInvoiceId, dblAppliedInvoiceDetailAmount)
	SELECT intPrepaymentId, intInvoiceId, dblAppliedInvoiceDetailAmount FROM
		tblARPrepaidAndCredit
	WHERE
		tblARPrepaidAndCredit.[intInvoiceId] = @InvoiceId 
			and ysnApplied = 1 
			and ysnPosted = 0
		
	DELETE FROM
		tblARPrepaidAndCredit
	WHERE
		tblARPrepaidAndCredit.[intInvoiceId] = @InvoiceId
		
	/*UPDATE
		tblARInvoice
	SET
		 [dblPayment] = @ZeroDecimal
		,[dblBasePayment] = @ZeroDecimal
	WHERE
		[intInvoiceId] = @InvoiceId 
	*/	
	--EXEC [dbo].uspARReComputeInvoiceAmounts @InvoiceId = @InvoiceId
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

	DECLARE @RestrictedItems TABLE(intItemId INT)	

	INSERT INTO @RestrictedItems(intItemId)
	SELECT ID.intItemId FROM dbo.tblARInvoice I WITH (NOLOCK)
	INNER JOIN (
		SELECT * FROM dbo.tblARInvoiceDetail
	)ID ON ID.intInvoiceId = I.intInvoiceId
	INNER JOIN(
		SELECT ID.intItemId FROM dbo.tblARInvoice I WITH (NOLOCK)
		INNER JOIN(
			SELECT * FROM dbo.tblARInvoiceDetail 
		)ID ON ID.intInvoiceId = I.intInvoiceId
		INNER JOIN (
			SELECT intPaymentId 
			FROM dbo.tblARPayment WITH (NOLOCK)
			WHERE ysnPosted = 1
		) AS P ON I.intPaymentId = P.intPaymentId
		WHERE I.strTransactionType = 'Customer Prepayment'
		AND I.intInvoiceId <> @InvoiceId
		AND I.intEntityCustomerId = @EntityCustomerId
		AND ID.intItemId IS NOT NULL
		AND ID.ysnRestricted = 1
	) RESTRICTEDITEM ON RESTRICTEDITEM.intItemId = ID.intItemId
	WHERE I.intInvoiceId  = @InvoiceId
	AND I.intEntityCustomerId = @EntityCustomerId
	AND ID.intItemId IS NOT NULL

	INSERT INTO tblARPrepaidAndCredit
		([intInvoiceId]
		,[intInvoiceDetailId]
		,[intPrepaymentId]
		,[intPrepaymentDetailId]
		,[dblPostedAmount]
		,[dblBasePostedAmount]
		,[dblPostedDetailAmount]
		,[dblBasePostedDetailAmount]
		,[dblAppliedInvoiceAmount]
		,[dblBaseAppliedInvoiceAmount]
		,[dblAppliedInvoiceDetailAmount]
		,[dblBaseAppliedInvoiceDetailAmount]
		,[ysnApplied]
		,[ysnPosted]
		,[intRowNumber]
		,[intConcurrencyId])
	SELECT DISTINCT
		  intInvoiceId						= @InvoiceId
		, intInvoiceDetailId				= NULL
		, intPrepaymentId					= I.intInvoiceId
		, intPrepaymentDetailId				= I.intInvoiceDetailId
		, dblPostedAmount					= @ZeroDecimal
		, dblBasePostedAmount				= @ZeroDecimal
		, dblPostedDetailAmount				= @ZeroDecimal
		, dblBasePostedDetailAmount			= @ZeroDecimal
		, dblAppliedInvoiceAmount			= @ZeroDecimal
		, dblBaseAppliedInvoiceAmount		= @ZeroDecimal
		, dblAppliedInvoiceDetailAmount		= @ZeroDecimal
		, dblBaseAppliedInvoiceDetailAmount	= @ZeroDecimal
		, ysnApplied						= 0
		, ysnPosted							= 0
		, intRowNumber						= ROW_NUMBER() OVER(ORDER BY I.intInvoiceId ASC)
		, intConcurrencyId					= 1
	FROM (
		SELECT I.intInvoiceId
			 , DETAILS.intInvoiceDetailId
		FROM dbo.tblARInvoice I WITH (NOLOCK)
		INNER JOIN (
			SELECT intPaymentId 
			FROM dbo.tblARPayment WITH (NOLOCK)
			WHERE ysnPosted = 1
		) AS P ON I.intPaymentId = P.intPaymentId
		INNER JOIN (
			SELECT intInvoiceDetailId, intItemId, intInvoiceId 
			FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
			WHERE (ID.ysnRestricted = 0 OR (ID.ysnRestricted = 1 AND ID.intContractDetailId = @intContractDetailId) OR (ID.intContractDetailId IS NULL AND ID.intItemId = @intItemId)
				OR(ID.ysnRestricted = 1 AND ID.intItemId IN (SELECT * FROM @RestrictedItems))
			)
		) AS DETAILS ON DETAILS.intInvoiceId = I.intInvoiceId
		WHERE I.strTransactionType = 'Customer Prepayment'
			AND I.ysnPosted = 1
			AND I.ysnPaid = 0
			AND I.intEntityCustomerId = @EntityCustomerId
			AND I.intInvoiceId <> @InvoiceId

		UNION ALL

		SELECT I.intInvoiceId
			 , intInvoiceDetailId = NULL		 
		FROM dbo.tblARInvoice I WITH (NOLOCK)
		WHERE I.strTransactionType = 'Credit Memo'
		  AND I.ysnPosted = 1
		  AND I.ysnPaid = 0
		  AND I.intEntityCustomerId = @EntityCustomerId
		  AND I.intInvoiceId <> @InvoiceId
	) I

	UPDATE A SET ysnApplied = 1, dblAppliedInvoiceDetailAmount = B.dblAppliedInvoiceDetailAmount
		FROM tblARPrepaidAndCredit A
			JOIN @AppliedInvoices B
				ON A.intPrepaymentId = B.intPrepaymentId
					AND A.intInvoiceId = B.intInvoiceId
		
END TRY
BEGIN CATCH	
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()	
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber) 	
END CATCH

GO