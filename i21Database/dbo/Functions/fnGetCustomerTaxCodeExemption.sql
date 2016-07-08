CREATE FUNCTION [dbo].[fnGetCustomerTaxCodeExemption]
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
--RETURNS NVARCHAR(500)
RETURNS @returntable TABLE
(
	 [ysnTaxExempt]			BIT
	,[ysnInvalidSetup]		BIT
	,[strExemptionNotes]	NVARCHAR(500)
	,[dblExemptionPercent]	NUMERIC(18,6)
)
AS
BEGIN
	DECLARE	@TaxCodeExemption	NVARCHAR(500)
			,@ExemptionPercent	NUMERIC(18,6)
			,@TaxExempt			BIT
			,@InvalidSetup		BIT
	
	SET @TaxCodeExemption = NULL
	SET @ExemptionPercent = 0.00000
	SET @TaxExempt = 0
	SET @InvalidSetup = 0

	IF @IsCustomerSiteTaxable IS NULL
		BEGIN
			--Customer
			IF EXISTS(SELECT NULL FROM tblARCustomer WHERE [intEntityCustomerId] = @CustomerId AND ISNULL([ysnTaxExempt],0) = 1)
				SET @TaxCodeExemption = 'Customer is tax exempted; Date: ' + CONVERT(NVARCHAR(20), GETDATE(), 101) + ' ' + CONVERT(NVARCHAR(20), GETDATE(), 114)
		
			IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
				BEGIN
					INSERT INTO @returntable
					SELECT 
						 [ysnTaxExempt] = 1
						,[ysnInvalidSetup] = @InvalidSetup
						,[strExemptionNotes] = @TaxCodeExemption
						,[dblExemptionPercent] = @ExemptionPercent
					RETURN 
				END
				
		END
	
	IF @IsCustomerSiteTaxable IS NOT NULL
		BEGIN
			--Customer
			IF ISNULL(@IsCustomerSiteTaxable,0) = 0
				SET @TaxCodeExemption = 'Customer Site is non taxable; Date: ' + CONVERT(NVARCHAR(20), GETDATE(), 101) + ' ' + CONVERT(NVARCHAR(20), GETDATE(), 114)
		
			IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
			INSERT INTO @returntable
			SELECT 
				 [ysnTaxExempt] = 1
				,[ysnInvalidSetup] = @InvalidSetup
				,[strExemptionNotes] = @TaxCodeExemption
				,[dblExemptionPercent] = @ExemptionPercent
			RETURN 			 
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
		SET @InvalidSetup = 1
	END
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		BEGIN
			INSERT INTO @returntable
			SELECT 
				 [ysnTaxExempt] = 1
				,[ysnInvalidSetup] = @InvalidSetup
				,[strExemptionNotes] = @TaxCodeExemption
				,[dblExemptionPercent] = @ExemptionPercent
			RETURN 	
		END
	
	--Customer Tax Exemption
	SET @ExemptionPercent = 0.00000
	SELECT TOP 1
		@TaxCodeExemption =  'Tax Exemption > '
							 + ISNULL('Number: ' + CAST(TE.[intCustomerTaxingTaxExceptionId] AS NVARCHAR(250)) +  ' - ' + ISNULL(TE.[strException], ''), '') 
							 + ISNULL('; Start Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; End Date: ' + CONVERT(NVARCHAR(25), TE.[dtmEndDate], 101), '')
							 + ISNULL('; Customer Location: ' + EL.[strLocationName], '')
							 + ISNULL('; Item No: ' + IC.[strItemNo], '')
							 + ISNULL('; Item Category: ' + ICC.[strCategoryCode], '')
							 + ISNULL('; Tax Code: ' + TC.[strTaxCode], '')
							 + ISNULL('; Tax Class: ' + TCL.[strTaxClass], '')
							 + ISNULL('; Tax State: ' + TE.[strState], '')
		,@ExemptionPercent = TE.[dblPartialTax] 
	FROM
		tblARCustomerTaxingTaxException TE
	LEFT OUTER JOIN
		tblSMTaxCode TC
			ON TE.[intTaxCodeId] = TC.[intTaxCodeId]
	LEFT OUTER JOIN
		[tblEMEntityLocation] EL
			ON TE.[intEntityCustomerLocationId] = EL.[intEntityLocationId]
	LEFT OUTER JOIN
		tblSMTaxClass TCL
			ON TE.[intTaxClassId] = TCL.[intTaxClassId]
	LEFT OUTER JOIN
		tblICItem  IC
			ON TE.[intItemId] = IC.[intItemId]
	LEFT OUTER JOIN
		tblICCategory ICC
			ON TE.[intCategoryId] = ICC.[intCategoryId]
	WHERE
		TE.[intEntityCustomerId] = @CustomerId
		AND	CAST(@TransactionDate AS DATE) BETWEEN CAST(ISNULL(TE.[dtmStartDate], @TransactionDate) AS DATE) AND CAST(ISNULL(TE.[dtmEndDate], @TransactionDate) AS DATE)
		AND (ISNULL(TE.[intEntityCustomerLocationId], 0) = 0 OR TE.[intEntityCustomerLocationId] = @ShipToLocationId)
		AND (ISNULL(TE.[intItemId], 0) = 0 OR TE.[intItemId] = @ItemId)
		AND (ISNULL(TE.[intCategoryId], 0) = 0 OR TE.[intCategoryId] = @ItemCategoryId)
		AND (ISNULL(TE.[intTaxCodeId], 0) = 0 OR TE.[intTaxCodeId] = @TaxCodeId)
		AND (ISNULL(TE.[intTaxClassId], 0) = 0 OR TE.[intTaxClassId] = @TaxClassId)
		AND (LEN(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) <= 0 OR (LEN(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) > 0 AND UPPER(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) = UPPER(LTRIM(RTRIM(@TaxState)))))
	ORDER BY
		(
			(CASE WHEN ISNULL(TE.[intEntityCustomerLocationId],0) = 0 THEN 0 ELSE 1 END)
			+
			(CASE WHEN ISNULL(TE.[intItemId],0) = 0 THEN 0 ELSE 1 END)
			+
			(CASE WHEN ISNULL(TE.[intCategoryId],0) = 0 THEN 0 ELSE 1 END)
			+
			(CASE WHEN ISNULL(TE.[intTaxCodeId],0) = 0 THEN 0 ELSE 1 END)
			+
			(CASE WHEN ISNULL(TE.[intTaxClassId],0) = 0 THEN 0 ELSE 1 END)
			+
			(CASE WHEN LEN(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) <= 0 THEN 0 ELSE 1 END)
		) DESC
		,ISNULL(TE.[dtmStartDate], @TransactionDate) ASC
		,ISNULL(TE.[dtmEndDate], @TransactionDate) DESC
		
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		BEGIN
			INSERT INTO @returntable
			SELECT 
				 [ysnTaxExempt] = 1
				,[ysnInvalidSetup] = @InvalidSetup
				,[strExemptionNotes] = @TaxCodeExemption
				,[dblExemptionPercent] = ISNULL(@ExemptionPercent, 0.000000)
			RETURN 	
		END	
		
	--Sales Tax Account
	SELECT TOP 1
		@TaxCodeExemption = 'Invalid Sales Tax Account for Tax Code ' + TC.[strTaxCode]
	FROM
		tblSMTaxCode TC
	WHERE
		TC.[intTaxCodeId] = @TaxCodeId
		AND	ISNULL(TC.[intSalesTaxAccountId],0) = 0	
			
				
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		BEGIN
			INSERT INTO @returntable
			SELECT 
				 [ysnTaxExempt] = 1
				,[ysnInvalidSetup] = 1
				,[strExemptionNotes] = @TaxCodeExemption
				,[dblExemptionPercent] = ISNULL(@ExemptionPercent, 0.000000)
			RETURN 	
		END					
	
	IF (@TaxExempt = 0)
	BEGIN
		IF EXISTS(SELECT TOP 1 intCategoryId FROM tblSMTaxGroupCodeCategoryExemption 
					WHERE intTaxGroupCodeId IN (SELECT intTaxGroupCodeId FROM [tblSMTaxGroupCode] WHERE intTaxCodeId = @TaxCodeId) AND intCategoryId = @ItemCategoryId
		)
		BEGIN
			SET @TaxExempt = 1
		END
	END

	INSERT INTO @returntable
	SELECT 
		[ysnTaxExempt] = @TaxExempt
		,[ysnInvalidSetup] = @InvalidSetup
		,[strExemptionNotes] = @TaxCodeExemption
		,[dblExemptionPercent] = ISNULL(@ExemptionPercent, 0.000000)				
	RETURN		
END
