CREATE PROCEDURE [dbo].[uspSMGetItemTaxes]
	@ItemId				INT
	,@LocationId		INT
	,@TransactionDate	DATETIME
	,@TransactionType	NVARCHAR(20) -- Purchase/Sale
	,@EntityId			INT			= NULL
	,@TaxMasterId		INT			= NULL
AS

BEGIN
			
	IF @TaxMasterId IS NOT NULL AND @TaxMasterId <> 0
		BEGIN				
		IF (@TransactionType = 'Sale')
			BEGIN
				SELECT
					 [intTransactionDetailTaxId]
					,[intTransactionDetailId]		AS [intInvoiceDetailId]
					,[intTaxGroupMasterId]
					,[intTaxGroupId]
					,[intTaxCodeId]
					,[intTaxClassId]
					,[strTaxableByOtherTaxes]
					,[strCalculationMethod]
					,[numRate]
					,[dblTax]
					,[dblAdjustedTax]
					,[intTaxAccountId]				AS [intSalesTaxAccountId]
					,[ysnSeparateOnInvoice]
					,[ysnCheckoffTax]
					,[strTaxCode]
					,[ysnTaxExempt]
					,[strTaxGroup]
				FROM
					[dbo].[fnGetTaxGroupTaxCodesForCustomer](@TaxMasterId, @EntityId, @TransactionDate, @ItemId)
					
				RETURN 1
			END
		ELSE
			BEGIN
				SELECT
					 [intTransactionDetailTaxId]
					,[intTransactionDetailId]		AS [intInvoiceDetailId]
					,NULL							AS [intTaxGroupMasterId]
					,[intTaxGroupId]
					,[intTaxCodeId]
					,[intTaxClassId]
					,[strTaxableByOtherTaxes]
					,[strCalculationMethod]
					,[numRate]
					,[dblTax]
					,[dblAdjustedTax]
					,[intTaxAccountId]
					,[ysnSeparateOnInvoice]
					,[ysnCheckoffTax]
					,[strTaxCode]
					,[ysnTaxExempt]
					,[strTaxGroup]
				FROM
					[dbo].[fnGetTaxGroupTaxCodes](@TaxMasterId, @TransactionDate)
					
				RETURN 1
			END
		END
		
	DECLARE @TaxGroupMasterId INT

	IF (@TransactionType = 'Sale')
		SELECT @TaxGroupMasterId = [dbo].[fnGetTaxMasterIdForCustomer](@EntityId, @LocationId, @ItemId)

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
			
	IF ISNULL(@TaxGroupMasterId, 0) <> 0
		BEGIN	
			DECLARE @Country NVARCHAR(MAX)
					,@County NVARCHAR(MAX)
					,@City NVARCHAR(MAX)
					,@State NVARCHAR(MAX)				
					
			IF (@TransactionType = 'Sale')
				BEGIN
					SELECT
						@Country	= UPPER(RTRIM(LTRIM(ISNULL(ISNULL(ShipToLocation.strCountry, EntityLocation.strCountry),''))))
						,@State		= UPPER(RTRIM(LTRIM(ISNULL(ISNULL(ShipToLocation.strState, EntityLocation.strState),''))))
						,@County	= UPPER(RTRIM(LTRIM(ISNULL(TaxCode.strCounty,'')))) 
						,@City		= UPPER(RTRIM(LTRIM(ISNULL(ISNULL(ShipToLocation.strCity, EntityLocation.strCity),''))))
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

				
			DECLARE @LocationTaxGroupId INT
			SELECT @LocationTaxGroupId = [dbo].[fnGetTaxGroupForLocation](@TaxGroupMasterId, @Country, @County, @City, @State)
																
			IF (@TransactionType = 'Sale')
				BEGIN
					SELECT
						 [intTransactionDetailTaxId]
						,[intTransactionDetailId]		AS [intInvoiceDetailId]
						,[intTaxGroupMasterId]
						,[intTaxGroupId]
						,[intTaxCodeId]
						,[intTaxClassId]
						,[strTaxableByOtherTaxes]
						,[strCalculationMethod]
						,[numRate]
						,[dblTax]
						,[dblAdjustedTax]
						,[intTaxAccountId] AS [intSalesTaxAccountId]
						,[ysnSeparateOnInvoice]
						,[ysnCheckoffTax]
						,[strTaxCode]
						,[ysnTaxExempt]
						,[strTaxGroup]
					FROM
						[dbo].[fnGetTaxGroupTaxCodesForCustomer](@LocationTaxGroupId, @EntityId, @TransactionDate, @ItemId)					
				END
			ELSE
				BEGIN
					SELECT
						 [intTransactionDetailTaxId]
						,[intTransactionDetailId]		AS [intInvoiceDetailId]
						,[intTaxGroupMasterId]
						,[intTaxGroupId]
						,[intTaxCodeId]
						,[intTaxClassId]
						,[strTaxableByOtherTaxes]
						,[strCalculationMethod]
						,[numRate]
						,[dblTax]
						,[dblAdjustedTax]
						,[intTaxAccountId]
						,[ysnSeparateOnInvoice]
						,[ysnCheckoffTax]
						,[strTaxCode]
						,[ysnTaxExempt]
						,[strTaxGroup]
					FROM
						[dbo].[fnGetTaxGroupTaxCodes](@LocationTaxGroupId, @TransactionDate)					
				END	
			RETURN 1											
		END						
	
	RETURN 0
END