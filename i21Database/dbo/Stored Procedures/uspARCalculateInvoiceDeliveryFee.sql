CREATE PROCEDURE [dbo].[uspARCalculateInvoiceDeliveryFee]
	@InvoiceIds AS Id READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	DECLARE @InvoiceLineItems AS TABLE (
		  intInvoiceId		INT
		, intTaxGroupId		INT
		, intTaxCodeId		INT
		, dblShipQty		NUMERIC(18, 6)
		, ysnGas			BIT
		, dtmTransDate		DATETIME
	)
	
	INSERT INTO @InvoiceLineItems (
		  intInvoiceId
		, intTaxGroupId
		, intTaxCodeId
		, dblShipQty
		, ysnGas
	)
	SELECT intInvoiceId		= ID.intInvoiceId
		 , intTaxGroupId	= TG.intTaxGroupId
		 , intTaxCodeId		= TC.intTaxCodeId
		 , dblQtyShipped	= ID.dblQtyShipped
		 , ysnGas			= CASE WHEN ISNULL(I.intCategoryId, -1) IN 
								(SELECT intGasolineItemCategoryId 
								FROM tblSMTaxCodeRate 
								WHERE intTaxCodeId = TC.intTaxCodeId AND
									  dtmEffectiveDate = (SELECT MAX(dtmEffectiveDate) 
										FROM tblSMTaxCodeRate 
										WHERE intTaxCodeId = TC.intTaxCodeId)) 
							  THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	FROM tblARInvoiceDetail ID
	INNER JOIN tblICItem I ON I.intItemId = ID.intItemId
	LEFT JOIN tblSMTaxGroup TG ON ID.intTaxGroupId = TG.intTaxGroupId
	INNER JOIN tblSMTaxGroupCode TGC ON TG.intTaxGroupId = TGC.intTaxGroupId
	INNER JOIN tblSMTaxCode TC ON TGC.intTaxCodeId = TC.intTaxCodeId AND TC.ysnTexasLoadingFee = 1
	INNER JOIN @InvoiceIds IDS ON ID.intInvoiceId = IDS.intId

	UPDATE ILI
	SET dtmTransDate = I.dtmDate
	FROM @InvoiceLineItems ILI
	INNER JOIN tblARInvoice I ON ILI.intInvoiceId = I.intInvoiceId

	DELETE IDF 
	FROM tblARInvoiceDeliveryFee IDF 
	INNER JOIN @InvoiceIds IDS ON IDF.intInvoiceId = IDS.intId

	IF EXISTS (SELECT TOP 1 1 FROM @InvoiceLineItems)
	BEGIN
		INSERT INTO tblARInvoiceDeliveryFee (
			  intInvoiceId
			, intTaxGroupId
			, intTaxCodeId
			, dblTax
			, intConcurrencyId
		)
		SELECT intInvoiceId		= intInvoiceId
			 , intTaxGroupId	= intTaxGroupId
			 , intTaxCodeId		= intTaxCodeId
			 , dblTax			= dbo.[fnCalculateTexasFee](intTaxCodeId, dtmTransDate, SUM(dblShipQty), SUM(CASE WHEN ysnGas = 1 THEN dblShipQty ELSE 0 END))
			 , intConcurrencyId	= 1
		FROM @InvoiceLineItems
		GROUP BY intTaxCodeId, intInvoiceId, intTaxGroupId, dtmTransDate

		UPDATE IDF
		SET dblBaseTax = dblTax
		FROM tblARInvoiceDeliveryFee IDF
		INNER JOIN @InvoiceIds IDS ON IDF.intInvoiceId = IDS.intId
		WHERE dblBaseTax IS NULL 
		   OR dblBaseTax = 0
	END
END