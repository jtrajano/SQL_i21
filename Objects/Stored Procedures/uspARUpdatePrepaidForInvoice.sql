CREATE PROCEDURE [dbo].[uspARUpdatePrepaidForInvoice]  
	  @InvoiceId	INT	
	, @UserId		INT
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

DECLARE @intEntityCustomerId	INT	= NULL
	  , @intErrorSeverity		INT = NULL
	  , @intErrorNumber			INT = NULL
	  , @intErrorState			INT = NULL
	  , @ysnPosted				BIT	= 0
	  , @strErrorMessage		NVARCHAR(MAX)
	  , @ZeroDecimal			NUMERIC(18, 6)	= 0

SELECT @intEntityCustomerId	= intEntityCustomerId
	 , @ysnPosted			= ysnPosted
FROM tblARInvoice
WHERE intInvoiceId = @InvoiceId

IF @ysnPosted = 1 RETURN;

IF(OBJECT_ID('tempdb..#APPLIEDINVOICES') IS NOT NULL)
BEGIN
	DROP TABLE #APPLIEDINVOICES
END

IF(OBJECT_ID('tempdb..#OPENCREDITMEMO') IS NOT NULL)
BEGIN
	DROP TABLE #OPENCREDITMEMO
END

IF(OBJECT_ID('tempdb..#OPENPREPAIDS') IS NOT NULL)
BEGIN
	DROP TABLE #OPENPREPAIDS
END

IF(OBJECT_ID('tempdb..#UNRESTRICTED') IS NOT NULL)
BEGIN
	DROP TABLE #UNRESTRICTED
END

IF(OBJECT_ID('tempdb..#RESTRICTEDITEMS') IS NOT NULL)
BEGIN
	DROP TABLE #RESTRICTEDITEMS
END

IF(OBJECT_ID('tempdb..#RESTRICTEDCONTRACTS') IS NOT NULL)
BEGIN
	DROP TABLE #RESTRICTEDCONTRACTS
END

IF(OBJECT_ID('tempdb..#ITEMCONTRACTS') IS NOT NULL)
BEGIN
	DROP TABLE #ITEMCONTRACTS
END

IF(OBJECT_ID('tempdb..#ITEMCATEGORY') IS NOT NULL)
BEGIN
	DROP TABLE #ITEMCATEGORY
END

IF(OBJECT_ID('tempdb..#APPLIEDCONTRACTS') IS NOT NULL)
BEGIN
	DROP TABLE #APPLIEDCONTRACTS
END

IF(OBJECT_ID('tempdb..#APPLIEDITEMCONTRACTS') IS NOT NULL)
BEGIN
	DROP TABLE #APPLIEDITEMCONTRACTS
END

