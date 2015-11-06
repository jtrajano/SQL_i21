CREATE FUNCTION [dbo].[fnGetVendorTaxCodeExemption]
( 
	 @VendorId			INT
	,@TransactionDate	DATETIME
	,@TaxCodeId			INT
	,@TaxClassId		INT
	,@TaxState			NVARCHAR(100)
	,@ItemId			INT
	,@ItemCategoryId	INT
	,@BillToLocationId	INT
)
RETURNS NVARCHAR(500)
AS
BEGIN
	DECLARE @TaxCodeExemption	NVARCHAR(500)
			
	--Vendor Location
	SELECT TOP 1
		@TaxCodeExemption = 'Tax Exemption '
							 + ISNULL('Number: ' + strException, '') 
							 + ISNULL('; Start Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; End Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; Vendor Location: ' + EL.[strLocationName], '')
							 + ISNULL('; Tax Code: ' + TC.[strTaxCode], '')
	FROM
		tblAPVendorTaxException TE
	LEFT OUTER JOIN
		tblSMTaxCode TC
			ON TE.[intTaxCodeId] = TC.[intTaxCodeId]
	LEFT OUTER JOIN
		tblEntityLocation EL
			ON TE.intEntityVendorLocationId = EL.[intEntityLocationId]
	WHERE
		[intEntityVendorId] = @VendorId
		AND TE.intEntityVendorLocationId = @BillToLocationId
		AND TE.[intTaxCodeId] = @TaxCodeId
		AND	CAST(@TransactionDate AS DATE) BETWEEN CAST(TE.[dtmStartDate] AS DATE) AND CAST(ISNULL(TE.[dtmEndDate], @TransactionDate) AS DATE)
	ORDER BY
		dtmStartDate
		
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		RETURN @TaxCodeExemption
	

	SELECT TOP 1
		@TaxCodeExemption = 'Tax Exemption '
							 + ISNULL('Number: ' + strException, '') 
							 + ISNULL('; Start Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; End Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; Vendor Location: ' + EL.[strLocationName], '')
							 + ISNULL('; Tax Class: ' + SMTC.[strTaxClass], '')
	FROM
		tblAPVendorTaxException TE
	LEFT OUTER JOIN
		tblEntityLocation EL
			ON TE.intEntityVendorLocationId = EL.[intEntityLocationId]
	LEFT OUTER JOIN
		tblSMTaxClass SMTC
			ON TE.[intTaxClassId] = SMTC.[intTaxClassId]
	WHERE
		[intEntityVendorId] = @VendorId
		AND intEntityVendorLocationId = @BillToLocationId
		AND TE.[intTaxClassId] = @TaxClassId
		AND	CAST(@TransactionDate AS DATE) BETWEEN CAST(TE.[dtmStartDate] AS DATE) AND CAST(ISNULL(TE.[dtmEndDate], @TransactionDate) AS DATE)
	ORDER BY
		dtmStartDate	
		
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		RETURN @TaxCodeExemption	
	
	
	SELECT TOP 1
		@TaxCodeExemption = 'Tax Exemption '
							 + ISNULL('Number: ' + strException, '') 
							 + ISNULL('; Start Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; End Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; Vendor Location: ' + EL.[strLocationName], '')
							 + ISNULL('; Tax State: ' + TE.[strState], '')
	FROM
		tblAPVendorTaxException TE
	LEFT OUTER JOIN
		tblEntityLocation EL
			ON TE.intEntityVendorLocationId = EL.[intEntityLocationId]
	WHERE
		[intEntityVendorId] = @VendorId
		AND TE.intEntityVendorLocationId = @BillToLocationId
		AND LEN(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) > 0
		AND UPPER(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) = @TaxState
		AND	CAST(@TransactionDate AS DATE) BETWEEN CAST(TE.[dtmStartDate] AS DATE) AND CAST(ISNULL(TE.[dtmEndDate], @TransactionDate) AS DATE)
	ORDER BY
		dtmStartDate	
		
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		RETURN @TaxCodeExemption	
	
	--Item
	SELECT TOP 1
		@TaxCodeExemption = 'Tax Exemption '
							 + ISNULL('Number: ' + strException, '') 
							 + ISNULL('; Start Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; End Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; Item No: ' + IC.[strItemNo], '')
							 + ISNULL('; Tax Code: ' + TC.[strTaxCode], '')
	FROM
		tblAPVendorTaxException TE
	LEFT OUTER JOIN
		tblSMTaxCode TC
			ON TE.[intTaxCodeId] = TC.[intTaxCodeId]
	LEFT OUTER JOIN
		tblICItem  IC
			ON TE.[intItemId] = IC.[intItemId]
	WHERE
		[intEntityVendorId] = @VendorId
		AND TE.[intItemId] = @ItemId
		AND TE.[intTaxCodeId] = @TaxCodeId
		AND	CAST(@TransactionDate AS DATE) BETWEEN CAST(TE.[dtmStartDate] AS DATE) AND CAST(ISNULL(TE.[dtmEndDate], @TransactionDate) AS DATE)
	ORDER BY
		dtmStartDate
		
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		RETURN @TaxCodeExemption
		
		
	SELECT TOP 1
		@TaxCodeExemption = 'Tax Exemption '
							 + ISNULL('Number: ' + strException, '') 
							 + ISNULL('; Start Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; End Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; Item No: ' + IC.[strItemNo], '')
							 + ISNULL('; Tax Code: ' + TC.[strTaxClass], '')
	FROM
		tblAPVendorTaxException TE
	LEFT OUTER JOIN
		tblSMTaxClass TC
			ON TE.[intTaxClassId] = TC.[intTaxClassId]
	LEFT OUTER JOIN
		tblICItem  IC
			ON TE.[intItemId] = IC.[intItemId]
	WHERE
		[intEntityVendorId] = @VendorId
		AND TE.[intItemId] = @ItemId
		AND TE.[intTaxClassId] = @TaxClassId
		AND	CAST(@TransactionDate AS DATE) BETWEEN CAST(TE.[dtmStartDate] AS DATE) AND CAST(ISNULL(TE.[dtmEndDate], @TransactionDate) AS DATE)
	ORDER BY
		dtmStartDate
		
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		RETURN @TaxCodeExemption		
	
		
	SELECT TOP 1
		@TaxCodeExemption = 'Tax Exemption '
							 + ISNULL('Number: ' + strException, '') 
							 + ISNULL('; Start Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; End Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; Item No: ' + IC.[strItemNo], '')
							 + ISNULL('; Tax Code: ' + TE.[strState], '')
	FROM
		tblAPVendorTaxException TE
	LEFT OUTER JOIN
		tblICItem  IC
			ON TE.[intItemId] = IC.[intItemId]
	WHERE
		[intEntityVendorId] = @VendorId
		AND TE.[intItemId] = @ItemId
		AND (LEN(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) > 0 AND UPPER(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) = @TaxState)
		AND	CAST(@TransactionDate AS DATE) BETWEEN CAST(TE.[dtmStartDate] AS DATE) AND CAST(ISNULL(TE.[dtmEndDate], @TransactionDate) AS DATE)
	ORDER BY
		dtmStartDate
		
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		RETURN @TaxCodeExemption
		
	SELECT TOP 1
		@TaxCodeExemption = 'Invalid Purchase Tax Account for Tax Code ' + TC.[strTaxCode]
	FROM
		tblSMTaxCode TC
	WHERE
		TC.[intTaxCodeId] = @TaxCodeId
		AND	ISNULL(TC.[intPurchaseTaxAccountId],0) = 0	
			
				
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		RETURN @TaxCodeExemption					

				
	RETURN NULL		
END
