CREATE FUNCTION [dbo].[fnARGetAccountUsedInLineItemAsTable] (
	 @LineItemDetailId		INT
	,@IsSalesOrderDetail	BIT
	,@SoftWareItemType		NVARCHAR(50)
)
RETURNS @returntable TABLE
(
	 [intAccountId]	INT	
)
AS 
BEGIN
	DECLARE @InvoiceDetailId INT			
	
	IF ISNULL(@IsSalesOrderDetail,0) = 1
		SET @InvoiceDetailId = (SELECT TOP 1 ARID.[intInvoiceDetailId] FROM tblARInvoiceDetail ARID INNER JOIN tblARInvoice ARI ON ARID.[intInvoiceId] = ARI.[intInvoiceId] WHERE ARID.[intSalesOrderDetailId] = @LineItemDetailId AND ARI.[ysnPosted] = 1)

	IF ISNULL(@InvoiceDetailId,0) = 0
		SET @InvoiceDetailId = @LineItemDetailId

	DECLARE  @AccountId			INT
			,@Posted			INT
			,@InvoiceId			INT
			,@InvoiceNumber		NVARCHAR(25)
			,@TransactionType	NVARCHAR(25)
			,@ItemId			INT
			,@itemType			NVARCHAR(50)
			
	DECLARE @ZeroDecimal DECIMAL(18,6)
	SET @ZeroDecimal = 0.000000	
			
	SET @AccountId = NULL
	
	SELECT TOP 1
		 @Posted			= ISNULL(ARI.[ysnPosted],0)
		,@InvoiceId			= ARI.[intInvoiceId]
		,@InvoiceNumber		= ARI.[strInvoiceNumber]  
		,@TransactionType	= ARI.[strTransactionType]
		,@AccountId         = CASE WHEN ARI.[strTransactionType] =  'Debit Memo' THEN ARID.intAccountId ELSE NULL END
	FROM
		tblARInvoice ARI
	INNER JOIN
		tblARInvoiceDetail ARID 
			ON ARI.[intInvoiceId] = ARID.[intInvoiceId]
	WHERE
		ARID.[intInvoiceDetailId] = @InvoiceDetailId
			
			
	IF @Posted = 1
		BEGIN
			IF @TransactionType <> 'Debit Memo'
				BEGIN
					INSERT INTO @returntable([intAccountId])
					SELECT TOP 1
						GLD.[intAccountId]
					FROM
						tblGLDetail GLD
					WHERE
						GLD.[intJournalLineNo] = @InvoiceDetailId
						AND ISNULL(GLD.[ysnIsUnposted],0) <> @Posted
						AND GLD.[intTransactionId] = @InvoiceId
						AND GLD.[strTransactionId] = @InvoiceNumber
						AND GLD.[strCode] = 'AR'
						AND (
								(GLD.dblCredit > @ZeroDecimal AND @TransactionType IN ('Invoice', 'Cash'))
							OR
								(GLD.dblDebit > @ZeroDecimal AND @TransactionType NOT IN ('Invoice', 'Cash'))
							)
						AND (
								RTRIM(LTRIM(ISNULL(@SoftWareItemType, ''))) = ''
							OR
								(
									(
										RTRIM(LTRIM(ISNULL(@SoftWareItemType, ''))) = 'Maintenance' 
									AND
										EXISTS(SELECT NULL FROM vyuGLAccountDetail GLAD WHERE GLAD.[intAccountId] = GLD.[intAccountId] AND GLAD.[strAccountCategory] = 'Maintenance Sales')
									)
								OR
									(
										RTRIM(LTRIM(ISNULL(@SoftWareItemType, ''))) = 'License' 
									AND
										(
											EXISTS(SELECT NULL FROM vyuGLAccountDetail GLAD WHERE GLAD.[intAccountId] = GLD.[intAccountId] AND GLAD.[strAccountCategory] = 'General')
										OR
											EXISTS(SELECT NULL FROM vyuGLAccountDetail GLAD WHERE GLAD.[intAccountId] = GLD.[intAccountId] AND GLAD.[strAccountCategory] = 'Sales Account')
										)
								
									)

								)
							)
					END
				ELSE
					INSERT INTO @returntable([intAccountId])
					SELECT @AccountId
		END
		
	RETURN;
END 