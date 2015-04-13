GO

IF EXISTS (SELECT TOP 1 1 FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnTMGetSpecialPricing]') AND type IN (N'FN'))
	DROP FUNCTION [dbo].[fnTMGetSpecialPricing]
GO 

IF (EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwcusmst')
	AND EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwitmmst')
	AND EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwprcmst')
	
)
BEGIN
	EXEC('
CREATE FUNCTION [dbo].[fnTMGetSpecialPricing](
	@strCustomerNumber AS NVARCHAR(20)
	,@strItemNumber NVARCHAR(20)
	,@strLocation NVARCHAR(20)
	,@strItemClass NVARCHAR(20)
	,@dtmOrderDate DATETIME
	,@dblQuantity DECIMAL(18,6)
)
RETURNS DECIMAL(18,6)
AS
BEGIN 

	--DECLARE @strCustomerNumber NVARCHAR(20)
	--DECLARE @strItemNumber NVARCHAR(20)
	--DECLARE @strLocation NVARCHAR(20)
	--DECLARE @strItemClass NVARCHAR(20)
	--DECLARE @dtmOrderDate DATETIME

	DECLARE @dblCurrentItemPrice DECIMAL(18,6)
	DECLARE @dblItemPrice DECIMAL(18,6)
	DECLARE @dblCurrentItemPriceWithLocation DECIMAL(18,6)
	DECLARE @dblAverageItemCostWithLocation DECIMAL(18,6)
	DECLARE @dblStandardItemCostWithLocation DECIMAL(18,6)
	DECLARE @dblLastItemCostWithLocation DECIMAL(18,6)
	DECLARE @intCustomerPriceLevel  INT
	DECLARE @strOrderDate NVARCHAR(8)
	DECLARE @strCostToUseLas NVARCHAR(5)
	DECLARE @strBasisIndicator NVARCHAR(5)
	DECLARE @strQuantityDiscountByPa NVARCHAR(5)
	DECLARE @dblFactor DECIMAL(18,6)
	DECLARE @dblUnits1 DECIMAL(18,6)
	DECLARE @dblUnits2 DECIMAL(18,6)
	DECLARE @dblUnits3 DECIMAL(18,6)
	DECLARE @dblItemCost DECIMAL(18,6)
	DECLARE @dblAverageItemCost DECIMAL(18,6)
	DECLARE @dblStandardItemCost DECIMAL(18,6)
	DECLARE @dblLastItemCost DECIMAL(18,6)


	--Get Customer pricing level
	SELECT TOP 1 @intCustomerPriceLevel = vwcus_prc_lvl 
	FROM vwcusmst
	WHERE vwcus_key = @strCustomerNumber
	SET @intCustomerPriceLevel = ISNULL(@intCustomerPriceLevel,1)


	--get item price based on customer pricing level and cost 
	SELECT TOP 1 
			@dblCurrentItemPrice =(
				CASE WHEN @intCustomerPriceLevel = 1 THEN 
							ISNULL(vwitm_un_prc1,0)
						WHEN @intCustomerPriceLevel = 2 THEN 
							ISNULL(vwitm_un_prc2,0)
						WHEN @intCustomerPriceLevel = 3 THEN 
							ISNULL(vwitm_un_prc3,0)
						WHEN @intCustomerPriceLevel = 4 THEN 
							ISNULL(vwitm_un_prc4,0)
						WHEN @intCustomerPriceLevel = 5 THEN 
							ISNULL(vwitm_un_prc5,0)
						WHEN @intCustomerPriceLevel = 6 THEN 
							ISNULL(vwitm_un_prc6,0)
						WHEN @intCustomerPriceLevel = 7 THEN 
							ISNULL(vwitm_un_prc7,0)
						WHEN @intCustomerPriceLevel = 8 THEN 
							ISNULL(vwitm_un_prc8,0)
						WHEN @intCustomerPriceLevel = 9 THEN 
							ISNULL(vwitm_un_prc9,0)					
						ELSE 0.0
				END )
			,@dblAverageItemCost = ISNULL(vwitm_avg_un_cost,0.0)
			,@dblStandardItemCost = ISNULL(vwitm_std_un_cost,0.0)
			,@dblLastItemCost = ISNULL(vwitm_last_un_cost,0.0)
		FROM vwitmmst
		WHERE vwitm_no = @strItemNumber

	--CHECK	item by location
	IF(@strLocation <> '''')
	BEGIN
		SELECT TOP 1 
			@dblCurrentItemPriceWithLocation =(
				CASE WHEN @intCustomerPriceLevel = 1 THEN 
							ISNULL(vwitm_un_prc1,0)
						WHEN @intCustomerPriceLevel = 2 THEN 
							ISNULL(vwitm_un_prc2,0)
						WHEN @intCustomerPriceLevel = 3 THEN 
							ISNULL(vwitm_un_prc3,0)
						WHEN @intCustomerPriceLevel = 4 THEN 
							ISNULL(vwitm_un_prc4,0)
						WHEN @intCustomerPriceLevel = 5 THEN 
							ISNULL(vwitm_un_prc5,0)
						WHEN @intCustomerPriceLevel = 6 THEN 
							ISNULL(vwitm_un_prc6,0)
						WHEN @intCustomerPriceLevel = 7 THEN 
							ISNULL(vwitm_un_prc7,0)
						WHEN @intCustomerPriceLevel = 8 THEN 
							ISNULL(vwitm_un_prc8,0)
						WHEN @intCustomerPriceLevel = 9 THEN 
							ISNULL(vwitm_un_prc9,0)					
						ELSE 0.0
				END )
			,@dblAverageItemCostWithLocation = ISNULL(vwitm_avg_un_cost,0.0)
			,@dblStandardItemCostWithLocation = ISNULL(vwitm_std_un_cost,0.0)
			,@dblLastItemCostWithLocation = ISNULL(vwitm_last_un_cost,0.0)
		FROM vwitmmst
		WHERE vwitm_no = @strItemNumber
			AND vwitm_loc_no = @strLocation
	END

	--CHECK if price is available for the location
	IF (@dblCurrentItemPriceWithLocation IS NOT NULL)
	BEGIN
		SET @dblCurrentItemPrice = @dblCurrentItemPriceWithLocation
		SET @dblAverageItemCost = @dblAverageItemCostWithLocation
		SET @dblStandardItemCost = @dblStandardItemCostWithLocation
		SET @dblLastItemCost = @dblLastItemCostWithLocation
	END
	ELSE
	BEGIN
		RETURN @dblCurrentItemPrice
	END
	
	SET @dblItemPrice = @dblCurrentItemPrice

	SET @strOrderDate =  CAST(YEAR(@dtmOrderDate)AS NVARCHAR(4)) + RIGHT(''00''+ CAST(MONTH(@dtmOrderDate)AS NVARCHAR(2)),2) + RIGHT(''00''+ CAST(DAY(@dtmOrderDate)AS NVARCHAR(2)),2)
	
	--Check for special Pricing Step 1
	--Customer and item
	IF EXISTS (SELECT TOP 1 1 FROM vwprcmst WHERE vwprc_cus_no = @strCustomerNumber AND vwprc_itm_no = @strItemNumber AND ISNULL(vwprc_begin_rev_dt,0) < CAST(@strOrderDate AS INT) AND ISNULL(vwprc_end_rev_dt,0) > CAST(@strOrderDate AS INT))
	BEGIN
		SELECT TOP 1 
			@strCostToUseLas = vwprc_cost_to_use_las
			,@strBasisIndicator =  vwprc_basis_ind
			,@dblFactor = vwprc_factor
			,@dblUnits1 = vwprc_units_1
			,@dblUnits2 = vwprc_units_2
			,@dblUnits3 = vwprc_units_3
			,@strQuantityDiscountByPa = vwprc_qty_disc_by_pa
		FROM vwprcmst WHERE vwprc_cus_no = @strCustomerNumber AND vwprc_itm_no = @strItemNumber AND ISNULL(vwprc_begin_rev_dt,0) < CAST(@strOrderDate AS INT) AND ISNULL(vwprc_end_rev_dt,0) > CAST(@strOrderDate AS INT)
	END
	ELSE
	BEGIN
	--Customer and Class
		IF EXISTS (SELECT TOP 1 1 FROM vwprcmst WHERE vwprc_cus_no = @strCustomerNumber AND ISNULL(vwprc_itm_no,'''') = '''' AND vwprc_class = @strItemClass AND ISNULL(vwprc_begin_rev_dt,0) < CAST(@strOrderDate AS INT) AND ISNULL(vwprc_end_rev_dt,0) > CAST(@strOrderDate AS INT))
		BEGIN
			
			SELECT TOP 1 
				@strCostToUseLas = vwprc_cost_to_use_las
				,@strBasisIndicator =  vwprc_basis_ind
				,@dblFactor = vwprc_factor
				,@dblUnits1 = vwprc_units_1
				,@dblUnits2 = vwprc_units_2
				,@dblUnits3 = vwprc_units_3
				,@strQuantityDiscountByPa = vwprc_qty_disc_by_pa
			FROM vwprcmst WHERE vwprc_cus_no = @strCustomerNumber AND ISNULL(vwprc_itm_no,'''') = '''' AND vwprc_class = @strItemClass AND ISNULL(vwprc_begin_rev_dt,0) < CAST(@strOrderDate AS INT) AND ISNULL(vwprc_end_rev_dt,0) > CAST(@strOrderDate AS INT)
		END
		ELSE
		BEGIN
		--Customer only
			IF EXISTS (SELECT TOP 1 1 FROM vwprcmst WHERE vwprc_cus_no = @strCustomerNumber AND ISNULL(vwprc_itm_no,'''') = '''' AND ISNULL(vwprc_class,'''') = '''' AND ISNULL(vwprc_begin_rev_dt,0) < CAST(@strOrderDate AS INT) AND ISNULL(vwprc_end_rev_dt,0) > CAST(@strOrderDate AS INT))
			BEGIN
				SELECT TOP 1 
					@strCostToUseLas = vwprc_cost_to_use_las
					,@strBasisIndicator =  vwprc_basis_ind
					,@dblFactor = vwprc_factor
					,@dblUnits1 = vwprc_units_1
					,@dblUnits2 = vwprc_units_2
					,@dblUnits3 = vwprc_units_3
					,@strQuantityDiscountByPa = vwprc_qty_disc_by_pa
				FROM vwprcmst WHERE vwprc_cus_no = @strCustomerNumber AND ISNULL(vwprc_itm_no,'''') = '''' AND ISNULL(vwprc_class,'''') = '''' AND ISNULL(vwprc_begin_rev_dt,0) < CAST(@strOrderDate AS INT) AND ISNULL(vwprc_end_rev_dt,0) > CAST(@strOrderDate AS INT)
			END
			ELSE
			BEGIN
			--Item only
				IF EXISTS (SELECT TOP 1 1 FROM vwprcmst WHERE ISNULL(vwprc_cus_no,'''') = '''' AND vwprc_itm_no = @strItemNumber AND ISNULL(vwprc_class,'''') = '''' AND ISNULL(vwprc_begin_rev_dt,0) < CAST(@strOrderDate AS INT) AND ISNULL(vwprc_end_rev_dt,0) > CAST(@strOrderDate AS INT))
				BEGIN
					SELECT TOP 1 
						@strCostToUseLas = vwprc_cost_to_use_las
						,@strBasisIndicator =  vwprc_basis_ind
						,@dblFactor = vwprc_factor
						,@dblUnits1 = vwprc_units_1
						,@dblUnits2 = vwprc_units_2
						,@dblUnits3 = vwprc_units_3
						,@strQuantityDiscountByPa = vwprc_qty_disc_by_pa
					FROM vwprcmst WHERE ISNULL(vwprc_cus_no,'''') = '''' AND vwprc_itm_no = @strItemNumber AND ISNULL(vwprc_class,'''') = '''' AND ISNULL(vwprc_begin_rev_dt,0) < CAST(@strOrderDate AS INT) AND ISNULL(vwprc_end_rev_dt,0) > CAST(@strOrderDate AS INT)
				END
			END
		END

	END

	IF (@strCostToUseLas IS NULL AND @strBasisIndicator IS NULL AND @dblFactor IS NULL AND @dblUnits1 IS NULL AND @dblUnits2 IS NULL AND @dblUnits3 IS NULL AND @strQuantityDiscountByPa IS NULL)
	BEGIN
		RETURN ISNULL(@dblCurrentItemPrice,0)
	END
	
	--GEt Item Cost
	----
	IF(@strCostToUseLas = ''A'')
	BEGIN
		SET @dblItemCost = @dblAverageItemCost
	END
	IF (@strCostToUseLas = ''S'')
	BEGIN
		SET @dblItemCost = @dblStandardItemCost
	END
	ELSE
	BEGIN
		SET @dblItemCost = @dblLastItemCost
	END
	
	
	---Calculate Based on factor
	
	IF(@strBasisIndicator = ''X'' OR @strBasisIndicator = ''F'')
	BEGIN
		SET @dblCurrentItemPrice = ISNULL(@dblFactor,0.0)
	END
	
	IF(@strBasisIndicator = ''C'')
	BEGIN
		SET @dblCurrentItemPrice = ((ISNULL(@dblFactor,0.0)/100) * @dblItemCost) + @dblItemCost
	END
	
	IF(@strBasisIndicator = ''S'')
	BEGIN
		SET @dblCurrentItemPrice = ((ISNULL(@dblFactor,0.0)/100) * @dblCurrentItemPrice) + @dblCurrentItemPrice
	END
	
	IF(@strBasisIndicator = ''A'')
	BEGIN
		SET @dblCurrentItemPrice = @dblItemCost + ISNULL(@dblFactor,0.0)
	END
	
	IF(@strBasisIndicator = ''M'')
	BEGIN
		SET @dblCurrentItemPrice = @dblCurrentItemPrice - ISNULL(@dblFactor,0.0)
	END
	
	IF(@strBasisIndicator = ''P'')
	BEGIN
		SET @dblCurrentItemPrice = @dblCurrentItemPrice + ISNULL(@dblFactor,0.0)
	END
	
	IF(@strBasisIndicator = ''Q'')
	BEGIN
		IF(@dblQuantity >= @dblUnits1)
		BEGIN
			SET @dblFactor = @dblUnits1
		END
		IF(@dblQuantity >= @dblUnits2)
		BEGIN
			SET @dblFactor = @dblUnits2
		END
		IF(@dblQuantity >= @dblUnits3)
		BEGIN
			SET @dblFactor = @dblUnits3
		END
		
		--get quantity discount
		IF (@strQuantityDiscountByPa = ''P'')
		BEGIN
			SET @dblCurrentItemPrice = (1 - (ISNULL(@dblFactor,0.0)/100)) * @dblCurrentItemPrice
		END
		ELSE
		BEGIN
			SET @dblCurrentItemPrice = @dblCurrentItemPrice - ISNULL(@dblFactor,0.0)
		END
		
	END
	
	IF(NOT(@strBasisIndicator = ''X'' AND @dblCurrentItemPrice > @dblItemPrice))
	BEGIN
		RETURN @dblCurrentItemPrice
	END
	ELSE
	BEGIN
		RETURN @dblItemPrice
	END
	
	RETURN ISNULL(@dblCurrentItemPrice,0)
END	
'
)
END
GO