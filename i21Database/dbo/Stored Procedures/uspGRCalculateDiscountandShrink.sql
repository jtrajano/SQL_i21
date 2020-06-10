CREATE PROCEDURE [dbo].[uspGRCalculateDiscountandShrink]
	 @intDiscountScheduleCodeId INT
	,@dblReading				DECIMAL(24, 10)
	,@intItemUOMId				INT = 0
	,@intItemId					INT = 0
AS
BEGIN TRY
	
	DECLARE @ErrMsg							  NVARCHAR(MAX)
	DECLARE @intIncrementalKey				  INT
	DECLARE @dblFrom						  DECIMAL(24, 6)
	DECLARE @dblTo							  DECIMAL(24, 6)
	DECLARE @dblIncrementBy					  DECIMAL(24, 6)
	DECLARE @dblDiscountAmount				  DECIMAL(24, 6)
	DECLARE @dblShrink						  DECIMAL(24, 6)
	DECLARE @dblNextRowFrom					  DECIMAL(24, 6)	
	DECLARE @dblEndingValue					  DECIMAL(24, 6)
	DECLARE @dblNewDiscountAmount			  DECIMAL(24, 6)
	DECLARE @dblNewShrink					  DECIMAL(24, 6)
	DECLARE @ysnZeroIsValid					  BIT
	DECLARE @dblMinimumValue				  DECIMAL(24, 6)
	DECLARE @dblMaximumValue				  DECIMAL(24, 6)	
	DECLARE @strDiscountChargeType			  Nvarchar(30)
	DECLARE @intDiscountCalculationOptionId   INT
	DECLARE @strCalculationDiscountOption     Nvarchar(50)
	DECLARE @intShrinkCalculationOptionId	  INT
	DECLARE @strCalculationShrinkOption		  Nvarchar(50)	
	DECLARE @dblMinFromForIncremental		  DECIMAL(24, 6)
	DECLARE @dblMaxToForIncremental			  DECIMAL(24, 6)	
	DECLARE @dblMaxFromForDecremental		  DECIMAL(24, 6)
	DECLARE @dblMinToForDecremental			  DECIMAL(24, 6)	
	DECLARE @intItemStockUOMId				  INT
	DECLARE @intDiscountUOMId				  INT
	DECLARE @strInventoryItemNo				  Nvarchar(50)
	DECLARE @strDiscountUOM					  Nvarchar(50)
	
	
	SELECT @dblMinimumValue					=  DSC.dblMinimumValue
		  ,@dblMaximumValue					=  DSC.dblMaximumValue
		  ,@ysnZeroIsValid					=  DSC.ysnZeroIsValid
		  ,@intDiscountCalculationOptionId  =  DSC.intDiscountCalculationOptionId
		  ,@strCalculationDiscountOption	=  DCOD.strDiscountCalculationOption
		  ,@strDiscountChargeType			=  DSC.strDiscountChargeType
		  ,@intShrinkCalculationOptionId	=  DSC.intShrinkCalculationOptionId
		  ,@strCalculationShrinkOption		=  DCOS.strShrinkCalculationOption
		  ,@intDiscountUOMId			    =  ISNULL(DSC.intUnitMeasureId,0)
	 FROM tblGRDiscountScheduleCode DSC 
	 JOIN tblGRDiscountCalculationOption DCOD ON DCOD.intDiscountCalculationOptionId = DSC.intDiscountCalculationOptionId
	 JOIN tblGRShrinkCalculationOption   DCOS ON DCOS.intShrinkCalculationOptionId   = DSC.intShrinkCalculationOptionId  
	 WHERE intDiscountScheduleCodeId = @intDiscountScheduleCodeId

	 IF ISNULL(@intItemUOMId,0) > 0
		 SELECT @intItemId = intItemId, @intItemStockUOMId = intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId =@intItemUOMId
	 
	IF ( @intItemId >0 AND @intDiscountUOMId > 0) AND NOT EXISTS(SELECT 1 FROM tblICItemUOM WHERE intItemId = @intItemId AND intUnitMeasureId = @intDiscountUOMId)
	BEGIN
	     SELECT @strInventoryItemNo = strItemNo FROM tblICItem WHERE intItemId = @intItemId
		 SELECT @strDiscountUOM     = strUnitMeasure   FROM tblICUnitMeasure WHERE intUnitMeasureId = @intDiscountUOMId
		 
		 SELECT 
		 intExtendedKey					= 1 
		,dblFrom						= 0.0 
		,dblTo							= 0.0 
		,dblDiscountAmount				= 0.0 
		,dblShrink						= 0.0 
		,strMessage						= 'Unit measure ' + @strDiscountUOM +' should be configured for item ' + @strInventoryItemNo+' .'
		,intDiscountCalculationOptionId = @intDiscountCalculationOptionId 
		,strCalculationDiscountOption   = @strCalculationDiscountOption 
		,strDiscountChargeType			= @strDiscountChargeType
		,intShrinkCalculationOptionId	= @intShrinkCalculationOptionId 
		,strCalculationShrinkOption	    = @strCalculationShrinkOption
		,intDiscountUOMId				= @intDiscountUOMId 

	END
	ELSE IF ((@dblReading < @dblMinimumValue OR @dblReading > @dblMaximumValue) AND (@ysnZeroIsValid=0)) OR ((@dblReading > 0) AND (@ysnZeroIsValid=1) AND (@dblReading < @dblMinimumValue OR @dblReading > @dblMaximumValue))
	BEGIN
		SELECT 
		 intExtendedKey					= 1 
		,dblFrom						= 0.0 
		,dblTo							= 0.0 
		,dblDiscountAmount				= 0.0 
		,dblShrink						= 0.0 
		,strMessage						= 'Invalid reading value entered. Minimum Reading is ' + dbo.fnRemoveTrailingZeroes(@dblMinimumValue) +' and Maximum Reading is ' +  dbo.fnRemoveTrailingZeroes(@dblMaximumValue) 
		,intDiscountCalculationOptionId = @intDiscountCalculationOptionId 
		,strCalculationDiscountOption   = @strCalculationDiscountOption 
		,strDiscountChargeType			= @strDiscountChargeType
		,intShrinkCalculationOptionId	= @intShrinkCalculationOptionId 
		,strCalculationShrinkOption	    = @strCalculationShrinkOption
		,intDiscountUOMId				= @intDiscountUOMId 
	END
	ELSE IF NOT EXISTS(SELECT 1 FROM tblGRDiscountScheduleLine WHERE intDiscountScheduleCodeId = @intDiscountScheduleCodeId)
	OR (@dblReading = 0 and @ysnZeroIsValid = 1)
	BEGIN
		  SELECT
		  intExtendedKey				 = 1 
		 ,dblFrom						 = 0.0 
		 ,dblTo							 = 0.0 
		 ,dblDiscountAmount				 = 0.0 
		 ,dblShrink						 = 0.0 
		 ,strMessage					 = 'Success' 
		 ,intDiscountCalculationOptionId = @intDiscountCalculationOptionId
		 ,strCalculationDiscountOption   = @strCalculationDiscountOption 
		 ,strDiscountChargeType			 = @strDiscountChargeType
		 ,intShrinkCalculationOptionId	 = @intShrinkCalculationOptionId 
		 ,strCalculationShrinkOption	 = @strCalculationShrinkOption
		 ,intDiscountUOMId				 = @intDiscountUOMId  	
	END
	ELSE
	BEGIN
		DECLARE @tblIncrementalTab AS TABLE 
		(
			intIncrementalKey INT IDENTITY(1, 1)
			,dblFrom DECIMAL(24, 6)
			,dblTo DECIMAL(24, 6)
			,dblIncrementBy DECIMAL(24, 6)
			,dblDiscountAmount DECIMAL(24, 6)
			,dblShrink DECIMAL(24, 6)
		)
		DECLARE @tblExtendedTab AS TABLE 
		(
			 intExtendedKey INT IDENTITY(1, 1)
			,dblFrom DECIMAL(24, 6)
			,dblTo DECIMAL(24, 6)
			,dblDiscountAmount DECIMAL(24, 6)
			,dblShrink DECIMAL(24, 6)
		 )

		 IF EXISTS(SELECT 1 FROM tblGRDiscountScheduleLine WHERE dblIncrementValue >0 AND intDiscountScheduleCodeId=@intDiscountScheduleCodeId)
		 BEGIN
				INSERT INTO @tblIncrementalTab 
				(
					 dblFrom
					,dblTo
					,dblIncrementBy
					,dblDiscountAmount
					,dblShrink
				)
				SELECT 
				 dblRangeStartingValue
				,dblRangeEndingValue
				,dblIncrementValue
				,dblDiscountValue
				,dblShrinkValue 
				FROM tblGRDiscountScheduleLine
				WHERE intDiscountScheduleCodeId = @intDiscountScheduleCodeId
				ORDER BY dblRangeStartingValue
		 END
		 ELSE
		 BEGIN
				INSERT INTO @tblIncrementalTab 
				(
					 dblFrom
					,dblTo
					,dblIncrementBy
					,dblDiscountAmount
					,dblShrink
				)
				SELECT 
				 dblRangeStartingValue
				,dblRangeEndingValue
				,dblIncrementValue
				,dblDiscountValue
				,dblShrinkValue 
				FROM tblGRDiscountScheduleLine
				WHERE intDiscountScheduleCodeId = @intDiscountScheduleCodeId
				ORDER BY dblRangeStartingValue DESC
		 END

		SELECT @intIncrementalKey = MIN(intIncrementalKey)
		FROM @tblIncrementalTab

		WHILE @intIncrementalKey > 0
		BEGIN
			SET @dblFrom = NULL
			SET @dblTo = NULL
			SET @dblIncrementBy = NULL
			SET @dblDiscountAmount = NULL
			SET @dblShrink = NULL
			SET @dblEndingValue = NULL
			SET @dblNextRowFrom = NULL			

			SELECT @dblFrom = dblFrom
				,@dblTo = dblTo
				,@dblIncrementBy = dblIncrementBy
				,@dblDiscountAmount = dblDiscountAmount
				,@dblShrink = dblShrink
			FROM @tblIncrementalTab
			WHERE intIncrementalKey = @intIncrementalKey

			SELECT @dblNextRowFrom = dblFrom
			FROM @tblIncrementalTab
			WHERE intIncrementalKey = (@intIncrementalKey + 1)

			SET @dblNextRowFrom = ISNULL(@dblNextRowFrom, 0)

			IF @dblIncrementBy > 0
			BEGIN
				WHILE @dblFrom < @dblTo
				BEGIN
					SET @dblEndingValue = ISNULL(@dblEndingValue, 0)

					IF @dblFrom + @dblIncrementBy > @dblTo
					BEGIN
						IF @dblTo = @dblNextRowFrom
							SET @dblEndingValue = @dblTo - 0.000001
						ELSE
							SET @dblEndingValue = @dblTo
					END
					ELSE IF @dblFrom + @dblIncrementBy >= @dblNextRowFrom AND @dblNextRowFrom > 0
						SET @dblEndingValue = @dblNextRowFrom - 0.000001
					ELSE IF (@dblFrom + @dblIncrementBy < @dblTo)
						SET @dblEndingValue = @dblFrom + @dblIncrementBy - 0.000001
					ELSE IF (@dblTo < @dblNextRowFrom AND @dblNextRowFrom > 0)
						SET @dblEndingValue = @dblNextRowFrom - 0.000001
					ELSE
						SET @dblEndingValue = @dblFrom + @dblIncrementBy

					SET @dblNewDiscountAmount = ISNULL(@dblNewDiscountAmount, 0) + @dblDiscountAmount
					SET @dblNewShrink = ISNULL(@dblNewShrink, 0) + @dblShrink

					INSERT INTO @tblExtendedTab 
					(
						dblFrom
						,dblTo
						,dblDiscountAmount
						,dblShrink
					)
					SELECT @dblFrom
						,@dblEndingValue
						,@dblNewDiscountAmount
						,@dblNewShrink

					SET @dblFrom = @dblFrom + @dblIncrementBy
				END
			END
			ELSE
			BEGIN
				WHILE @dblFrom > @dblTo
				BEGIN
					SET @dblEndingValue = ISNULL(@dblEndingValue, 0)

					IF @dblFrom > @dblTo - @dblIncrementBy
					BEGIN
						SET @dblEndingValue = @dblFrom + @dblIncrementBy
						IF @dblEndingValue >= @dblNextRowFrom
						   SET @dblEndingValue = @dblEndingValue + 0.000001
					END
					ELSE IF @dblFrom <= @dblTo - @dblIncrementBy
						IF @dblTo = @dblNextRowFrom
							SET @dblEndingValue = @dblTo + 0.000001
						ELSE
							SET @dblEndingValue = CASE WHEN @dblNextRowFrom > 0 THEN  @dblNextRowFrom + 0.000001 ELSE @dblTo END

					SET @dblNewDiscountAmount = ISNULL(@dblNewDiscountAmount, 0) + @dblDiscountAmount
					SET @dblNewShrink = ISNULL(@dblNewShrink, 0) + @dblShrink

					INSERT INTO @tblExtendedTab 
					(
						 dblFrom
						,dblTo
						,dblDiscountAmount
						,dblShrink
					)
					SELECT
						 @dblFrom
						,@dblEndingValue
						,@dblNewDiscountAmount
						,@dblNewShrink

					SET @dblFrom = @dblFrom + @dblIncrementBy
				END
			END

			SELECT @intIncrementalKey = MIN(intIncrementalKey)
			FROM @tblIncrementalTab
			WHERE intIncrementalKey > @intIncrementalKey
		END
		
		IF @dblIncrementBy > 0
		BEGIN		
			 SELECT @dblMinFromForIncremental=MIN(dblFrom),@dblMaxToForIncremental=MAX(dblTo)FROM @tblExtendedTab
			 
			 IF EXISTS(SELECT 1 FROM @tblExtendedTab WHERE dblFrom <= @dblReading AND dblTo >= @dblReading)
			 BEGIN
				 SELECT 
				 intExtendedKey					 =  intExtendedKey
				,dblFrom						 =  dblFrom
				,dblTo							 =  dblTo
				,dblDiscountAmount				 =  CASE 
														WHEN @intDiscountUOMId>0 AND @intItemStockUOMId > 0 
															THEN 
																CASE
																	WHEN @strDiscountChargeType = 'Percent'
																		THEN dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@intItemStockUOMId,@intDiscountUOMId,dblDiscountAmount) * 100
																	ELSE
																		dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@intItemStockUOMId,@intDiscountUOMId,dblDiscountAmount)
																END
														ELSE 
															CASE 
																WHEN @strDiscountChargeType = 'Percent' THEN dblDiscountAmount * 100 
																ELSE dblDiscountAmount
															END
													END
				,dblShrink						 =  CASE 
														WHEN @intDiscountUOMId>0 AND @intItemStockUOMId > 0 THEN dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@intItemStockUOMId,@intDiscountUOMId,dblShrink)
														ELSE dblShrink
													END
				,strMessage						 =  'Success'
				,intDiscountCalculationOptionId  =  @intDiscountCalculationOptionId
				,strCalculationDiscountOption    =  @strCalculationDiscountOption
				,strDiscountChargeType			 =  @strDiscountChargeType
				,intShrinkCalculationOptionId	 =  @intShrinkCalculationOptionId
				,strCalculationShrinkOption	     =  @strCalculationShrinkOption
				,intDiscountUOMId				 =  @intDiscountUOMId 
				 FROM @tblExtendedTab WHERE dblFrom <= @dblReading AND dblTo >= @dblReading
			 END
			 ELSE IF (@dblReading < @dblMinFromForIncremental)
			 BEGIN
				 SELECT
				 TOP 1 
				 intExtendedKey					 = intExtendedKey
				,dblFrom						 = dblFrom
				,dblTo							 = dblTo
    			,dblDiscountAmount				 = 0.0 
    			,dblShrink						 = 0.0
				,strMessage						 = 'Success'
				,intDiscountCalculationOptionId  = @intDiscountCalculationOptionId
				,strCalculationDiscountOption    = @strCalculationDiscountOption
				,strDiscountChargeType			 = @strDiscountChargeType
				,intShrinkCalculationOptionId	 = @intShrinkCalculationOptionId
				,strCalculationShrinkOption		 = @strCalculationShrinkOption
				,intDiscountUOMId				 = @intDiscountUOMId 
				 FROM @tblExtendedTab ORDER BY 1 
			 END
			 ELSE IF (@dblReading > @dblMaxToForIncremental)
			 BEGIN
				 SELECT
				 TOP 1 
				 intExtendedKey					 = intExtendedKey
				,dblFrom						 = dblFrom
				,dblTo							 = dblTo
				,dblDiscountAmount				 = CASE 
														WHEN @intDiscountUOMId>0 AND @intItemStockUOMId > 0  
															THEN 
																CASE
																	WHEN @strDiscountChargeType = 'Percent'
																		THEN dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@intItemStockUOMId,@intDiscountUOMId,dblDiscountAmount) * 100
																	ELSE 
																		dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@intItemStockUOMId,@intDiscountUOMId,dblDiscountAmount)
																END
														ELSE 
															CASE 
																WHEN @strDiscountChargeType = 'Percent' THEN dblDiscountAmount * 100 
																ELSE dblDiscountAmount 
															END
													END
				,dblShrink						 = CASE 
														WHEN @intDiscountUOMId>0 AND @intItemStockUOMId > 0 THEN dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@intItemStockUOMId,@intDiscountUOMId,dblShrink)
														ELSE dblShrink
													END
				,strMessage						 = 'Success'
				,intDiscountCalculationOptionId  = @intDiscountCalculationOptionId
				,strCalculationDiscountOption    = @strCalculationDiscountOption
				,strDiscountChargeType			 = @strDiscountChargeType
				,intShrinkCalculationOptionId	 = @intShrinkCalculationOptionId
				,strCalculationShrinkOption		 = @strCalculationShrinkOption
				,intDiscountUOMId				 = @intDiscountUOMId 			 
				 FROM @tblExtendedTab ORDER BY 1 DESC
			 END
		END	 							
		ELSE
		BEGIN
			SELECT @dblMaxFromForDecremental=MAX(dblFrom),@dblMinToForDecremental=MIN(dblTo)FROM @tblExtendedTab
			
			IF EXISTS(SELECT 1 FROM @tblExtendedTab WHERE dblFrom >= @dblReading AND dblTo <= @dblReading)
			BEGIN
				SELECT 
				 TOP 1
				 intExtendedKey					 = intExtendedKey
				,dblFrom						 = dblFrom
				,dblTo							 = dblTo
				,dblDiscountAmount				 =  CASE 
														WHEN @intDiscountUOMId>0 AND @intItemStockUOMId > 0 
															THEN 
																CASE
																	WHEN @strDiscountChargeType = 'Percent'
																		THEN dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@intItemStockUOMId,@intDiscountUOMId,dblDiscountAmount) * 100
																	ELSE
																		dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@intItemStockUOMId,@intDiscountUOMId,dblDiscountAmount)
																END
														ELSE 
															CASE 
																WHEN @strDiscountChargeType = 'Percent' THEN dblDiscountAmount * 100 
																ELSE dblDiscountAmount
															END
													END
				,dblShrink						 =  CASE 
														WHEN @intDiscountUOMId>0 AND @intItemStockUOMId > 0 THEN dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@intItemStockUOMId,@intDiscountUOMId,dblShrink)
														ELSE dblShrink
													END
				,strMessage						 = 'Success'
				,intDiscountCalculationOptionId  = @intDiscountCalculationOptionId 
				,strCalculationDiscountOption    = @strCalculationDiscountOption
				,strDiscountChargeType			 = @strDiscountChargeType
				,intShrinkCalculationOptionId	 = @intShrinkCalculationOptionId 
				,strCalculationShrinkOption		 = @strCalculationShrinkOption
				,intDiscountUOMId				 = @intDiscountUOMId 	  
				FROM @tblExtendedTab WHERE dblFrom >= @dblReading AND dblTo <= @dblReading ORDER BY intExtendedKey DESC
			END
			ELSE IF (@dblReading > @dblMaxFromForDecremental)
			BEGIN
				SELECT
				 TOP 1 
				 intExtendedKey					 = intExtendedKey
				,dblFrom						 = dblFrom
				,dblTo							 = dblTo
    			,dblDiscountAmount				 = 0.0
    			,dblShrink						 = 0.0
				,strMessage						 = 'Success' 
				,intDiscountCalculationOptionId  = @intDiscountCalculationOptionId
				,strCalculationDiscountOption    = @strCalculationDiscountOption
				,strDiscountChargeType			 = @strDiscountChargeType
				,intShrinkCalculationOptionId	 = @intShrinkCalculationOptionId
				,strCalculationShrinkOption		 = @strCalculationShrinkOption
				,intDiscountUOMId				 = @intDiscountUOMId 				 
				 FROM @tblExtendedTab ORDER BY intExtendedKey
			END
			ELSE IF (@dblReading < @dblMinToForDecremental)
			BEGIN
				SELECT
				 TOP 1 
				 intExtendedKey					 = intExtendedKey
				,dblFrom						 = dblFrom
				,dblTo							 = dblTo
				,dblDiscountAmount				 =  CASE 
														WHEN @intDiscountUOMId>0 AND @intItemStockUOMId > 0 
															THEN 
																CASE
																	WHEN @strDiscountChargeType = 'Percent'
																		THEN dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@intItemStockUOMId,@intDiscountUOMId,dblDiscountAmount) * 100
																	ELSE
																		dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@intItemStockUOMId,@intDiscountUOMId,dblDiscountAmount)
																END
														ELSE 
															CASE 
																WHEN @strDiscountChargeType = 'Percent' THEN dblDiscountAmount * 100 
																ELSE dblDiscountAmount
															END
													END
				,dblShrink						 =  CASE 
														WHEN @intDiscountUOMId>0 AND @intItemStockUOMId > 0 THEN dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@intItemStockUOMId,@intDiscountUOMId,dblShrink)
														ELSE dblShrink
													END
				,strMessage						 = 'Success'
				,intDiscountCalculationOptionId  = @intDiscountCalculationOptionId 
				,strCalculationDiscountOption    = @strCalculationDiscountOption
				,strDiscountChargeType			 = @strDiscountChargeType
				,intShrinkCalculationOptionId	 = @intShrinkCalculationOptionId
				,strCalculationShrinkOption		 = @strCalculationShrinkOption
				,intDiscountUOMId				 = @intDiscountUOMId 				 
				 FROM @tblExtendedTab ORDER BY intExtendedKey DESC
			END
			
		END								
		
	END
			
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH