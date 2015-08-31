CREATE PROCEDURE [dbo].[uspARGetItemTaxes]
	@ItemId				INT
	,@LocationId		INT	
	,@CustomerId		INT			= NULL	
	,@TransactionDate	DATETIME
	,@TaxMasterId		INT			= NULL	
	,@TaxGroupId		INT			= NULL		
AS

--DECLARE 	
-- @ItemId			INT
-- ,@LocationId		INT
-- ,@CustomerId		INT	

--SET @ItemId = 5323
--SET @LocationId = 1
--SET @CustomerId = 10075


	IF @TaxGroupId IS NOT NULL AND @TaxGroupId <> 0
		BEGIN
			SELECT
				0
				,0 AS [intInvoiceDetailId]
				,0 AS [intTaxGroupMasterId] 
				,TG.[intTaxGroupId] 
				,TC.[intTaxCodeId]
				,TC.[intTaxClassId]				
				,TC.[strTaxableByOtherTaxes]
				,ISNULL((SELECT TOP 1 tblSMTaxCodeRate.[strCalculationMethod] FROM tblSMTaxCodeRate WHERE tblSMTaxCodeRate.[intTaxCodeId] = TC.[intTaxCodeId] AND  CAST(tblSMTaxCodeRate.[dtmEffectiveDate]  AS DATE) <= CAST(@TransactionDate AS DATE) ORDER BY tblSMTaxCodeRate.[dtmEffectiveDate]ASC ,tblSMTaxCodeRate.[numRate] DESC), 'Unit') AS [strCalculationMethod]
				,ISNULL((SELECT TOP 1 tblSMTaxCodeRate.[numRate] FROM tblSMTaxCodeRate WHERE tblSMTaxCodeRate.[intTaxCodeId] = TC.[intTaxCodeId] AND  CAST(tblSMTaxCodeRate.[dtmEffectiveDate]  AS DATE) <= CAST(@TransactionDate AS DATE) ORDER BY tblSMTaxCodeRate.[dtmEffectiveDate]ASC ,tblSMTaxCodeRate.[numRate] DESC), 0.00) AS [numRate]
				,0.00 AS [dblTax]
				,0.00 AS [dblAdjustedTax]				
				,TC.[intSalesTaxAccountId]								
				,0 [ysnSeparateOnInvoice] 
				,TC.[ysnCheckoffTax]
				,TC.[strTaxCode]
				,0 AS [ysnTaxExempt] 				
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
				AND (TC.[intSalesTaxAccountId] IS NOT NULL
					AND TC.[intSalesTaxAccountId] <> 0)
			ORDER BY
				TGC.[intTaxGroupCodeId]
				
			RETURN 1
		END

	DECLARE @CustomerSpecialTax TABLE(
		[intARSpecialTaxId] INT
		,[intEntityCustomerId] INT
		,[intEntityVendorId] INT
		,[intItemId] INT
		,[intCategoryId] INT
		,[intTaxGroupMasterId] INT)


	INSERT INTO @CustomerSpecialTax(
		 [intARSpecialTaxId]
		,[intEntityCustomerId]
		,[intEntityVendorId]
		,[intItemId]
		,[intCategoryId]
		,[intTaxGroupMasterId])
	SELECT
		 ST.[intARSpecialTaxId]
		,ST.[intEntityCustomerId]
		,ST.[intEntityVendorId]
		,ST.[intItemId]
		,ST.[intCategoryId]
		,ST.[intTaxGroupMasterId]
	FROM
		tblARSpecialTax ST
	INNER JOIN
		tblARCustomer C
			ON ST.[intEntityCustomerId] = C.[intEntityCustomerId]
	WHERE
		C.intEntityCustomerId = @CustomerId

	DECLARE @TaxGroupMasterId INT
			,@VendorId INT
			,@ItemCategoryId INT
			,@TaxExempt BIT

	SELECT
		@VendorId = VI.intVendorId
		,@ItemCategoryId = I.intCategoryId
	FROM
		tblICItem I
	INNER JOIN
		vyuICGetItemStock VI
			ON I.intItemId = VI.intItemId
	INNER JOIN
		tblICCategory C
			ON I.intCategoryId = C.intCategoryId
	WHERE
		I.intItemId = @ItemId
		AND VI.[intLocationId]	 = @LocationId
		
	SET @TaxExempt = ISNULL((SELECT ysnTaxExempt FROM tblARCustomer WHERE intEntityCustomerId = @CustomerId AND @CustomerId IS NOT NULL),0)

	--Customer Special Tax
	IF(EXISTS(SELECT TOP 1 NULL FROM @CustomerSpecialTax))
	BEGIN

		SELECT
			@TaxGroupMasterId = [intTaxGroupMasterId]
		FROM
			@CustomerSpecialTax
		WHERE
			[intEntityVendorId] = @VendorId 
			AND [intItemId] = @ItemId 
			
		IF @TaxGroupMasterId IS NULL OR @TaxGroupMasterId = 0
			BEGIN				
				SELECT
					@TaxGroupMasterId = [intTaxGroupMasterId]
				FROM
					@CustomerSpecialTax
				WHERE
					[intEntityVendorId] = @VendorId 
					AND [intCategoryId] = @ItemCategoryId   
			END
			
		IF @TaxGroupMasterId IS NULL OR @TaxGroupMasterId = 0
			BEGIN				
				SELECT
					@TaxGroupMasterId = [intTaxGroupMasterId]
				FROM
					@CustomerSpecialTax
				WHERE
					[intEntityVendorId] = @VendorId 
			END	
			
		IF @TaxGroupMasterId IS NULL OR @TaxGroupMasterId = 0
			BEGIN				
				SELECT
					@TaxGroupMasterId = [intTaxGroupMasterId]
				FROM
					@CustomerSpecialTax
				WHERE
					[intItemId] = @ItemId  
			END		
			
		IF @TaxGroupMasterId IS NULL OR @TaxGroupMasterId = 0
			BEGIN				
				SELECT
					@TaxGroupMasterId = [intTaxGroupMasterId]
				FROM
					@CustomerSpecialTax
				WHERE
					[intCategoryId] = @ItemCategoryId  
			END																
													
	END
			
	IF @TaxGroupMasterId IS NULL OR @TaxGroupMasterId = 0
		BEGIN				
			SELECT
				@TaxGroupMasterId = [intSalesTaxGroupId]
			FROM
				tblICItem
			WHERE
				[intItemId] = @ItemId    
		END
		
	IF @TaxMasterId IS NOT NULL AND @TaxMasterId <> 0
		SET	@TaxGroupMasterId = @TaxMasterId
	
	
	IF @TaxGroupMasterId IS NOT NULL OR @TaxGroupMasterId <> 0
		BEGIN	
		
			DECLARE @Country nvarchar(MAX)
					,@County nvarchar(MAX)
					,@City nvarchar(MAX)
					,@State nvarchar(MAX)				
					
			IF @TaxMasterId IS NULL OR @TaxMasterId = 0
				BEGIN
					SELECT
						@Country = UPPER(RTRIM(LTRIM(ISNULL(ISNULL(SL.[strCountry], EL.[strCountry]),''))))
						,@State = UPPER(RTRIM(LTRIM(ISNULL(ISNULL(SL.[strState], EL.[strState]),''))))
						,@County = UPPER(RTRIM(LTRIM(ISNULL(TC.[strCounty],'')))) 
						,@City = UPPER(RTRIM(LTRIM(ISNULL(ISNULL(SL.[strCity], EL.[strCity]),''))))
					FROM
						tblARCustomer C
					LEFT OUTER JOIN
						(	SELECT
								[intEntityLocationId]
								,[intEntityId] 
								,[strCountry]
								,[strState]
								,[strCity]
							FROM 
							tblEntityLocation
							WHERE
								ysnDefaultLocation = 1
						) EL
							ON C.[intEntityCustomerId] = EL.[intEntityId]
					LEFT OUTER JOIN
						tblEntityLocation SL
							ON C.[intShipToId] = SL.[intEntityLocationId]
					LEFT OUTER JOIN
						tblSMTaxCode TC
							ON C.[intTaxCodeId] = TC.[intTaxCodeId] 								
					WHERE
						C.[intEntityCustomerId] = @CustomerId
				END
			ELSE
				BEGIN
					SELECT
						@Country = UPPER(RTRIM(LTRIM(ISNULL(CL.[strCountry], ''))))
						,@State = UPPER(RTRIM(LTRIM(ISNULL(CL.[strStateProvince], ''))))
						,@County = '' 
						,@City = UPPER(RTRIM(LTRIM(ISNULL(CL.[strCity], ''))))
					FROM
						tblSMCompanyLocation CL													
					WHERE
						CL.[intCompanyLocationId] = @LocationId				
				END
			

				
			DECLARE @TaxGroups TABLE(intTaxGroupId INT)				
			DECLARE @ValidTaxGroups TABLE(intTaxGroupId INT)				
			DECLARE @TaxCodes TABLE(
				intTaxGroupMasterId INT
				,intTaxGroupId INT
				,intTaxCodeId INT
				,strCountry NVARCHAR(500)
				,strState NVARCHAR(500)
				,strCounty NVARCHAR(500)
				,strCity NVARCHAR(500))			
			
			INSERT INTO @TaxCodes
			SELECT DISTINCT 
				TGM.[intTaxGroupMasterId]
				,TG.[intTaxGroupId]
				,TC.[intTaxCodeId]
				,UPPER(RTRIM(LTRIM(TC.[strCountry])))
				,UPPER(RTRIM(LTRIM(TC.[strState])))
				,UPPER(RTRIM(LTRIM(TC.[strCounty])))
				,UPPER(RTRIM(LTRIM(TC.[strCity])))
			FROM tblSMTaxCode TC	
				INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
				INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
				INNER JOIN tblSMTaxGroupMasterGroup TGTM ON TG.[intTaxGroupId] = TGTM.[intTaxGroupId]
				INNER JOIN tblSMTaxGroupMaster TGM ON TGTM.[intTaxGroupMasterId] = TGM.[intTaxGroupMasterId]
			WHERE 
				TGM.[intTaxGroupMasterId] = @TaxGroupMasterId
				AND TC.[intTaxCodeId] NOT IN
					(
						SELECT DISTINCT TC.intTaxCodeId
						FROM tblSMTaxCode TC	
							INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
							INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
							INNER JOIN tblSMTaxGroupMasterGroup TGTM ON TG.[intTaxGroupId] = TGTM.[intTaxGroupId]
							INNER JOIN tblSMTaxGroupMaster TGM ON TGTM.[intTaxGroupMasterId] = TGM.[intTaxGroupMasterId]
						WHERE 
							TGM.[intTaxGroupMasterId] = @TaxGroupMasterId
						GROUP BY
							TC.intTaxCodeId
						HAVING COUNT(TC.intTaxCodeId) > 1
					)
											
			
			INSERT INTO @TaxGroups
			SELECT DISTINCT [intTaxGroupId]
			FROM @TaxCodes
			


			--Country
			INSERT INTO @ValidTaxGroups
			SELECT DISTINCT
				[intTaxGroupId] 
			FROM 
				@TaxCodes
			WHERE
				[strCountry] = @Country 
				
			IF (SELECT COUNT(1) FROM @TaxGroups) > 1 AND ((SELECT COUNT(1) FROM @TaxGroups) > (SELECT COUNT(1) FROM @ValidTaxGroups))
				BEGIN
					DELETE FROM @TaxGroups
					WHERE [intTaxGroupId] NOT IN (SELECT DISTINCT [intTaxGroupId] FROM @ValidTaxGroups)				
				END
				
				
			DELETE FROM @ValidTaxGroups				
			--State
			INSERT INTO @ValidTaxGroups
			SELECT DISTINCT
				[intTaxGroupId] 
			FROM 
				@TaxCodes
			WHERE 
				[strCountry] = @Country
				AND [strState] = @State 																			
			IF (SELECT COUNT(1) FROM @TaxGroups) > 1 AND ((SELECT COUNT(1) FROM @TaxGroups) > (SELECT COUNT(1) FROM @ValidTaxGroups))
				BEGIN
					DELETE FROM @TaxGroups
					WHERE [intTaxGroupId] NOT IN (SELECT DISTINCT [intTaxGroupId] FROM @ValidTaxGroups)
				END
				
			DELETE FROM @ValidTaxGroups				
			--County
			INSERT INTO @ValidTaxGroups
			SELECT DISTINCT
				[intTaxGroupId] 
			FROM 
				@TaxCodes
			WHERE 
				[strCountry] = @Country
				AND [strState] = @State
				AND [strCounty] = @County	
			IF (SELECT COUNT(1) FROM @TaxGroups) > 1 AND ((SELECT COUNT(1) FROM @TaxGroups) > (SELECT COUNT(1) FROM @ValidTaxGroups))
				BEGIN
					DELETE FROM @TaxGroups
					WHERE [intTaxGroupId] NOT IN (SELECT DISTINCT [intTaxGroupId] FROM @ValidTaxGroups)			
				END	
				
			DELETE FROM @ValidTaxGroups				
			--City
			INSERT INTO @ValidTaxGroups
			SELECT DISTINCT
				[intTaxGroupId] 
			FROM 
				@TaxCodes
			WHERE 
				[strCountry] = @Country
				AND [strState] = @State
				AND [strCounty] = @County
				AND [strCity] = @City																					
			IF (SELECT COUNT(1) FROM @TaxGroups) > 1 AND ((SELECT COUNT(1) FROM @TaxGroups) > (SELECT COUNT(1) FROM @ValidTaxGroups))
				BEGIN
					DELETE FROM @TaxGroups
					WHERE [intTaxGroupId] NOT IN (SELECT DISTINCT [intTaxGroupId] FROM @ValidTaxGroups)				
				END	
				
					
			SELECT
				0
				,0 AS [intInvoiceDetailId]
				,TGM.[intTaxGroupMasterId] 
				,TG.[intTaxGroupId] 
				,TC.[intTaxCodeId]
				,TC.[intTaxClassId]				
				,TC.[strTaxableByOtherTaxes]
				,ISNULL((SELECT TOP 1 tblSMTaxCodeRate.[strCalculationMethod] FROM tblSMTaxCodeRate WHERE tblSMTaxCodeRate.[intTaxCodeId] = TC.[intTaxCodeId] AND  CAST(tblSMTaxCodeRate.[dtmEffectiveDate]  AS DATE) <= CAST(@TransactionDate AS DATE) ORDER BY tblSMTaxCodeRate.[dtmEffectiveDate]ASC ,tblSMTaxCodeRate.[numRate] DESC), 'Unit') AS [strCalculationMethod]
				,ISNULL((SELECT TOP 1 tblSMTaxCodeRate.[numRate] FROM tblSMTaxCodeRate WHERE tblSMTaxCodeRate.[intTaxCodeId] = TC.[intTaxCodeId] AND  CAST(tblSMTaxCodeRate.[dtmEffectiveDate]  AS DATE) <= CAST(@TransactionDate AS DATE) ORDER BY tblSMTaxCodeRate.[dtmEffectiveDate]ASC ,tblSMTaxCodeRate.[numRate] DESC), 0.00) AS [numRate]
				,0.00 AS [dblTax]
				,0.00 AS [dblAdjustedTax]				
				,TC.[intSalesTaxAccountId]								
				,TGM.[ysnSeparateOnInvoice] 
				,TC.[ysnCheckoffTax]
				,TC.[strTaxCode]
				,0 AS [ysnTaxExempt] 				
			FROM
				tblSMTaxCode TC
			INNER JOIN
				tblSMTaxGroupCode TGC
					ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
			INNER JOIN
				tblSMTaxGroup TG
					ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
			INNER JOIN
				tblSMTaxGroupMasterGroup TGTM
					ON TG.[intTaxGroupId] = TGTM.[intTaxGroupId]
			INNER JOIN
				tblSMTaxGroupMaster TGM
					ON TGTM.[intTaxGroupMasterId] = TGM.[intTaxGroupMasterId] 
			INNER JOIN
				(
					SELECT DISTINCT TOP 1  [intTaxGroupId] FROM @TaxGroups ORDER BY [intTaxGroupId]
				)
				FG
					ON TG.[intTaxGroupId] = FG.[intTaxGroupId]
			WHERE
				TGM.[intTaxGroupMasterId] = @TaxGroupMasterId
				AND (TC.[intSalesTaxAccountId] IS NOT NULL
					AND TC.[intSalesTaxAccountId] <> 0)
			ORDER BY
				TGTM.intTaxGroupMasterGroupId
				
			RETURN 1											
		END						
	
	RETURN 0
