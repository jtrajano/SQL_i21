CREATE PROCEDURE [dbo].[uspSTDuplicateRetailPriceAdjustment]
	@intRetailPriceAdjustmentId INT,
	@NewRetailPriceAdjustmentId INT OUTPUT
AS
BEGIN

	------------------------------------------------
	-- Generate New Retail Price Adjustment Entry
	------------------------------------------------
	DECLARE @dtmEffectiveDate		DATETIME,
		    @NewdtmEffectiveDate	DATETIME,
		    @NewItemNoWithCounter	NVARCHAR(50),
		    @counter				INT,
			@intCompanyLocationId	INT,
			@strBatchId				NVARCHAR(100),
			@ysnSuccess				BIT,
			@strMessage				NVARCHAR(1000)

	SELECT 
		@dtmEffectiveDate = rpa.dtmEffectiveDate, 
		@NewdtmEffectiveDate = GETDATE()
	FROM tblSTRetailPriceAdjustment rpa
	WHERE rpa.intRetailPriceAdjustmentId = @intRetailPriceAdjustmentId


	IF EXISTS(SELECT TOP 1 1 FROM tblSTRetailPriceAdjustment WHERE dtmEffectiveDate = @NewdtmEffectiveDate)
	BEGIN
    	SET @counter = 1
		print @counter
		SET @NewItemNoWithCounter = @NewdtmEffectiveDate + (CAST(@counter AS NVARCHAR(50)))

		WHILE EXISTS(SELECT TOP 1 1 FROM tblSTRetailPriceAdjustment WHERE dtmEffectiveDate = @NewItemNoWithCounter)
			BEGIN
				SET @counter += 1
				SET @NewItemNoWithCounter = @NewdtmEffectiveDate + (CAST(@counter AS NVARCHAR(50)))
			END

		SET @NewdtmEffectiveDate = @NewItemNoWithCounter
	END
	-- PRINT @NewRetailPriceAdjustmentId
	---------------------------------------------------
	-- End Generation of New RetailPriceAdjustmentId --
	--------------------------------------------------



	----------------------------------------------------
	-- Duplicate RetailPriceAdjustment Header table   --
	----------------------------------------------------
	EXEC [dbo].[uspSTGetStartingNumber]
				@strModule				= N'Store'
				, @strTransactionType	= N'Retail Price Adjustment'
				, @strPrefix			= N'RPA-'
				, @intLocationId		= NULL
				, @strBatchId			= @strBatchId OUTPUT
				, @ysnSuccess			= @ysnSuccess OUTPUT
				, @strMessage			= @strMessage OUTPUT


	INSERT INTO tblSTRetailPriceAdjustment
	(
		dtmEffectiveDate,
		strDescription,
		strRetailPriceAdjustmentNumber,
		intConcurrencyId
	)
	SELECT 
		dtmEffectiveDate					= NULL,
		strDescription						= strDescription,
		strRetailPriceAdjustmentNumber		= CASE
												WHEN @ysnSuccess = CAST(1 AS BIT)
													THEN @strBatchId
												ELSE NULL
											END,
		intConcurrencyId					= 1
	FROM tblSTRetailPriceAdjustment
	WHERE intRetailPriceAdjustmentId = @intRetailPriceAdjustmentId
	---------------------------------------------------------------
	-- End duplication of RetailPriceAdjustment Header table     --
	---------------------------------------------------------------

	SET @NewRetailPriceAdjustmentId = SCOPE_IDENTITY()
	
	--------------------------------------------------
	-- Duplicate RetailPriceAdjustment Detail table --
	--------------------------------------------------
	INSERT INTO tblSTRetailPriceAdjustmentDetail
	(
		intRetailPriceAdjustmentId,
		intCompanyLocationId,
		strRegion,
		strDistrict,
		strState,
		intEntityId,
		intCategoryId,
		intManufacturerId,
		intFamilyId,
		intClassId,
		intItemUOMId,
		strUpcDescription,
		ysnPromo,
		strPriceMethod,
		dblFactor,
		dblPrice,
		dblLastCost,
		ysnActive,
		ysnOneTimeuse,
		ysnChangeCost,
		dblCost,
		dtmSalesStartDate,
		dtmSalesEndDate,
		ysnPosted,
		strPriceType,
		intConcurrencyId
	)
	SELECT 
		@NewRetailPriceAdjustmentId,
		intCompanyLocationId,
		strRegion,
		strDistrict,
		strState,
		intEntityId,
		intCategoryId,
	    intManufacturerId,
		intFamilyId,
		intClassId,
		intItemUOMId,
		strUpcDescription,
		ysnPromo,
		strPriceMethod,
		dblFactor,
		dblPrice,
		dblLastCost,
		ysnActive,
		ysnOneTimeuse,
		ysnChangeCost,
		dblCost,
		dtmSalesStartDate,
		dtmSalesEndDate,
		0,
		strPriceType,
		1
	FROM tblSTRetailPriceAdjustmentDetail
	WHERE intRetailPriceAdjustmentId = @intRetailPriceAdjustmentId
	-------------------------------------------------------------
	-- End duplication of RetailPriceAdjustment Detail table --
	-----------------------------------------------------------
END