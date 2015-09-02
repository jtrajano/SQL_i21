﻿CREATE PROCEDURE [dbo].[uspARGetCustomerSpecialPrice]
	@ItemId				INT
	,@CustomerId		INT	
	,@LocationId		INT
	,@ItemUOMId			INT				= NULL
	,@TransactionDate	DATETIME		= NULL
	,@Quantity			NUMERIC(18,6)
	,@Price				NUMERIC(18,6)	= NULL OUTPUT
	,@Pricing			NVARCHAR(250)	= NULL OUTPUT	
	,@VendorId			INT				= NULL
	,@SupplyPointId		INT				= NULL
	,@LastCost			NUMERIC(18,6)	= NULL
	,@ShipToLocationId  INT				= NULL
AS		
	
	DECLARE @ItemVendorId		INT
			,@ItemLocationId	INT
			,@ItemCategoryId	INT
			,@ItemCategory		NVARCHAR(100)
			,@UOMQuantity		NUMERIC(18,6)

	SELECT @ItemVendorId	= ISNULL(@VendorId, VI.intVendorId)
		  ,@ItemLocationId	= intItemLocationId
		  ,@ItemCategoryId	= I.intCategoryId
		  ,@ItemCategory	= C.strCategoryCode
		  ,@UOMQuantity		= CASE WHEN UOM.dblUnitQty = 0 OR UOM.dblUnitQty IS NULL THEN 1.00 ELSE UOM.dblUnitQty END
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
		,intEntityLocationId INT
		,dblCustomerPrice NUMERIC(18,6)
		,strPricing NVARCHAR(200) COLLATE Latin1_General_CI_AS)


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
		,intEntityLocationId
		,dblCustomerPrice
		,strPricing)
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
		,SP.ysnConsignable
		,SP.intRackVendorId
		,SP.intRackItemId
		,SP.intEntityLocationId
		,NULL
		,''
	FROM
		tblARCustomerSpecialPrice SP
	INNER JOIN
		tblARCustomer C
			ON SP.intEntityCustomerId = C.intEntityCustomerId
	WHERE
		C.intEntityCustomerId = @CustomerId AND SP.intCustomerLocationId = @ShipToLocationId
		AND ((@TransactionDate BETWEEN SP.dtmBeginDate AND ISNULL(SP.dtmEndDate, GETDATE())) OR (CAST(@TransactionDate AS DATE) >= CAST(SP.dtmBeginDate AS DATE) AND SP.dtmBeginDate IS NULL))

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
									WHEN strCostToUse = 'Last'
										THEN ISNULL(ISNULL(@LastCost, VI.dblLastCost), 0.00)
									WHEN strCostToUse = 'Standard'
										THEN ISNULL(VI.dblStandardCost, 0.00)
									WHEN strCostToUse = 'Average'
										THEN ISNULL(VI.dblAverageCost, 0.00)
									WHEN strCostToUse = 'EOM'
										THEN ISNULL(VI.dblEndMonthCost, 0.00)
									WHEN strCostToUse = 'Sale Price'
										THEN ISNULL(VI.dblSalePrice, 0.00)
									WHEN strCostToUse = 'MSRP'
										THEN ISNULL(VI.dblMSRPPrice, 0.00)
								END)
								 +
								(	(CASE
									WHEN strCostToUse = 'Last'
										THEN ISNULL(ISNULL(@LastCost, VI.dblLastCost), 0.00)
									WHEN strCostToUse = 'Standard'
										THEN ISNULL(VI.dblStandardCost, 0.00)
									WHEN strCostToUse = 'Average'
										THEN ISNULL(VI.dblAverageCost, 0.00)
									WHEN strCostToUse = 'EOM'
										THEN ISNULL(VI.dblEndMonthCost, 0.00)
									WHEN strCostToUse = 'Sale Price'
										THEN ISNULL(VI.dblSalePrice, 0.00)
									WHEN strCostToUse = 'MSRP'
										THEN ISNULL(VI.dblMSRPPrice, 0.00)
									END)
								* (dblDeviation/100.00))
					WHEN strPriceBasis = 'A'
						THEN	((CASE
									WHEN strCostToUse = 'Last'
										THEN ISNULL(ISNULL(@LastCost, VI.dblLastCost), 0.00)
									WHEN strCostToUse = 'Standard'
										THEN ISNULL(VI.dblStandardCost, 0.00)
									WHEN strCostToUse = 'Average'
										THEN ISNULL(VI.dblAverageCost, 0.00)
									WHEN strCostToUse = 'EOM'
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
						THEN PL1.dblUnitPrice + dblDeviation
					WHEN strPriceBasis = '2'
						THEN PL2.dblUnitPrice + dblDeviation
					WHEN strPriceBasis = '3'
						THEN PL3.dblUnitPrice + dblDeviation
					WHEN strPriceBasis = 'O'
						THEN (CASE
									WHEN strCostToUse = 'Vendor'
										THEN RACK.dblVendorRack
									WHEN strCostToUse = 'Jobber'
										THEN RACK.dblJobberRack
								END) + dblDeviation
					WHEN strPriceBasis = 'L'
						THEN dblDeviation
				END)
			,strPricing  = 
				(CASE 
					WHEN strPriceBasis = 'X'
						THEN ''
					WHEN strPriceBasis = 'F'
						THEN 'Customer Pricing of (F)Fixed'
					WHEN strPriceBasis = 'C'
						THEN 'Customer Pricing of (C)Inventory Cost + Pct'
					WHEN strPriceBasis = 'A'
						THEN 'Customer Pricing of (A)Inventory Cost + Amt'
					WHEN strPriceBasis = 'S'
						THEN 'Customer Pricing of (S)Sell - Pct'
					WHEN strPriceBasis = 'M'
						THEN 'Customer Pricing of (M)Sell - Amt'
					WHEN strPriceBasis = '1'
						THEN 'Customer Pricing of (1)Price Level + Amt'
					WHEN strPriceBasis = '2'
						THEN 'Customer Pricing of (2)Price Level + Amt'
					WHEN strPriceBasis = '3'
						THEN 'Customer Pricing of (3)Price Level + Amt'
					WHEN strPriceBasis = 'R'
						THEN 'Customer Pricing of (R)Fixed Rack + Amount'
					WHEN strPriceBasis = 'L'
						THEN 'Customer Pricing of (L)Link'
					WHEN strPriceBasis = 'O'
						THEN 'Customer Pricing of (O)Origin Rack + Amt'
				END)
		FROM
			vyuICGetItemStock VI
		LEFT OUTER JOIN
			(
				SELECT PL.intItemId, PL.intItemUnitMeasureId AS intItemUOM, PL.dblMin, PL.dblMax, PL.dblUnitPrice, ICL.intLocationId 
				FROM tblICItemPricingLevel PL	
				INNER JOIN tblSMCompanyLocationPricingLevel CPL ON PL.strPriceLevel = CPL.strPricingLevelName 		
				INNER JOIN tblICItemLocation ICL ON PL.intItemLocationId = ICL.intItemLocationId
				WHERE CPL.intSort = 1 
			) AS PL1
				ON VI.intItemId = PL1.intItemId AND VI.intLocationId = PL1.intLocationId AND VI.intStockUOMId = PL1.intItemUOM AND @Quantity BETWEEN PL1.dblMin AND PL1.dblMax
		LEFT OUTER JOIN
			(
				SELECT PL.intItemId, PL.intItemUnitMeasureId AS intItemUOM, PL.dblMin, PL.dblMax, PL.dblUnitPrice, ICL.intLocationId 
				FROM tblICItemPricingLevel PL	
				INNER JOIN tblSMCompanyLocationPricingLevel CPL ON PL.strPriceLevel = CPL.strPricingLevelName 		
				INNER JOIN tblICItemLocation ICL ON PL.intItemLocationId = ICL.intItemLocationId
				WHERE CPL.intSort = 2
			) AS PL2 
				ON VI.intItemId = PL1.intItemId AND VI.intLocationId = PL1.intLocationId AND VI.intStockUOMId = PL1.intItemUOM AND @Quantity BETWEEN PL1.dblMin AND PL1.dblMax				
		LEFT OUTER JOIN
			(
				SELECT PL.intItemId, PL.intItemUnitMeasureId AS intItemUOM, PL.dblMin, PL.dblMax, PL.dblUnitPrice, ICL.intLocationId 
				FROM tblICItemPricingLevel PL	
				INNER JOIN tblSMCompanyLocationPricingLevel CPL ON PL.strPriceLevel = CPL.strPricingLevelName 		
				INNER JOIN tblICItemLocation ICL ON PL.intItemLocationId = ICL.intItemLocationId
				WHERE CPL.intSort = 3
			) AS PL3 
				ON VI.intItemId = PL1.intItemId AND VI.intLocationId = PL1.intLocationId AND VI.intStockUOMId = PL1.intItemUOM AND @Quantity BETWEEN PL1.dblMin AND PL1.dblMax				
		LEFT OUTER JOIN
			tblICItemUOM UOM
				ON VI.intItemId = UOM.intItemId
				AND VI.intStockUOMId = UOM.intItemUOMId
		LEFT OUTER JOIN
			vyuTRRackPrice AS RACK
				ON  VI.intItemId = RACK.intItemId
				AND (RACK.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL)
				AND CAST(@TransactionDate AS DATE) >= CAST(RACK.dtmEffectiveDateTime AS DATE)
		WHERE 
			VI.intItemId = @ItemId
			AND VI.intLocationId = @LocationId 
			AND (@ItemUOMId IS NULL OR UOM.intItemUOMId = @ItemUOMId)
			
		UPDATE
			@CustomerSpecialPricing
		SET
			dblCustomerPrice = (SELECT TOP 1 CASE WHEN strCostToUse = 'Vendor' THEN dblVendorRack 
								    			   WHEN strCostToUse = 'Jobber' THEN dblJobberRack
											  END 
								FROM vyuTRRackPrice INNER JOIN tblTRSupplyPoint 
									ON vyuTRRackPrice.intSupplyPointId = tblTRSupplyPoint.intSupplyPointId 
								WHERE tblTRSupplyPoint.intEntityLocationId = intEntityLocationId 
									AND vyuTRRackPrice.intItemId = intRackItemId
									AND vyuTRRackPrice.intSupplyPointId = @SupplyPointId 
									AND CAST(@TransactionDate AS DATE) >= CAST(vyuTRRackPrice.dtmEffectiveDateTime AS DATE)
									ORDER BY vyuTRRackPrice.dtmEffectiveDateTime DESC) + dblDeviation
		WHERE
			strPriceBasis = 'R'

		
		DECLARE @SpecialGroupPricing TABLE(
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
			,intEntityLocationId INT
			,dblCustomerPrice NUMERIC(18,6)
			,strPricing NVARCHAR(200) COLLATE Latin1_General_CI_AS)

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
			,C.intEntityCustomerId 
			,C.strPricing
			,C.ysnSpecialPriceGroup
		FROM 
			tblARCustomerGroup CG
		INNER JOIN
			tblARCustomerGroupDetail CGD
				ON CG.intCustomerGroupId = CGD.intCustomerGroupId
		INNER JOIN
			tblARCustomer C
				ON CGD.intEntityId = C.intEntityCustomerId					
		WHERE
			C.intEntityCustomerId = @CustomerId
			AND CGD.ysnSpecialPricing = 1


		INSERT INTO @SpecialGroupPricing (
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
			,intEntityLocationId
			,dblCustomerPrice
			,strPricing)
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
			,SP.intEntityLocationId
			,SP.dblCustomerPrice
			,SP.strPricing 
		FROM
			@CustomerSpecialPricing SP
		INNER JOIN
			@CustomerGroup CG
				ON SP.strCustomerGroup = CG.strGroupName
				
		--Customer Group - Rack Vendor No + Rack Item No
		SET @Price = @UOMQuantity *	(SELECT TOP 1 SP.dblCustomerPrice FROM @SpecialGroupPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intEntityLocationId = TR.intEntityLocationId  WHERE SP.intRackItemId = @ItemId AND SP.intRackVendorId = @ItemVendorId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 SP.strPricing FROM @SpecialGroupPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intEntityLocationId = TR.intEntityLocationId  WHERE SP.intRackItemId = @ItemId AND SP.intRackVendorId = @ItemVendorId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'
				RETURN 1;
			END

		--Customer Group - Rack Vendor No
		SET @Price = @UOMQuantity *	(SELECT TOP 1 SP.dblCustomerPrice FROM @SpecialGroupPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intEntityLocationId = TR.intEntityLocationId  WHERE SP.intRackItemId = @ItemId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 SP.strPricing FROM @SpecialGroupPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intEntityLocationId = TR.intEntityLocationId  WHERE SP.intRackItemId = @ItemId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'
				RETURN 1;
			END

		--Customer Group - Rack Item No
		SET @Price = @UOMQuantity *	(SELECT TOP 1 SP.dblCustomerPrice FROM @SpecialGroupPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intEntityLocationId = TR.intEntityLocationId  WHERE SP.intRackVendorId = @ItemVendorId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 SP.strPricing FROM @SpecialGroupPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intEntityLocationId = TR.intEntityLocationId  WHERE SP.intRackVendorId = @ItemVendorId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'
				RETURN 1;
			END
			
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
			,intEntityLocationId INT
			,dblCustomerPrice NUMERIC(18,6)
			,strPricing NVARCHAR(200) COLLATE Latin1_General_CI_AS)
					
		--Customer Special Pricing
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
			,intEntityLocationId
			,dblCustomerPrice
			,strPricing)
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
			,SP.intEntityLocationId
			,SP.dblCustomerPrice
			,SP.strPricing
		FROM
			@CustomerSpecialPricing SP
		LEFT OUTER JOIN
			@CustomerGroup CG
				ON SP.strCustomerGroup = CG.strGroupName
		WHERE
			CG.intCustomerGroupId IS NULL
			

		--Customer - Rack Vendor No + Rack Item No
		SET @Price = @UOMQuantity *	(SELECT TOP 1 SP.dblCustomerPrice FROM @SpecialPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intEntityLocationId = TR.intEntityLocationId  WHERE SP.intRackItemId = @ItemId AND SP.intRackVendorId = @ItemVendorId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 SP.strPricing FROM @SpecialPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intEntityLocationId = TR.intEntityLocationId  WHERE SP.intRackItemId = @ItemId AND SP.intRackVendorId = @ItemVendorId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
				RETURN 1;
			END

		--Customer - Vendor + Rack Vendor No
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intEntityLocationId = TR.intEntityLocationId  WHERE SP.intRackVendorId = @ItemVendorId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intEntityLocationId = TR.intEntityLocationId  WHERE SP.intRackVendorId = @ItemVendorId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
				RETURN 1;
			END

		--Customer - Rack Item No
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intEntityLocationId = TR.intEntityLocationId  WHERE SP.intRackItemId = @ItemId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intEntityLocationId = TR.intEntityLocationId  WHERE SP.intRackItemId = @ItemId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
				RETURN 1;
			END										
					

		--Customer Group - Vendor + Item
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialGroupPricing WHERE intItemId = @ItemId AND intVendorId = @ItemVendorId)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialGroupPricing WHERE intItemId = @ItemId AND intVendorId = @ItemVendorId)
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'
				RETURN 1;
			END

		--Customer Group - Vendor + Item Class
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialGroupPricing WHERE intItemId = @ItemId AND strClass = @ItemCategory)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialGroupPricing WHERE intItemId = @ItemId AND strClass = @ItemCategory)
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'
				RETURN 1;
			END

		--Customer Group - Vendor
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialGroupPricing WHERE intVendorId = @ItemVendorId)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialGroupPricing WHERE intVendorId = @ItemVendorId)
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'
				RETURN 1;
			END		

		--Customer Group - Item
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialGroupPricing WHERE intItemId = @ItemId)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialGroupPricing WHERE intItemId = @ItemId)
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'				
				RETURN 1;
			END	
				
		--Customer Group - Item Class
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialGroupPricing WHERE strClass = @ItemCategory)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialGroupPricing WHERE strClass = @ItemCategory)
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
				RETURN 1;
			END			

		--Customer - Vendor + Item
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialPricing WHERE intItemId = @ItemId AND intVendorId = @ItemVendorId)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialPricing WHERE intItemId = @ItemId AND intVendorId = @ItemVendorId)
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
				RETURN 1;
			END

		--Customer - Vendor + Item Class
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialPricing WHERE intItemId = @ItemId AND strClass = @ItemCategory)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialPricing WHERE intItemId = @ItemId AND strClass = @ItemCategory)
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
				RETURN 1;
			END

		--Customer - Vendor
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialPricing WHERE intVendorId = @ItemVendorId)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialPricing WHERE intVendorId = @ItemVendorId)
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
				RETURN 1;
			END		

		--Customer - Item
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialPricing WHERE intItemId = @ItemId)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialPricing WHERE intItemId = @ItemId)
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
				RETURN 1;
			END	
				
		--Customer - Item Class
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @CustomerSpecialPricing WHERE strClass = @ItemCategory)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @CustomerSpecialPricing WHERE strClass = @ItemCategory)
				--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
				RETURN 1;
			END	
								

	END

RETURN 0
