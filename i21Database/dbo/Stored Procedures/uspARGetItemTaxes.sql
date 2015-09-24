CREATE PROCEDURE [dbo].[uspARGetItemTaxes]
	@ItemId				INT			= NULL
	,@LocationId		INT
	,@CustomerId		INT			= NULL	
	,@CustomerShipToId	INT			= NULL	
	,@TransactionDate	DATETIME
	,@TaxMasterId		INT			= NULL	
	,@TaxGroupId		INT			= NULL		
AS


	IF(ISNULL(@TaxGroupId,0) = 0)
		SET @TaxGroupId = ISNULL((SELECT tblEntityLocation.intTaxGroupId  FROM tblARCustomer INNER JOIN tblEntityLocation ON tblARCustomer.intEntityCustomerId = tblEntityLocation.intEntityId  AND tblEntityLocation.ysnDefaultLocation = 1 WHERE intEntityCustomerId = @CustomerId AND @CustomerId IS NOT NULL),0)
	
	IF @TaxGroupId IS NOT NULL AND @TaxGroupId <> 0
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
				[dbo].[fnGetTaxGroupTaxCodesForCustomer](@TaxGroupId, @CustomerId, @TransactionDate, @ItemId)
				
			RETURN 1
		END
		
	DECLARE @TaxGroupMasterId INT

	SELECT @TaxGroupMasterId = [dbo].[fnGetTaxMasterIdForCustomer](@CustomerId, @LocationId, @ItemId)
		
	IF @TaxMasterId IS NOT NULL AND @TaxMasterId <> 0
		SET	@TaxGroupMasterId = @TaxMasterId
	
	
	IF @TaxGroupMasterId IS NOT NULL OR @TaxGroupMasterId <> 0
		BEGIN	
		
			DECLARE @Country nvarchar(MAX)
					,@County nvarchar(MAX)
					,@City nvarchar(MAX)
					,@State nvarchar(MAX)				
					
			IF ISNULL(@TaxMasterId, 0) <> 0
				BEGIN
					SELECT
						 @Country	= UPPER(RTRIM(LTRIM(ISNULL(CL.[strCountry], ''))))
						,@State		= UPPER(RTRIM(LTRIM(ISNULL(CL.[strStateProvince], ''))))
						,@County	= '' 
						,@City		= UPPER(RTRIM(LTRIM(ISNULL(CL.[strCity], ''))))
					FROM
						tblSMCompanyLocation CL													
					WHERE
						CL.[intCompanyLocationId] = @LocationId	
				END
			ELSE
				BEGIN
					IF ISNULL(@CustomerShipToId,0) <> 0
					BEGIN
						SELECT TOP 1
							 @Country	= UPPER(RTRIM(LTRIM(ISNULL(ISNULL(SL.[strCountry], EL.[strCountry]),''))))
							,@State		= UPPER(RTRIM(LTRIM(ISNULL(ISNULL(SL.[strState], EL.[strState]),''))))
							,@County	= UPPER(RTRIM(LTRIM(ISNULL(TC.[strCounty],'')))) 
							,@City		= UPPER(RTRIM(LTRIM(ISNULL(ISNULL(SL.[strCity], EL.[strCity]),''))))
						FROM
							tblEntityLocation SL
						LEFT OUTER JOIN
							tblARCustomer C
								ON SL.[intEntityLocationId] = C.[intShipToId] 							
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
							tblSMTaxCode TC
								ON C.[intTaxCodeId] = TC.[intTaxCodeId] 								
						WHERE
							SL.[intEntityLocationId] = @CustomerShipToId
					END
					ELSE
					BEGIN
						SELECT TOP 1
							 @Country	= UPPER(RTRIM(LTRIM(ISNULL(ISNULL(SL.[strCountry], EL.[strCountry]),''))))
							,@State		= UPPER(RTRIM(LTRIM(ISNULL(ISNULL(SL.[strState], EL.[strState]),''))))
							,@County	= UPPER(RTRIM(LTRIM(ISNULL(TC.[strCounty],'')))) 
							,@City		= UPPER(RTRIM(LTRIM(ISNULL(ISNULL(SL.[strCity], EL.[strCity]),''))))
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
				END
			

				
			DECLARE @LocationTaxGroupId INT
			SELECT @LocationTaxGroupId = [dbo].[fnGetTaxGroupForLocation](@TaxGroupMasterId, @Country, @County, @City, @State)
				
					
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
				[dbo].[fnGetTaxGroupTaxCodesForCustomer](@LocationTaxGroupId, @CustomerId, @TransactionDate, @ItemId)
				
			RETURN 1											
		END						
	
	RETURN 0