BEGIN TRY
	--GET APPLIED INVOICES
	SELECT intPrepaymentId
         , intPrepaymentDetailId
		 , intInvoiceId
		 , dblAppliedInvoiceDetailAmount
		 , dblBaseAppliedInvoiceDetailAmount
	INTO #APPLIEDINVOICES 
	FROM tblARPrepaidAndCredit
	WHERE intInvoiceId = @InvoiceId 
	  AND ysnApplied = 1 
	  AND ysnPosted = 0
		
	DELETE FROM tblARPrepaidAndCredit WHERE intInvoiceId = @InvoiceId

	--GET OPEN CREDIT MEMO AND OVERPAYMENTS
	SELECT intInvoiceId
	INTO #OPENCREDITMEMO
	FROM tblARInvoice
	WHERE ysnPosted = 1
	  AND ysnPaid = 0
	  AND strTransactionType IN ('Credit Memo', 'Overpayment')
	  AND intEntityCustomerId = @intEntityCustomerId
	  AND dblAmountDue > 0
	  AND intInvoiceId <> @InvoiceId

	--GET OPEN PREPAIDS
	SELECT intInvoiceId			= OP.intInvoiceId
		 , strContractApplyTo	= ISNULL(OP.strContractApplyTo, 'Any')
		 , ysnFromItemContract	= ISNULL(OP.ysnFromItemContract, 0)
	INTO #OPENPREPAIDS
	FROM tblARInvoice OP
	INNER JOIN tblARPayment PAYMENT ON OP.intPaymentId = PAYMENT.intPaymentId
	WHERE OP.ysnPosted = 1
	  AND PAYMENT.ysnPosted = 1
	  AND PAYMENT.ysnProcessedToNSF = 0
	  AND OP.ysnPaid = 0
	  AND OP.strTransactionType = 'Customer Prepayment'
	  AND OP.intEntityCustomerId = @intEntityCustomerId
	  AND OP.dblAmountDue > 0
	  AND OP.intInvoiceId <> @InvoiceId

	--GET UN-RESTRICTED PREPAIDS
	SELECT intInvoiceId			= OP.intInvoiceId
		 , intInvoiceDetailId	= OPD.intInvoiceDetailId
	INTO #UNRESTRICTED
	FROM #OPENPREPAIDS OP
	INNER JOIN tblARInvoiceDetail OPD ON OP.intInvoiceId = OPD.intInvoiceId
	WHERE OPD.ysnRestricted = 0
	  AND OP.ysnFromItemContract = 0
	
	--GET RESTRICTED ITEMS
	SELECT intInvoiceId			= OP.intInvoiceId
		 , intInvoiceDetailId	= OPD.intInvoiceDetailId
		 , intItemId			= OPD.intItemId
	INTO #RESTRICTEDITEMS
	FROM #OPENPREPAIDS OP
	INNER JOIN tblARInvoiceDetail OPD ON OP.intInvoiceId = OPD.intInvoiceId
	WHERE OPD.ysnRestricted = 1
	  AND OPD.intContractDetailId IS NULL
	  AND OPD.intItemContractDetailId IS NULL
	  AND OPD.intItemCategoryId IS NULL
	  AND OP.ysnFromItemContract = 0

	--GET RESTRICTED CONTRACTS
	SELECT intInvoiceId			= OP.intInvoiceId
		 , intInvoiceDetailId	= OPD.intInvoiceDetailId
		 , intContractDetailId	= OPD.intContractDetailId
	INTO #RESTRICTEDCONTRACTS
	FROM #OPENPREPAIDS OP
	INNER JOIN tblARInvoiceDetail OPD ON OP.intInvoiceId = OPD.intInvoiceId
	WHERE OPD.ysnRestricted = 1
	  AND OPD.intContractDetailId IS NOT NULL
	  AND OPD.intItemContractDetailId IS NULL
	  AND OPD.intItemCategoryId IS NULL

	--GET ITEM CONTRACTS
	SELECT intInvoiceId				= OP.intInvoiceId
		 , intInvoiceDetailId		= OPD.intInvoiceDetailId
		 , intItemContractDetailId	= OPD.intItemContractDetailId
		 , intItemId				= OPD.intItemId
		 , ysnRestricted			= ISNULL(OPD.ysnRestricted, 0)
		 , strContractApplyTo		= OP.strContractApplyTo
	INTO #ITEMCONTRACTS
	FROM #OPENPREPAIDS OP
	INNER JOIN tblARInvoiceDetail OPD ON OP.intInvoiceId = OPD.intInvoiceId
	WHERE OPD.intContractDetailId IS NULL
	  AND OPD.intItemCategoryId IS NULL
	  AND OPD.intItemContractDetailId IS NOT NULL

	--GET ITEM CATEGORY
	SELECT intInvoiceId				= OP.intInvoiceId
		 , intInvoiceDetailId		= OPD.intInvoiceDetailId
		 , intItemCategoryId		= OPD.intItemCategoryId
		 , intCategoryId			= OPD.intCategoryId
		 , intItemContractHeaderId	= OPD.intItemContractHeaderId
		 , ysnRestricted			= ISNULL(OPD.ysnRestricted, 0)
		 , strContractApplyTo		= OP.strContractApplyTo
	INTO #ITEMCATEGORY
	FROM #OPENPREPAIDS OP
	INNER JOIN tblARInvoiceDetail OPD ON OP.intInvoiceId = OPD.intInvoiceId
	WHERE OPD.intContractDetailId IS NULL
	  AND OPD.intItemCategoryId IS NOT NULL
	  AND OPD.intItemContractHeaderId IS NOT NULL
	  AND OPD.intItemCategoryId IS NOT NULL
	  AND OPD.intCategoryId IS NOT NULL

	--GET APPLIED CONTRACTS
	SELECT ID.intContractDetailId
		 , ID.intInvoiceDetailId
		 , ID.intInvoiceId
	INTO #APPLIEDCONTRACTS
	FROM tblARPrepaidAndCredit PC
	INNER JOIN tblARInvoice I ON PC.intInvoiceId = I.intInvoiceId
	INNER JOIN tblARInvoiceDetail ID ON PC.intPrepaymentDetailId = ID.intInvoiceDetailId
	WHERE ID.intContractHeaderId IS NOT NULL
	  AND ID.intContractDetailId IS NOT NULL
	  AND I.intEntityCustomerId = @intEntityCustomerId
	  AND PC.ysnApplied = 1
	  AND I.intInvoiceId <> @InvoiceId

	--GET APPLIED ITEM CONTRACTS
	SELECT ID.intItemContractDetailId
		 , ID.intInvoiceDetailId
		 , ID.intInvoiceId
	INTO #APPLIEDITEMCONTRACTS
	FROM tblARPrepaidAndCredit PC
	INNER JOIN tblARInvoice I ON PC.intInvoiceId = I.intInvoiceId
	INNER JOIN tblARInvoiceDetail ID ON PC.intPrepaymentDetailId = ID.intInvoiceDetailId
	WHERE ID.intItemContractHeaderId IS NOT NULL
	  AND ID.intItemContractDetailId IS NOT NULL
	  AND I.intEntityCustomerId = @intEntityCustomerId
	  AND PC.ysnApplied = 1
	  AND I.intInvoiceId <> @InvoiceId

	INSERT INTO tblARPrepaidAndCredit (
		  intInvoiceId
		, intInvoiceDetailId
		, intPrepaymentId
		, intPrepaymentDetailId
		, dblPostedAmount
		, dblBasePostedAmount
		, dblPostedDetailAmount
		, dblBasePostedDetailAmount
		, dblAppliedInvoiceAmount
		, dblBaseAppliedInvoiceAmount
		, dblAppliedInvoiceDetailAmount
		, dblBaseAppliedInvoiceDetailAmount
		, ysnApplied
		, ysnPosted
		, intRowNumber
		, intConcurrencyId
	)
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
		SELECT intInvoiceId			= UR.intInvoiceId
			 , intInvoiceDetailId	= UR.intInvoiceDetailId
		FROM #UNRESTRICTED UR

		UNION ALL

		SELECT intInvoiceId			= RI.intInvoiceId
			 , intInvoiceDetailId	= RI.intInvoiceDetailId
		FROM tblARInvoiceDetail ID
		INNER JOIN #RESTRICTEDITEMS RI ON ID.intItemId = RI.intItemId
		WHERE ID.intInvoiceId = @InvoiceId

		UNION ALL

		SELECT intInvoiceId			= RC.intInvoiceId
			 , intInvoiceDetailId	= RC.intInvoiceDetailId
		FROM tblARInvoiceDetail ID
		INNER JOIN #RESTRICTEDCONTRACTS RC ON ID.intContractDetailId = RC.intContractDetailId
		WHERE ID.intInvoiceId = @InvoiceId

		UNION ALL

		SELECT intInvoiceId			= RIC.intInvoiceId
			 , intInvoiceDetailId	= RIC.intInvoiceDetailId
		FROM tblARInvoiceDetail ID
		INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
		INNER JOIN #ITEMCONTRACTS RIC ON ((RIC.strContractApplyTo = 'Contract' AND RIC.ysnRestricted = 1 AND ID.intItemContractDetailId IS NOT NULL AND ID.intItemId = RIC.intItemId)
									   OR (RIC.strContractApplyTo = 'Contract' AND RIC.ysnRestricted = 0 AND ID.intItemContractDetailId IS NOT NULL)
									   OR (RIC.strContractApplyTo = 'Any' AND RIC.ysnRestricted = 1 AND ID.intItemId = RIC.intItemId)
									   OR (RIC.strContractApplyTo = 'Any' AND RIC.ysnRestricted = 0 AND RIC.intItemId IS NOT NULL))
		WHERE ID.intInvoiceId = @InvoiceId
		
		UNION ALL

		SELECT intInvoiceId			= RCAT.intInvoiceId
			 , intInvoiceDetailId	= RCAT.intInvoiceDetailId
		FROM tblARInvoiceDetail ID
		INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
		INNER JOIN tblICItem ITEM ON ID.intItemId = ITEM.intItemId 
		INNER JOIN #ITEMCATEGORY RCAT ON ((RCAT.strContractApplyTo = 'Contract' AND RCAT.ysnRestricted = 1 AND ID.intItemContractHeaderId IS NOT NULL AND ITEM.intCategoryId = RCAT.intCategoryId)
									   OR (RCAT.strContractApplyTo = 'Contract' AND RCAT.ysnRestricted = 0 AND ID.intItemContractHeaderId IS NOT NULL)
									   OR (RCAT.strContractApplyTo = 'Any' AND RCAT.ysnRestricted = 1 AND ITEM.intCategoryId = RCAT.intCategoryId)
									   OR (RCAT.strContractApplyTo = 'Any' AND RCAT.ysnRestricted = 0 AND RCAT.intCategoryId IS NOT NULL))
		WHERE ID.intInvoiceId = @InvoiceId

		UNION ALL

		SELECT intInvoiceId			= OM.intInvoiceId
			 , intInvoiceDetailId	= NULL
		FROM #OPENCREDITMEMO OM
	) I
	
	DELETE PC
	FROM tblARPrepaidAndCredit PC
	INNER JOIN #APPLIEDCONTRACTS AC ON PC.intPrepaymentDetailId = AC.intInvoiceDetailId AND PC.intPrepaymentId = AC.intInvoiceId
	WHERE PC.intInvoiceId = @InvoiceId
		
	UPDATE A 
	SET ysnApplied = 1
	  , dblAppliedInvoiceDetailAmount		= B.dblAppliedInvoiceDetailAmount
	  , dblBaseAppliedInvoiceDetailAmount	= B.dblBaseAppliedInvoiceDetailAmount
	FROM tblARPrepaidAndCredit A
	INNER JOIN #APPLIEDINVOICES B ON A.intPrepaymentId = B.intPrepaymentId
								 AND A.intInvoiceId = B.intInvoiceId
								 AND (A.intPrepaymentDetailId IS NULL OR (A.intPrepaymentDetailId IS NOT NULL AND A.intPrepaymentDetailId = B.intPrepaymentDetailId))
		
END TRY
BEGIN CATCH	
	SET @intErrorSeverity = ERROR_SEVERITY()
	SET @intErrorNumber   = ERROR_NUMBER()
	SET @strErrorMessage  = ERROR_MESSAGE()
	SET @intErrorState    = ERROR_STATE()
		
	RAISERROR (@strErrorMessage, @intErrorSeverity, @intErrorState, @intErrorNumber) 	
END CATCH

GO