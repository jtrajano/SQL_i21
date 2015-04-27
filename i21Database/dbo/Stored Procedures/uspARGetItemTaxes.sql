CREATE PROCEDURE [dbo].[uspARGetItemTaxes]
	@ItemId				INT
	,@CustomerId		INT	
AS

--DECLARE 	
-- @ItemId			INT
--,@CustomerId		INT	

--SET @ItemId = 5348
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
			,@ItemLocationyId INT
			,@ItemCategoryId INT
			,@ItemCategory NVARCHAR(100)

	SELECT
		@VendorId = VI.intVendorId
		,@ItemLocationyId = intItemLocationId
		,@ItemCategoryId = I.intCategoryId
		,@ItemCategory = C.strCategoryCode
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
		
			DECLARE @State nvarchar(MAX)
					,@County nvarchar(MAX)
					,@City nvarchar(MAX)
					,@Country nvarchar(MAX)
					
			SELECT
				 @State = ISNULL(EL.[strState], SL.[strState])
				,@Country = ISNULL(EL.[strCountry], SL.[strCountry])
				,@City = ISNULL(EL.[strCity], SL.[strCity])
			FROM
				tblEntityLocation EL
			INNER JOIN
				tblARCustomer C
					ON EL.[intEntityLocationId] = C.[intDefaultLocationId] 
			LEFT OUTER JOIN
				tblEntityLocation SL
					ON C.[intShipToId] = SL.[intEntityLocationId]				
			WHERE
				C.[intEntityCustomerId] = @CustomerId
				
				
			IF(	SELECT COUNT(1)
				FROM tblSMTaxCode TC	
					INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
					INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
					INNER JOIN tblSMTaxGroupMasterGroup TGTM ON TG.[intTaxGroupId] = TGTM.[intTaxGroupId]
					INNER JOIN tblSMTaxGroupMaster TGM ON TGTM.[intTaxGroupMasterId] = TGM.[intTaxGroupMasterId]
				WHERE 
					TGM.[intTaxGroupMasterId] = @TaxGroupMasterId 
					AND (TC.[strState] IS NULL OR TC.[strState] = @State OR @State = @State)) > 1
				BEGIN
					IF(	SELECT COUNT(1)
						FROM tblSMTaxCode TC	
							INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
							INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
							INNER JOIN tblSMTaxGroupMasterGroup TGTM ON TG.[intTaxGroupId] = TGTM.[intTaxGroupId]
							INNER JOIN tblSMTaxGroupMaster TGM ON TGTM.[intTaxGroupMasterId] = TGM.[intTaxGroupMasterId]
						WHERE 
							TGM.[intTaxGroupMasterId] = @TaxGroupMasterId 
							AND (TC.[strCounty] IS NULL OR TC.[strCounty] = @County OR @County IS NULL)
							AND (TC.[strState] IS NULL OR TC.[strState] = @State OR @State IS NULL)) > 1
						BEGIN
							IF(	SELECT COUNT(1)
								FROM tblSMTaxCode TC	
									INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
									INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
									INNER JOIN tblSMTaxGroupMasterGroup TGTM ON TG.[intTaxGroupId] = TGTM.[intTaxGroupId]
									INNER JOIN tblSMTaxGroupMaster TGM ON TGTM.[intTaxGroupMasterId] = TGM.[intTaxGroupMasterId]
								WHERE 
									TGM.[intTaxGroupMasterId] = @TaxGroupMasterId 
									AND (TC.[strCity] IS NULL OR TC.[strCity] = @City OR @City IS NULL)
									AND (TC.[strCounty] IS NULL OR TC.[strCounty] = @County OR @County IS NULL)
									AND (TC.[strState] IS NULL OR TC.[strState] = @State OR @State IS NULL)) >= 1
								BEGIN
									SELECT
										 TC.[intTaxCodeId]
										,TC.[strTaxCode] 
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
									WHERE
										TGM.[intTaxGroupMasterId] = @TaxGroupMasterId
										AND (TC.[strCity] IS NULL OR TC.[strCity] = @City OR @City IS NULL)
										AND (TC.[strCounty] IS NULL OR TC.[strCounty] = @County OR @County IS NULL)
										AND (TC.[strState] IS NULL OR TC.[strState] = @State OR @State IS NULL)
									
									RETURN 1								
								END
							ELSE
								BEGIN
									SELECT
										 TC.[intTaxCodeId]
										,TC.[strTaxCode] 
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
									WHERE
										TGM.[intTaxGroupMasterId] = @TaxGroupMasterId 
										AND (TC.[strCounty] IS NULL OR TC.[strCounty] = @County OR @County IS NULL)
										AND (TC.[strState] IS NULL OR TC.[strState] = @State OR @State IS NULL)
											
									RETURN 1
								END
						END
					ELSE
						BEGIN
							SELECT
								 TC.[intTaxCodeId]
								,TC.[strTaxCode] 
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
							WHERE
								TGM.[intTaxGroupMasterId] = @TaxGroupMasterId 
								AND (TC.[strState] IS NULL OR TC.[strState] = @State OR @State IS NULL)
									
							RETURN 1
						END
				END
			ELSE
				BEGIN
					SELECT
						 TC.[intTaxCodeId]
						,TC.[strTaxCode] 
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
					WHERE
						TGM.[intTaxGroupMasterId] = @TaxGroupMasterId
							
					RETURN 1
				END	
				
			SELECT
				 TC.[intTaxCodeId]
				,TC.[strTaxCode] 
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
			WHERE
				TGM.[intTaxGroupMasterId] = @TaxGroupMasterId 	
				
			RETURN 1									
		END	
					

	SELECT
		 NULL AS [intTaxCodeId]
		,NULL AS [strTaxCode] 
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
