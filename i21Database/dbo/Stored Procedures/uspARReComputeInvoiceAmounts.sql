﻿CREATE PROCEDURE [dbo].[uspARReComputeInvoiceAmounts]
	 @InvoiceId				AS INT
	,@AvailableDiscountOnly	AS BIT = 0
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE  @ZeroDecimal			DECIMAL(18,6)
		,@InvoiceIdLocal		INT
		,@CurrencyId			INT
		,@strTransType			NVARCHAR(50)
		,@OriginalInvoiceId		INT

SET @ZeroDecimal = 0.000000	
SET @InvoiceIdLocal = @InvoiceId
						
SELECT
	@CurrencyId			= [intCurrencyId],
	@OriginalInvoiceId	= [intOriginalInvoiceId],
	@strTransType		= [strTransactionType]
FROM
	tblARInvoice
WHERE
	[intInvoiceId] = @InvoiceIdLocal


UPDATE
	tblARInvoiceDetailTax
SET
	 [dblRate]				= ISNULL([dblRate], @ZeroDecimal)
	,[dblTax]				= ISNULL([dblTax], @ZeroDecimal)
	,[dblAdjustedTax]		= [dbo].fnRoundBanker(ISNULL([dblAdjustedTax], @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())
	,[dblBaseAdjustedTax]	= [dbo].fnRoundBanker(ISNULL([dblBaseAdjustedTax], @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())
	,[ysnTaxAdjusted]		= ISNULL([ysnTaxAdjusted], 0)
WHERE 
	intInvoiceDetailId IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @InvoiceIdLocal)
	
	
UPDATE
	tblARInvoiceDetail
SET
	 [dblQtyOrdered]			= ISNULL([dblQtyOrdered], @ZeroDecimal)
	,[dblQtyShipped]			= ISNULL([dblQtyShipped], @ZeroDecimal)
	,[dblDiscount]				= ISNULL([dblDiscount], @ZeroDecimal)
	,[dblItemWeight]			= ISNULL([dblItemWeight], 1.00)
	,[dblShipmentNetWt]			= ISNULL([dblShipmentNetWt], [dblQtyShipped])
	,[dblPrice]					= ISNULL([dblPrice], @ZeroDecimal)
	,[dblBasePrice]				= ISNULL(ISNULL([dblPrice], @ZeroDecimal) * (CASE WHEN ISNULL([dblCurrencyExchangeRate], @ZeroDecimal) = @ZeroDecimal THEN 1 ELSE [dblCurrencyExchangeRate] END), @ZeroDecimal)
	,[dblUnitPrice] 			= ISNULL(ISNULL([dblUnitPrice], [dblPrice]), @ZeroDecimal)
	,[dblBaseUnitPrice]			= ISNULL(ISNULL(ISNULL([dblUnitPrice], [dblPrice]), @ZeroDecimal) * (CASE WHEN ISNULL([dblCurrencyExchangeRate], @ZeroDecimal) = @ZeroDecimal THEN 1 ELSE [dblCurrencyExchangeRate] END), @ZeroDecimal)
	,[dblTotalTax]				= ISNULL([dblTotalTax], @ZeroDecimal)
	,[dblBaseTotalTax]			= ISNULL([dblBaseTotalTax], @ZeroDecimal)
	,[dblTotal]					= ISNULL([dblTotal], @ZeroDecimal)
	,[dblBaseTotal]				= ISNULL([dblBaseTotal], @ZeroDecimal)
	,[dblItemTermDiscount]		= ISNULL([dblItemTermDiscount], @ZeroDecimal)
	,[strItemTermDiscountBy]	= ISNULL([strItemTermDiscountBy], 'Amount') 
	,[intSubCurrencyId]			= ISNULL([intSubCurrencyId], @CurrencyId)
	,[dblSubCurrencyRate]		= CASE WHEN ISNULL([dblSubCurrencyRate], @ZeroDecimal) = @ZeroDecimal THEN 1 ELSE [dblSubCurrencyRate] END
	,[dblCurrencyExchangeRate] 	= CASE WHEN ISNULL([dblCurrencyExchangeRate], @ZeroDecimal) = @ZeroDecimal THEN 1 ELSE [dblCurrencyExchangeRate] END
WHERE
	[intInvoiceId] = @InvoiceIdLocal
	
	
UPDATE
	tblARInvoice
SET
	 [dblInvoiceSubtotal]		= ISNULL([dblInvoiceSubtotal], @ZeroDecimal)
	,[dblBaseInvoiceSubtotal]	= ISNULL([dblBaseInvoiceSubtotal], @ZeroDecimal)
	,[dblShipping]				= ISNULL([dblShipping], @ZeroDecimal)
	,[dblBaseShipping]			= ISNULL([dblBaseShipping], @ZeroDecimal)
	,[dblTax]					= ISNULL([dblTax], @ZeroDecimal)
	,[dblBaseTax]				= ISNULL([dblBaseTax], @ZeroDecimal)
	,[dblInvoiceTotal]			= ISNULL([dblInvoiceTotal], @ZeroDecimal)
	,[dblBaseInvoiceTotal]		= ISNULL([dblBaseInvoiceTotal], @ZeroDecimal)
	,[dblDiscount]				= ISNULL([dblDiscount], @ZeroDecimal)
	,[dblBaseDiscount]			= ISNULL([dblBaseDiscount], @ZeroDecimal)
	,[dblAmountDue]				= ISNULL([dblAmountDue], @ZeroDecimal)
	,[dblBaseAmountDue]			= ISNULL([dblBaseAmountDue], @ZeroDecimal)
	,[dblPayment]				= ISNULL([dblPayment], @ZeroDecimal)
	,[dblBasePayment]			= ISNULL([dblBasePayment], @ZeroDecimal)
	,[dblDiscountAvailable]		= ISNULL([dblDiscountAvailable], @ZeroDecimal)
	,[dblBaseDiscountAvailable]	= ISNULL([dblBaseDiscountAvailable], @ZeroDecimal)
	,[dblTotalTermDiscount]		= ISNULL([dblTotalTermDiscount], @ZeroDecimal)
	,[dblInterest]				= ISNULL([dblInterest], @ZeroDecimal)
	,[dblBaseInterest]			= ISNULL([dblBaseInterest], @ZeroDecimal)
	,[dblSplitPercent] 			= CASE WHEN ISNULL([ysnSplitted],0) = 0 OR [intSplitId] IS NULL THEN 1 ELSE ISNULL([dblSplitPercent],1) END
WHERE
	[intInvoiceId] = @InvoiceIdLocal


--IF @strTransType = 'CF Invoice' OR  @strTransType = 'CF Tran' 
--BEGIN
	UPDATE
		tblARInvoice
	SET
		  [dblDiscountAvailable]		= ISNULL([dbo].[fnGetDiscountBasedOnTerm]([dtmDate], [dtmDate], [intTermId], [dblInvoiceTotal])  + T.[dblItemTermDiscountTotal], @ZeroDecimal)
		 ,[dblBaseDiscountAvailable]	= ISNULL([dbo].[fnGetDiscountBasedOnTerm]([dtmDate], [dtmDate], [intTermId], [dblBaseInvoiceTotal])  + T.[dblBaseItemTermDiscountTotal], @ZeroDecimal)
		 ,[dblTotalTermDiscount]		= ISNULL(T.[dblItemTermDiscountTotal], @ZeroDecimal)
	FROM
		(
			SELECT 
				 SUM(
					CASE WHEN [strItemTermDiscountBy] = 'Percent'
						THEN
							[dbo].fnRoundBanker(([dblQtyShipped] * [dblPrice]) * ([dblItemTermDiscount]/100.000000), [dbo].[fnARGetDefaultDecimal]())
						ELSE
							[dbo].fnRoundBanker([dblItemTermDiscount], [dbo].[fnARGetDefaultDecimal]())
					END
					)	AS [dblItemTermDiscountTotal]
				,SUM(
					CASE WHEN [strItemTermDiscountBy] = 'Percent'
						THEN
							[dbo].fnRoundBanker((([dblQtyShipped] * [dblPrice]) * ([dblItemTermDiscount]/100.000000)) * [dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
						ELSE
							[dbo].fnRoundBanker([dblItemTermDiscount] * [dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
					END
					)	AS [dblBaseItemTermDiscountTotal]
				,[intInvoiceId]
			FROM
				tblARInvoiceDetail
			WHERE
				[intInvoiceId] = @InvoiceIdLocal
			GROUP BY
				[intInvoiceId]
		)
		 T
	WHERE
		tblARInvoice.[intInvoiceId] = T.[intInvoiceId]
		AND tblARInvoice.[intInvoiceId] = @InvoiceIdLocal
--END



IF (@AvailableDiscountOnly = 1)
	RETURN 1;

	
UPDATE
	tblARInvoiceDetail
SET
	  [dblTotalTax]		= ISNULL(T.[dblAdjustedTax], @ZeroDecimal)
	 ,[dblBaseTotalTax]	= ISNULL(T.[dblBaseAdjustedTax], @ZeroDecimal)
FROM
	(
		SELECT
			 SUM([dblAdjustedTax]) [dblAdjustedTax]
			,SUM([dblBaseAdjustedTax]) [dblBaseAdjustedTax]
			,[intInvoiceDetailId]
		FROM
			tblARInvoiceDetailTax
		GROUP BY
			[intInvoiceDetailId]	
	)
	 T
WHERE
	tblARInvoiceDetail.[intInvoiceDetailId] = T.[intInvoiceDetailId]
	AND tblARInvoiceDetail.[intInvoiceId] = @InvoiceIdLocal

UPDATE
	ARID
SET
	ARID.[dblTotal]		= (CASE WHEN ISNULL(ICI.[strType], '') = 'Comment' THEN @ZeroDecimal
							ELSE
								(	CASE WHEN (ISNULL(ARID.[intLoadDetailId],0) <> 0 AND ISNULL(ARID.[intItemWeightUOMId],0) <> 0)
										THEN
											[dbo].fnRoundBanker([dbo].fnRoundBanker(((ARID.[dblUnitPrice] / ARID.[dblSubCurrencyRate]) * ARID.[dblShipmentNetWt]), [dbo].[fnARGetDefaultDecimal]()) - [dbo].fnRoundBanker((((ARID.[dblUnitPrice] / ARID.[dblSubCurrencyRate]) * ARID.[dblShipmentNetWt]) * (ARID.[dblDiscount]/100.00)), [dbo].[fnARGetDefaultDecimal]()), [dbo].[fnARGetDefaultDecimal]())
										ELSE
											[dbo].fnRoundBanker([dbo].fnRoundBanker(((ARID.[dblPrice] / ARID.[dblSubCurrencyRate]) * ARID.[dblQtyShipped]), [dbo].[fnARGetDefaultDecimal]()) - [dbo].fnRoundBanker((((ARID.[dblPrice] / ARID.[dblSubCurrencyRate]) * ARID.[dblQtyShipped]) * (ARID.[dblDiscount]/100.00)), [dbo].[fnARGetDefaultDecimal]()), [dbo].[fnARGetDefaultDecimal]())
									END							
								  )
							END)
	
FROM
	tblARInvoiceDetail ARID
LEFT OUTER JOIN
	tblICItem ICI
		ON ARID.[intItemId] = ICI.[intItemId] 
WHERE
	ARID.[intInvoiceId] = @InvoiceIdLocal

UPDATE
	ARID
SET
	ARID.[dblBaseTotal]		= [dbo].fnRoundBanker(ARID.[dblTotal] * ARID.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
	
FROM
	tblARInvoiceDetail ARID
LEFT OUTER JOIN
	tblICItem ICI
		ON ARID.[intItemId] = ICI.[intItemId] 
WHERE
	ARID.[intInvoiceId] = @InvoiceIdLocal
		
	
UPDATE
	tblARInvoice
SET
	 [dblTax]					= ISNULL(T.[dblTotalTax], @ZeroDecimal)
	,[dblBaseTax]				= ISNULL(T.[dblBaseTotalTax], @ZeroDecimal)
	,[dblInvoiceSubtotal]		= ISNULL(T.[dblTotal], @ZeroDecimal)
	,[dblBaseInvoiceSubtotal]	= ISNULL(T.[dblBaseTotal], @ZeroDecimal)
FROM
	(
		SELECT 
			 SUM([dblTotalTax])		AS [dblTotalTax]
			,SUM([dblBaseTotalTax])	AS [dblBaseTotalTax]
			,SUM([dblTotal])		AS [dblTotal]
			,SUM([dblBaseTotal])	AS [dblBaseTotal]
			,[intInvoiceId]
		FROM
			tblARInvoiceDetail
		WHERE
			[intInvoiceId] = @InvoiceIdLocal
		GROUP BY
			[intInvoiceId]
	)
	 T
WHERE
	tblARInvoice.[intInvoiceId] = T.[intInvoiceId]
	AND tblARInvoice.[intInvoiceId] = @InvoiceIdLocal
	
	
UPDATE
	tblARInvoice
SET
	 [dblInvoiceTotal]		= ([dblInvoiceSubtotal] + [dblTax] + [dblShipping])
	,[dblBaseInvoiceTotal]	= ([dblBaseInvoiceSubtotal] + [dblBaseTax] + [dblBaseShipping])
	,[dblAmountDue]			= ([dblInvoiceSubtotal] + [dblTax] + [dblShipping]) - ([dblPayment] + [dblDiscount])
	,[dblBaseAmountDue]		= ([dblBaseInvoiceSubtotal] + [dblBaseTax] + [dblBaseShipping]) - ([dblBasePayment] + [dblBaseDiscount])
WHERE
	[intInvoiceId] = @InvoiceIdLocal

END

--IF ISNULL(@OriginalInvoiceId, 0) <> 0
--	BEGIN
--		DECLARE @dblProvisionalAmt	NUMERIC(18,6)
--				,@dblBaseProvisionalAmt	NUMERIC(18,6)

--		SELECT TOP 1 
--			 @dblProvisionalAmt = dblAmountDue 
--			,@dblBaseProvisionalAmt = dblBaseAmountDue 
--		FROM dbo.tblARInvoice WITH (NOLOCK)
--		WHERE intInvoiceId = @OriginalInvoiceId
--		  AND ysnProcessed = 1
--		  AND strType = 'Provisional'

--		UPDATE tblARInvoice
--		SET dblAmountDue		= dblAmountDue - ISNULL(@dblProvisionalAmt, @ZeroDecimal)
--		  , dblBaseAmountDue	= dblAmountDue - ISNULL(@dblBaseProvisionalAmt, @ZeroDecimal)
--		  , dblPayment			= ISNULL(@dblProvisionalAmt, @ZeroDecimal)
--		  , dblBasePayment		= ISNULL(@dblBaseProvisionalAmt, @ZeroDecimal)
--		WHERE intInvoiceId = @OriginalInvoiceId
--	END