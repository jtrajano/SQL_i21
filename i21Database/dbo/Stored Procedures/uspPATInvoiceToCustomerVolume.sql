CREATE PROCEDURE [dbo].[uspPATInvoiceToCustomerVolume]
	@intEntityCustomerId INT = NULL,
	@intInvoiceId INT = NULL,
	@ysnPosted BIT = NULL,
	@successfulCount INT = 0 OUTPUT,
	@invalidCount INT = 0 OUTPUT,
	@success BIT = 0 OUTPUT
AS
BEGIN
		SET QUOTED_IDENTIFIER OFF
		SET ANSI_NULLS ON
		SET NOCOUNT ON
		SET XACT_ABORT ON
		SET ANSI_WARNINGS OFF

		-- VARIABLES NEEDED 
		DECLARE @strStockStatus NVARCHAR(50),
				@intFiscalYear INT

			

		-- GET STOCK STATUS
		SET @strStockStatus = (SELECT strStockStatus FROM tblARCustomer where [intEntityId] = @intEntityCustomerId)
	
		IF(@strStockStatus = '' OR @strStockStatus IS NULL)
		BEGIN -- NOT ELIGIBLE FOR PATRONAGE
			RETURN;
		END
		
		SET @intFiscalYear = (SELECT intFiscalYearId 
										FROM tblGLFiscalYear 
										WHERE (SELECT dtmDate 
												FROM tblARInvoice 
												WHERE intInvoiceId = @intInvoiceId) 
										BETWEEN dtmDateFrom AND dtmDateTo)
		
		IF(@intFiscalYear IS NULL)
		BEGIN -- INVALID
			RETURN;
		END

		SELECT AR.intEntityCustomerId,
			   IC.intPatronageCategoryId,
			   AR.ysnPosted,
			   dblVolume =	sum (CASE WHEN PC.strUnitAmount = 'Amount' THEN (CASE WHEN ARD.dblQtyShipped <= 0 THEN 0 ELSE (ARD.dblQtyShipped * ARD.dblPrice) END)
							ELSE (CASE WHEN ICU.dblUnitQty <= 0 THEN ARD.dblQtyShipped ELSE (ARD.dblQtyShipped * ICU.dblUnitQty) END ) END),
			   @intFiscalYear as fiscalYear
		  INTO #tempItem
		  FROM tblARInvoice AR 
	INNER JOIN tblARInvoiceDetail ARD
			ON ARD.intInvoiceId = AR.intInvoiceId
	INNER JOIN tblICItem IC
			ON IC.intItemId = ARD.intItemId
	INNER JOIN tblICItemUOM ICU
			ON ICU.intItemId = IC.intItemId
	       AND ICU.intItemUOMId = ARD.intItemUOMId
	INNER JOIN tblPATPatronageCategory PC
			ON PC.intPatronageCategoryId = IC.intPatronageCategoryId
		   AND PC.strPurchaseSale = 'Sale'
		 WHERE AR.intInvoiceId = @intInvoiceId
		   AND IC.intPatronageCategoryId IS NOT NULL
		   group by AR.intEntityCustomerId,
			   IC.intPatronageCategoryId,
			   AR.ysnPosted

		IF NOT EXISTS(SELECT * FROM #tempItem)
		BEGIN
		
			DROP TABLE #tempItem
			RETURN;
		END
		ELSE
		BEGIN
			
			UPDATE tblARCustomer SET dtmLastActivityDate = GETDATE() 
				WHERE [intEntityId] IN (SELECT intEntityCustomerId FROM #tempItem)
			
			MERGE tblPATCustomerVolume AS PAT
			USING #tempItem AS B
			   ON (PAT.intCustomerPatronId = B.intEntityCustomerId AND PAT.intPatronageCategoryId = B.intPatronageCategoryId AND PAT.intFiscalYear = B.fiscalYear AND PAT.ysnRefundProcessed <> 1)
			 --WHEN MATCHED AND B.ysnPosted = 0 AND PAT.dblVolume = B.dblVolume
				--  THEN DELETE
			 WHEN MATCHED
				  THEN UPDATE SET PAT.dblVolume = CASE WHEN B.ysnPosted = 1 THEN (PAT.dblVolume + B.dblVolume) 
													   ELSE (PAT.dblVolume - B.dblVolume) END
			 WHEN NOT MATCHED BY TARGET
				  THEN INSERT (intCustomerPatronId, intPatronageCategoryId, intFiscalYear, dblVolume, intConcurrencyId)
					   VALUES (B.intEntityCustomerId, B.intPatronageCategoryId, @intFiscalYear, B.dblVolume, 1);

			DROP TABLE #tempItem
		END

END



GO