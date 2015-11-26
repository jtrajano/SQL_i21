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
		DECLARE @dtmMembershipDate DATETIME,
				@intFiscalYear INT

		-- GET MEMBERSHIP DATE
		SET @dtmMembershipDate = (SELECT dtmMembershipDate FROM tblARCustomer where intEntityCustomerId = @intEntityCustomerId)
	
		IF(ISNULL(@dtmMembershipDate, 0) = 0)
		BEGIN -- NOT ELIGIBLE FOR PATRONAGE
			RETURN;
		END
		
		SELECT AR.intEntityCustomerId,
			   ARD.intItemId,
			   IC.intPatronageCategoryId,
			   PC.strUnitAmount,
			   ARD.dblQtyOrdered,
			   ARD.dblPrice,
			   ICU.dblUnitQty,
			   AR.ysnPosted,
			   dblVolume = CASE WHEN PC.strUnitAmount = 'Amount' THEN (ARD.dblQtyOrdered * ARD.dblPrice) 
						   ELSE (ARD.dblQtyOrdered * ICU.dblUnitQty) END
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
		 WHERE AR.intInvoiceId = @intInvoiceId
		   AND IC.intPatronageCategoryId IS NOT NULL
		   AND ICU.ysnStockUnit = 1 -- Confirm with sir Ajith

		IF NOT EXISTS(SELECT * FROM #tempItem)
		BEGIN
		
			DROP TABLE #tempItem
			RETURN;
		END
		ELSE
		BEGIN
			SET @intFiscalYear = (SELECT intFiscalYearId 
										FROM tblGLFiscalYear 
										WHERE (SELECT dtmDate 
												FROM tblARInvoice 
												WHERE intInvoiceId = @intInvoiceId) 
										BETWEEN dtmDateFrom AND dtmDateTo)

			
			MERGE tblPATCustomerVolume AS PAT
			USING #tempItem AS B
			   ON (PAT.intCustomerPatronId = B.intEntityCustomerId AND PAT.intPatronageCategoryId = B.intPatronageCategoryId)
			 WHEN MATCHED AND B.ysnPosted = 0 AND PAT.dblVolume = B.dblVolume
				  THEN DELETE
			 WHEN MATCHED
				  THEN UPDATE SET PAT.dblVolume = CASE WHEN B.ysnPosted = 1 THEN (PAT.dblVolume + B.dblVolume) 
													   ELSE (PAT.dblVolume - B.dblVolume) END
			 WHEN NOT MATCHED BY TARGET
				  THEN INSERT (intCustomerPatronId, intPatronageCategoryId, intFiscalYear, dtmLastActivityDate, dblVolume, intConcurrencyId)
					   VALUES (B.intEntityCustomerId, B.intPatronageCategoryId, @intFiscalYear, GETDATE(),  B.dblVolume, 1);

			DROP TABLE #tempItem
		END

END


GO