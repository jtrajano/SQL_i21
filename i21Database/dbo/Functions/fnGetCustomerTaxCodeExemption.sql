﻿CREATE FUNCTION [dbo].[fnGetCustomerTaxCodeExemption]
( 
	 @CustomerId			INT
	,@TransactionDate		DATETIME
	,@TaxCodeId				INT
	,@TaxClassId			INT
	,@TaxState				NVARCHAR(100)
	,@ItemId				INT
	,@ItemCategoryId		INT
	,@ShipToLocationId		INT
	,@IsCustomerSiteTaxable	BIT
)
RETURNS NVARCHAR(500)
AS
BEGIN
	DECLARE @TaxCodeExemption	NVARCHAR(500)
	
	IF @IsCustomerSiteTaxable IS NULL
		BEGIN
			--Customer
			IF EXISTS(SELECT NULL FROM tblARCustomer WHERE [intEntityCustomerId] = @CustomerId AND ISNULL([ysnTaxExempt],0) = 1)
				SET @TaxCodeExemption = 'Customer is tax exempted; Date: ' + CONVERT(NVARCHAR(20), GETDATE(), 101) + ' ' + CONVERT(NVARCHAR(20), GETDATE(), 114)
		
			IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
				RETURN @TaxCodeExemption
		END

	IF @IsCustomerSiteTaxable IS NOT NULL
		BEGIN
			--Customer
			IF ISNULL(@IsCustomerSiteTaxable,0) = 0
				SET @TaxCodeExemption = 'Customer Site is non taxable; Date: ' + CONVERT(NVARCHAR(20), GETDATE(), 101) + ' ' + CONVERT(NVARCHAR(20), GETDATE(), 114)
		
			IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
				RETURN @TaxCodeExemption
		END
		
	--Item Category Tax Class		
	IF NOT EXISTS	(
						SELECT
							ICCT.intTaxClassId
						FROM 
							tblICItem ICI
						INNER JOIN
							tblICCategory ICC
								ON ICI.[intCategoryId] = ICC.[intCategoryId]
						INNER JOIN 
							tblICCategoryTax ICCT
								ON ICC.[intCategoryId] = ICCT.[intCategoryId]
						WHERE 
							ICI.intItemId = @ItemId
							AND ICC.intCategoryId = @ItemCategoryId
							AND ICCT.intTaxClassId = @TaxClassId
					)
	BEGIN
		SET @TaxCodeExemption	= ISNULL('Tax Class - ' + (SELECT TOP 1 [strTaxClass] FROM tblSMTaxClass WHERE [intTaxClassId] = @TaxClassId), '')
								+ ISNULL(' is not included in Item Category - ' + (SELECT TOP 1 [strCategoryCode] FROM tblICCategory WHERE [intCategoryId] = @ItemCategoryId) + ' tax class setup.', '') 	
	END
		
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
		AND TE.[intItemId] = @ItemId
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
		AND ISNULL(TE.[intItemId],0) = 0
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
		AND ISNULL(TE.[intItemId],0) = 0
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
		AND ISNULL(TE.[intItemId],0) = 0
		AND LEN(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) > 0
		AND UPPER(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) = @TaxState
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
							 + ISNULL('; Item No: ' + IC.[strItemNo], '')
	FROM
		tblARCustomerTaxingTaxException TE
	LEFT OUTER JOIN
		tblEntityLocation EL
			ON TE.[intEntityCustomerLocationId] = EL.[intEntityLocationId]
	LEFT OUTER JOIN
		tblICItem  IC
			ON TE.[intItemId] = IC.[intItemId]
	WHERE
		[intEntityCustomerId] = @CustomerId
		AND TE.[intEntityCustomerLocationId] = @ShipToLocationId
		AND TE.[intItemId] = @ItemId
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
	FROM
		tblARCustomerTaxingTaxException TE
	LEFT OUTER JOIN
		tblEntityLocation EL
			ON TE.[intEntityCustomerLocationId] = EL.[intEntityLocationId]
	WHERE
		[intEntityCustomerId] = @CustomerId
		AND TE.[intEntityCustomerLocationId] = @ShipToLocationId
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
		AND ISNULL(TE.intEntityCustomerLocationId,0) = 0
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
							 + ISNULL('; Tax Class: ' + TC.[strTaxClass], '')
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
		AND ISNULL(TE.intEntityCustomerLocationId,0) = 0
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
							 + ISNULL('; Tax State: ' + TE.[strState], '')
	FROM
		tblARCustomerTaxingTaxException TE
	LEFT OUTER JOIN
		tblICItem  IC
			ON TE.[intItemId] = IC.[intItemId]
	WHERE
		[intEntityCustomerId] = @CustomerId
		AND ISNULL(TE.intEntityCustomerLocationId,0) = 0
		AND TE.[intItemId] = @ItemId
		AND (LEN(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) > 0 AND UPPER(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) = @TaxState)
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
	FROM
		tblARCustomerTaxingTaxException TE
	LEFT OUTER JOIN
		tblICItem  IC
			ON TE.[intItemId] = IC.[intItemId]
	WHERE
		[intEntityCustomerId] = @CustomerId
		AND ISNULL(TE.intEntityCustomerLocationId,0) = 0
		AND TE.[intItemId] = @ItemId
		AND	CAST(@TransactionDate AS DATE) BETWEEN CAST(TE.[dtmStartDate] AS DATE) AND CAST(ISNULL(TE.[dtmEndDate], @TransactionDate) AS DATE)
	ORDER BY
		dtmStartDate			
				
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		RETURN @TaxCodeExemption					
				
		
	--Tax Code
	SELECT TOP 1
		@TaxCodeExemption = 'Tax Exemption '
							 + ISNULL('Number: ' + TE.[strException], '') 
							 + ISNULL('; Start Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; End Date: ' + CONVERT(NVARCHAR(25), TE.[dtmEndDate], 101), '')
							 + ISNULL('; Tax Code: ' + TC.[strTaxCode], '')
	FROM
		tblARCustomerTaxingTaxException TE
	LEFT OUTER JOIN
		tblSMTaxCode TC
			ON TE.[intTaxCodeId] = TC.[intTaxCodeId]
	WHERE
		[intEntityCustomerId] = @CustomerId
		AND ISNULL(TE.intEntityCustomerLocationId,0) = 0
		AND ISNULL(TE.[intItemId],0) = 0
		AND TE.[intTaxCodeId] = @TaxCodeId
		AND	CAST(@TransactionDate AS DATE) BETWEEN CAST(TE.[dtmStartDate] AS DATE) AND CAST(ISNULL(TE.[dtmEndDate], @TransactionDate) AS DATE)
	ORDER BY
		dtmStartDate
		
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		RETURN @TaxCodeExemption
	
	--Tax Class
	SELECT TOP 1
		@TaxCodeExemption = 'Tax Exemption '
							 + ISNULL('Number: ' + TE.[strException], '') 
							 + ISNULL('; Start Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; End Date: ' + CONVERT(NVARCHAR(25), TE.[dtmEndDate], 101), '')
							 + ISNULL('; Tax Class: ' + SMTC.[strTaxClass], '')
	FROM
		tblARCustomerTaxingTaxException TE
	LEFT OUTER JOIN
		tblSMTaxClass SMTC
			ON TE.[intTaxClassId] = SMTC.[intTaxClassId]
	WHERE
		[intEntityCustomerId] = @CustomerId
		AND ISNULL(TE.intEntityCustomerLocationId,0) = 0
		AND ISNULL(TE.[intItemId],0) = 0
		AND TE.[intTaxClassId] = @TaxClassId
		AND	CAST(@TransactionDate AS DATE) BETWEEN CAST(TE.[dtmStartDate] AS DATE) AND CAST(ISNULL(TE.[dtmEndDate], @TransactionDate) AS DATE)
	ORDER BY
		dtmStartDate	
		
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		RETURN @TaxCodeExemption	
	
	--Tax State
	SELECT TOP 1
		@TaxCodeExemption = 'Tax Exemption '
							 + ISNULL('Number: ' + TE.[strException], '') 
							 + ISNULL('; Start Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; End Date: ' + CONVERT(NVARCHAR(25), TE.[dtmEndDate], 101), '')
							 + ISNULL('; Tax State: ' + TE.[strState], '')
	FROM
		tblARCustomerTaxingTaxException TE
	LEFT OUTER JOIN
		tblEntityLocation EL
			ON TE.[intEntityCustomerLocationId] = EL.[intEntityLocationId]
	WHERE
		[intEntityCustomerId] = @CustomerId
		AND ISNULL(TE.intEntityCustomerLocationId,0) = 0
		AND ISNULL(TE.[intItemId],0) = 0
		AND LEN(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) > 0
		AND UPPER(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) = @TaxState
		AND	CAST(@TransactionDate AS DATE) BETWEEN CAST(TE.[dtmStartDate] AS DATE) AND CAST(ISNULL(TE.[dtmEndDate], @TransactionDate) AS DATE)
	ORDER BY
		dtmStartDate	
		
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		RETURN @TaxCodeExemption	
		
	--Sales Tax Account
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
