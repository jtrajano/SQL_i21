CREATE FUNCTION [dbo].[fnGetTaxGroupTaxCodes]
(
	 @TaxGroupId		INT
	,@TransactionDate	DATETIME
)
RETURNS @returntable TABLE
(
	 [intTransactionDetailTaxId]	INT
	,[intTransactionDetailId]		INT
	,[intTaxGroupMasterId]			INT
	,[intTaxGroupId]				INT
	,[intTaxCodeId]					INT
	,[intTaxClassId]				INT
	,[strTaxableByOtherTaxes]		NVARCHAR(MAX)
	,[strCalculationMethod]			NVARCHAR(30)
	,[numRate]						NUMERIC(18,6)
	,[dblTax]						NUMERIC(18,6)
	,[dblAdjustedTax]				NUMERIC(18,6)
	,[intTaxAccountId]				INT
	,[ysnSeparateOnInvoice]			BIT
	,[ysnCheckoffTax]				BIT
	,[strTaxCode]					NVARCHAR(100)						
	,[ysnTaxExempt]					BIT
	,[strTaxGroup]					NVARCHAR(100)
)
AS
BEGIN

	DECLARE @ZeroDecimal NUMERIC(18, 6)
			,@TaxExempt BIT

	SET @ZeroDecimal = 0.000000
	
	INSERT INTO @returntable
	SELECT
		 0 AS [intTransactionDetailTaxId]
		,0 AS [intTransactionDetailId]
		,0 AS [intTaxGroupMasterId] 
		,TG.[intTaxGroupId] 
		,TC.[intTaxCodeId]
		,TC.[intTaxClassId]				
		,TC.[strTaxableByOtherTaxes]
		,ISNULL((SELECT TOP 1 tblSMTaxCodeRate.[strCalculationMethod] FROM tblSMTaxCodeRate WHERE tblSMTaxCodeRate.[intTaxCodeId] = TC.[intTaxCodeId] AND  CAST(tblSMTaxCodeRate.[dtmEffectiveDate]  AS DATE) <= CAST(@TransactionDate AS DATE) ORDER BY tblSMTaxCodeRate.[dtmEffectiveDate]ASC ,tblSMTaxCodeRate.[numRate] DESC), 'Unit') AS [strCalculationMethod]
		,ISNULL((SELECT TOP 1 tblSMTaxCodeRate.[numRate] FROM tblSMTaxCodeRate WHERE tblSMTaxCodeRate.[intTaxCodeId] = TC.[intTaxCodeId] AND  CAST(tblSMTaxCodeRate.[dtmEffectiveDate]  AS DATE) <= CAST(@TransactionDate AS DATE) ORDER BY tblSMTaxCodeRate.[dtmEffectiveDate]ASC ,tblSMTaxCodeRate.[numRate] DESC), 0.00) AS [numRate]
		,@ZeroDecimal AS [dblTax]
		,@ZeroDecimal AS [dblAdjustedTax]				
		,TC.[intPurchaseTaxAccountId] AS [intTaxAccountId]								 
		,0 AS [ysnSeparateOnInvoice] 
		,TC.[ysnCheckoffTax]
		,TC.[strTaxCode]
		,0 AS [ysnTaxExempt] 
		,TG.[strTaxGroup] 				
	FROM
		tblSMTaxCode TC
	INNER JOIN
		tblSMTaxGroupCode TGC
			ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
	INNER JOIN
		tblSMTaxGroup TG
			ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
	WHERE
			TG.intTaxGroupId = @TaxGroupId
		AND	(TC.intPurchaseTaxAccountId IS NOT NULL AND TC.intPurchaseTaxAccountId <> 0)
	ORDER BY
		TGC.[intTaxGroupCodeId]
		
	RETURN				
END
