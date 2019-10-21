CREATE PROCEDURE [dbo].[uspGRDuplicateDiscountSchedule]
	@DiscountScheduleId INT,
	@NewDiscountScheduleId INT OUTPUT
AS
BEGIN

	--------------------------
	-- Generate New Discount Schedule --
	--------------------------
	DECLARE @DiscountDescription NVARCHAR(50),
		@NewDiscountDescription NVARCHAR(50),
		@NewDiscountDescriptionWithCounter NVARCHAR(50),
		@counter INT,
		@DiscountScheduleCodeId INT,
		@NewDiscountScheduleCodeId INT

	SELECT @DiscountDescription = strDiscountDescription
		  ,@NewDiscountDescription = strDiscountDescription + '-copy' 
    FROM tblGRDiscountSchedule  
	WHERE intDiscountScheduleId = @DiscountScheduleId

	IF EXISTS(SELECT TOP 1 1 FROM tblGRDiscountSchedule WHERE strDiscountDescription = @NewDiscountDescription)
	BEGIN
		SET @counter = 1
		SET @NewDiscountDescriptionWithCounter = @NewDiscountDescription + (CAST(@counter AS NVARCHAR(50)))
		WHILE EXISTS(SELECT TOP 1 1 FROM tblGRDiscountSchedule WHERE strDiscountDescription = @NewDiscountDescriptionWithCounter)
		BEGIN
			SET @counter += 1
			SET @NewDiscountDescriptionWithCounter = @NewDiscountDescription + (CAST(@counter AS NVARCHAR(50)))
		END
		SET @NewDiscountDescription = @NewDiscountDescriptionWithCounter
	END
	-- PRINT @NewDiscountDescription
	-----------------------------------
	-- End Generation of New Discount Schedule --
	-----------------------------------

	---------------------------------
	-- Duplicate Discount Schedule Header table --
	---------------------------------
	INSERT INTO tblGRDiscountSchedule
	(
		 intCurrencyId
		,intCommodityId
	    ,strDiscountDescription
		,intConcurrencyId
	 )
	SELECT 
		 intCurrencyId
		,intCommodityId
		,@NewDiscountDescription
		,1
	FROM tblGRDiscountSchedule  
	WHERE intDiscountScheduleId = @DiscountScheduleId
	------------------------------------------
	-- End duplication of Discount Schedule Header table --
	------------------------------------------

	SET @NewDiscountScheduleId = SCOPE_IDENTITY()
	
	------------------------------
	-- Duplicate Discount Code and Incremental Grid table --
	------------------------------
	SELECT * INTO #tmpDiscountScheduleCode
	FROM tblGRDiscountScheduleCode 
	WHERE intDiscountScheduleId=@DiscountScheduleId

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpDiscountScheduleCode)
	BEGIN
		SELECT TOP 1 @DiscountScheduleCodeId = intDiscountScheduleCodeId FROM #tmpDiscountScheduleCode ORDER BY intSort

		INSERT INTO tblGRDiscountScheduleCode
		(
		     intDiscountScheduleId
			,intDiscountCalculationOptionId
			,intShrinkCalculationOptionId
			,ysnZeroIsValid
			,dblMinimumValue
			,dblMaximumValue
			,dblDefaultValue
			,ysnQualityDiscount
			,ysnDryingDiscount
			,dtmEffectiveDate
			,dtmTerminationDate
			,intConcurrencyId
			,intSort
			,strDiscountChargeType
			,intItemId
			,intStorageTypeId
			,intCompanyLocationId
			,intUnitMeasureId
		)
		SELECT 
			@NewDiscountScheduleId
			,intDiscountCalculationOptionId
			,intShrinkCalculationOptionId
			,ysnZeroIsValid
			,dblMinimumValue
			,dblMaximumValue
			,dblDefaultValue
			,ysnQualityDiscount
			,ysnDryingDiscount
			,dtmEffectiveDate
			,dtmTerminationDate
			,intConcurrencyId
			,intSort
			,strDiscountChargeType
			,intItemId
			,intStorageTypeId
			,intCompanyLocationId
			,intUnitMeasureId
		FROM #tmpDiscountScheduleCode
		WHERE intDiscountScheduleCodeId = @DiscountScheduleCodeId

		SET @NewDiscountScheduleCodeId = SCOPE_IDENTITY()

		INSERT INTO tblGRDiscountScheduleLine 
		(
			 intDiscountScheduleCodeId
			,dblRangeStartingValue
			,dblRangeEndingValue
			,dblIncrementValue
			,dblDiscountValue
			,dblShrinkValue
			,intConcurrencyId
		)
		SELECT
		 @NewDiscountScheduleCodeId 
		,dblRangeStartingValue
		,dblRangeEndingValue
		,dblIncrementValue
		,dblDiscountValue
		,dblShrinkValue
		,1 
		FROM
		(
			 SELECT TOP 100 PERCENT
			 intDiscountScheduleLineId
			,dblRangeStartingValue
			,dblRangeEndingValue
			,dblIncrementValue
			,dblDiscountValue
			,dblShrinkValue
			FROM tblGRDiscountScheduleLine
			WHERE intDiscountScheduleCodeId = @DiscountScheduleCodeId
			ORDER BY intDiscountScheduleLineId
		)t

		DELETE FROM #tmpDiscountScheduleCode
		WHERE intDiscountScheduleCodeId = @DiscountScheduleCodeId
	END

	DROP TABLE #tmpDiscountScheduleCode
	-------------------------------------------------------------
	---- End duplication of Discount Code and Incremental Grid --
	-------------------------------------------------------------

END
GO