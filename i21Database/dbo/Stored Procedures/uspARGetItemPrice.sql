CREATE PROCEDURE [dbo].[uspARGetItemPrice]
	@ItemId				INT
	,@CustomerId		INT	
	,@LocationId		INT
	,@ItemUOMId			INT
	,@TransactionDate	DATETIME
	,@Quantity			NUMERIC(18,6)
	,@CustomerPricing	NVARCHAR(250)
	,@Price				NUMERIC(18,6)	= NULL OUTPUT
	,@Pricing			NVARCHAR(250)	= NULL OUTPUT
AS
	--	DECLARE 	
	--	@ItemId				INT
	--	,@CustomerId		INT	
	--	,@LocationId		INT
	--	,@ItemUOMId			INT
	--	,@TransactionDate	DATETIME
	--	,@Quantity			NUMERIC(18,6)
	--	,@CustomerPricing	NVARCHAR(250)


	--SET @ItemId = 5347
	--SET @CustomerId = 457
	--SET @LocationId = 1
	--SET @ItemUOMId = 793
	--SET @TransactionDate = '03/22/2015'
	--SET @Quantity = 6



	--DECLARE	@Price AS NUMERIC(18,6)
	--		,@Pricing AS NVARCHAR(250)
	--SET @Price = NULL;
	--SET @Pricing = '';

	DECLARE @CustomerSpecialPricing TABLE(
		intSpecialPriceId INT
		,intEntityId INT
		,intVendorId INT
		,intItemId INT
		,strClass VARCHAR(100) COLLATE Latin1_General_CI_AS
		,strPriceBasis VARCHAR(100) COLLATE Latin1_General_CI_AS
		,strCustomerGroup NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strCostToUse NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,dblDeviation NUMERIC(18,6)
		,strLineNote NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,ysnConsignable BIT
		,intRackVendorId INT
		,intRackItemId INT
		,dblCustomerPrice NUMERIC(18,6))


	INSERT INTO @CustomerSpecialPricing(
		intSpecialPriceId
		,intEntityId
		,intVendorId
		,intItemId
		,strClass
		,strPriceBasis
		,strCustomerGroup
		,strCostToUse
		,dblDeviation
		,strLineNote
		,ysnConsignable
		,intRackVendorId
		,intRackItemId
		,dblCustomerPrice)
	SELECT
		SP.intSpecialPriceId
		,SP.intEntityId
		,SP.intVendorId
		,SP.intItemId
		,SP.strClass
		,SP.strPriceBasis
		,SP.strCustomerGroup
		,SP.strCostToUse
		,SP.dblDeviation
		,SP.strLineNote
		,SP.ysnConsignable
		,SP.intRackVendorId
		,SP.intRackItemId
		,NULL
	FROM
		tblARCustomerSpecialPrice SP
	INNER JOIN
		tblARCustomer C
			ON SP.intEntityId = C.intEntityId
	WHERE
		C.intCustomerId = @CustomerId
		AND @TransactionDate BETWEEN SP.dtmBeginDate AND SP.dtmEndDate


	DECLARE @VendorId INT
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
		AND VI.intLocationId = @LocationId 
		AND (VI.intIssueUOMId = @ItemUOMId OR @ItemUOMId IS NULL)
	

	--Customer Special Pricing
	IF(EXISTS(SELECT TOP 1 NULL FROM @CustomerSpecialPricing))
	BEGIN

		UPDATE
			@CustomerSpecialPricing
		SET
			dblCustomerPrice = 
				(CASE 
					WHEN strPriceBasis = 'X'
						THEN 0
					WHEN strPriceBasis = 'F'
						THEN dblDeviation
					WHEN strPriceBasis = 'C'
						THEN	(CASE
									WHEN strCostToUse = 'Last Cost'
										THEN ISNULL(VI.dblLastCost, 0.00)
									WHEN strCostToUse = 'Standard Cost'
										THEN ISNULL(VI.dblStandardCost, 0.00)
									WHEN strCostToUse = 'Average Cost'
										THEN ISNULL(VI.dblAverageCost, 0.00)
									WHEN strCostToUse = 'EOM Cost'
										THEN ISNULL(VI.dblEndMonthCost, 0.00)
									WHEN strCostToUse = 'Sale Price'
										THEN ISNULL(VI.dblSalePrice, 0.00)
									WHEN strCostToUse = 'MSRP'
										THEN ISNULL(VI.dblMSRPPrice, 0.00)
								END)
								 +
								(	(CASE
									WHEN strCostToUse = 'Last Cost'
										THEN ISNULL(VI.dblLastCost, 0.00)
									WHEN strCostToUse = 'Standard Cost'
										THEN ISNULL(VI.dblStandardCost, 0.00)
									WHEN strCostToUse = 'Average Cost'
										THEN ISNULL(VI.dblAverageCost, 0.00)
									WHEN strCostToUse = 'EOM Cost'
										THEN ISNULL(VI.dblEndMonthCost, 0.00)
									WHEN strCostToUse = 'Sale Price'
										THEN ISNULL(VI.dblSalePrice, 0.00)
									WHEN strCostToUse = 'MSRP'
										THEN ISNULL(VI.dblMSRPPrice, 0.00)
									END)
								* (dblDeviation/100.00))
					WHEN strPriceBasis = 'A'
						THEN	(CASE
									WHEN strCostToUse = 'Last Cost'
										THEN ISNULL(VI.dblLastCost, 0.00)
									WHEN strCostToUse = 'Standard Cost'
										THEN ISNULL(VI.dblStandardCost, 0.00)
									WHEN strCostToUse = 'Average Cost'
										THEN ISNULL(VI.dblAverageCost, 0.00)
									WHEN strCostToUse = 'EOM Cost'
										THEN ISNULL(VI.dblEndMonthCost, 0.00)
									WHEN strCostToUse = 'Sale Price'
										THEN ISNULL(VI.dblSalePrice, 0.00)
									WHEN strCostToUse = 'Retail Price'
										THEN ISNULL(VI.dblSalePrice, 0.00)
									WHEN strCostToUse = 'Wholesale Price'
										THEN ISNULL(VI.dblSalePrice, 0.00)
									WHEN strCostToUse = 'Large Volume Pricing'
										THEN ISNULL(VI.dblSalePrice, 0.00)
									WHEN strCostToUse = 'MSRP'
										THEN ISNULL(VI.dblMSRPPrice, 0.00)
									WHEN strCostToUse = 'Pricing Level'
										THEN 0
								END)
								 +
								(	(CASE
									WHEN strCostToUse = 'Last Cost'
										THEN ISNULL(VI.dblLastCost, 0.00)
									WHEN strCostToUse = 'Standard Cost'
										THEN ISNULL(VI.dblStandardCost, 0.00)
									WHEN strCostToUse = 'Average Cost'
										THEN ISNULL(VI.dblAverageCost, 0.00)
									WHEN strCostToUse = 'EOM Cost'
										THEN ISNULL(VI.dblEndMonthCost, 0.00)
									WHEN strCostToUse = 'Sale Price'
										THEN ISNULL(VI.dblSalePrice, 0.00)
									WHEN strCostToUse = 'Retail Price'
										THEN ISNULL(VI.dblSalePrice, 0.00)
									WHEN strCostToUse = 'Wholesale Price'
										THEN ISNULL(VI.dblSalePrice, 0.00)
									WHEN strCostToUse = 'Large Volume Pricing'
										THEN ISNULL(VI.dblSalePrice, 0.00)
									WHEN strCostToUse = 'MSRP'
										THEN ISNULL(VI.dblMSRPPrice, 0.00)
									WHEN strCostToUse = 'Pricing Level'
										THEN 0
									END)
								+ dblDeviation)
					WHEN strPriceBasis = 'S'
						THEN VI.dblSalePrice - (VI.dblSalePrice * (dblDeviation/100.00)) 
					WHEN strPriceBasis = 'M'
						THEN VI.dblSalePrice - dblDeviation
					WHEN strPriceBasis = '1'
						THEN dblDeviation
					WHEN strPriceBasis = '2'
						THEN dblDeviation
					WHEN strPriceBasis = '3'
						THEN dblDeviation
					WHEN strPriceBasis = 'R'
						THEN dblDeviation
					WHEN strPriceBasis = 'V'
						THEN dblDeviation
					WHEN strPriceBasis = 'T'
						THEN dblDeviation
					WHEN strPriceBasis = 'L'
						THEN dblDeviation
					WHEN strPriceBasis = 'O'
						THEN dblDeviation
				END)
		FROM
			vyuICGetItemStock VI
		LEFT OUTER JOIN
			tblICItemPricingLevel PL
				ON VI.intItemId = PL.intItemId
					AND VI.intItemLocationId = PL.intItemLocationId
					AND VI.intIssueUOMId = PL.intItemUnitMeasureId
		WHERE 
			VI.intItemId = @ItemId
			AND VI.intLocationId = @LocationId 
			AND (@ItemUOMId IS NULL OR VI.intIssueUOMId = @ItemUOMId)

		
		DECLARE @SpecialPricing TABLE(
		intSpecialPriceId INT
		,intEntityId INT
		,intVendorId INT
		,intItemId INT
		,strClass VARCHAR(100) COLLATE Latin1_General_CI_AS
		,strPriceBasis VARCHAR(100) COLLATE Latin1_General_CI_AS
		,strCustomerGroup NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strCostToUse NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,dblDeviation NUMERIC(18,6)
		,strLineNote NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,ysnConsignable BIT
		,intRackVendorId INT
		,intRackItemId INT
		,dblCustomerPrice NUMERIC(18,6))

		--Customer Group 
		DECLARE @CustomerGroup TABLE(
			intCustomerGroupId INT
			,strGroupName NVARCHAR(100) COLLATE Latin1_General_CI_AS
			,ysnSpecialPricing BIT
			,intEntityId INT
			,intCustomerId INT
			,strPricing NVARCHAR(MAX)
			,ysnSpecialPriceGroup BIT) 	
	
		INSERT INTO @CustomerGroup(
			intCustomerGroupId
			,strGroupName
			,ysnSpecialPricing
			,intEntityId
			,intCustomerId
			,strPricing
			,ysnSpecialPriceGroup)
		SELECT
			 CG.intCustomerGroupId 
			,CG.strGroupName
			,CGD.ysnSpecialPricing 
			,CGD.intEntityId
			,C.intCustomerId 
			,C.strPricing
			,C.ysnSpecialPriceGroup
		FROM 
			tblARCustomerGroup CG
		INNER JOIN
			tblARCustomerGroupDetail CGD
				ON CG.intCustomerGroupId = CGD.intCustomerGroupId
		INNER JOIN
			tblARCustomer C
				ON CGD.intEntityId = C.intEntityId					
		WHERE
			C.intCustomerId = @CustomerId
			AND CGD.ysnSpecialPricing = 1


		INSERT INTO @SpecialPricing (
			intSpecialPriceId
			,intEntityId
			,intVendorId
			,intItemId
			,strClass
			,strPriceBasis
			,strCustomerGroup
			,strCostToUse
			,dblDeviation
			,strLineNote
			,ysnConsignable
			,intRackVendorId
			,intRackItemId
			,dblCustomerPrice)
		SELECT
			SP.intSpecialPriceId
			,SP.intEntityId
			,SP.intVendorId
			,SP.intItemId
			,SP.strClass
			,SP.strPriceBasis
			,SP.strCustomerGroup
			,SP.strCostToUse
			,SP.dblDeviation
			,SP.strLineNote
			,SP.ysnConsignable
			,SP.intRackVendorId
			,SP.intRackItemId
			,SP.dblCustomerPrice
		FROM
			@CustomerSpecialPricing SP
		INNER JOIN
			@CustomerGroup CG
				ON SP.strCustomerGroup = CG.strGroupName
					

		--Customer Group - Vendor + Item
		SET @Price =	(SELECT dblCustomerPrice FROM @SpecialPricing WHERE intItemId = @ItemId AND intVendorId = @VendorId)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = 'Customer Group - Vendor + Item'
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'
				RETURN 1;
			END

		--Customer Group - Vendor + Item Class
		SET @Price =	(SELECT dblCustomerPrice FROM @SpecialPricing WHERE intItemId = @ItemId AND strClass = @ItemCategory)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = 'Customer Group - Vendor + Item Class'
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'
				RETURN 1;
			END

		--Customer Group - Vendor
		SET @Price =	(SELECT dblCustomerPrice FROM @SpecialPricing WHERE intVendorId = @VendorId)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = 'Customer Group - Vendor'
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'
				RETURN 1;
			END		

		--Customer Group - Item
		SET @Price =	(SELECT dblCustomerPrice FROM @SpecialPricing WHERE intItemId = @ItemId)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = 'Customer Group - Item'
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'				
				RETURN 1;
			END	
				
		--Customer Group - Item Class
		SET @Price =	(SELECT dblCustomerPrice FROM @SpecialPricing WHERE strClass = @ItemCategory)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = 'Customer Group - Item Class'
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
				RETURN 1;
			END	


		--Customer Special Pricing
		DELETE FROM @SpecialPricing			
		INSERT INTO @SpecialPricing (
			intSpecialPriceId
			,intEntityId
			,intVendorId
			,intItemId
			,strClass
			,strPriceBasis
			,strCustomerGroup
			,strCostToUse
			,dblDeviation
			,strLineNote
			,ysnConsignable
			,intRackVendorId
			,intRackItemId
			,dblCustomerPrice)
		SELECT
			SP.intSpecialPriceId
			,SP.intEntityId
			,SP.intVendorId
			,SP.intItemId
			,SP.strClass
			,SP.strPriceBasis
			,SP.strCustomerGroup
			,SP.strCostToUse
			,SP.dblDeviation
			,SP.strLineNote
			,SP.ysnConsignable
			,SP.intRackVendorId
			,SP.intRackItemId
			,SP.dblCustomerPrice
		FROM
			@CustomerSpecialPricing SP
		LEFT OUTER JOIN
			@CustomerGroup CG
				ON SP.strCustomerGroup = CG.strGroupName
		WHERE
			CG.intCustomerGroupId IS NULL


		--Customer - Vendor + Item
		SET @CustomerPricing =	(SELECT dblCustomerPrice FROM @SpecialPricing WHERE intItemId = @ItemId AND intVendorId = @VendorId)
		IF(@CustomerPricing IS NOT NULL)
			BEGIN
				SET @Pricing = 'Customer - Vendor + Item'
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
				RETURN 1;
			END

		--Customer - Vendor + Item Class
		SET @Price =	(SELECT dblCustomerPrice FROM @SpecialPricing WHERE intItemId = @ItemId AND strClass = @ItemCategory)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = 'Customer - Vendor + Item Class'
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
				RETURN 1;
			END

		--Customer - Vendor
		SET @Price =	(SELECT dblCustomerPrice FROM @SpecialPricing WHERE intVendorId = @VendorId)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = 'Customer - Vendor'
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
				RETURN 1;
			END		

		--Customer - Item
		SET @Price =	(SELECT dblCustomerPrice FROM @SpecialPricing WHERE intItemId = @ItemId)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = 'Customer - Item'
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
				RETURN 1;
			END	
				
		--Customer - Item Class
		SET @Price =	(SELECT dblCustomerPrice FROM @CustomerSpecialPricing WHERE strClass = @ItemCategory)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = 'Customer - Item Class'
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
				RETURN 1;
			END	
								

	END



	--Item Special Pricing
	SET @Price =	(	SELECT 
									dblDiscount
								FROM
									tblICItemSpecialPricing 
								WHERE
									intItemId = @ItemId 
									AND intItemLocationId = @ItemLocationyId 
									AND (@ItemUOMId IS NULL OR intItemUnitMeasureId = @ItemUOMId)
									AND @TransactionDate BETWEEN dtmBeginDate AND dtmEndDate
							)
	IF(@Price IS NOT NULL)
		BEGIN
			SET @Pricing = 'Inventory - Special Pricing'
			--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
			RETURN 1;
		END	


	--Item Pricing Level
	DECLARE @PricingLevel NVARCHAR(100)
	SET @Price =	( 
							SELECT
								(CASE
									WHEN PL.strPricingMethod = 'Fixed Dollar Amount'
										THEN PL.dblUnitPrice
									WHEN PL.strPricingMethod = 'Markup Standard Cost'
										THEN VIS.dblStandardCost + (PL.dblUnitPrice * (PL.dblAmountRate/100.00))
									WHEN PL.strPricingMethod = 'Percent of Margin'
										THEN VIS.dblSalePrice / (1 - (PL.dblAmountRate/100.00))
									WHEN PL.strPricingMethod = 'Discount Sales Price'
										THEN VIS.dblSalePrice - (PL.dblUnitPrice * (PL.dblAmountRate/100.00))
									WHEN PL.strPricingMethod = 'MSRP Discount'
										THEN VIS.dblMSRPPrice - (PL.dblUnitPrice * (PL.dblAmountRate/100.00))
									WHEN PL.strPricingMethod = 'Percent of Margin (MSRP)'
										THEN VIS.dblMSRPPrice / (1 - (PL.dblAmountRate/100.00))
									WHEN PL.strPricingMethod = 'None'
										THEN NULL
								END)
							FROM
								tblICItemPricingLevel PL
							INNER JOIN
								tblEntityLocation CL
									ON PL.strPriceLevel = CL.strPricingLevel
							INNER JOIN
								tblARCustomer C									
									ON CL.intEntityId = C.intEntityId																
							INNER JOIN vyuICGetItemStock VIS
									ON PL.intItemId = VIS.intItemId
									AND PL.intItemLocationId = VIS.intItemLocationId															
							WHERE
								C.intCustomerId = @CustomerId
								AND PL.intItemId = @ItemId
								AND PL.intItemLocationId = @ItemLocationyId
								AND PL.intItemUnitMeasureId = @ItemUOMId
								AND @Quantity BETWEEN PL.dblMin AND PL.dblMax
							)
	IF(@Price IS NOT NULL)
		BEGIN
			SET @Pricing = 'Inventory - Pricing Level'
			--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
			RETURN 1;
		END	


	--Item Standard Pricing
	SET @Price =	( 
							SELECT
								(CASE
									WHEN P.strPricingMethod = 'Fixed Dollar Amount'
										THEN P.dblSalePrice 
									WHEN P.strPricingMethod = 'Markup Standard Cost'
										THEN P.dblStandardCost + (P.dblSalePrice * (P.dblAmountPercent/100.00))
									WHEN P.strPricingMethod = 'Percent of Margin'
										THEN P.dblSalePrice / (1 - (P.dblAmountPercent/100.00))
									WHEN P.strPricingMethod = 'Discount Sales Price'
										THEN P.dblSalePrice - (P.dblSalePrice * (P.dblAmountPercent/100.00))
									WHEN P.strPricingMethod = 'MSRP Discount'
										THEN P.dblMSRPPrice - (P.dblSalePrice * (P.dblAmountPercent/100.00))
									WHEN P.strPricingMethod = 'Percent of Margin (MSRP)'
										THEN P.dblMSRPPrice / (1 - (P.dblAmountPercent/100.00))
									WHEN P.strPricingMethod = 'None'
										THEN NULL
								END)
							FROM
								tblICItemPricing P
							WHERE
								P.intItemId = @ItemId
								AND P.intItemLocationId = @ItemLocationyId
							)
	IF(@Price IS NOT NULL)
		BEGIN
			SET @Pricing = 'Inventory - Standard Pricing'
			--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
			RETURN 1;
		END	



RETURN 0
