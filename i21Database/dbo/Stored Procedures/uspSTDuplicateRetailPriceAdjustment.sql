CREATE PROCEDURE [dbo].[uspSTDuplicateRetailPriceAdjustment]
	@intRetailPriceAdjustmentId INT,
	@NewRetailPriceAdjustmentId INT OUTPUT
AS
BEGIN

	------------------------------------------------
	-- Generate New Retail Price Adjustment Entry
	------------------------------------------------
	DECLARE @dtmEffectiveDate DATETIME,
		@NewdtmEffectiveDate  DATETIME,
		@NewItemNoWithCounter NVARCHAR(50),
		@counter INT
	SELECT @dtmEffectiveDate = dtmEffectiveDate, @NewdtmEffectiveDate = GETDATE()
	FROM tblSTRetailPriceAdjustment WHERE intRetailPriceAdjustmentId = @intRetailPriceAdjustmentId
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
	-- Duplicate RetailPriceAdjustment Header table --
	----------------------------------------------------
	INSERT INTO tblSTRetailPriceAdjustment(dtmEffectiveDate,
				strDescription,
				intConcurrencyId)
	--SELECT @NewdtmEffectiveDate,
	SELECT NULL,
		strDescription,1	
	FROM tblSTRetailPriceAdjustment
	WHERE intRetailPriceAdjustmentId = @intRetailPriceAdjustmentId
	---------------------------------------------------------------
	-- End duplication of RetailPriceAdjustment Header table --
	---------------------------------------------------------------

	SET @NewRetailPriceAdjustmentId = SCOPE_IDENTITY()
	
	--------------------------------------------------
	-- Duplicate RetailPriceAdjustment Detail table --
	--------------------------------------------------
	INSERT INTO tblSTRetailPriceAdjustmentDetail(intRetailPriceAdjustmentId,
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
	SELECT @NewRetailPriceAdjustmentId,
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