CREATE PROCEDURE [dbo].[uspARGetItemTaxes]
	@ItemId				INT
	,@LocationId		INT	
	,@CustomerId		INT			= NULL	
	,@TransactionDate	DATETIME
	,@TaxMasterId		INT			= NULL		
AS

--DECLARE 	
-- @ItemId			INT
-- ,@LocationId		INT
-- ,@CustomerId		INT	

--SET @ItemId = 5323
--SET @LocationId = 1
--SET @CustomerId = 10075

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
						@Country = ISNULL(SL.[strCountry], EL.[strCountry])
						,@State = ISNULL(SL.[strState], EL.[strState])
						,@County = TC.[strCounty] 
						,@City = ISNULL(SL.[strCity], EL.[strCity])
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
						@Country = ISNULL(CL.[strCountry], '')
						,@State = ISNULL(CL.[strStateProvince], '')
						,@County = '' 
						,@City = ISNULL(CL.[strCity], '')
					FROM
						tblSMCompanyLocation CL													
					WHERE
						CL.[intCompanyLocationId] = @LocationId				
				END
			

				
			DECLARE @TaxGroups TABLE(intTaxGroupId INT)				
			
			INSERT INTO @TaxGroups
			SELECT DISTINCT TG.[intTaxGroupId]
			FROM tblSMTaxCode TC	
				INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
				INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
				INNER JOIN tblSMTaxGroupMasterGroup TGTM ON TG.[intTaxGroupId] = TGTM.[intTaxGroupId]
				INNER JOIN tblSMTaxGroupMaster TGM ON TGTM.[intTaxGroupMasterId] = TGM.[intTaxGroupMasterId]
			WHERE 
				TGM.[intTaxGroupMasterId] = @TaxGroupMasterId
				
			--Country
			IF (SELECT COUNT(1) FROM @TaxGroups) > 1
				BEGIN
					DELETE FROM @TaxGroups
					WHERE
						[intTaxGroupId] NOT IN
						(
							SELECT DISTINCT
								TG.[intTaxGroupId] 
							FROM tblSMTaxCode TC	
								INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
								INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
								INNER JOIN tblSMTaxGroupMasterGroup TGTM ON TG.[intTaxGroupId] = TGTM.[intTaxGroupId]
								INNER JOIN tblSMTaxGroupMaster TGM ON TGTM.[intTaxGroupMasterId] = TGM.[intTaxGroupMasterId]
							WHERE 
								TGM.[intTaxGroupMasterId] = @TaxGroupMasterId
								AND TC.[strCountry] = @Country 
						)				
				END
				
			--State
			IF (SELECT COUNT(1) FROM @TaxGroups) > 1
				BEGIN
					DELETE FROM @TaxGroups
					WHERE
						[intTaxGroupId] NOT IN
						(
							SELECT DISTINCT
								TG.[intTaxGroupId] 
							FROM tblSMTaxCode TC	
								INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
								INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
								INNER JOIN tblSMTaxGroupMasterGroup TGTM ON TG.[intTaxGroupId] = TGTM.[intTaxGroupId]
								INNER JOIN tblSMTaxGroupMaster TGM ON TGTM.[intTaxGroupMasterId] = TGM.[intTaxGroupMasterId]
							WHERE 
								TGM.[intTaxGroupMasterId] = @TaxGroupMasterId
								AND TC.[strCountry] = @Country
								AND TC.[strState] = @State 
						)				
				END
				
			--County
			IF (SELECT COUNT(1) FROM @TaxGroups) > 1
				BEGIN
					DELETE FROM @TaxGroups
					WHERE
						[intTaxGroupId] NOT IN
						(
							SELECT DISTINCT
								TG.[intTaxGroupId] 
							FROM tblSMTaxCode TC	
								INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
								INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
								INNER JOIN tblSMTaxGroupMasterGroup TGTM ON TG.[intTaxGroupId] = TGTM.[intTaxGroupId]
								INNER JOIN tblSMTaxGroupMaster TGM ON TGTM.[intTaxGroupMasterId] = TGM.[intTaxGroupMasterId]
							WHERE 
								TGM.[intTaxGroupMasterId] = @TaxGroupMasterId
								AND TC.[strCountry] = @Country
								AND TC.[strState] = @State 
								AND TC.[strCounty] = @County
						)				
				END	
				
			--City
			IF (SELECT COUNT(1) FROM @TaxGroups) > 1
				BEGIN
					DELETE FROM @TaxGroups
					WHERE
						[intTaxGroupId] NOT IN
						(
							SELECT DISTINCT
								TG.[intTaxGroupId] 
							FROM tblSMTaxCode TC	
								INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
								INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
								INNER JOIN tblSMTaxGroupMasterGroup TGTM ON TG.[intTaxGroupId] = TGTM.[intTaxGroupId]
								INNER JOIN tblSMTaxGroupMaster TGM ON TGTM.[intTaxGroupMasterId] = TGM.[intTaxGroupMasterId]
							WHERE 
								TGM.[intTaxGroupMasterId] = @TaxGroupMasterId
								AND TC.[strCountry] = @Country
								AND TC.[strState] = @State 
								AND TC.[strCounty] = @County
								AND TC.[strCity] = @City
						)				
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
				,@TaxExempt AS [ysnTaxExempt] 				
			FROM
				tblSMTaxCode TC
			--LEFT OUTER JOIN
			--	(
			--		SELECT TOP 1
			--			 [intTaxCodeId]
			--			,[numRate]
			--			,[strCalculationMethod]
			--		FROM
			--			tblSMTaxCodeRate
			--		WHERE
			--			CAST([dtmEffectiveDate] AS DATE) <= CAST(@TransactionDate AS DATE)
			--		ORDER BY
			--			 [dtmEffectiveDate]	ASC
			--			,[numRate]			DESC
			--	) TCR
			--		ON TC.[intTaxCodeId] = TCR.[intTaxCodeId]
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
				
			RETURN 1											
		END						
	
	RETURN 0
