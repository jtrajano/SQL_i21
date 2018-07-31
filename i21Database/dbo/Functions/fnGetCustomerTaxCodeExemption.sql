CREATE FUNCTION [dbo].[fnGetCustomerTaxCodeExemption]
( 
	 @CustomerId				INT
	,@TransactionDate			DATETIME
	,@TaxGroupId				INT
	,@TaxCodeId					INT
	,@TaxClassId				INT
	,@TaxState					NVARCHAR(100)
	,@ItemId					INT
	,@ItemCategoryId			INT
	,@ShipToLocationId			INT
	,@IsCustomerSiteTaxable		BIT
	,@CardId					INT
	,@VehicleId					INT
	,@SiteId					INT
	,@DisregardExemptionSetup	BIT
	,@CompanyLocationId			INT
	,@FreightTermId				INT
	,@CFSiteId					INT
	,@IsDeliver					BIT
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
			,@State				NVARCHAR(100)
			,@SiteNumberId		INT
	
	SET @TaxCodeExemption = NULL
	SET @ExemptionPercent = 0.00000
	SET @TaxExempt = 0
	SET @InvalidSetup = 0
	SET @DisregardExemptionSetup = ISNULL(@DisregardExemptionSetup, 0)
	
	--Customer
	IF EXISTS(SELECT NULL FROM tblARCustomer WHERE [intEntityId] = @CustomerId AND ISNULL([ysnTaxExempt],0) = 1)
		SET @TaxCodeExemption = 'Customer is tax exempted; Date: ' + CONVERT(NVARCHAR(20), GETDATE(), 101) + ' ' + CONVERT(NVARCHAR(20), GETDATE(), 114)
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0 AND @DisregardExemptionSetup <> 1
		BEGIN
			INSERT INTO @returntable
			SELECT 
				 [ysnTaxExempt] = 1
				,[ysnInvalidSetup] = @InvalidSetup
				,[strExemptionNotes] = @TaxCodeExemption
				,[dblExemptionPercent] = @ExemptionPercent
			RETURN 
		END

	IF ISNULL(@SiteId, 0) <> 0
		BEGIN
			SELECT TOP 1 @SiteNumberId = intSiteNumber
			FROM tblTMSite 
			WHERE intSiteID = @SiteId
		END
				
		--END
	
	--IF @IsCustomerSiteTaxable IS NOT NULL
	--	BEGIN
	--		--Customer
	--		IF ISNULL(@IsCustomerSiteTaxable,0) = 0 AND @DisregardExemptionSetup <> 1
	--			SET @TaxCodeExemption = 'Customer Site is non taxable; Date: ' + CONVERT(NVARCHAR(20), GETDATE(), 101) + ' ' + CONVERT(NVARCHAR(20), GETDATE(), 114)
		
	--		IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
	--		INSERT INTO @returntable
	--		SELECT 
	--			 [ysnTaxExempt] = 1
	--			,[ysnInvalidSetup] = @InvalidSetup
	--			,[strExemptionNotes] = @TaxCodeExemption
	--			,[dblExemptionPercent] = @ExemptionPercent
	--		RETURN 			 
	--	END


	SELECT TOP 1
		@TaxCodeExemption =  'Customer Site is non sales-taxable; Date: ' + CONVERT(NVARCHAR(20), GETDATE(), 101) + ' ' + CONVERT(NVARCHAR(20), GETDATE(), 114)
	FROM
		tblSMTaxGroupCode SMTGC
	INNER JOIN
		tblSMTaxGroup SMTG
			ON SMTGC.[intTaxGroupId] = SMTG.[intTaxGroupId] 
	INNER JOIN
		tblSMTaxCode SMTC
			ON SMTGC.[intTaxCodeId] = SMTC.[intTaxCodeId] 
	INNER JOIN
		tblSMTaxClass SMTCL
			ON SMTC.[intTaxClassId] = SMTCL.[intTaxClassId]
	WHERE
		@IsCustomerSiteTaxable IS NOT NULL
		AND @IsCustomerSiteTaxable = 0
		AND SMTCL.strTaxClass LIKE '%Sales Tax%'
		AND SMTGC.[intTaxCodeId] = @TaxCodeId
		AND SMTGC.[intTaxGroupId] = @TaxGroupId		

	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0 AND @DisregardExemptionSetup <> 1
		BEGIN
			INSERT INTO @returntable
			SELECT 
				 [ysnTaxExempt] = 1
				,[ysnInvalidSetup] = @InvalidSetup
				,[strExemptionNotes] = @TaxCodeExemption
				,[dblExemptionPercent] = @ExemptionPercent
			RETURN 	
		END


	SELECT TOP 1
		@TaxCodeExemption =  'Tax Code - ' + SMTC.[strTaxCode] +  ' under Tax Group  ' + SMTG.strTaxGroup + ' has an exemption set for item category - ' + ICC.[strCategoryCode] 
	FROM
		tblSMTaxGroupCodeCategoryExemption SMTGCE
	INNER JOIN
		tblSMTaxGroupCode SMTGC
			ON SMTGCE.[intTaxGroupCodeId] = SMTGC.[intTaxGroupCodeId]
	INNER JOIN
		tblSMTaxGroup SMTG
			ON SMTGC.[intTaxGroupId] = SMTG.[intTaxGroupId] 
	INNER JOIN
		tblSMTaxCode SMTC
			ON SMTGC.[intTaxCodeId] = SMTC.[intTaxCodeId] 
	INNER JOIN
		tblICCategory ICC
			ON SMTGCE.[intCategoryId] = ICC.[intCategoryId]
	WHERE 
		SMTGCE.intCategoryId = @ItemCategoryId
		AND SMTGC.[intTaxCodeId] = @TaxCodeId
		AND SMTGC.[intTaxGroupId] = @TaxGroupId		

	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0 AND @DisregardExemptionSetup <> 1
		BEGIN
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
		--AND ISNULL(@ItemId,0) <> 0
	BEGIN
		SET @TaxCodeExemption	= ISNULL('Tax Class - ' + (SELECT TOP 1 [strTaxClass] FROM tblSMTaxClass WHERE [intTaxClassId] = @TaxClassId), '')
								+ ISNULL(' is not included in Item Category - ' + (SELECT TOP 1 [strCategoryCode] FROM tblICCategory WHERE [intCategoryId] = @ItemCategoryId) + ' tax class setup.', '') 	
		SET @InvalidSetup = 1
	END
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0 --AND @DisregardExemptionSetup <> 1
		BEGIN
			INSERT INTO @returntable
			SELECT 
				 [ysnTaxExempt] = 1
				,[ysnInvalidSetup] = @InvalidSetup
				,[strExemptionNotes] = @TaxCodeExemption
				,[dblExemptionPercent] = @ExemptionPercent
			RETURN 	
		END

	DECLARE @FOB NVARCHAR(150)
		SET @FOB = LOWER(RTRIM(LTRIM(ISNULL((SELECT [strFobPoint] FROM tblSMFreightTerms WHERE [intFreightTermId] = @FreightTermId),''))))

	SET @State = @TaxState

	IF ISNULL(@CFSiteId,0) <> 0 AND (ISNULL(@IsDeliver,0) = 0 OR @FOB = 'origin')
		SET @State = ISNULL((SELECT TOP 1 [strTaxState] FROM tblCFSite WHERE [intSiteId] = @CFSiteId), @TaxState)
	ELSE
	BEGIN		

		IF (ISNULL(@FreightTermId,0) <> 0 AND @FOB <> 'origin') OR (ISNULL(@FreightTermId,0) = 0 AND ISNULL(@IsDeliver,0) = 1)
			SET @State = ISNULL((SELECT TOP 1 [strState] FROM tblEMEntityLocation WHERE	[intEntityLocationId] = @ShipToLocationId), @TaxState)

		IF ISNULL(@FreightTermId,0) <> 0 AND @FOB = 'origin'
			SET @State = ISNULL((SELECT TOP 1 strStateProvince FROM tblSMCompanyLocation WHERE	[intCompanyLocationId] = @CompanyLocationId), @TaxState)
	END
	
	--Customer Tax Exemption
	SET @ExemptionPercent = 0.00000
	SELECT TOP 1
		@TaxCodeExemption =  'Tax Exemption > '
							 + ISNULL('Number: ' + CAST(TE.[intCustomerTaxingTaxExceptionId] AS NVARCHAR(250)) +  ' - ' + ISNULL(TE.[strException], ''), '') 
							 + ISNULL('; Start Date: ' + CONVERT(NVARCHAR(25), TE.[dtmStartDate], 101), '')
							 + ISNULL('; End Date: ' + CONVERT(NVARCHAR(25), TE.[dtmEndDate], 101), '')
							 + ISNULL('; Card: ' + CFC.[strCardNumber], '')
							 + ISNULL('; Vehicle: ' + CFV.[strVehicleNumber], '')
							 + ISNULL('; Site No: ' + REPLACE(STR(TMS.[intSiteNumber], 4), SPACE(1), '0'), '')
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
	LEFT OUTER JOIN
		tblCFCard CFC
			ON TE.[intCardId] = CFC.[intCardId]
	LEFT OUTER JOIN
		tblCFVehicle CFV
			ON TE.[intVehicleId] = CFV.[intVehicleId] 
	LEFT OUTER JOIN
		tblTMSite TMS
			ON TE.[intSiteNumber] = TMS.[intSiteNumber]
	WHERE
		TE.[intEntityCustomerId] = @CustomerId		
		AND	CAST(@TransactionDate AS DATE) BETWEEN CAST(ISNULL(TE.[dtmStartDate], @TransactionDate) AS DATE) AND CAST(ISNULL(TE.[dtmEndDate], @TransactionDate) AS DATE)
		AND (ISNULL(TE.[intEntityCustomerLocationId], 0) = 0 OR TE.[intEntityCustomerLocationId] = @ShipToLocationId)
		AND (ISNULL(TE.[intItemId], 0) = 0 OR TE.[intItemId] = @ItemId)
		AND (ISNULL(TE.[intCategoryId], 0) = 0 OR TE.[intCategoryId] = @ItemCategoryId)
		AND (ISNULL(TE.[intTaxCodeId], 0) = 0 OR TE.[intTaxCodeId] = @TaxCodeId)
		AND (ISNULL(TE.[intTaxClassId], 0) = 0 OR TE.[intTaxClassId] = @TaxClassId)	
		AND (ISNULL(TE.[intSiteNumber], 0) = 0 OR TE.[intSiteNumber] = @SiteNumberId)
		AND (
				(ISNULL(TE.[intCardId], 0) <> 0 AND ISNULL(TE.[intVehicleId], 0) <> 0 AND TE.[intCardId] = @CardId AND TE.[intVehicleId] = @VehicleId)
				OR
				(ISNULL(TE.[intCardId], 0) = 0 AND ISNULL(TE.[intVehicleId], 0) <> 0 AND TE.[intVehicleId] = @VehicleId)
				OR
				(ISNULL(TE.[intVehicleId], 0) = 0 AND ISNULL(TE.[intCardId], 0) <> 0 AND TE.[intCardId] = @CardId)
				OR
				(ISNULL(TE.[intCardId], 0) = 0 AND ISNULL(TE.[intVehicleId], 0) = 0)

			)
		AND (LEN(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) <= 0 OR (TE.[strState] = @State AND @State = @TaxState) OR LEN(LTRIM(RTRIM(ISNULL(@State,'')))) <= 0 )
		--AND (LEN(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) <= 0 OR ISNULL(TE.[intTaxCodeId], 0) = 0 OR (LEN(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) > 0 AND UPPER(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) = UPPER(LTRIM(RTRIM(@TaxState)))))
	ORDER BY
		(
			(CASE WHEN ISNULL(TE.[intCardId],0) = 0 THEN 0 ELSE 1 END)
			+
			(CASE WHEN ISNULL(TE.[intVehicleId],0) = 0 THEN 0 ELSE 1 END)
			+
			(CASE WHEN ISNULL(TE.[intSiteNumber],0) = 0 THEN 0 ELSE 1 END)		
		) DESC
		,(
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
		
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0 AND @DisregardExemptionSetup <> 1
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
			
				
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0 AND @DisregardExemptionSetup <> 1
		BEGIN
			INSERT INTO @returntable
			SELECT 
				 [ysnTaxExempt] = 1
				,[ysnInvalidSetup] = 1
				,[strExemptionNotes] = @TaxCodeExemption
				,[dblExemptionPercent] = ISNULL(@ExemptionPercent, 0.000000)
			RETURN 	
		END
		
	SET @TaxCodeExemption = NULL
	SET @ExemptionPercent = 0.00000
	SET @TaxExempt = 0
	SET @InvalidSetup = 0				
	
	INSERT INTO @returntable
	SELECT 
		[ysnTaxExempt] = @TaxExempt
		,[ysnInvalidSetup] = @InvalidSetup
		,[strExemptionNotes] = @TaxCodeExemption
		,[dblExemptionPercent] = ISNULL(@ExemptionPercent, 0.000000)				
	RETURN		
END
