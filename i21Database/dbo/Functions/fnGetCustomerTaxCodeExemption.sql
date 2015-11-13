CREATE FUNCTION [dbo].[fnGetCustomerTaxCodeExemption]
( 
	 @CustomerId		INT
	,@TransactionDate	DATETIME
	,@TaxCodeId			INT
	,@TaxClassId		INT
	,@TaxState			NVARCHAR(100)
	,@ItemId			INT
	,@ItemCategoryId	INT
	,@ShipToLocationId	INT
)
RETURNS NVARCHAR(500)
AS
BEGIN
	DECLARE @TaxCodeExemption	NVARCHAR(500)
	
	--Customer
	IF EXISTS(SELECT NULL FROM tblARCustomer WHERE [intEntityCustomerId] = @CustomerId AND ISNULL([ysnTaxExempt],0) = 1)
		SET @TaxCodeExemption = 'Customer is tax exempted; Date: ' + CONVERT(NVARCHAR(20), GETDATE(), 101) + ' ' + CONVERT(NVARCHAR(20), GETDATE(), 114)
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		RETURN @TaxCodeExemption
		
	--Item Category Tax Class		
	SELECT TOP 1
		@TaxCodeExemption = ISNULL('Tax Class - ' + (SELECT TOP 1 [strTaxClass] FROM tblSMTaxClass WHERE [intTaxClassId] = @TaxClassId), '')
							+ ISNULL(' is not included in Item Category - ' + ICC.[strCategoryCode] + ' tax class setup.', '') 							 
	FROM
		tblICItem ICI
	INNER JOIN
		tblICCategory ICC
			ON ICI.[intCategoryId] = ICC.[intCategoryId]
	LEFT OUTER JOIN
		tblICCategoryTax ICCT
			ON ICC.[intCategoryId] = ICCT.[intCategoryId]
			--AND ICCT.[ysnActive] = 1
	WHERE
		ISNULL(ICCT.[intCategoryTaxId],0) = 0
		AND ICI.[intItemId] = @ItemId 
		AND ICI.[intCategoryId] = @ItemCategoryId
		
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		RETURN @TaxCodeExemption	
			
	--Customer Location
	SELECT TOP 1
		@TaxCodeExemption = 'Tax Exemption '
							 + ISNULL('Number: ' + TE.[strException], '') 
							 + ISNULL('; Start Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; End Date: ' + CONVERT(NVARCHAR(25), TE.[dtmEndDate], 101), '')
							 + ISNULL('; Customer Location: ' + EL.[strLocationName], '')
							 + ISNULL('; Tax Code: ' + TC.[strTaxCode], '')
	FROM
		tblARCustomerTaxingTaxException TE
	LEFT OUTER JOIN
		tblSMTaxCode TC
			ON TE.[intTaxCodeId] = TC.[intTaxCodeId]
	LEFT OUTER JOIN
		tblEntityLocation EL
			ON TE.[intEntityCustomerLocationId] = EL.[intEntityLocationId]
	WHERE
		[intEntityCustomerId] = @CustomerId
		AND TE.[intEntityCustomerLocationId] = @ShipToLocationId
		AND TE.[intTaxCodeId] = @TaxCodeId
		AND	CAST(@TransactionDate AS DATE) BETWEEN CAST(TE.[dtmStartDate] AS DATE) AND CAST(ISNULL(TE.[dtmEndDate], @TransactionDate) AS DATE)
	ORDER BY
		dtmStartDate
		
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		RETURN @TaxCodeExemption
	

	SELECT TOP 1
		@TaxCodeExemption = 'Tax Exemption '
							 + ISNULL('Number: ' + TE.[strException], '') 
							 + ISNULL('; Start Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; End Date: ' + CONVERT(NVARCHAR(25), TE.[dtmEndDate], 101), '')
							 + ISNULL('; Customer Location: ' + EL.[strLocationName], '')
							 + ISNULL('; Tax Class: ' + SMTC.[strTaxClass], '')
	FROM
		tblARCustomerTaxingTaxException TE
	LEFT OUTER JOIN
		tblEntityLocation EL
			ON TE.[intEntityCustomerLocationId] = EL.[intEntityLocationId]
	LEFT OUTER JOIN
		tblSMTaxClass SMTC
			ON TE.[intTaxClassId] = SMTC.[intTaxClassId]
	WHERE
		[intEntityCustomerId] = @CustomerId
		AND [intEntityCustomerLocationId] = @ShipToLocationId
		AND TE.[intTaxClassId] = @TaxClassId
		AND	CAST(@TransactionDate AS DATE) BETWEEN CAST(TE.[dtmStartDate] AS DATE) AND CAST(ISNULL(TE.[dtmEndDate], @TransactionDate) AS DATE)
	ORDER BY
		dtmStartDate	
		
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		RETURN @TaxCodeExemption	
	
	
	SELECT TOP 1
		@TaxCodeExemption = 'Tax Exemption '
							 + ISNULL('Number: ' + TE.[strException], '') 
							 + ISNULL('; Start Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; End Date: ' + CONVERT(NVARCHAR(25), TE.[dtmEndDate], 101), '')
							 + ISNULL('; Customer Location: ' + EL.[strLocationName], '')
							 + ISNULL('; Tax State: ' + TE.[strState], '')
	FROM
		tblARCustomerTaxingTaxException TE
	LEFT OUTER JOIN
		tblEntityLocation EL
			ON TE.[intEntityCustomerLocationId] = EL.[intEntityLocationId]
	WHERE
		[intEntityCustomerId] = @CustomerId
		AND TE.[intEntityCustomerLocationId] = @ShipToLocationId
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
							 + ISNULL('Number: ' + TE.[strException], '') 
							 + ISNULL('; Start Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; End Date: ' + CONVERT(NVARCHAR(25), TE.[dtmEndDate], 101), '')
							 + ISNULL('; Item No: ' + IC.[strItemNo], '')
							 + ISNULL('; Tax Code: ' + TC.[strTaxCode], '')
	FROM
		tblARCustomerTaxingTaxException TE
	LEFT OUTER JOIN
		tblSMTaxCode TC
			ON TE.[intTaxCodeId] = TC.[intTaxCodeId]
	LEFT OUTER JOIN
		tblICItem  IC
			ON TE.[intItemId] = IC.[intItemId]
	WHERE
		[intEntityCustomerId] = @CustomerId
		AND TE.[intItemId] = @ItemId
		AND TE.[intTaxCodeId] = @TaxCodeId
		AND	CAST(@TransactionDate AS DATE) BETWEEN CAST(TE.[dtmStartDate] AS DATE) AND CAST(ISNULL(TE.[dtmEndDate], @TransactionDate) AS DATE)
	ORDER BY
		dtmStartDate
		
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		RETURN @TaxCodeExemption
		
		
	SELECT TOP 1
		@TaxCodeExemption = 'Tax Exemption '
							 + ISNULL('Number: ' + TE.[strException], '') 
							 + ISNULL('; Start Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; End Date: ' + CONVERT(NVARCHAR(25), TE.[dtmEndDate], 101), '')
							 + ISNULL('; Item No: ' + IC.[strItemNo], '')
							 + ISNULL('; Tax Code: ' + TC.[strTaxClass], '')
	FROM
		tblARCustomerTaxingTaxException TE
	LEFT OUTER JOIN
		tblSMTaxClass TC
			ON TE.[intTaxClassId] = TC.[intTaxClassId]
	LEFT OUTER JOIN
		tblICItem  IC
			ON TE.[intItemId] = IC.[intItemId]
	WHERE
		[intEntityCustomerId] = @CustomerId
		AND TE.[intItemId] = @ItemId
		AND TE.[intTaxClassId] = @TaxClassId
		AND	CAST(@TransactionDate AS DATE) BETWEEN CAST(TE.[dtmStartDate] AS DATE) AND CAST(ISNULL(TE.[dtmEndDate], @TransactionDate) AS DATE)
	ORDER BY
		dtmStartDate
		
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		RETURN @TaxCodeExemption		
	
		
	SELECT TOP 1
		@TaxCodeExemption = 'Tax Exemption '
							 + ISNULL('Number: ' + TE.[strException], '') 
							 + ISNULL('; Start Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; End Date: ' + CONVERT(NVARCHAR(25), TE.[dtmEndDate], 101), '')
							 + ISNULL('; Item No: ' + IC.[strItemNo], '')
							 + ISNULL('; Tax Code: ' + TE.[strState], '')
	FROM
		tblARCustomerTaxingTaxException TE
	LEFT OUTER JOIN
		tblICItem  IC
			ON TE.[intItemId] = IC.[intItemId]
	WHERE
		[intEntityCustomerId] = @CustomerId
		AND TE.[intItemId] = @ItemId
		AND (LEN(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) > 0 AND UPPER(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) = @TaxState)
		AND	CAST(@TransactionDate AS DATE) BETWEEN CAST(TE.[dtmStartDate] AS DATE) AND CAST(ISNULL(TE.[dtmEndDate], @TransactionDate) AS DATE)
	ORDER BY
		dtmStartDate			
				
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		RETURN @TaxCodeExemption	
		
		
	SELECT TOP 1
		@TaxCodeExemption = 'Invalid Sales Tax Account for Tax Code ' + TC.[strTaxCode]
	FROM
		tblSMTaxCode TC
	WHERE
		TC.[intTaxCodeId] = @TaxCodeId
		AND	ISNULL(TC.[intSalesTaxAccountId],0) = 0	
			
				
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		RETURN @TaxCodeExemption				

				
	RETURN NULL		
END
