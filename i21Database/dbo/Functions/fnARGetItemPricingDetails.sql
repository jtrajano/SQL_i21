CREATE FUNCTION [dbo].[fnARGetItemPricingDetails]
(
	 @ItemId				INT
	,@CustomerId			INT	
	,@LocationId			INT
	,@ItemUOMId				INT
	,@TransactionDate		DATETIME
	,@Quantity				NUMERIC(18,6)
	,@ContractHeaderId		INT
	,@ContractDetailId		INT
	,@ContractNumber		NVARCHAR(50)
	,@ContractSeq			INT
	,@AvailableQuantity		NUMERIC(18,6)
	,@UnlimitedQuantity     BIT
	,@OriginalQuantity		NUMERIC(18,6)
	,@CustomerPricingOnly	BIT
	,@VendorId				INT
	,@SupplyPointId			INT
	,@LastCost				NUMERIC(18,6)
	,@ShipToLocationId      INT
	,@VendorLocationId		INT
)
RETURNS @returntable TABLE
(
	 dblPrice				NUMERIC(18,6)
	,strPricing				NVARCHAR(250)
	,intContractHeaderId	INT
	,intContractDetailId	INT
	,strContractNumber		NVARCHAR(50)
	,intContractSeq			INT
	,dblAvailableQty        NUMERIC(18,6)
	,ysnUnlimitedQty        BIT
)
AS
BEGIN

