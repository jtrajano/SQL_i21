﻿CREATE FUNCTION [dbo].[fnARGetCustomerPricingDetails]
(
	 @ItemId				INT
	,@CustomerId			INT	
	,@LocationId			INT
	,@ItemUOMId				INT
	,@TransactionDate		DATETIME
	,@Quantity				NUMERIC(18,6)
	,@VendorId				INT
	,@SupplyPointId			INT
	,@LastCost				NUMERIC(18,6)
	,@ShipToLocationId      INT
	,@VendorLocationId		INT
	,@InvoiceType			NVARCHAR(200)
)
RETURNS @returntable TABLE
(
	 dblPrice			NUMERIC(18,6)
	,strPricing			NVARCHAR(250)
	,intSpecialPriceId	INT
	,dblPriceBasis		NUMERIC(18,6)
	,dblDeviation		NUMERIC(18,6)
	,dblUOMQuantity		NUMERIC(18,6)
)
AS
BEGIN

	DECLARE @SpecialPriceId	INT

	SET @TransactionDate = ISNULL(@TransactionDate,GETDATE())	
	
	DECLARE @ItemVendorId				INT
			,@ItemLocationId			INT
			,@ItemCategoryId			INT
			,@ItemCategory				NVARCHAR(100)
			,@UOMQuantity				NUMERIC(18,6)
			,@CustomerShipToLocationId	INT
			,@VendorShipFromLocationId	INT

	SELECT TOP 1 
		 @ItemVendorId				= intItemVendorId
		,@ItemLocationId			= intItemLocationId
		,@ItemCategoryId			= intItemCategoryId
		,@ItemCategory				= strItemCategory
		,@UOMQuantity				= dblUOMQuantity
		,@CustomerShipToLocationId	= intCustomerShipToLocationId
		,@VendorShipFromLocationId	= intVendorShipFromLocationId
	FROM
		[dbo].[fnARGetLocationItemVendorDetailsForPricing](
			 @ItemId
			,@CustomerId
			,@LocationId
			,@ItemUOMId
			,@VendorId
			,@ShipToLocationId
			,@VendorLocationId
		);													
			

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
		,intRackVendorId INT
		,intRackItemId INT
		,intRackItemLocationId INT
		,intVendorLocationId INT
		,intCustomerLocationId INT
		,dblPriceBasis NUMERIC(18,6)
		,dblCustomerPrice NUMERIC(18,6)
		,strPricing NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strInvoiceType NVARCHAR(200) COLLATE Latin1_General_CI_AS)


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
		,intRackVendorId
		,intRackItemId
		,intRackItemLocationId
		,intVendorLocationId
		,intCustomerLocationId
		,dblPriceBasis
		,dblCustomerPrice
		,strPricing
		,strInvoiceType)
	SELECT
		SP.intSpecialPriceId
		,SP.intEntityCustomerId
		,SP.intEntityVendorId
		,SP.intItemId
		,UPPER(LTRIM(RTRIM(ISNULL(SP.strClass,''))))
		,SP.strPriceBasis
		,SP.strCustomerGroup
		,SP.strCostToUse
		,SP.dblDeviation
		,SP.strLineNote
		,SP.intRackVendorId
		,SP.intRackItemId
		,SP.intRackLocationId 
		,ISNULL(SP.intEntityLocationId, SP.intRackLocationId)
		,SP.intCustomerLocationId
		,NULL
		,NULL
		,''
		,SP.strInvoiceType
	FROM
		tblARCustomerSpecialPrice SP
	INNER JOIN
		tblARCustomer C
			ON SP.intEntityCustomerId = C.intEntityCustomerId
	WHERE
		C.intEntityCustomerId = @CustomerId
		AND ((CAST(@TransactionDate AS DATE) BETWEEN CAST(SP.dtmBeginDate AS DATE) AND CAST(ISNULL(SP.dtmEndDate, GETDATE()) AS DATE)) OR (CAST(@TransactionDate AS DATE) >= CAST(SP.dtmBeginDate AS DATE) AND SP.dtmEndDate IS NULL))
		AND ((@LocationId IS NOT NULL) OR (@LocationId IS NULL AND SP.strPriceBasis IN ('F', 'R', 'L', 'O')))
		AND SP.intItemId = @ItemId

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
					--WHEN strPriceBasis = 'O'
					--	THEN (CASE WHEN [dbo].fnTRGetRackPrice(@TransactionDate, @SupplyPointId, @ItemId) <> 0 THEN [dbo].fnTRGetRackPrice(@TransactionDate, @SupplyPointId, @ItemId) + dblDeviation ELSE NULL END)
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
			,dblPriceBasis = 
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
					WHEN strPriceBasis = 'A'
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
					WHEN strPriceBasis = 'S'
						THEN VI.dblSalePrice
					WHEN strPriceBasis = 'M'
						THEN VI.dblSalePrice
					WHEN strPriceBasis = '1'
						THEN PL1.dblUnitPrice
					WHEN strPriceBasis = '2'
						THEN PL2.dblUnitPrice
					WHEN strPriceBasis = '3'
						THEN PL3.dblUnitPrice
					--WHEN strPriceBasis = 'O'
					--	THEN (CASE WHEN [dbo].fnTRGetRackPrice(@TransactionDate, @SupplyPointId, @ItemId) <> 0 THEN [dbo].fnTRGetRackPrice(@TransactionDate, @SupplyPointId, @ItemId) ELSE NULL END)
					WHEN strPriceBasis = 'L'
						THEN dblDeviation
				END)
		FROM
			vyuICGetItemStock VI
		LEFT OUTER JOIN
			(
				SELECT TOP 1 PL.intItemId, PL.intItemUnitMeasureId AS intItemUOM, PL.dblMin, PL.dblMax, PL.dblUnitPrice, ICL.intLocationId 
				FROM tblICItemPricingLevel PL	
				INNER JOIN tblSMCompanyLocationPricingLevel CPL ON PL.strPriceLevel = CPL.strPricingLevelName 		
				INNER JOIN tblICItemLocation ICL ON PL.intItemLocationId = ICL.intItemLocationId
				WHERE CPL.intSort = 1
					AND @Quantity BETWEEN PL.dblMin  AND PL.dblMax
				ORDER BY PL.dblMax 
			) AS PL1
				ON VI.intItemId = PL1.intItemId AND VI.intLocationId = PL1.intLocationId AND VI.intStockUOMId = PL1.intItemUOM AND @Quantity BETWEEN PL1.dblMin AND PL1.dblMax
		LEFT OUTER JOIN
			(
				SELECT TOP 1 PL.intItemId, PL.intItemUnitMeasureId AS intItemUOM, PL.dblMin, PL.dblMax, PL.dblUnitPrice, ICL.intLocationId 
				FROM tblICItemPricingLevel PL	
				INNER JOIN tblSMCompanyLocationPricingLevel CPL ON PL.strPriceLevel = CPL.strPricingLevelName 		
				INNER JOIN tblICItemLocation ICL ON PL.intItemLocationId = ICL.intItemLocationId
				WHERE CPL.intSort = 2
					AND @Quantity BETWEEN PL.dblMin  AND PL.dblMax
				ORDER BY PL.dblMax
			) AS PL2 
				ON VI.intItemId = PL2.intItemId AND VI.intLocationId = PL2.intLocationId AND VI.intStockUOMId = PL2.intItemUOM AND @Quantity BETWEEN PL2.dblMin AND PL2.dblMax				
		LEFT OUTER JOIN
			(
				SELECT TOP 1 PL.intItemId, PL.intItemUnitMeasureId AS intItemUOM, PL.dblMin, PL.dblMax, PL.dblUnitPrice, ICL.intLocationId 
				FROM tblICItemPricingLevel PL	
				INNER JOIN tblSMCompanyLocationPricingLevel CPL ON PL.strPriceLevel = CPL.strPricingLevelName 		
				INNER JOIN tblICItemLocation ICL ON PL.intItemLocationId = ICL.intItemLocationId
				WHERE CPL.intSort = 3
					AND @Quantity BETWEEN PL.dblMin  AND PL.dblMax
				ORDER BY PL.dblMax
			) AS PL3 
				ON VI.intItemId = PL3.intItemId AND VI.intLocationId = PL3.intLocationId AND VI.intStockUOMId = PL3.intItemUOM AND @Quantity BETWEEN PL3.dblMin AND PL3.dblMax				
		LEFT OUTER JOIN
			tblICItemUOM UOM
				ON VI.intItemId = UOM.intItemId
				AND VI.intStockUOMId = UOM.intItemUOMId
		WHERE 
			VI.intItemId = @ItemId
			AND VI.intLocationId = @LocationId 
			AND (@ItemUOMId IS NULL OR UOM.intItemUOMId = @ItemUOMId)
			

		--(R)Fixed Rack			
		UPDATE
			@CustomerSpecialPricing
		SET
			dblCustomerPrice = (SELECT TOP 1 CASE WHEN strCostToUse = 'Vendor' THEN dblVendorRack 
								    			   WHEN strCostToUse = 'Jobber' THEN dblJobberRack
											  END 
								FROM vyuTRRackPrice INNER JOIN tblTRSupplyPoint 
									ON vyuTRRackPrice.intSupplyPointId = ISNULL(tblTRSupplyPoint.intRackPriceSupplyPointId ,tblTRSupplyPoint.intSupplyPointId) 
								WHERE tblTRSupplyPoint.intEntityLocationId = intVendorLocationId 
									AND vyuTRRackPrice.intItemId = intRackItemId
									AND ((vyuTRRackPrice.intSupplyPointId = ISNULL(@SupplyPointId,0) AND ISNULL(@SupplyPointId,0) <> 0) OR tblTRSupplyPoint.intEntityLocationId = intRackItemLocationId)
									AND CAST(@TransactionDate AS DATE) >= CAST(vyuTRRackPrice.dtmEffectiveDateTime AS DATE)
									ORDER BY vyuTRRackPrice.dtmEffectiveDateTime DESC) + dblDeviation
			,dblPriceBasis = (SELECT TOP 1 CASE WHEN strCostToUse = 'Vendor' THEN dblVendorRack 
								    			   WHEN strCostToUse = 'Jobber' THEN dblJobberRack
											  END 
								FROM vyuTRRackPrice INNER JOIN tblTRSupplyPoint 
									ON vyuTRRackPrice.intSupplyPointId = ISNULL(tblTRSupplyPoint.intRackPriceSupplyPointId ,tblTRSupplyPoint.intSupplyPointId)
								WHERE tblTRSupplyPoint.intEntityLocationId = intVendorLocationId 
									AND vyuTRRackPrice.intItemId = intRackItemId
									AND ((vyuTRRackPrice.intSupplyPointId = ISNULL(@SupplyPointId,0) AND ISNULL(@SupplyPointId,0) <> 0) OR tblTRSupplyPoint.intEntityLocationId = intRackItemLocationId)
									AND CAST(@TransactionDate AS DATE) >= CAST(vyuTRRackPrice.dtmEffectiveDateTime AS DATE)
									ORDER BY vyuTRRackPrice.dtmEffectiveDateTime DESC)									
		WHERE
			strPriceBasis = 'R'
			AND (intCustomerLocationId = @ShipToLocationId OR ISNULL(@ShipToLocationId,0) = 0)
					
		
		--(O)Origin Rack			
		UPDATE
			@CustomerSpecialPricing
		SET
			dblCustomerPrice = (SELECT TOP 1 CASE WHEN strCostToUse = 'Vendor' THEN dblVendorRack 
								    			   WHEN strCostToUse = 'Jobber' THEN dblJobberRack
											  END 
								FROM vyuTRRackPrice INNER JOIN tblTRSupplyPoint 
									ON vyuTRRackPrice.intSupplyPointId = ISNULL(tblTRSupplyPoint.intRackPriceSupplyPointId ,tblTRSupplyPoint.intSupplyPointId) 
								WHERE vyuTRRackPrice.intItemId = @ItemId
									AND ((vyuTRRackPrice.intSupplyPointId = ISNULL(@SupplyPointId,0) AND ISNULL(@SupplyPointId,0) <> 0) OR tblTRSupplyPoint.intEntityLocationId = intVendorLocationId)
									AND CAST(@TransactionDate AS DATE) >= CAST(vyuTRRackPrice.dtmEffectiveDateTime AS DATE)
									ORDER BY vyuTRRackPrice.dtmEffectiveDateTime DESC) + dblDeviation
			,dblPriceBasis = (SELECT TOP 1 CASE WHEN strCostToUse = 'Vendor' THEN dblVendorRack 
								    			   WHEN strCostToUse = 'Jobber' THEN dblJobberRack
											  END 
								FROM vyuTRRackPrice INNER JOIN tblTRSupplyPoint 
									ON vyuTRRackPrice.intSupplyPointId = ISNULL(tblTRSupplyPoint.intRackPriceSupplyPointId ,tblTRSupplyPoint.intSupplyPointId) 
								WHERE vyuTRRackPrice.intItemId = @ItemId
									AND ((vyuTRRackPrice.intSupplyPointId = ISNULL(@SupplyPointId,0) AND ISNULL(@SupplyPointId,0) <> 0) OR tblTRSupplyPoint.intEntityLocationId = intVendorLocationId)
									AND CAST(@TransactionDate AS DATE) >= CAST(vyuTRRackPrice.dtmEffectiveDateTime AS DATE)
									ORDER BY vyuTRRackPrice.dtmEffectiveDateTime DESC)									
		WHERE
			strPriceBasis = 'O'
			AND intItemId = @ItemId
			AND (intCustomerLocationId = @ShipToLocationId OR ISNULL(@ShipToLocationId,0) = 0)
						
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
			,intRackVendorId INT
			,intRackItemId INT
			,intRackItemLocationId INT
			,intVendorLocationId INT
			,intCustomerLocationId INT
			,dblPriceBasis NUMERIC(18,6)
			,dblCustomerPrice NUMERIC(18,6)
			,strPricing NVARCHAR(200) COLLATE Latin1_General_CI_AS
			,strInvoiceType NVARCHAR(200) COLLATE Latin1_General_CI_AS)

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
			,intRackVendorId
			,intRackItemId
			,intRackItemLocationId
			,intVendorLocationId
			,intCustomerLocationId
			,dblPriceBasis
			,dblCustomerPrice
			,strPricing
			,strInvoiceType)
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
			,SP.intRackVendorId
			,SP.intRackItemId
			,SP.intRackItemLocationId
			,SP.intVendorLocationId
			,SP.intCustomerLocationId
			,SP.dblPriceBasis 
			,SP.dblCustomerPrice
			,SP.strPricing 
			,SP.strInvoiceType
		FROM
			@CustomerSpecialPricing SP
		INNER JOIN
			@CustomerGroup CG
				ON SP.strCustomerGroup = CG.strGroupName					
		
		--Customer Group - Rack Vendor No + Rack Item No
		SET @SpecialPriceId = (SELECT TOP 1 SP.intSpecialPriceId FROM @SpecialGroupPricing SP INNER JOIN tblTRSupplyPoint TR ON (SP.intRackVendorId = TR.intEntityVendorId OR SP.intVendorId = TR.intEntityVendorId) AND (SP.intVendorLocationId = TR.intEntityLocationId OR (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))  WHERE (SP.intRackItemId = @ItemId OR SP.intItemId = @ItemId) AND (SP.intRackVendorId = @ItemVendorId OR SP.intVendorId = @ItemVendorId) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END

		--Customer Group - Rack Vendor No
		SET @SpecialPriceId = (SELECT TOP 1 SP.intSpecialPriceId FROM @SpecialGroupPricing SP INNER JOIN tblTRSupplyPoint TR ON (SP.intRackVendorId = TR.intEntityVendorId OR SP.intVendorId = TR.intEntityVendorId) AND (SP.intVendorLocationId = TR.intEntityLocationId OR (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))  WHERE (SP.intRackItemId = @ItemId OR SP.intItemId = @ItemId) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation 
					,@UOMQuantity
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END

		--Customer Group - Rack Item No
		SET @SpecialPriceId = (SELECT TOP 1 SP.intSpecialPriceId FROM @SpecialGroupPricing SP INNER JOIN tblTRSupplyPoint TR ON (SP.intRackVendorId = TR.intEntityVendorId OR SP.intVendorId = TR.intEntityVendorId) AND (SP.intVendorLocationId = TR.intEntityLocationId OR (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))  WHERE (SP.intRackVendorId = @ItemVendorId OR SP.intVendorId = @ItemVendorId) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
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
			,intRackVendorId INT
			,intRackItemLocationId INT
			,intRackItemId INT
			,intVendorLocationId INT
			,intCustomerLocationId INT
			,dblPriceBasis NUMERIC(18,6)
			,dblCustomerPrice NUMERIC(18,6)
			,strPricing NVARCHAR(200) COLLATE Latin1_General_CI_AS
			,strInvoiceType NVARCHAR(200) COLLATE Latin1_General_CI_AS)
					
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
			,intRackVendorId
			,intRackItemId
			,intRackItemLocationId
			,intVendorLocationId
			,intCustomerLocationId
			,dblPriceBasis 
			,dblCustomerPrice
			,strPricing
			,strInvoiceType)
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
			,SP.intRackVendorId
			,SP.intRackItemId
			,SP.intRackItemLocationId 
			,SP.intVendorLocationId
			,SP.intCustomerLocationId
			,SP.dblPriceBasis 
			,SP.dblCustomerPrice
			,SP.strPricing
			,SP.strInvoiceType
		FROM
			@CustomerSpecialPricing SP
		LEFT OUTER JOIN
			@CustomerGroup CG
				ON SP.strCustomerGroup = CG.strGroupName
		WHERE
			CG.intCustomerGroupId IS NULL
			

		--Customer - Rack Vendor No + Rack Item No
		SET @SpecialPriceId = (SELECT TOP 1 SP.intSpecialPriceId FROM @SpecialPricing SP INNER JOIN tblTRSupplyPoint TR ON (SP.intRackVendorId = TR.intEntityVendorId OR SP.intVendorId = TR.intEntityVendorId) AND (SP.intVendorLocationId = TR.intEntityLocationId OR (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))  WHERE (SP.intRackItemId = @ItemId OR SP.intItemId = @ItemId) AND (SP.intRackVendorId = @ItemVendorId OR SP.intVendorId = @ItemVendorId) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END

		--Customer - Vendor + Rack Vendor No
		SET @SpecialPriceId = (SELECT TOP 1 SP.intSpecialPriceId FROM @SpecialPricing SP INNER JOIN tblTRSupplyPoint TR ON (SP.intRackVendorId = TR.intEntityVendorId OR SP.intVendorId = TR.intEntityVendorId) AND (SP.intVendorLocationId = TR.intEntityLocationId OR (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL)) WHERE (SP.intRackVendorId = @ItemVendorId OR SP.intVendorId = @ItemVendorId) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END

		--Customer - Rack Item No
		SET @SpecialPriceId = (SELECT TOP 1 SP.intSpecialPriceId FROM @SpecialPricing SP INNER JOIN tblTRSupplyPoint TR ON (SP.intRackVendorId = TR.intEntityVendorId OR SP.intVendorId = TR.intEntityVendorId) AND (SP.intVendorLocationId = TR.intEntityLocationId OR (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))  WHERE (SP.intRackItemId = @ItemId OR SP.intItemId = @ItemId) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--a. Customer - Customer Location - Invoice Type - Vendor - Vendor Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		--b. Customer - Customer Location - Invoice Type - Vendor - Vendor Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '') AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END		

		--c. Customer - Customer Location - Invoice Type - Vendor - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '') AND intVendorId = @ItemVendorId AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END	
		--d. Customer - Customer Location - Invoice Type - Vendor - Vendor Location - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '') AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END		

		--e. Customer - Customer Location - Invoice Type - Vendor - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '') AND intVendorId = @ItemVendorId AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END		

		--f. Customer - Customer Location - Invoice Type - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '') AND (ISNULL(intVendorId,0) = 0 OR ISNULL(intVendorId,0) = @ItemVendorId) AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END		

		--g. Customer - Customer Location - Invoice Type - Item Category
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '') AND (ISNULL(intVendorId,0) = 0 OR ISNULL(intVendorId,0) = @ItemVendorId) AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END		
		
		--h. Customer - Customer Location - Vendor - Vendor Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)		
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--i. Customer - Customer Location - Vendor - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)		
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND intVendorId = @ItemVendorId AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
						
		--j. Customer - Customer Location - Vendor - Vendor Location - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--k. Customer - Customer Location - Vendor - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND intVendorId = @ItemVendorId AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--l. Customer - Customer Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)		
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND (ISNULL(intVendorId,0) = 0 OR ISNULL(intVendorId,0) = @ItemVendorId) AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--m. Customer - Customer Location - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND (ISNULL(intVendorId,0) = 0 OR ISNULL(intVendorId,0) = @ItemVendorId) AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--n. Customer - Customer Location - Customer Group - Invoice Type - Vendor - Vendor Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '') AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END	
			
		--o. Customer - Customer Location - Customer Group - Invoice Type - Vendor - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '') AND intVendorId = @ItemVendorId AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END	
			
		--p. Customer - Customer Location - Customer Group - Invoice Type - Vendor - Vendor Location - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '') AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END	
			
		--q. Customer - Customer Location - Customer Group - Invoice Type - Vendor - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '') AND intVendorId = @ItemVendorId AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END	
			
		--r. Customer - Customer Location - Customer Group - Invoice Type - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '') AND (ISNULL(intVendorId,0) = 0 OR ISNULL(intVendorId,0) = @ItemVendorId) AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END	
			
		--s. Customer - Customer Location - Customer Group - Invoice Type - Item Category
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '') AND (ISNULL(intVendorId,0) = 0 OR ISNULL(intVendorId,0) = @ItemVendorId) AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END	
			
		
		--t. Customer - Customer Location - Customer Group - Vendor - Vendor Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END	
			
		--u. Customer - Customer Location - Customer Group - Vendor - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND intVendorId = @ItemVendorId AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END	
			
		--v. Customer - Customer Location - Customer Group - Vendor - Vendor Location - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--w. Customer - Customer Location - Customer Group - Vendor - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND intVendorId = @ItemVendorId AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--x. Customer - Customer Location - Customer Group - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND (ISNULL(intVendorId,0) = 0 OR ISNULL(intVendorId,0) = @ItemVendorId) AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--y. Customer - Customer Location - Customer Group - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND (ISNULL(intVendorId,0) = 0 OR ISNULL(intVendorId,0) = @ItemVendorId) AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--z. Customer - Invoice Type - Vendor - Vendor Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		--aa. Customer - Invoice Type - Vendor - Vendor Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '')  AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
				
		--ab. Customer - Invoice Type - Vendor - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '')  AND intVendorId = @ItemVendorId AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
						 
		--ac. Customer - Invoice Type - Vendor - Vendor Location - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '')  AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
				
		--ad. Customer - Invoice Type - Vendor - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '')  AND intVendorId = @ItemVendorId AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
				
		--ae. Customer - Invoice Type - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '')  AND (ISNULL(intVendorId,0) = 0 OR ISNULL(intVendorId,0) = @ItemVendorId) AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
				
		--af. Customer - Invoice Type - Item Category
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '')  AND (ISNULL(intVendorId,0) = 0 OR ISNULL(intVendorId,0) = @ItemVendorId) AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END				
		
		--ag. Customer - Vendor - Vendor Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
				
		--ah. Customer - Vendor - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND intVendorId = @ItemVendorId AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END	
			
		--ai. Customer - Vendor - Vendor Location - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--aj. Customer - Vendor - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND intVendorId = @ItemVendorId  AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--ak. Customer - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND (ISNULL(intVendorId,0) = 0 OR ISNULL(intVendorId,0) = @ItemVendorId) AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--al. Customer - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND (ISNULL(intVendorId,0) = 0 OR ISNULL(intVendorId,0) = @ItemVendorId) AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--am. Customer - Customer Group - Invoice Type - Vendor - Vendor Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '') AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--an. Customer - Customer Group - Invoice Type - Vendor - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '') AND intVendorId = @ItemVendorId AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--ao. Customer - Customer Group - Invoice Type - Vendor - Vendor Location - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '') AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--ap. Customer - Customer Group - Invoice Type - Vendor - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '') AND intVendorId = @ItemVendorId AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--aq. Customer - Customer Group - Invoice Type - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '') AND (ISNULL(intVendorId,0) = 0 OR ISNULL(intVendorId,0) = @ItemVendorId) AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--ar. Customer - Customer Group - Invoice Type - Item Category
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') AND ISNULL(@InvoiceType,'') <> '') AND (ISNULL(intVendorId,0) = 0 OR ISNULL(intVendorId,0) = @ItemVendorId) AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
					
		--as. Customer - Customer Group - Vendor - Vendor Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--at. Customer - Customer Group - Vendor - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND intVendorId = @ItemVendorId AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			 
		--au. Customer - Customer Group - Vendor - Vendor Location - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--av. Customer - Customer Group - Vendor - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND intVendorId = @ItemVendorId AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--aw. Customer - Customer Group - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND (ISNULL(intVendorId,0) = 0 OR ISNULL(intVendorId,0) = @ItemVendorId) AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END
			
		--ax. Customer - Customer Group - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)									
		SET @SpecialPriceId = (SELECT TOP 1 intSpecialPriceId FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (ISNULL(strInvoiceType,'') = ISNULL(@InvoiceType,'') OR ISNULL(strInvoiceType,'') = '' OR ISNULL(@InvoiceType,'') = '') AND (ISNULL(intVendorId,0) = 0 OR ISNULL(intVendorId,0) = @ItemVendorId) AND (ISNULL(intVendorLocationId,0) = 0 OR ISNULL(intVendorLocationId,0) = @VendorShipFromLocationId) AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(ISNULL(@SpecialPriceId,0) <> 0)
			BEGIN
				INSERT @returntable(dblPrice, strPricing, intSpecialPriceId, dblPriceBasis, dblDeviation, dblUOMQuantity)
				SELECT
					dblCustomerPrice * @UOMQuantity
					,strPricing
					,intSpecialPriceId
					,dblPriceBasis
					,dblDeviation
					,@UOMQuantity 
				FROM
					@SpecialGroupPricing
				WHERE
					intSpecialPriceId = @SpecialPriceId
					
				RETURN;
			END			
										
	END		
			
	RETURN;				
END
