CREATE FUNCTION [dbo].[fnGetItemPricing]
(
	@ItemId				INT
	,@CustomerId		INT	
	,@LocationId		INT
	,@ItemUOMId			INT				= NULL
	,@TransactionDate	DATETIME		= NULL
	,@Quantity			NUMERIC(18,6)
	,@ResultDelimeter	CHAR			= ':'
)
RETURNS NVARCHAR(500)
AS
BEGIN
	DECLARE  @Price		NUMERIC(18,6)
			,@Pricing	NVARCHAR(250)

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
		--,ysnConsignable
		,intRackVendorId
		,intRackItemId
		,dblCustomerPrice)
	SELECT
		SP.intSpecialPriceId
		,SP.intEntityCustomerId
		,SP.intEntityVendorId
		,SP.intItemId
		,SP.strClass
		,SP.strPriceBasis
		,SP.strCustomerGroup
		,SP.strCostToUse
		,SP.dblDeviation
		,SP.strLineNote
		--,SP.ysnConsignable
		,SP.intRackVendorId
		,SP.intRackItemId
		,NULL
	FROM
		tblARCustomerSpecialPrice SP
	INNER JOIN
		tblARCustomer C
			ON SP.intEntityCustomerId = C.[intEntityId]
	WHERE
		C.[intEntityId] = @CustomerId
		AND @TransactionDate BETWEEN SP.dtmBeginDate AND SP.dtmEndDate


	DECLARE @VendorId			INT
			,@ItemLocationId	INT
			,@ItemCategoryId	INT
			,@ItemCategory	NVARCHAR(100)
			,@UOMQuantity		NUMERIC(18,6)

	SELECT
		@VendorId = VI.intVendorId
		,@ItemLocationId = intItemLocationId
		,@ItemCategoryId = I.intCategoryId
		,@ItemCategory = C.strCategoryCode
		,@UOMQuantity		= ISNULL(UOM.dblUnitQty,1.00)
	FROM
		tblICItem I
	INNER JOIN
		vyuICGetItemStock VI
			ON I.intItemId = VI.intItemId
	LEFT OUTER JOIN
		tblICCategory C
			ON I.intCategoryId = C.intCategoryId
	LEFT OUTER JOIN
		tblICItemUOM UOM
			ON I.intItemId = UOM.intItemId
	WHERE
		I.intItemId = @ItemId
		AND VI.intLocationId = @LocationId 
		AND (UOM.intItemUOMId = @ItemUOMId OR @ItemUOMId IS NULL)
	

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
		LEFT OUTER JOIN
			tblICItemUOM UOM
				ON PL.intItemId = UOM.intItemId
				AND PL.intItemUnitMeasureId = UOM.intItemUOMId
		WHERE 
			VI.intItemId = @ItemId
			AND VI.intLocationId = @LocationId 
			AND (@ItemUOMId IS NULL OR UOM.intItemUOMId = @ItemUOMId)

		
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
			,C.[intEntityId] 
			,C.strPricing
			,C.ysnSpecialPriceGroup
		FROM 
			tblARCustomerGroup CG
		INNER JOIN
			tblARCustomerGroupDetail CGD
				ON CG.intCustomerGroupId = CGD.intCustomerGroupId
		INNER JOIN
			tblARCustomer C
				ON CGD.intEntityId = C.[intEntityId]					
		WHERE
			C.[intEntityId] = @CustomerId
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
		SET @Price = @UOMQuantity *	(SELECT dblCustomerPrice FROM @SpecialPricing WHERE intItemId = @ItemId AND intVendorId = @VendorId)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = 'Customer Group - Vendor + Item'
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'
				RETURN CONVERT(VARCHAR, CAST(@Price AS MONEY), 1) + @ResultDelimeter + ' ' + @Pricing;
			END

		--Customer Group - Vendor + Item Class
		SET @Price = @UOMQuantity *	(SELECT dblCustomerPrice FROM @SpecialPricing WHERE intItemId = @ItemId AND strClass = @ItemCategory)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = 'Customer Group - Vendor + Item Class'
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'
				RETURN CONVERT(VARCHAR, CAST(@Price AS MONEY), 1) + @ResultDelimeter + ' ' + @Pricing;
			END

		--Customer Group - Vendor
		SET @Price = @UOMQuantity *	(SELECT dblCustomerPrice FROM @SpecialPricing WHERE intVendorId = @VendorId)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = 'Customer Group - Vendor'
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'
				RETURN CONVERT(VARCHAR, CAST(@Price AS MONEY), 1) + @ResultDelimeter + ' ' + @Pricing;
			END		

		--Customer Group - Item
		SET @Price = @UOMQuantity *	(SELECT dblCustomerPrice FROM @SpecialPricing WHERE intItemId = @ItemId)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = 'Customer Group - Item'
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'				
				RETURN CONVERT(VARCHAR, CAST(@Price AS MONEY), 1) + @ResultDelimeter + ' ' + @Pricing;
			END	
				
		--Customer Group - Item Class
		SET @Price = @UOMQuantity *	(SELECT dblCustomerPrice FROM @SpecialPricing WHERE strClass = @ItemCategory)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = 'Customer Group - Item Class'
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
				RETURN CONVERT(VARCHAR, CAST(@Price AS MONEY), 1) + @ResultDelimeter + ' ' + @Pricing;
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
		SET @Price = @UOMQuantity *	(SELECT dblCustomerPrice FROM @SpecialPricing WHERE intItemId = @ItemId AND intVendorId = @VendorId)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = 'Customer - Vendor + Item'
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
				RETURN CONVERT(VARCHAR, CAST(@Price AS MONEY), 1) + @ResultDelimeter + ' ' + @Pricing;
			END

		--Customer - Vendor + Item Class
		SET @Price = @UOMQuantity *	(SELECT dblCustomerPrice FROM @SpecialPricing WHERE intItemId = @ItemId AND strClass = @ItemCategory)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = 'Customer - Vendor + Item Class'
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
				RETURN CONVERT(VARCHAR, CAST(@Price AS MONEY), 1) + @ResultDelimeter + ' ' + @Pricing;
			END

		--Customer - Vendor
		SET @Price = @UOMQuantity *	(SELECT dblCustomerPrice FROM @SpecialPricing WHERE intVendorId = @VendorId)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = 'Customer - Vendor'
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
				RETURN CONVERT(VARCHAR, CAST(@Price AS MONEY), 1) + @ResultDelimeter + ' ' + @Pricing;
			END		

		--Customer - Item
		SET @Price = @UOMQuantity *	(SELECT dblCustomerPrice FROM @SpecialPricing WHERE intItemId = @ItemId)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = 'Customer - Item'
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
				RETURN CONVERT(VARCHAR, CAST(@Price AS MONEY), 1) + @ResultDelimeter + ' ' + @Pricing;
			END	
				
		--Customer - Item Class
		SET @Price = @UOMQuantity *	(SELECT dblCustomerPrice FROM @CustomerSpecialPricing WHERE strClass = @ItemCategory)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = 'Customer - Item Class'
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
				RETURN CONVERT(VARCHAR, CAST(@Price AS MONEY), 1) + @ResultDelimeter + ' ' + @Pricing;
			END	
								

	END



	--Item Special Pricing
	SET @Price = @UOMQuantity *	
					(	SELECT 
							--dblUnitAfterDiscount
							(CASE
								WHEN strDiscountBy = 'Amount'
									THEN dblUnitAfterDiscount - ISNULL(dblDiscount, 0.00)
								ELSE	
									dblUnitAfterDiscount - (dblUnitAfterDiscount * (ISNULL(dblDiscount, 0.00)/100.00) )
							END)
						FROM
							tblICItemSpecialPricing 
						WHERE
							intItemId = @ItemId 
							AND intItemLocationId = @ItemLocationId 
							AND (@ItemUOMId IS NULL OR intItemUnitMeasureId = @ItemUOMId)
							AND @TransactionDate BETWEEN dtmBeginDate AND dtmEndDate
							)
	IF(@Price IS NOT NULL)
		BEGIN
			SET @Pricing = 'Inventory - Special Pricing'
			--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
			RETURN CONVERT(VARCHAR, CAST(@Price AS MONEY), 1) + @ResultDelimeter + ' ' + @Pricing;
		END	


	--Item Pricing Level
	DECLARE @PricingLevel NVARCHAR(100)
	SET @Price = @UOMQuantity *	
						( 
							SELECT
								PL.dblUnitPrice
							FROM
								tblICItemPricingLevel PL
							INNER JOIN
								[tblEMEntityLocation] CL
									ON PL.strPriceLevel = CL.strPricingLevel
							INNER JOIN
								tblARCustomer C									
									ON CL.intEntityId = C.[intEntityId]
									AND CL.ysnDefaultLocation = 1															
							INNER JOIN vyuICGetItemStock VIS
									ON PL.intItemId = VIS.intItemId
									AND PL.intItemLocationId = VIS.intItemLocationId															
							WHERE
								C.[intEntityId] = @CustomerId
								AND PL.intItemId = @ItemId
								AND PL.intItemLocationId = @ItemLocationId
								AND PL.intItemUnitMeasureId = @ItemUOMId
								AND @Quantity BETWEEN PL.dblMin AND PL.dblMax
							)
	IF(@Price IS NOT NULL)
		BEGIN
			SET @Pricing = 'Inventory - Pricing Level'
			--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
			RETURN CONVERT(VARCHAR, CAST(@Price AS MONEY), 1) + @ResultDelimeter + ' ' + @Pricing;
		END	


	--Item Standard Pricing
	IF ISNULL(@UOMQuantity,0) = 0
		SET @UOMQuantity = 1
	SET @Price = @UOMQuantity *	
						( 
							SELECT
								P.dblSalePrice
							FROM
								tblICItemPricing P
							WHERE
								P.intItemId = @ItemId
								AND P.intItemLocationId = @ItemLocationId
							)
	IF(@Price IS NOT NULL)
		BEGIN
			SET @Pricing = 'Inventory - Standard Pricing'
			--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
			RETURN CONVERT(VARCHAR, CAST(@Price AS MONEY), 1) + @ResultDelimeter + ' ' + @Pricing;
		END	
			 

	RETURN CONVERT(VARCHAR, CAST(@Price AS MONEY), 1) + @ResultDelimeter + ' ' + @Pricing;
END
