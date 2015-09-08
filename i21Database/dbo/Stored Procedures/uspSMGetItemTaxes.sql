CREATE PROCEDURE [dbo].[uspSMGetItemTaxes]
	@ItemId				INT
	,@LocationId		INT
	,@TransactionDate	DATETIME
	,@TransactionType	NVARCHAR(20) -- Purchase/Sale
	,@EntityId			INT			= NULL
	,@TaxMasterId		INT			= NULL
AS

BEGIN
	DECLARE @TaxGroupMasterId INT
			,@TaxExempt BIT
			
			
		IF @TaxMasterId IS NOT NULL AND @TaxMasterId <> 0
		BEGIN				
			SELECT
				0
				,0 AS intInvoiceDetailId
				,NULL AS intTaxGroupMasterId 
				,TaxGroup.intTaxGroupId 
				,TaxCode.intTaxCodeId
				,TaxCode.intTaxClassId				
				,TaxCode.strTaxableByOtherTaxes
				,ISNULL(
						(SELECT TOP 1 tblSMTaxCodeRate.strCalculationMethod 
							FROM tblSMTaxCodeRate 
							WHERE tblSMTaxCodeRate.intTaxCodeId = TaxCode.intTaxCodeId 
								AND CAST(tblSMTaxCodeRate.dtmEffectiveDate  AS DATE) <= CAST(@TransactionDate AS DATE)
							ORDER BY tblSMTaxCodeRate.dtmEffectiveDate ASC
								,tblSMTaxCodeRate.numRate DESC
						), 'Unit'
					) AS strCalculationMethod
				,ISNULL(
						(SELECT TOP 1 tblSMTaxCodeRate.numRate 
							FROM tblSMTaxCodeRate 
							WHERE tblSMTaxCodeRate.intTaxCodeId = TaxCode.intTaxCodeId 
								AND CAST(tblSMTaxCodeRate.dtmEffectiveDate  AS DATE) <= CAST(@TransactionDate AS DATE)
							ORDER BY tblSMTaxCodeRate.dtmEffectiveDate ASC
								,tblSMTaxCodeRate.numRate DESC
						), 0.00
					) AS numRate
				,0.00 AS dblTax
				,0.00 AS dblAdjustedTax				
				,intTaxAccountId = (CASE WHEN @TransactionType = 'Sale' THEN TaxCode.intSalesTaxAccountId
										WHEN @TransactionType = 'Purchase' THEN TaxCode.intPurchaseTaxAccountId
									END)
				,0 AS ysnSeparateOnInvoice 
				,TaxCode.ysnCheckoffTax
				,TaxCode.strTaxCode
				,@TaxExempt AS ysnTaxExempt 				
			FROM tblSMTaxCode TaxCode
			INNER JOIN tblSMTaxGroupCode TaxGroupCode ON TaxCode.intTaxCodeId = TaxGroupCode.intTaxCodeId 
			INNER JOIN tblSMTaxGroup TaxGroup ON TaxGroupCode.intTaxGroupId = TaxGroup.intTaxGroupId
			WHERE TaxGroup.intTaxGroupId = @TaxMasterId
				AND (
						((CASE WHEN @TransactionType = 'Sale' THEN ISNULL(TaxCode.intSalesTaxAccountId, 0) 
							WHEN @TransactionType = 'Purchase' THEN ISNULL(TaxCode.intPurchaseTaxAccountId, 0) 
							END) <> 0)
					)				
				
			RETURN 1
		END

	IF (@TransactionType = 'Sale')
	BEGIN

		DECLARE @EntitySpecialTax TABLE(
			intSpecialTaxId INT
			, intEntityCustomerId INT
			, intEntityVendorId INT
			, intItemId INT
			, intCategoryId INT
			, intTaxGroupMasterId INT)
		DECLARE @VendorId INT
			,@ItemCategoryId INT

		INSERT INTO @EntitySpecialTax(
			 intSpecialTaxId
			,intEntityCustomerId
			,intEntityVendorId,intItemId
			,intCategoryId
			,intTaxGroupMasterId)
		SELECT
			 SpecialTax.intARSpecialTaxId
			,SpecialTax.intEntityCustomerId
			,SpecialTax.intEntityVendorId
			,SpecialTax.intItemId
			,SpecialTax.intCategoryId
			,SpecialTax.intTaxGroupMasterId
		FROM tblARSpecialTax SpecialTax
		INNER JOIN tblARCustomer Customer ON SpecialTax.intEntityCustomerId = Customer.intEntityCustomerId
		WHERE Customer.intEntityCustomerId = @EntityId
		
		SELECT
			@VendorId = ItemStock.intVendorId
			,@ItemCategoryId = Item.intCategoryId
		FROM tblICItem Item
		INNER JOIN vyuICGetItemStock ItemStock ON Item.intItemId = ItemStock.intItemId
		WHERE Item.intItemId = @ItemId AND ItemStock.intLocationId = @LocationId

		SET @TaxExempt = ISNULL((SELECT ysnTaxExempt FROM tblARCustomer WHERE intEntityCustomerId = @EntityId AND @EntityId IS NOT NULL),0)

		--Customer Special Tax
		IF(EXISTS(SELECT TOP 1 NULL FROM @EntitySpecialTax))
		BEGIN

			SELECT @TaxGroupMasterId = intTaxGroupMasterId
			FROM @EntitySpecialTax
			WHERE intEntityVendorId = @VendorId AND intItemId = @ItemId 
			
			IF @TaxGroupMasterId IS NULL OR @TaxGroupMasterId = 0
			BEGIN				
				SELECT @TaxGroupMasterId = intTaxGroupMasterId
				FROM @EntitySpecialTax
				WHERE intEntityVendorId = @VendorId AND intCategoryId = @ItemCategoryId   
			END
			
			IF @TaxGroupMasterId IS NULL OR @TaxGroupMasterId = 0
			BEGIN				
				SELECT @TaxGroupMasterId = intTaxGroupMasterId
				FROM @EntitySpecialTax
				WHERE intEntityVendorId = @VendorId 
			END	
			
			IF @TaxGroupMasterId IS NULL OR @TaxGroupMasterId = 0
			BEGIN				
				SELECT @TaxGroupMasterId = intTaxGroupMasterId
				FROM @EntitySpecialTax
				WHERE intItemId = @ItemId  
			END		
			
			IF @TaxGroupMasterId IS NULL OR @TaxGroupMasterId = 0
			BEGIN				
				SELECT @TaxGroupMasterId = intTaxGroupMasterId
				FROM @EntitySpecialTax
				WHERE intCategoryId = @ItemCategoryId  
			END																
													
		END
	END
	ELSE
	BEGIN
		SET @TaxExempt = 0
	END

	IF ISNULL(@TaxGroupMasterId, 0) = 0
	BEGIN				
		SELECT @TaxGroupMasterId = (
			CASE WHEN @TransactionType = 'Sale' THEN intSalesTaxGroupId
				WHEN @TransactionType = 'Purchase' THEN intPurchaseTaxGroupId
			END
		)
		FROM tblICItem
		WHERE intItemId = @ItemId
	END
		
	IF ISNULL(@TaxMasterId, 0) <> 0
		SET	@TaxGroupMasterId = @TaxMasterId
	
	IF ISNULL(@TaxGroupMasterId, 0) <> 0
		BEGIN	
			DECLARE @Country NVARCHAR(MAX)
					,@County NVARCHAR(MAX)
					,@City NVARCHAR(MAX)
					,@State NVARCHAR(MAX)				
					
			IF ISNULL(@TaxMasterId, 0) = 0
				BEGIN
					IF (@TransactionType = 'Sale')
					BEGIN
						SELECT
							@Country = UPPER(RTRIM(LTRIM(ISNULL(ISNULL(ShipToLocation.strCountry, EntityLocation.strCountry),''))))
							,@State = UPPER(RTRIM(LTRIM(ISNULL(ISNULL(ShipToLocation.strState, EntityLocation.strState),''))))
							,@County = UPPER(RTRIM(LTRIM(ISNULL(TaxCode.strCounty,'')))) 
							,@City = UPPER(RTRIM(LTRIM(ISNULL(ISNULL(ShipToLocation.strCity, EntityLocation.strCity),''))))
						FROM tblARCustomer Customer
						LEFT OUTER JOIN
							(	SELECT
									intEntityLocationId
									,intEntityId 
									,strCountry
									,strState
									,strCity
								FROM tblEntityLocation
								WHERE ysnDefaultLocation = 1
							) EntityLocation ON Customer.intEntityCustomerId = EntityLocation.intEntityId
						LEFT OUTER JOIN tblEntityLocation ShipToLocation ON Customer.intShipToId = ShipToLocation.intEntityLocationId
						LEFT OUTER JOIN tblSMTaxCode TaxCode ON Customer.intTaxCodeId = TaxCode.intTaxCodeId 								
						WHERE Customer.intEntityCustomerId = @EntityId
					END
					ELSE IF (@TransactionType = 'Purchase')
					BEGIN
						--IF(@LocationId IS NULL OR @LocationId = 0)
						--BEGIN
						--	SELECT
						--	@Country = UPPER(RTRIM(LTRIM(ISNULL(ISNULL(ShipToLocation.strCountry, EntityLocation.strCountry),''))))
						--	,@State = UPPER(RTRIM(LTRIM(ISNULL(ISNULL(ShipToLocation.strState, EntityLocation.strState),''))))
						--	,@County = UPPER(RTRIM(LTRIM(ISNULL(TaxCode.strCounty,''))))
						--	,@City = UPPER(RTRIM(LTRIM(ISNULL(ISNULL(ShipToLocation.strCity, EntityLocation.strCity),''))))
						--	FROM tblAPVendor Vendor
						--	LEFT OUTER JOIN
						--		(	SELECT
						--				intEntityLocationId
						--				,intEntityId 
						--				,strCountry
						--				,strState
						--				,strCity
						--			FROM tblEntityLocation
						--			WHERE ysnDefaultLocation = 1
						--		) EntityLocation ON Vendor.intEntityVendorId = EntityLocation.intEntityId
						--	LEFT OUTER JOIN tblEntityLocation ShipToLocation ON Vendor.intShipFromId = ShipToLocation.intEntityLocationId
						--	LEFT OUTER JOIN tblSMTaxCode TaxCode ON Vendor.intTaxCodeId = TaxCode.intTaxCodeId 								
						--	WHERE Vendor.intEntityVendorId = @EntityId
						--END
						--ELSE
						--BEGIN
							SELECT
								@Country = UPPER(RTRIM(LTRIM(ISNULL(Location.strCountry, ''))))
								,@State = UPPER(RTRIM(LTRIM(ISNULL(Location.strStateProvince, ''))))
								,@County = '' 
								,@City = UPPER(RTRIM(LTRIM(ISNULL(Location.strCity, ''))))
							FROM tblSMCompanyLocation Location
							WHERE Location.intCompanyLocationId = @LocationId
						--END			
					END
				END
			ELSE
				BEGIN
					SELECT
						@Country = UPPER(RTRIM(LTRIM(ISNULL(Location.strCountry, ''))))
						,@State = UPPER(RTRIM(LTRIM(ISNULL(Location.strStateProvince, ''))))
						,@County = '' 
						,@City = UPPER(RTRIM(LTRIM(ISNULL(Location.strCity, ''))))
					FROM tblSMCompanyLocation Location
					WHERE Location.intCompanyLocationId = @LocationId				
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
					
			IF (SELECT COUNT(1) FROM @TaxCodes) < 1
				BEGIN
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
				END
											
			
			INSERT INTO @TaxGroups
			SELECT DISTINCT [intTaxGroupId]
			FROM @TaxCodes
			
			DECLARE @TaxGroupCount INT
					,@ValidTaxGroupCount INT
			


			--Country
			INSERT INTO @ValidTaxGroups
			SELECT DISTINCT
				[intTaxGroupId] 
			FROM 
				@TaxCodes
			WHERE
				[strCountry] = @Country
				
			SELECT @TaxGroupCount = COUNT(1) FROM @TaxGroups
			SELECT @ValidTaxGroupCount = COUNT(1) FROM @ValidTaxGroups
				
			IF @TaxGroupCount >= 1 AND @ValidTaxGroupCount >= 1 AND (@TaxGroupCount - @ValidTaxGroupCount >= 1)
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
				[strState] = @State 																			
				
			SELECT @TaxGroupCount = COUNT(1) FROM @TaxGroups
			SELECT @ValidTaxGroupCount = COUNT(1) FROM @ValidTaxGroups
				
			IF @TaxGroupCount >= 1 AND @ValidTaxGroupCount >= 1 AND (@TaxGroupCount - @ValidTaxGroupCount >= 1)
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
				[strCounty] = @County	
				
			SELECT @TaxGroupCount = COUNT(1) FROM @TaxGroups
			SELECT @ValidTaxGroupCount = COUNT(1) FROM @ValidTaxGroups
				
			IF @TaxGroupCount >= 1 AND @ValidTaxGroupCount >= 1 AND (@TaxGroupCount - @ValidTaxGroupCount >= 1)
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
				[strCity] = @City																					
				
			SELECT @TaxGroupCount = COUNT(1) FROM @TaxGroups
			SELECT @ValidTaxGroupCount = COUNT(1) FROM @ValidTaxGroups
				
			IF @TaxGroupCount >= 1 AND @ValidTaxGroupCount >= 1 AND (@TaxGroupCount - @ValidTaxGroupCount >= 1)
				BEGIN
					DELETE FROM @TaxGroups
					WHERE [intTaxGroupId] NOT IN (SELECT DISTINCT [intTaxGroupId] FROM @ValidTaxGroups)				
				END										
					
			SELECT
				0
				,0 AS intInvoiceDetailId
				,tblSMTaxGroupMaster.intTaxGroupMasterId 
				,TaxGroup.intTaxGroupId 
				,TaxCode.intTaxCodeId
				,TaxCode.intTaxClassId				
				,TaxCode.strTaxableByOtherTaxes
				,ISNULL(
						(SELECT TOP 1 tblSMTaxCodeRate.strCalculationMethod 
							FROM tblSMTaxCodeRate 
							WHERE tblSMTaxCodeRate.intTaxCodeId = TaxCode.intTaxCodeId 
								AND CAST(tblSMTaxCodeRate.dtmEffectiveDate  AS DATE) <= CAST(@TransactionDate AS DATE)
							ORDER BY tblSMTaxCodeRate.dtmEffectiveDate ASC
								,tblSMTaxCodeRate.numRate DESC
						), 'Unit'
					) AS strCalculationMethod
				,ISNULL(
						(SELECT TOP 1 tblSMTaxCodeRate.numRate 
							FROM tblSMTaxCodeRate 
							WHERE tblSMTaxCodeRate.intTaxCodeId = TaxCode.intTaxCodeId 
								AND CAST(tblSMTaxCodeRate.dtmEffectiveDate  AS DATE) <= CAST(@TransactionDate AS DATE)
							ORDER BY tblSMTaxCodeRate.dtmEffectiveDate ASC
								,tblSMTaxCodeRate.numRate DESC
						), 0.00
					) AS numRate
				,0.00 AS dblTax
				,0.00 AS dblAdjustedTax				
				,intTaxAccountId = (CASE WHEN @TransactionType = 'Sale' THEN TaxCode.intSalesTaxAccountId
										WHEN @TransactionType = 'Purchase' THEN TaxCode.intPurchaseTaxAccountId
									END)
				,tblSMTaxGroupMaster.ysnSeparateOnInvoice 
				,TaxCode.ysnCheckoffTax
				,TaxCode.strTaxCode
				,@TaxExempt AS ysnTaxExempt 				
			FROM tblSMTaxCode TaxCode
			INNER JOIN tblSMTaxGroupCode TaxGroupCode ON TaxCode.intTaxCodeId = TaxGroupCode.intTaxCodeId 
			INNER JOIN tblSMTaxGroup TaxGroup ON TaxGroupCode.intTaxGroupId = TaxGroup.intTaxGroupId
			INNER JOIN tblSMTaxGroupMasterGroup TaxGroupMasterGroup ON TaxGroup.intTaxGroupId = TaxGroupMasterGroup.intTaxGroupId
			INNER JOIN tblSMTaxGroupMaster tblSMTaxGroupMaster ON TaxGroupMasterGroup.intTaxGroupMasterId = tblSMTaxGroupMaster.intTaxGroupMasterId 
			INNER JOIN
				(
					SELECT DISTINCT TOP 1 intTaxGroupId FROM @TaxGroups ORDER BY intTaxGroupId
				)
				FG ON TaxGroup.intTaxGroupId = FG.intTaxGroupId
			WHERE tblSMTaxGroupMaster.intTaxGroupMasterId = @TaxGroupMasterId
				AND (
						((CASE WHEN @TransactionType = 'Sale' THEN ISNULL(TaxCode.intSalesTaxAccountId, 0) 
							WHEN @TransactionType = 'Purchase' THEN ISNULL(TaxCode.intPurchaseTaxAccountId, 0) 
							END) <> 0)
						OR (ISNULL(@TaxMasterId, 0) <> 0)
					)
				
			RETURN 1											
		END						
	
	RETURN 0
END