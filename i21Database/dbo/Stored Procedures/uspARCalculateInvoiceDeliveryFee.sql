CREATE PROCEDURE [dbo].[uspARCalculateInvoiceDeliveryFee]
	@intInvoiceId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	DECLARE @dtmTransDate DATETIME
	DECLARE @InvoiceLineItems AS TABLE (
		  intInvoiceId INT
		, intTaxGroupId INT
		, intTaxCodeId INT
		, dblShipQty NUMERIC(18, 6)
		, ysnGas BIT)

	SELECT 
		@dtmTransDate = dtmDate 
	FROM 
		tblARInvoice 
	WHERE 
		intInvoiceId = @intInvoiceId


	INSERT INTO 
		@InvoiceLineItems
	SELECT
		  ID.intInvoiceId
		, TG.intTaxGroupId
		, TC.intTaxCodeId
		, ID.dblQtyShipped
		, CASE WHEN ISNULL(I.intCategoryId, -1) = ISNULL(TCR.intGasolineItemCategoryId, -2) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	FROM 
		tblARInvoiceDetail ID
	INNER JOIN
		tblICItem I
			ON I.intItemId = ID.intItemId
	LEFT JOIN 
		tblSMTaxGroup TG 
			ON ID.intTaxGroupId = TG.intTaxGroupId
				INNER JOIN tblSMTaxGroupCode TGC 
					ON TG.intTaxGroupId = TGC.intTaxGroupId
				INNER JOIN tblSMTaxCode TC
					ON TGC.intTaxCodeId = TC.intTaxCodeId AND TC.ysnTexasLoadingFee = 1
						INNER JOIN tblSMTaxCodeRate TCR 
							ON TCR.intTaxCodeId = TC.intTaxCodeId 
	WHERE intInvoiceId =  @intInvoiceId

	IF EXISTS (SELECT TOP 1 1 FROM @InvoiceLineItems)
	BEGIN
		DELETE FROM tblARInvoiceDeliveryFee WHERE intInvoiceId = @intInvoiceId

		INSERT INTO 
			tblARInvoiceDeliveryFee
		SELECT 
			  @intInvoiceId AS intInvoiceId
			, intTaxGroupId AS intTaxGroupId
			, intTaxCodeId AS intTaxCodeId
			, dbo.[fnCalculateTexasFee](intTaxCodeId, @dtmTransDate, SUM(dblShipQty), SUM(CASE WHEN ysnGas = 1 THEN dblShipQty ELSE 0 END)) AS dblTax
			, 1 AS intConcurrencyId
		FROM 
			@InvoiceLineItems
		GROUP BY intTaxCodeId, intInvoiceId, intTaxGroupId
	END
END