DECLARE	 @Price		NUMERIC(18,6)
		,@Pricing	NVARCHAR(250)

	SET @TransactionDate = ISNULL(@TransactionDate,GETDATE())
	
	IF @CustomerPricingOnly IS NULL
		SET @CustomerPricingOnly = 0
	
	
	DECLARE @ItemVendorId		INT
			,@ItemLocationId	INT
			,@ItemCategoryId	INT
			,@ItemCategory		NVARCHAR(100)
			,@UOMQuantity		NUMERIC(18,6)
			,@CustomerShipToLocationId	INT
			,@VendorShipFromLocationId	INT

	SELECT TOP 1 
		 @ItemVendorId		= ISNULL(@VendorId, VI.intVendorId)
		,@ItemLocationId	= intItemLocationId
		,@ItemCategoryId	= I.intCategoryId
		,@ItemCategory		= UPPER(LTRIM(RTRIM(ISNULL(C.strCategoryCode,''))))
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
		AND (VI.intLocationId = @LocationId OR @LocationId IS NULL)
		AND (UOM.intItemUOMId = @ItemUOMId OR @ItemUOMId IS NULL)
		
	IF @CustomerPricingOnly = 0
	BEGIN
		--Customer Contract Price
		
		SELECT TOP 1
			 @Price				= dblCashPrice
			,@ContractHeaderId	= intContractHeaderId
			,@ContractDetailId	= intContractDetailId
			,@ContractNumber	= strContractNumber
			,@ContractSeq		= intContractSeq
			,@AvailableQuantity = dblAvailableQty
			,@UnlimitedQuantity = ysnUnlimitedQuantity
		FROM
			vyuCTContractDetailView
		WHERE
			intEntityId = @CustomerId
			AND intCompanyLocationId = @LocationId
			AND intItemUOMId = @ItemUOMId
			AND intItemId = @ItemId
			AND ((ISNULL(@OriginalQuantity,0.00) + dblAvailableQty >= @Quantity) OR ysnUnlimitedQuantity = 1)
			AND CAST(@TransactionDate AS DATE) BETWEEN CAST(dtmStartDate AS DATE) AND CAST(ISNULL(dtmEndDate,@TransactionDate) AS DATE)
			AND intContractHeaderId = @ContractHeaderId
			AND intContractDetailId = @ContractDetailId
			AND ((ISNULL(@OriginalQuantity,0.00) + dblAvailableQty > 0) OR ysnUnlimitedQuantity = 1)
			AND (dblBalance > 0 OR ysnUnlimitedQuantity = 1)
			AND strContractStatus NOT IN ('Cancelled', 'Unconfirmed', 'Complete')
		ORDER BY
			 dtmStartDate
			,intContractSeq
			
		IF(@Price IS NOT NULL)
		BEGIN
			SET @Pricing = 'Contracts - Customer Pricing'
			INSERT @returntable
			SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
			RETURN
		END
		
		SET @ContractHeaderId	= NULL
		SET @ContractDetailId	= NULL
		SET @ContractNumber		= NULL
		SET @ContractSeq		= NULL
		SET @AvailableQuantity  = NULL
		SET @UnlimitedQuantity  = NULL
				
		SELECT TOP 1
			 @Price				= dblCashPrice
			,@ContractHeaderId	= intContractHeaderId
			,@ContractDetailId	= intContractDetailId
			,@ContractNumber	= strContractNumber
			,@ContractSeq		= intContractSeq
			,@AvailableQuantity = dblAvailableQty
			,@UnlimitedQuantity = ysnUnlimitedQuantity
		FROM
			vyuCTContractDetailView
		WHERE
			intEntityId = @CustomerId
			AND intCompanyLocationId = @LocationId
			AND intItemUOMId = @ItemUOMId
			AND intItemId = @ItemId
			AND (((dblAvailableQty) >= @Quantity) OR ysnUnlimitedQuantity = 1)
			AND CAST(@TransactionDate AS DATE) BETWEEN CAST(dtmStartDate AS DATE) AND CAST(ISNULL(dtmEndDate,@TransactionDate) AS DATE)
			AND (((dblAvailableQty) > 0) OR ysnUnlimitedQuantity = 1)
			AND (dblBalance > 0 OR ysnUnlimitedQuantity = 1)
			AND strContractStatus NOT IN ('Cancelled', 'Unconfirmed', 'Complete')
		ORDER BY
			 dtmStartDate
			,intContractSeq
			
		IF(@Price IS NOT NULL)
		BEGIN
			SET @Pricing = 'Contracts - Customer Pricing'
			INSERT @returntable
			SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
			RETURN
		END	
		
	END			
		
	SELECT
		@CustomerShipToLocationId = ISNULL(@ShipToLocationId,ShipToLocation.intEntityLocationId)
	FROM 
		tblARCustomer Customer
		--LEFT OUTER JOIN
		--	(	SELECT
		--			intEntityLocationId
		--			,intEntityId 
		--			,strCountry
		--			,strState
		--			,strCity
		--		FROM tblEntityLocation
		--		WHERE ysnDefaultLocation = 1
		--	) EntityLocation 
		--	ON Customer.intEntityCustomerId = EntityLocation.intEntityId
	LEFT OUTER JOIN 
		tblEntityLocation ShipToLocation 
			ON Customer.intShipToId = ShipToLocation.intEntityLocationId
	WHERE 
		Customer.intEntityCustomerId = @CustomerId
		
	SELECT
		@VendorShipFromLocationId = ISNULL(@VendorLocationId,ISNULL(ShipFromLocation.intEntityLocationId, EntityLocation.intEntityLocationId))
	FROM 
		tblAPVendor Vendor
		LEFT OUTER JOIN
			(	SELECT
					intEntityLocationId
					,intEntityId 
					,strCountry
					,strState
					,strCity
				FROM tblEntityLocation
				WHERE ysnDefaultLocation = 1
			) EntityLocation 
			ON Vendor.intEntityVendorId = EntityLocation.intEntityId
	LEFT OUTER JOIN 
		tblEntityLocation ShipFromLocation 
			ON Vendor.intShipFromId = ShipFromLocation.intEntityLocationId
	WHERE 
		Vendor.intEntityVendorId = @ItemVendorId						
			

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
		,intRackItemLocationId INT
		,intVendorLocationId INT
		,intCustomerLocationId INT
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
		,intRackItemLocationId
		,intVendorLocationId
		,intCustomerLocationId
		,dblCustomerPrice
		,strPricing)
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
		,SP.ysnConsignable
		,SP.intRackVendorId
		,SP.intRackItemId
		,SP.intRackLocationId 
		,SP.intEntityLocationId
		,SP.intCustomerLocationId
		,NULL
		,''
	FROM
		tblARCustomerSpecialPrice SP
	INNER JOIN
		tblARCustomer C
			ON SP.intEntityCustomerId = C.intEntityCustomerId
	WHERE
		C.intEntityCustomerId = @CustomerId
		AND ((CAST(@TransactionDate AS DATE) BETWEEN CAST(SP.dtmBeginDate AS DATE) AND CAST(ISNULL(SP.dtmEndDate, GETDATE()) AS DATE)) OR (CAST(@TransactionDate AS DATE) >= CAST(SP.dtmBeginDate AS DATE) AND SP.dtmBeginDate IS NULL))
		AND ((@LocationId IS NOT NULL) OR (@LocationId IS NULL AND SP.strPriceBasis IN ('F', 'R', 'L', 'O')))

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
						THEN (CASE WHEN [dbo].fnTRGetRackPrice(@TransactionDate, @SupplyPointId, @ItemId) <> 0 THEN [dbo].fnTRGetRackPrice(@TransactionDate, @SupplyPointId, @ItemId) + dblDeviation ELSE NULL END)
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
				SELECT TOP 1 PL.intItemId, PL.intItemUnitMeasureId AS intItemUOM, PL.dblMin, PL.dblMax, PL.dblUnitPrice, ICL.intLocationId 
				FROM tblICItemPricingLevel PL	
				INNER JOIN tblSMCompanyLocationPricingLevel CPL ON PL.strPriceLevel = CPL.strPricingLevelName 		
				INNER JOIN tblICItemLocation ICL ON PL.intItemLocationId = ICL.intItemLocationId
				WHERE CPL.intSort = 1
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
									ON vyuTRRackPrice.intSupplyPointId = tblTRSupplyPoint.intSupplyPointId 
								WHERE tblTRSupplyPoint.intEntityLocationId = intEntityLocationId 
									AND vyuTRRackPrice.intItemId = intRackItemId
									AND ((vyuTRRackPrice.intSupplyPointId = ISNULL(null,0) AND ISNULL(null,0) <> 0) OR tblTRSupplyPoint.intEntityLocationId = intRackItemLocationId)
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
			,intRackItemLocationId INT
			,intVendorLocationId INT
			,intCustomerLocationId INT
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
			,intRackItemLocationId
			,intVendorLocationId
			,intCustomerLocationId
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
			,SP.intRackItemLocationId
			,SP.intVendorLocationId
			,SP.intCustomerLocationId
			,SP.dblCustomerPrice
			,SP.strPricing 
		FROM
			@CustomerSpecialPricing SP
		INNER JOIN
			@CustomerGroup CG
				ON SP.strCustomerGroup = CG.strGroupName					
		
		--Customer Group - Rack Vendor No + Rack Item No
		SET @Price = @UOMQuantity *	(SELECT TOP 1 SP.dblCustomerPrice FROM @SpecialGroupPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intVendorLocationId = TR.intEntityLocationId  WHERE SP.intRackItemId = @ItemId AND SP.intRackVendorId = @ItemVendorId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 SP.strPricing FROM @SpecialGroupPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intVendorLocationId = TR.intEntityLocationId  WHERE SP.intRackItemId = @ItemId AND SP.intRackVendorId = @ItemVendorId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END

		--Customer Group - Rack Vendor No
		SET @Price = @UOMQuantity *	(SELECT TOP 1 SP.dblCustomerPrice FROM @SpecialGroupPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intVendorLocationId = TR.intEntityLocationId  WHERE SP.intRackItemId = @ItemId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 SP.strPricing FROM @SpecialGroupPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intVendorLocationId = TR.intEntityLocationId  WHERE SP.intRackItemId = @ItemId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END

		--Customer Group - Rack Item No
		SET @Price = @UOMQuantity *	(SELECT TOP 1 SP.dblCustomerPrice FROM @SpecialGroupPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intVendorLocationId = TR.intEntityLocationId  WHERE SP.intRackVendorId = @ItemVendorId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 SP.strPricing FROM @SpecialGroupPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intVendorLocationId = TR.intEntityLocationId  WHERE SP.intRackVendorId = @ItemVendorId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL))
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
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
			,intRackItemLocationId INT
			,intRackItemId INT
			,intVendorLocationId INT
			,intCustomerLocationId INT
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
			,intRackItemLocationId
			,intVendorLocationId
			,intCustomerLocationId
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
			,SP.intRackItemLocationId 
			,SP.intVendorLocationId
			,SP.intCustomerLocationId
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
		SET @Price = @UOMQuantity *	(SELECT TOP 1 SP.dblCustomerPrice FROM @SpecialPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intVendorLocationId = TR.intEntityLocationId  WHERE SP.intRackItemId = @ItemId AND SP.intRackVendorId = @ItemVendorId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 SP.strPricing FROM @SpecialPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intVendorLocationId = TR.intEntityLocationId  WHERE SP.intRackItemId = @ItemId AND SP.intRackVendorId = @ItemVendorId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL) AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END

		--Customer - Vendor + Rack Vendor No
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intVendorLocationId = TR.intEntityLocationId  WHERE SP.intRackVendorId = @ItemVendorId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intVendorLocationId = TR.intEntityLocationId  WHERE SP.intRackVendorId = @ItemVendorId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL) AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END

		--Customer - Rack Item No
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intVendorLocationId = TR.intEntityLocationId  WHERE SP.intRackItemId = @ItemId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialPricing SP INNER JOIN tblTRSupplyPoint TR ON SP.intRackVendorId = TR.intEntityVendorId AND SP.intVendorLocationId = TR.intEntityLocationId  WHERE SP.intRackItemId = @ItemId AND (TR.intSupplyPointId = @SupplyPointId OR @SupplyPointId IS NULL) AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END
			
		--a. Customer - Customer Location - Invoice Type - Vendor - Vendor Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		--b. Customer - Customer Location - Invoice Type - Vendor - Vendor Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		--c. Customer - Customer Location - Invoice Type - Vendor - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		--d. Customer - Customer Location - Invoice Type - Vendor - Vendor Location - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		--e. Customer - Customer Location - Invoice Type - Vendor - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		--f. Customer - Customer Location - Invoice Type - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		--g. Customer - Customer Location - Invoice Type - Item Category
		
		--h. Customer - Customer Location - Vendor - Vendor Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)		
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END	
			
		--i. Customer - Customer Location - Vendor - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)		
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND intVendorId = @ItemVendorId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND intVendorId = @ItemVendorId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END
						
		--j. Customer - Customer Location - Vendor - Vendor Location - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END
			
		--k. Customer - Customer Location - Vendor - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND intVendorId = @ItemVendorId  AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND intVendorId = @ItemVendorId  AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END
			
		--l. Customer - Customer Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)		
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END
			
		--m. Customer - Customer Location - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END
			
		--n. Customer - Customer Location - Customer Group - Invoice Type - Vendor - Vendor Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		--o. Customer - Customer Location - Customer Group - Invoice Type - Vendor - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		--p. Customer - Customer Location - Customer Group - Invoice Type - Vendor - Vendor Location - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		--q. Customer - Customer Location - Customer Group - Invoice Type - Vendor - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		--r. Customer - Customer Location - Customer Group - Invoice Type - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		--s. Customer - Customer Location - Customer Group - Invoice Type - Item Category
		
		--t. Customer - Customer Location - Customer Group - Vendor - Vendor Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END	
			
		--u. Customer - Customer Location - Customer Group - Vendor - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND intVendorId = @ItemVendorId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND intVendorId = @ItemVendorId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END
			
		--v. Customer - Customer Location - Customer Group - Vendor - Vendor Location - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END
			
		--w. Customer - Customer Location - Customer Group - Vendor - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND intVendorId = @ItemVendorId  AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND intVendorId = @ItemVendorId  AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END
			
		--x. Customer - Customer Location - Customer Group - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END
			
		--y. Customer - Customer Location - Customer Group - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialGroupPricing WHERE intCustomerLocationId = @CustomerShipToLocationId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END
			
		--z. Customer - Invoice Type - Vendor - Vendor Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		--aa. Customer - Invoice Type - Vendor - Vendor Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		--ab. Customer - Invoice Type - Vendor - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		--ac. Customer - Invoice Type - Vendor - Vendor Location - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		--ad. Customer - Invoice Type - Vendor - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		--ae. Customer - Invoice Type - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		--af. Customer - Invoice Type - Item Category
		
		--ag. Customer - Vendor - Vendor Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END
				
		--ah. Customer - Vendor - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND intVendorId = @ItemVendorId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND intVendorId = @ItemVendorId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END		
		--ai. Customer - Vendor - Vendor Location - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END
			
		--aj. Customer - Vendor - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND intVendorId = @ItemVendorId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND intVendorId = @ItemVendorId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END
			
		--ak. Customer - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END
		--al. Customer - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END
			
		--am. Customer - Customer Group - Invoice Type - Vendor - Vendor Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		--an. Customer - Customer Group - Invoice Type - Vendor - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		--ao. Customer - Customer Group - Invoice Type - Vendor - Vendor Location - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		--ap. Customer - Customer Group - Invoice Type - Vendor - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		--aq. Customer - Customer Group - Invoice Type - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing) 
		--ar. Customer - Customer Group - Invoice Type - Item Category
		
		--as. Customer - Customer Group - Vendor - Vendor Location - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END
			
		--at. Customer - Customer Group - Vendor - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND intVendorId = @ItemVendorId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND intVendorId = @ItemVendorId AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END
			 
		--au. Customer - Customer Group - Vendor - Vendor Location - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND intVendorId = @ItemVendorId AND intVendorLocationId = @VendorShipFromLocationId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END
			
		--av. Customer - Customer Group - Vendor - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND intVendorId = @ItemVendorId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND intVendorId = @ItemVendorId AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END
			
		--aw. Customer - Customer Group - Item (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND intItemId = @ItemId AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END
			
		--ax. Customer - Customer Group - Item Category (AR>Maintenance>Customers>Setup Tab>Pricing Tab>Special Pricing)									
		SET @Price = @UOMQuantity *	(SELECT TOP 1 dblCustomerPrice FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = (SELECT TOP 1 strPricing FROM @SpecialGroupPricing WHERE (ISNULL(intCustomerLocationId,0) = 0) AND (strClass = @ItemCategory AND LEN(@ItemCategory)>0 ) AND ISNULL(dblCustomerPrice,0) <> 0)
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END			
										
	END
	
	IF @CustomerPricingOnly = 0
	BEGIN
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
								AND CAST(@TransactionDate AS DATE) BETWEEN CAST(dtmBeginDate AS DATE) AND CAST(ISNULL(dtmEndDate,@TransactionDate) AS DATE)
								)
		IF(@Price IS NOT NULL)
			BEGIN
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
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
									tblARCustomer C									
										ON PL.strPriceLevel = C.strLevel																								
								INNER JOIN vyuICGetItemStock VIS
										ON PL.intItemId = VIS.intItemId
										AND PL.intItemLocationId = VIS.intItemLocationId															
								WHERE
									C.intEntityCustomerId = @CustomerId
									AND C.strPricing = 'Multi-Level Pricing'
									AND PL.intItemId = @ItemId
									AND PL.intItemLocationId = @ItemLocationId
									AND PL.intItemUnitMeasureId = @ItemUOMId
									AND @Quantity BETWEEN PL.dblMin AND PL.dblMax
								)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = 'Inventory - Pricing Level'
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END	


		--Item Standard Pricing
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
				INSERT @returntable
				SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
				RETURN
			END							
	END	
	INSERT @returntable
	SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
	RETURN				
END
