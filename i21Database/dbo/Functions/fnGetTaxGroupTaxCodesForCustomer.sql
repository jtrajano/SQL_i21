CREATE FUNCTION [dbo].[fnGetTaxGroupTaxCodesForCustomer]
(
	 @TaxGroupId		INT
	,@CustomerId		INT
	,@TransactionDate	DATETIME
	,@ItemId			INT
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
			,@ItemCategoryId INT

	SET @ZeroDecimal = 0.000000
	SELECT @TaxExempt = ysnTaxExempt FROM tblARCustomer WHERE intEntityCustomerId = @CustomerId
	SELECT @ItemCategoryId = intCategoryId FROM tblICItem WHERE intItemId = @ItemId 
	
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
		,TC.[intSalesTaxAccountId]	AS [intTaxAccountId]							
		,0 AS [ysnSeparateOnInvoice] 
		,TC.[ysnCheckoffTax]
		,TC.[strTaxCode]
		,(CASE WHEN ISNULL(@TaxExempt,0) = 0
			THEN ISNULL((
					SELECT TOP 1 1 FROM
						tblARCustomerTaxingTaxException
					WHERE
						intEntityCustomerId = @CustomerId								
						AND (((intCategoryId = @ItemCategoryId OR ISNULL(@ItemCategoryId,0) = 0) OR (intItemId = @ItemId OR ISNULL(@ItemId,0) = 0)) OR (intTaxClassId = TC.[intTaxClassId] OR intTaxCodeId = TC.[intTaxCodeId] OR (UPPER(LTRIM(RTRIM(ISNULL(strState,'')))) = UPPER(LTRIM(RTRIM(ISNULL(TC.strState,'')))) AND LEN(UPPER(LTRIM(RTRIM(ISNULL(strState,''))))) > 0 ) ))
						AND	CAST(@TransactionDate AS DATE) BETWEEN CAST(dtmStartDate AS DATE) AND CAST(ISNULL(dtmEndDate, @TransactionDate) AS DATE)
					ORDER BY
						dtmStartDate
					),0)
			ELSE @TaxExempt
		END) AS [ysnTaxExempt] 
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
		AND	(TC.[intSalesTaxAccountId] IS NOT NULL AND TC.[intSalesTaxAccountId] <> 0)
	ORDER BY
		TGC.[intTaxGroupCodeId]
	RETURN				
END