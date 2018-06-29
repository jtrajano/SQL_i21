CREATE PROCEDURE [dbo].[uspGRDuplicateDiscountTable]
	@DiscountId INT,
	@NewDiscountId INT OUTPUT
AS
BEGIN

	--------------------------
	-- Generate New Discount Table --
	--------------------------
	DECLARE 
		@strDiscountId NVARCHAR(50),
		@NewstrDiscountId NVARCHAR(50),
		@NewstrDiscountIdWithCounter NVARCHAR(50),
		
		@DiscountDescription NVARCHAR(50),
		@NewDiscountDescription NVARCHAR(50),
		@NewDiscountDescriptionWithCounter NVARCHAR(50),

		@counter INT,
		@DiscountScheduleId INT,
		@NewDiscountScheduleId INT

	SELECT 
		    @strDiscountId		= strDiscountId
		   ,@NewstrDiscountId	= strDiscountId + '-copy' 
		  ,@DiscountDescription = strDiscountDescription
		  ,@NewDiscountDescription = strDiscountDescription + '-copy' 
    FROM tblGRDiscountId  
	WHERE intDiscountId = @DiscountId

	IF EXISTS(SELECT TOP 1 1 FROM tblGRDiscountId WHERE strDiscountId = @NewstrDiscountId)
	BEGIN
		SET @counter = 1
		SET @NewstrDiscountIdWithCounter = @NewstrDiscountId + (CAST(@counter AS NVARCHAR(50)))
		WHILE EXISTS(SELECT TOP 1 1 FROM tblGRDiscountId WHERE strDiscountId = @NewstrDiscountIdWithCounter)
		BEGIN
			SET @counter += 1
			SET @NewstrDiscountIdWithCounter = @NewstrDiscountId + (CAST(@counter AS NVARCHAR(50)))
		END
		SET @NewstrDiscountId = @NewstrDiscountIdWithCounter
	END

	IF EXISTS(SELECT TOP 1 1 FROM tblGRDiscountId WHERE strDiscountDescription = @NewDiscountDescription)
	BEGIN
		SET @counter = 1
		SET @NewDiscountDescriptionWithCounter = @NewDiscountDescription + (CAST(@counter AS NVARCHAR(50)))
		WHILE EXISTS(SELECT TOP 1 1 FROM tblGRDiscountId WHERE strDiscountDescription = @NewDiscountDescriptionWithCounter)
		BEGIN
			SET @counter += 1
			SET @NewDiscountDescriptionWithCounter = @NewDiscountDescription + (CAST(@counter AS NVARCHAR(50)))
		END
		SET @NewDiscountDescription = @NewDiscountDescriptionWithCounter
	END
	-- PRINT @NewDiscountDescription
	-----------------------------------
	-- End Generation of New Discount Table --
	-----------------------------------

	---------------------------------
	-- Duplicate Discount Table Header table --
	---------------------------------
	INSERT INTO tblGRDiscountId
	(
		  intCurrencyId
		 ,strDiscountId
		 ,strDiscountDescription
		 ,ysnDiscountIdActive
		 ,intConcurrencyId
	 )
	SELECT 
		  intCurrencyId
		 ,@NewstrDiscountId 
		 ,@NewDiscountDescription
		 ,ysnDiscountIdActive
		 , 1
	FROM tblGRDiscountId  
	WHERE intDiscountId = @DiscountId
	------------------------------------------
	-- End duplication of Discount Table Header table --
	------------------------------------------

	SET @NewDiscountId = SCOPE_IDENTITY()

	----------------------------------------------------
	----Linking Location for the New Discount Table
	----------------------------------------------------
	INSERT INTO tblGRDiscountLocationUse
	(
	   intDiscountId
	  ,intCompanyLocationId
	  ,ysnDiscountLocationActive
	  ,intConcurrencyId 
	)
	SELECT
		 intDiscountId				= @NewDiscountId
		,intCompanyLocationId		= intCompanyLocationId
		,ysnDiscountLocationActive  = ysnDiscountLocationActive
		,intConcurrencyId			= 1
		FROM tblGRDiscountLocationUse 
		WHERE intDiscountId = @DiscountId
	----------------------------------------------------
	---- End Linking Location for the New Discount Table
	----------------------------------------------------

	----------------------------------------------------
	-- Duplicate Discount Schedule --
	----------------------------------------------------
	SELECT * INTO #tblGRDiscountCrossReference
	FROM tblGRDiscountCrossReference 
	WHERE intDiscountId = @DiscountId

	WHILE EXISTS(SELECT TOP 1 1 FROM #tblGRDiscountCrossReference)
	BEGIN
	     SET @DiscountScheduleId    = NULL
		 SET @NewDiscountScheduleId = NULL

		SELECT TOP 1 @DiscountScheduleId = intDiscountScheduleId FROM #tblGRDiscountCrossReference ORDER BY intDiscountCrossReferenceId

		EXEC uspGRDuplicateDiscountSchedule @DiscountScheduleId,@NewDiscountScheduleId OUTPUT

		INSERT INTO tblGRDiscountCrossReference
		(
		      intDiscountId
			 ,intDiscountScheduleId
			 ,intConcurrencyId
		)
		SELECT 
			 intDiscountId          = @NewDiscountId
			,intDiscountScheduleId  = @NewDiscountScheduleId
			,intConcurrencyId		= 1

		DELETE FROM #tblGRDiscountCrossReference
		WHERE intDiscountScheduleId = @DiscountScheduleId
	END

	DROP TABLE #tblGRDiscountCrossReference
	-------------------------------------------------------------
	---- End duplication of Discount Schedule --
	-------------------------------------------------------------

END
