CREATE PROCEDURE [dbo].[uspARGetItemTaxes]
	@ItemId				INT
	,@LocationId		INT	
	,@CustomerId		INT		
AS

--DECLARE 	
-- @ItemId			INT
-- ,@LocationId		INT
-- ,@CustomerId		INT	

--SET @ItemId = 5348
--SET @LocationId = 1
--SET @CustomerId = 2203

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
				@TaxGroupMasterId = [intTaxGroupId]
			FROM
				tblICItem
			WHERE
				[intItemId] = @ItemId    
		END		
	
	
	IF @TaxGroupMasterId IS NOT NULL OR @TaxGroupMasterId <> 0
		BEGIN	
		
			DECLARE @Country nvarchar(MAX)
					,@County nvarchar(MAX)
					,@City nvarchar(MAX)
					,@State nvarchar(MAX)				
					
			SELECT
				@Country = ISNULL(SL.[strCountry], EL.[strCountry])
				,@State = ISNULL(SL.[strState], EL.[strState])
				,@County = TC.[strCounty] 
				,@City = ISNULL(SL.[strCity], EL.[strCity])
			FROM
				tblEntityLocation EL
			INNER JOIN
				tblARCustomer C
					ON EL.[intEntityLocationId] = C.[intDefaultLocationId] 
			LEFT OUTER JOIN
				tblEntityLocation SL
					ON C.[intShipToId] = SL.[intEntityLocationId]
			LEFT OUTER JOIN
				tblSMTaxCode TC
					ON C.[intTaxCodeId] = TC.[intTaxCodeId] 								
			WHERE
				C.[intEntityCustomerId] = @CustomerId

				
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
				 TC.[intTaxCodeId]
				,TC.[strTaxCode] 
				,TC.[intTaxClassId]
				,TC.[strCalculationMethod] 
				,TC.[numRate]
				,TC.[strTaxAgency] 
				,TC.[strState] 
				,TC.[strCity]
				,TC.[strCountry] 
				,TC.[strCounty] 
				,TC.[intSalesTaxAccountId]
				,TC.[strTaxableByOtherTaxes]
				,TG.[intTaxGroupId] 
				,TG.[strTaxGroup] 
				,TGM.[intTaxGroupMasterId] 
				,TGM.[strTaxGroupMaster] 
				,TGM.[ysnSeparateOnInvoice] 
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
				@TaxGroups FG
					ON TG.[intTaxGroupId] = FG.[intTaxGroupId] 
				
			RETURN 1											
		END	
					

	SELECT
		 NULL AS [intTaxCodeId]
		,NULL AS [strTaxCode]
		,NULL AS [intTaxClassId] 
		,NULL AS [strCalculationMethod] 
		,NULL AS [numRate]
		,NULL AS [strTaxAgency] 
		,NULL AS [strState] 
		,NULL AS [strCity]
		,NULL AS [strCountry] 
		,NULL AS [strCounty] 
		,NULL AS [intSalesTaxAccountId]
		,NULL AS [strTaxableByOtherTaxes]
		,NULL AS [intTaxGroupId] 
		,NULL AS [strTaxGroup] 
		,NULL AS [intTaxGroupMasterId] 
		,NULL AS [strTaxGroupMaster] 
		,NULL AS [ysnSeparateOnInvoice] 
	
	RETURN 0
