CREATE PROCEDURE [dbo].[uspMFPickWorkOrder] 
(
	@intWorkOrderId					INT
  , @dblProduceQty					NUMERIC(38, 20)
  , @intProduceUOMId				INT				= NULL
  , @intUserId						INT
  , @intBatchId						INT
  , @strPickPreference				NVARCHAR(50)	= ''
  , @ysnExcessConsumptionAllowed	BIT				= 0
  , @dblUnitQty						NUMERIC(38, 20)
  , @ysnProducedQtyByWeight			BIT				= 1
  , @ysnFillPartialPallet			BIT				= 0
  , @dblProducePartialQty			NUMERIC(38, 20) = 0
  , @intMachineId					INT				= NULL
  , @dtmCurrentDateTime				DATETIME		= NULL
)
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	/* Variables. */
	DECLARE @ErrMsg							NVARCHAR(MAX)
		  , @strItemNo						NVARCHAR(50)
		  , @intItemId						INT
		  , @intRecipeId					INT
		  , @intItemRecordId				INT
		  , @intLotRecordId					INT
		  , @dblReqQty						NUMERIC(18, 6)
		  , @intLotId						INT
		  , @dblQty							NUMERIC(38, 20)
		  , @intLocationId					INT
		  , @intSequenceNo					INT
		  , @ysnSubstituteItem				BIT
		  , @dblSubstituteRatio				NUMERIC(18, 6)
		  , @dblMaxSubstituteRatio			NUMERIC(18, 6)
		  , @intStorageLocationId			INT
		  , @dtmCurrentDate					DATETIME
		  , @intDayOfYear					INT
		  , @intConsumptionMethodId			INT
		  , @intWeightUOMId					INT
		  , @dblAdjustByQuantity			NUMERIC(38, 20)
		  , @dblWeightPerQty				NUMERIC(38, 20)
		  , @intInventoryAdjustmentId		INT
		  , @intTransactionCount			INT = @@TRANCOUNT
		  , @intManufacturingProcessId		INT
		  , @strAllInputItemsMandatoryforConsumption NVARCHAR(50)
		  , @intManufacturingCellId			INT
		  , @intPackagingCategoryId			INT
		  , @strPackagingCategory			NVARCHAR(50)
		  , @intInputItemId					INT
		  , @strReqQty						NVARCHAR(50)
		  , @strQty							NVARCHAR(50)
		  , @dtmBusinessDate				DATETIME
		  , @intBusinessShiftId				INT
		  , @strWorkOrderNo					NVARCHAR(50)
		  , @strLotTracking					NVARCHAR(50)
		  , @strLifeTimeType				NVARCHAR(50)
		  , @intLifeTime					INT
		  , @dtmExpiryDate					DATETIME
		  , @intItemLocationId				INT
		  , @strLotNumber					NVARCHAR(50)
		  , @intItemUOMId					INT
		  , @intSubLocationId				INT
		  , @intCategoryId					INT
		  , @intItemIssuedUOMId				INT
		  , @intStorageLocationId1			NUMERIC(18, 6)
		  , @intRecipeItemUOMId				INT
		  , @intProductionStageLocationId	INT
		  , @ysnPickByLotCode				BIT
		  , @intLotCodeStartingPosition		INT
		  , @intLotCodeNoOfDigits			INT
		  , @dblLowerToleranceReqQty		NUMERIC(18, 6)
		  , @dblUpperToleranceReqQty		NUMERIC(18, 6)
		  , @intLotItemId					INT
		  , @intPMCategoryId				INT
		  , @intPMStageLocationId			INT
		  , @intNoOfDecimalPlacesOnConsumption INT
		  , @ysnConsumptionByRatio			BIT
		  , @intStageLocationId				INT
		  , @ysnLifeTimeByEndOfMonth		BIT
		  , @intRecipeTypeId				INT
		  , @ItemsToReserve					[dbo].[ItemReservationTableType]
		  , @strInstantConsumption			NVARCHAR(50)
		  , @strCycleCountbasedonRecipeTolerance NVARCHAR(50)
		  , @dblPhysicalCount				NUMERIC(18, 6)
		  , @intWorkOrderConsumedLotId		INT
		  , @intMainItemId					INT

	DECLARE @tblMFWorkOrderInputLot TABLE 
	(	
		strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	);

	DECLARE @tblMFWorkOrderInputItem TABLE 
	(
		intItemId		INT
	  , dblQuantity		NUMERIC(18, 6)
	  , intItemUOMId	INT
	  , dblRatio		NUMERIC(18, 6)
	  , intMainItemId	INT
	);

	DECLARE @tblMFMachine TABLE 
	(
		intMachineId INT
	);

	DECLARE @tblMFRMProductionStageLocation TABLE 
	(
		intRMProductionStageLocationId INT
	);

	DECLARE @tblMFProductionStageLocation TABLE 
	(
		intProductionStageLocationId INT
	);

	DECLARE @tblItem TABLE 
	(
		intItemRecordId			INT IDENTITY(1, 1)
	  , intItemId				INT
	  , dblReqQty				NUMERIC(18, 6)
	  , intItemUOMId			INT
	  , intStorageLocationId	INT
	  , intConsumptionMethodId	INT
	  , strLotTracking			NVARCHAR(50)
	  , dblLowerToleranceReqQty NUMERIC(18, 6)
	  , intMainItemId			INT
	  , intCategoryId			INT
	  , dblUpperToleranceReqQty NUMERIC(18, 6)
	);

	DECLARE @tblSubstituteItem TABLE 
	(
		intItemRecordId			INT IDENTITY(1, 1)
	  , intItemId				INT
	  , intSubstituteItemId		INT
	  , dblSubstituteRatio		NUMERIC(18, 6)
	  , dblMaxSubstituteRatio	NUMERIC(18, 6)
	);

	DECLARE @tblLot TABLE 
	(
		intLotRecordId			INT IDENTITY(1, 1)
	  , strLotNumber			NVARCHAR(50)
	  , intLotId				INT
	  , intItemId				INT
	  , dblQty					NUMERIC(38, 20)
	  , dblIssuedQuantity		NUMERIC(38, 20)
	  , dblWeightPerUnit		NUMERIC(38, 20)
	  , intItemUOMId			INT
	  , intItemIssuedUOMId		INT
	  , ysnSubstituteItem		BIT
	  , dblSubstituteRatio		NUMERIC(18, 6)
	  , dblMaxSubstituteRatio	NUMERIC(18, 6)
	  , intStorageLocationId	INT
	  , intSubLocationId		INT
	);

	/* End of Variables. */

	/* Retrieve Company Configuration. */
	SELECT @intNoOfDecimalPlacesOnConsumption	= ISNULL(intNoOfDecimalPlacesOnConsumption, 4)
		 , @ysnConsumptionByRatio				= ISNULL(ysnConsumptionByRatio, 0)
		 , @ysnLifeTimeByEndOfMonth				= ysnLifeTimeByEndOfMonth
		 , @ysnPickByLotCode					= ysnPickByLotCode
		 , @intLotCodeStartingPosition			= intLotCodeStartingPosition
		 , @intLotCodeNoOfDigits				= intLotCodeNoOfDigits
	FROM tblMFCompanyPreference;

	/* Set Default Value. */
	SELECT @dtmCurrentDateTime	= ISNULL(@dtmCurrentDateTime, GETDATE())
		 , @dtmCurrentDate		= CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))
		 , @intDayOfYear		= DATEPART(dy, @dtmCurrentDateTime)

	SELECT @intItemId					= intItemId
		 , @intLocationId				= intLocationId
		 , @intManufacturingProcessId	= intManufacturingProcessId
		 , @intManufacturingCellId		= intManufacturingCellId
		 , @strWorkOrderNo				= strWorkOrderNo
		 , @intRecipeTypeId				= intRecipeTypeId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @strInstantConsumption = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
	  AND intLocationId				= @intLocationId
	  AND intAttributeId			= 20; --Is Instant Consumption

	INSERT INTO @tblMFWorkOrderInputLot 
	(
		strLotNumber
	)
	SELECT Lot.strLotNumber
	FROM dbo.tblICLot AS Lot
	JOIN dbo.tblMFWorkOrderInputLot AS InputLot ON InputLot.intLotId = Lot.intLotId AND ysnConsumptionReversed = 0
	WHERE InputLot.intWorkOrderId = @intWorkOrderId 
	  AND ISNULL(InputLot.intMachineId, 0) = (CASE WHEN ISNULL(InputLot.intMachineId, 0) = 0 THEN ISNULL(InputLot.intMachineId, 0) 
												   ELSE IsNULL(@intMachineId, IsNULL(intMachineId, 0))
											  END);

	/* Retrieve machine used on the process. */
	IF EXISTS (SELECT intMachineId FROM tblMFWorkOrderProducedLot WHERE intWorkOrderId = @intWorkOrderId AND ysnProductionReversed = 0)
		BEGIN
			INSERT INTO @tblMFMachine 
			(
				intMachineId
			)
			SELECT intMachineId
			FROM tblMFWorkOrderProducedLot
			WHERE intWorkOrderId = @intWorkOrderId AND ysnProductionReversed = 0;
		END
	ELSE 
		BEGIN
			INSERT INTO @tblMFMachine 
			(
				intMachineId
			)
			SELECT intMachineId
			FROM tblMFWorkOrderInputLot
			WHERE intWorkOrderId = @intWorkOrderId AND ysnConsumptionReversed = 0;
		END

	/* Retrieve staging location that will be use on transaction. */
	IF EXISTS (SELECT intProductionStagingLocationId 
			   FROM tblMFManufacturingProcessMachine 
			   WHERE intManufacturingProcessId = @intManufacturingProcessId
				 AND intMachineId IN (SELECT intMachineId FROM @tblMFMachine )
				 AND intProductionStagingLocationId IS NOT NULL)
		BEGIN
			INSERT INTO @tblMFRMProductionStageLocation 
			(
				intRMProductionStageLocationId
			)
			SELECT intProductionStagingLocationId
			FROM tblMFManufacturingProcessMachine
			WHERE intManufacturingProcessId = @intManufacturingProcessId
			  AND intMachineId IN (SELECT intMachineId FROM @tblMFMachine)
			  AND intProductionStagingLocationId IS NOT NULL
		END
	ELSE
		BEGIN
			INSERT INTO @tblMFRMProductionStageLocation 
			(
				intRMProductionStageLocationId
			)
			SELECT ProcessAttribute.strAttributeValue
			FROM tblMFManufacturingProcessAttribute AS ProcessAttribute
			OUTER APPLY (SELECT *
						 FROM tblMFAttribute
						 WHERE strAttributeName = 'Production Staging Location') AS Attribute
			WHERE ProcessAttribute.intManufacturingProcessId = @intManufacturingProcessId
			  AND ProcessAttribute.intLocationId			 = @intLocationId
			  AND ProcessAttribute.intAttributeId			 = Attribute.intAttributeId
		END
	/* End of Retrieve staging location that will be use on transaction. */


	/* Retrieve manufacturing process attribute values that will be use on transaction. */
	SELECT @ysnExcessConsumptionAllowed				= CASE WHEN strAttributeValue = 'True' AND strAttributeName = 'Is Yield Adjustment Allowed' THEN 1
														   ELSE ISNULL(@ysnExcessConsumptionAllowed, 0)
													  END
		 , @intPMCategoryId							= CASE WHEN strAttributeName = 'Packaging Category' THEN strAttributeValue 
														   ELSE ISNULL(@intPMCategoryId, 0)
													  END
		 , @strPackagingCategory					= ISNULL(Category.strCategoryCode, '')
		 , @strCycleCountbasedonRecipeTolerance		= CASE WHEN strAttributeName = 'Cycle Count based on Recipe Tolerance' THEN strAttributeValue
														   ELSE ISNULL(@strCycleCountbasedonRecipeTolerance, 'False')
													  END
		 , @intPMStageLocationId					= CASE WHEN  strAttributeName = 'PM Production Staging Location' THEN strAttributeValue
														   ELSE @intPMStageLocationId
													  END
		 , @strAllInputItemsMandatoryforConsumption	= CASE WHEN  strAttributeName = 'All input items mandatory for consumption' THEN strAttributeValue
														   ELSE @strAllInputItemsMandatoryforConsumption
													  END
	FROM vyuMFProcessAttributeDetail
	OUTER APPLY (SELECT ICCategory.strCategoryCode
				 FROM tblICCategory AS ICCategory
				 WHERE ICCategory.strCategoryCode = strAttributeValue AND strAttributeName = 'Packaging Category') AS Category
	WHERE intManufacturingProcessId = @intManufacturingProcessId
	  AND intLocationId				= @intLocationId;
	/* End of Retrieve manufacturing process attribute values that will be use on transaction. */
    

	/* Transaction Starts here. */
	IF @intTransactionCount = 0
		BEGIN TRANSACTION
			SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDateTime, @intLocationId);

			SELECT @intBusinessShiftId = intShiftId
			FROM dbo.tblMFShift
			WHERE intLocationId = @intLocationId
			  AND @dtmCurrentDateTime BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			  AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset;

			SELECT @intRecipeId = intRecipeId
			FROM dbo.tblMFWorkOrderRecipe a
			WHERE intWorkOrderId = @intWorkOrderId;

			/* Create Stock Reservation for Consume Transaction (8). */
			EXEC dbo.uspICCreateStockReservation @ItemsToReserve
											   , @intWorkOrderId
											   , 8;

			/* Create Stock Reservation for Produce Transaction (9). */
			EXEC dbo.uspICCreateStockReservation @ItemsToReserve
											   , @intWorkOrderId
											   , 9

			/* Set Batch ID of Consumed Lot. */
			UPDATE ConsumedLot
			SET ConsumedLot.intBatchId = @intBatchId
			FROM tblMFWorkOrderConsumedLot AS ConsumedLot
			JOIN tblMFWorkOrderProducedLot AS ProducedLot ON ProducedLot.intWorkOrderId			= ConsumedLot.intWorkOrderId 
													     AND ProducedLot.intSpecialPalletLotId	= ConsumedLot.intLotId
			WHERE ConsumedLot.intWorkOrderId = @intWorkOrderId
			  AND intSpecialPalletLotId IS NOT NULL
			  AND ConsumedLot.intBatchId IS NULL;

			INSERT INTO @tblItem 
			(
				intItemId
			  , dblReqQty
			  , intItemUOMId
			  , intStorageLocationId
			  , intConsumptionMethodId
			  , strLotTracking
			  , dblLowerToleranceReqQty
			  , intMainItemId
			  , intCategoryId
			  , dblUpperToleranceReqQty
			)
			SELECT ri.intItemId
				 /* dblReqQty */
				 , CASE WHEN C.strCategoryCode = @strPackagingCategory 
					     AND @ysnProducedQtyByWeight = 1 
						 AND P.dblMaxWeightPerPack > 0 
						THEN 
						(
							CASE WHEN ri.ysnScaled = 1 
							     THEN (CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / P.dblMaxWeightPerPack)) 
									 + CASE WHEN ri.ysnPartialFillConsumption = 1 THEN (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / P.dblMaxWeightPerPack))
											ELSE 0
									    END) AS NUMERIC(38, 20)))
								 ELSE CAST(CEILING(ri.dblCalculatedQuantity) AS NUMERIC(38, 20))
							END
						)
						/* Process only take by Category. */
						WHEN C.strCategoryCode = @strPackagingCategory 
						THEN 
						(
							CASE WHEN ri.ysnScaled = 1
								 THEN (CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / r.dblQuantity)) 
									 + CASE WHEN ri.ysnPartialFillConsumption = 1 THEN (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / r.dblQuantity))
											ELSE 0
									   END) AS NUMERIC(38, 20)))
								 ELSE CAST(CEILING(ri.dblCalculatedQuantity) AS NUMERIC(38, 20))
							END
						)
						
						ELSE 
						(
							/* Recipe Item Scaled Type */
							CASE WHEN ri.ysnScaled = 1 
								 THEN (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) 
									/ (CASE WHEN r.intRecipeTypeId = 1 THEN r.dblQuantity 
											ELSE 1
									   END)) 
									+ CASE WHEN ri.ysnPartialFillConsumption = 1 THEN ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / (
														CASE 
															WHEN r.intRecipeTypeId = 1
																THEN r.dblQuantity
															ELSE 1
															END
														)
													)
										ELSE 0
										END
									)
								 ELSE ri.dblCalculatedQuantity
							END
						) END AS RequiredQty
				 , ri.intItemUOMId
				 , ri.intStorageLocationId
				 , ri.intConsumptionMethodId
				 , I.strLotTracking
				 /* dblLowerToleranceReqQty */
				, CASE WHEN C.strCategoryCode = @strPackagingCategory
						AND @ysnProducedQtyByWeight = 1
						AND P.dblMaxWeightPerPack > 0
					   THEN 
					   (
							CASE WHEN ri.ysnScaled = 1
								 THEN (CAST(CEILING((ri.dblCalculatedLowerTolerance * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / P.dblMaxWeightPerPack)) 
									 + CASE WHEN ri.ysnPartialFillConsumption = 1 THEN (ri.dblCalculatedLowerTolerance * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / P.dblMaxWeightPerPack))
											ELSE 0
									   END) AS NUMERIC(38, 20)))
								 ELSE CAST(CEILING(ri.dblCalculatedLowerTolerance) AS NUMERIC(38, 20))
							END
						)
					   /* Compute based on Item Category. */
					   WHEN C.strCategoryCode = @strPackagingCategory
					   THEN 
					   (
							CASE WHEN ri.ysnScaled = 1
								 THEN (CAST(CEILING((ri.dblCalculatedLowerTolerance * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / r.dblQuantity)) 
									 + CASE WHEN ri.ysnPartialFillConsumption = 1 THEN (ri.dblCalculatedLowerTolerance * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / r.dblQuantity))
											ELSE 0
									   END) AS NUMERIC(38, 20)))
								 ELSE CAST(CEILING(ri.dblCalculatedLowerTolerance) AS NUMERIC(38, 20))
							END
					   )						

					   ELSE 
					   (
							/* Recipe Item Scaled Type */
							CASE WHEN ri.ysnScaled = 1
								 THEN (ri.dblCalculatedLowerTolerance * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) 
									/ (
											CASE WHEN r.intRecipeTypeId = 1 THEN r.dblQuantity
												 ELSE 1
											END
									   )) 
									+ CASE WHEN ri.ysnPartialFillConsumption = 1
										   THEN ri.dblCalculatedLowerTolerance * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) 
											 / (
												  CASE WHEN r.intRecipeTypeId = 1 THEN r.dblQuantity
													   ELSE 1
												  END
											   ))
										   ELSE 0
									  END)
								 ELSE ri.dblCalculatedLowerTolerance
							END
					   )
				  END
				, ri.intItemId
				, I.intCategoryId
				/* dblUpperToleranceReqQty */
				, CASE WHEN C.strCategoryCode = @strPackagingCategory
					    AND @ysnProducedQtyByWeight = 1
					    AND P.dblMaxWeightPerPack > 0
					   THEN (CASE 
							WHEN ri.ysnScaled = 1
								THEN (
										CAST(CEILING((ri.dblCalculatedUpperTolerance * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / P.dblMaxWeightPerPack)) + CASE 
													WHEN ri.ysnPartialFillConsumption = 1
														THEN (ri.dblCalculatedUpperTolerance * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / P.dblMaxWeightPerPack))
													ELSE 0
													END) AS NUMERIC(38, 20))
										)
							ELSE CAST(CEILING(ri.dblCalculatedUpperTolerance) AS NUMERIC(38, 20))
							END
						)
					   /* Compute based on Item Category. */
					   WHEN C.strCategoryCode = @strPackagingCategory
					   THEN 
					   (
							CASE WHEN ri.ysnScaled = 1
								 THEN (CAST(CEILING((ri.dblCalculatedUpperTolerance * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / r.dblQuantity)) 
									 + CASE WHEN ri.ysnPartialFillConsumption = 1 THEN (ri.dblCalculatedUpperTolerance * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / r.dblQuantity))
											ELSE 0
									   END) AS NUMERIC(38, 20)))
								 ELSE CAST(CEILING(ri.dblCalculatedUpperTolerance) AS NUMERIC(38, 20))
							END
					   )
					   ELSE 
					   (
							CASE WHEN ri.ysnScaled = 1
								 THEN (ri.dblCalculatedUpperTolerance * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) 
									/ (
											CASE WHEN r.intRecipeTypeId = 1 THEN r.dblQuantity
												 ELSE 1
											END
									  )) 
									+ CASE WHEN ri.ysnPartialFillConsumption = 1 
										   THEN ri.dblCalculatedUpperTolerance * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) 
											  / (
													CASE WHEN r.intRecipeTypeId = 1 THEN r.dblQuantity
														 ELSE 1
													END
												))
											ELSE 0
									  END)
								 ELSE ri.dblCalculatedUpperTolerance
							END
					   )
				  END
			FROM dbo.tblMFWorkOrderRecipeItem ri
			JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId AND r.intWorkOrderId = ri.intWorkOrderId
			JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
			JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
			JOIN dbo.tblICItem P ON r.intItemId = P.intItemId
			WHERE r.intWorkOrderId = @intWorkOrderId 
			  AND ri.intRecipeItemTypeId = 1
			  AND 
			  (
				(
					ri.ysnYearValidationRequired = 1 AND @dtmCurrentDate BETWEEN ri.dtmValidFrom AND ri.dtmValidTo
				)
			  OR 
				(
					ri.ysnYearValidationRequired = 0 AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom) AND DATEPART(dy, ri.dtmValidTo)
				)
			  )
			  AND ri.intConsumptionMethodId <> 4
			  AND NOT EXISTS 
			  (
					SELECT 1
					FROM dbo.tblMFWorkOrderConsumedLot WC
					JOIN dbo.tblMFWorkOrderRecipeSubstituteItem SI ON WC.intWorkOrderId = SI.intWorkOrderId
																  AND WC.intWorkOrderId = @intWorkOrderId
																  AND ISNULL(WC.intBatchId, @intBatchId) = @intBatchId
																  AND WC.intItemId = SI.intSubstituteItemId
																  AND SI.intItemId = ri.intItemId
																  AND ISNULL(WC.ysnPosted, 0) = 0
					UNION
					SELECT 1 
					FROM dbo.tblMFWorkOrderConsumedLot WC
					WHERE WC.intWorkOrderId = @intWorkOrderId
					  AND ISNULL(WC.intBatchId, @intBatchId) = @intBatchId
					  AND WC.intItemId = ri.intItemId
					  AND ISNULL(WC.ysnPosted, 0) = 0
			  )
			UNION
	
			SELECT ri.intItemId
		,(
			CASE 
				WHEN C.strCategoryCode = @strPackagingCategory
					AND @ysnProducedQtyByWeight = 1
					AND P.dblMaxWeightPerPack > 0
					THEN (
							CASE 
								WHEN ri.ysnScaled = 1
									THEN (
											CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / P.dblMaxWeightPerPack)) + CASE 
														WHEN ri.ysnPartialFillConsumption = 1
															THEN (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / P.dblMaxWeightPerPack))
														ELSE 0
														END) AS NUMERIC(38, 20))
											)
								ELSE CAST(CEILING(ri.dblCalculatedQuantity) AS NUMERIC(38, 20))
								END
							)
				WHEN C.strCategoryCode = @strPackagingCategory
					THEN (
							CASE 
								WHEN ri.ysnScaled = 1
									THEN (
											CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / r.dblQuantity)) + CASE 
														WHEN ri.ysnPartialFillConsumption = 1
															THEN (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / r.dblQuantity))
														ELSE 0
														END) AS NUMERIC(38, 20))
											)
								ELSE CAST(CEILING(ri.dblCalculatedQuantity) AS NUMERIC(38, 20))
								END
							)
				ELSE (
						CASE 
							WHEN ri.ysnScaled = 1
								THEN (
										ri.dblCalculatedQuantity * (
											dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / (
												CASE 
													WHEN r.intRecipeTypeId = 1
														THEN r.dblQuantity
													ELSE 1
													END
												)
											) + CASE 
											WHEN ri.ysnPartialFillConsumption = 1
												THEN ri.dblCalculatedQuantity * (
														dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / (
															CASE 
																WHEN r.intRecipeTypeId = 1
																	THEN r.dblQuantity
																ELSE 1
																END
															)
														)
											ELSE 0
											END
										)
							ELSE ri.dblCalculatedQuantity
							END
						)
				END
			) - WC.dblQuantity / rs.dblSubstituteRatio AS RequiredQty
		,IU.intItemUOMId
		,ri.intStorageLocationId
		,ri.intConsumptionMethodId
		,I.strLotTracking
		,(
			CASE 
				WHEN C.strCategoryCode = @strPackagingCategory
					AND @ysnProducedQtyByWeight = 1
					AND P.dblMaxWeightPerPack > 0
					THEN (
							CASE 
								WHEN ri.ysnScaled = 1
									THEN (CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / P.dblMaxWeightPerPack))) + CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / P.dblMaxWeightPerPack))) AS NUMERIC(38, 20)))
								ELSE CAST(CEILING(ri.dblCalculatedQuantity) AS NUMERIC(38, 20))
								END
							)
				WHEN C.strCategoryCode = @strPackagingCategory
					THEN (
							CASE 
								WHEN ri.ysnScaled = 1
									THEN (CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / r.dblQuantity))) + CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / r.dblQuantity))) AS NUMERIC(38, 20)))
								ELSE CAST(CEILING(ri.dblCalculatedQuantity) AS NUMERIC(38, 20))
								END
							)
				ELSE (
						CASE 
							WHEN ri.ysnScaled = 1
								THEN (
										ri.dblCalculatedQuantity * (
											dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / (
												CASE 
													WHEN r.intRecipeTypeId = 1
														THEN r.dblQuantity
													ELSE 1
													END
												)
											) + ri.dblCalculatedQuantity * (
											dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / (
												CASE 
													WHEN r.intRecipeTypeId = 1
														THEN r.dblQuantity
													ELSE 1
													END
												)
											)
										)
							ELSE ri.dblCalculatedQuantity
							END
						)
				END
			) - WC.dblQuantity / rs.dblSubstituteRatio AS RequiredQty
		,ri.intItemId
		,I.intCategoryId
		,(
			CASE 
				WHEN C.strCategoryCode = @strPackagingCategory
					AND @ysnProducedQtyByWeight = 1
					AND P.dblMaxWeightPerPack > 0
					THEN (
							CASE 
								WHEN ri.ysnScaled = 1
									THEN (CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / P.dblMaxWeightPerPack))) + CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / P.dblMaxWeightPerPack))) AS NUMERIC(38, 20)))
								ELSE CAST(CEILING(ri.dblCalculatedQuantity) AS NUMERIC(38, 20))
								END
							)
				WHEN C.strCategoryCode = @strPackagingCategory
					THEN (
							CASE 
								WHEN ri.ysnScaled = 1
									THEN (CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / r.dblQuantity))) + CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / r.dblQuantity))) AS NUMERIC(38, 20)))
								ELSE CAST(CEILING(ri.dblCalculatedQuantity) AS NUMERIC(38, 20))
								END
							)
				ELSE (
						CASE 
							WHEN ri.ysnScaled = 1
								THEN (
										ri.dblCalculatedQuantity * (
											dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / (
												CASE 
													WHEN r.intRecipeTypeId = 1
														THEN r.dblQuantity
													ELSE 1
													END
												)
											) + ri.dblCalculatedQuantity * (
											dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / (
												CASE 
													WHEN r.intRecipeTypeId = 1
														THEN r.dblQuantity
													ELSE 1
													END
												)
											)
										)
							ELSE ri.dblCalculatedQuantity
							END
						)
				END
			) - WC.dblQuantity / rs.dblSubstituteRatio AS RequiredQty
	FROM dbo.tblMFWorkOrderRecipeItem ri
	JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId AND r.intWorkOrderId = ri.intWorkOrderId
	JOIN dbo.tblMFWorkOrderRecipeSubstituteItem rs ON rs.intRecipeItemId = ri.intRecipeItemId
		AND rs.intWorkOrderId = ri.intWorkOrderId
	JOIN dbo.tblMFWorkOrderConsumedLot WC ON WC.intWorkOrderId = rs.intWorkOrderId
		AND IsNull(WC.intBatchId, @intBatchId) = @intBatchId
		AND WC.intItemId = rs.intSubstituteItemId
		AND rs.intItemId = ri.intItemId
	JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
	JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = rs.intItemUOMId
	JOIN dbo.tblICItem P ON r.intItemId = P.intItemId
	WHERE r.intWorkOrderId = @intWorkOrderId
		AND ri.intRecipeItemTypeId = 1
		AND (
			(
				ri.ysnYearValidationRequired = 1
				AND @dtmCurrentDate BETWEEN ri.dtmValidFrom
					AND ri.dtmValidTo
				)
			OR (
				ri.ysnYearValidationRequired = 0
				AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom)
					AND DATEPART(dy, ri.dtmValidTo)
				)
			)
		AND ri.intConsumptionMethodId <> 4
		AND (
			CASE 
				WHEN C.strCategoryCode = @strPackagingCategory
					THEN (CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / P.dblMaxWeightPerPack)))) + (CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / P.dblMaxWeightPerPack))))
				ELSE (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / r.dblQuantity)) + (
						ri.dblCalculatedQuantity * (
							dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / (
								CASE 
									WHEN r.intRecipeTypeId = 1
										THEN r.dblQuantity
									ELSE 1
									END
								)
							)
						)
				END
			) - WC.dblQuantity / rs.dblSubstituteRatio > 0

	IF @strPickPreference = 'Substitute Item'
		AND @ysnConsumptionByRatio = 0
	BEGIN
		INSERT INTO @tblSubstituteItem (
			intItemId
			,intSubstituteItemId
			,dblSubstituteRatio
			,dblMaxSubstituteRatio
			)
		SELECT ri.intItemId
			,rs.intSubstituteItemId
			,dblSubstituteRatio
			,dblMaxSubstituteRatio
		FROM dbo.tblMFWorkOrderRecipeItem ri
		JOIN dbo.tblMFWorkOrderRecipeSubstituteItem rs ON rs.intRecipeItemId = ri.intRecipeItemId
			AND rs.intWorkOrderId = ri.intWorkOrderId
		WHERE ri.intWorkOrderId = @intWorkOrderId
			AND ri.intRecipeItemTypeId = 1
			AND (
				(
					ri.ysnYearValidationRequired = 1
					AND @dtmCurrentDate BETWEEN ri.dtmValidFrom
						AND ri.dtmValidTo
					)
				OR (
					ri.ysnYearValidationRequired = 0
					AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom)
						AND DATEPART(dy, ri.dtmValidTo)
					)
				)
			AND ri.intConsumptionMethodId <> 4
			AND ri.ysnPartialFillConsumption = (
				CASE 
					WHEN @ysnFillPartialPallet = 1
						THEN 1
					ELSE ri.ysnPartialFillConsumption
					END
				)
	END

	IF @ysnConsumptionByRatio = 1
	BEGIN
		DECLARE @tblICItem TABLE (
			intItemId INT
			,intMainItemId INT
			,intItemUOMId INT
			)

		INSERT INTO @tblICItem (
			intItemId
			,intMainItemId
			,intItemUOMId
			)
		SELECT ri.intItemId
			,ri.intItemId
			,ri.intItemUOMId
		FROM dbo.tblMFWorkOrderRecipeItem ri
		JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId
			AND r.intWorkOrderId = ri.intWorkOrderId
		JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
		JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
		JOIN dbo.tblICItem P ON r.intItemId = P.intItemId
		WHERE ri.intWorkOrderId = @intWorkOrderId
			AND (
				(
					ri.ysnYearValidationRequired = 1
					AND @dtmCurrentDate BETWEEN ri.dtmValidFrom
						AND ri.dtmValidTo
					)
				OR (
					ri.ysnYearValidationRequired = 0
					AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom)
						AND DATEPART(dy, ri.dtmValidTo)
					)
				)
			AND ri.intRecipeItemTypeId = 1
			AND ri.intConsumptionMethodId IN (
				1
				,2
				)
		
		UNION
		
		SELECT RSI.intSubstituteItemId
			,RSI.intItemId
			,RSI.intItemUOMId
		FROM dbo.tblMFWorkOrderRecipeItem RI
		JOIN dbo.tblMFWorkOrderRecipeSubstituteItem RSI ON RSI.intRecipeItemId = RI.intRecipeItemId
			AND RI.intWorkOrderId = RSI.intWorkOrderId
		WHERE RI.intWorkOrderId = @intWorkOrderId
			AND (
				(
					RI.ysnYearValidationRequired = 1
					AND @dtmCurrentDate BETWEEN RI.dtmValidFrom
						AND RI.dtmValidTo
					)
				OR (
					RI.ysnYearValidationRequired = 0
					AND @intDayOfYear BETWEEN DATEPART(dy, RI.dtmValidFrom)
						AND DATEPART(dy, RI.dtmValidTo)
					)
				)
			AND RI.intRecipeItemTypeId = 1
			AND RI.intConsumptionMethodId IN (
				1
				,2
				)

		INSERT INTO @tblMFWorkOrderInputItem
		SELECT DISTINCT I.intItemId
			,SUM(IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(WI.intItemUOMId, I.intItemUOMId, WI.dblQuantity), 0)) OVER (PARTITION BY I.intItemId,WI.intMainItemId)
			,I.intItemUOMId
			,(SUM(IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(WI.intItemUOMId, I.intItemUOMId, WI.dblQuantity), 0)) OVER (PARTITION BY I.intItemId,WI.intMainItemId) / SUM(IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(WI.intItemUOMId, I.intItemUOMId, WI.dblQuantity), 0)) OVER (PARTITION BY I.intMainItemId)) * 100
			,I.intMainItemId
		FROM @tblICItem I
		JOIN dbo.tblMFWorkOrderInputLot WI ON WI.intItemId = I.intItemId
			AND WI.intWorkOrderId = @intWorkOrderId
			AND WI.ysnConsumptionReversed = 0
			and I.intMainItemId =WI.intMainItemId 

		DECLARE @tblItem1 TABLE (intItemId INT)

		INSERT INTO @tblItem1 (intItemId)
		SELECT WI.intItemId
		FROM @tblMFWorkOrderInputItem WI
		JOIN @tblItem I ON I.intItemId = WI.intMainItemId
		WHERE NOT EXISTS (
				SELECT *
				FROM @tblItem I2
				WHERE I2.intItemId = WI.intItemId
				)

		INSERT INTO @tblItem (
			intItemId
			,dblReqQty
			,intItemUOMId
			,intStorageLocationId
			,intConsumptionMethodId
			,strLotTracking
			,dblLowerToleranceReqQty
			,intMainItemId
			,intCategoryId
			,dblUpperToleranceReqQty
			)
		SELECT WI.intItemId
			,Round(I.dblReqQty * WI.dblRatio / 100, 2)
			,WI.intItemUOMId
			,I.intStorageLocationId
			,I.intConsumptionMethodId
			,WOLotTrack.strLotTracking
			,Round(I.dblLowerToleranceReqQty * WI.dblRatio / 100, 2)
			,I.intMainItemId
			,I.intCategoryId
			,Round(I.dblUpperToleranceReqQty * WI.dblRatio / 100, 2)
		FROM @tblMFWorkOrderInputItem WI
		JOIN @tblItem I ON I.intItemId = WI.intMainItemId
		OUTER APPLY (SELECT TOP 1 strLotTracking 
					 FROM tblICItem AS ICItem
					 WHERE intItemId = WI.intItemId) AS WOLotTrack
		WHERE NOT EXISTS (
				SELECT *
				FROM @tblItem I2
				WHERE I2.intItemId = WI.intItemId
				)

		UPDATE @tblItem
		SET dblReqQty = Round(dblReqQty * IsNULL(dblRatio, 0) / 100, @intNoOfDecimalPlacesOnConsumption)
			,dblLowerToleranceReqQty = Round(dblLowerToleranceReqQty * IsNULL(dblRatio, 0) / 100, @intNoOfDecimalPlacesOnConsumption)
			,dblUpperToleranceReqQty = Round(dblUpperToleranceReqQty * IsNULL(dblRatio, 0) / 100, @intNoOfDecimalPlacesOnConsumption)
		FROM @tblItem I
		JOIN @tblMFWorkOrderInputItem WI ON WI.intItemId = I.intItemId
		WHERE NOT EXISTS (
				SELECT *
				FROM @tblItem1 I2
				WHERE I2.intItemId = WI.intItemId
				)

		DELETE I
		FROM @tblItem I
		WHERE I.intItemId IN (
				SELECT WI.intMainItemId
				FROM @tblMFWorkOrderInputItem WI
				WHERE WI.intItemId <> WI.intMainItemId
				GROUP BY WI.intMainItemId
				HAVING Round(SUM(dblRatio), 0) = 100
				)
	END

	DELETE
	FROM @tblItem
	WHERE dblReqQty = 0

	SELECT @intItemRecordId = Min(intItemRecordId)
	FROM @tblItem

	WHILE (@intItemRecordId IS NOT NULL)
	BEGIN
		SET @intLotRecordId = NULL

		SELECT @intCategoryId = NULL

		SELECT @dblUpperToleranceReqQty = NULL

		Select @intMainItemId=NULL

		SELECT @intItemId = intItemId
			,@dblReqQty = dblReqQty
			,@intRecipeItemUOMId = intItemUOMId
			,@intStorageLocationId = intStorageLocationId
			,@intConsumptionMethodId = intConsumptionMethodId
			,@strLotTracking = strLotTracking
			,@dblLowerToleranceReqQty = dblLowerToleranceReqQty
			,@dblUpperToleranceReqQty = dblUpperToleranceReqQty
			,@intCategoryId = intCategoryId
			,@intMainItemId=intMainItemId
		FROM @tblItem
		WHERE intItemRecordId = @intItemRecordId

		DELETE
		FROM @tblLot

		DELETE
		FROM @tblMFProductionStageLocation

		IF @intConsumptionMethodId = 1
			AND @intCategoryId = @intPMCategoryId --By Lot
		BEGIN
			INSERT INTO @tblMFProductionStageLocation (intProductionStageLocationId)
			SELECT @intPMStageLocationId
		END
		ELSE IF @intConsumptionMethodId = 1
			AND @intCategoryId <> @intPMCategoryId --By Lot
		BEGIN
			INSERT INTO @tblMFProductionStageLocation (intProductionStageLocationId)
			SELECT intRMProductionStageLocationId
			FROM @tblMFRMProductionStageLocation
		END
		ELSE IF @intConsumptionMethodId = 2 --By Location
		BEGIN
			INSERT INTO @tblMFProductionStageLocation (intProductionStageLocationId)
			SELECT @intStorageLocationId
		END
		ELSE IF @intConsumptionMethodId = 3 --By FIFO
		BEGIN
			INSERT INTO @tblMFProductionStageLocation (intProductionStageLocationId)
			SELECT 0
		END

		IF @strLotTracking = 'No'
		BEGIN
			INSERT INTO @tblLot (
				intItemId
				,dblQty
				,dblIssuedQuantity
				,dblWeightPerUnit
				,intItemUOMId
				,intItemIssuedUOMId
				,ysnSubstituteItem
				,intStorageLocationId
				,intSubLocationId
				)
			SELECT S.intItemId
				,S.dblOnHand - S.dblUnitReserved AS dblQty
				,S.dblOnHand - S.dblUnitReserved AS dblIssuedQuantity
				,1 AS dblWeightPerUnit
				,S.intItemUOMId
				,S.intItemUOMId
				,0 AS ysnSubstituteItem
				,S.intStorageLocationId
				,S.intSubLocationId
			FROM dbo.tblICItemStockUOM S
			JOIN dbo.tblICItemLocation IL ON IL.intItemLocationId = S.intItemLocationId
				AND S.intItemId = @intItemId
				AND S.dblOnHand - S.dblUnitReserved > 0
			JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = S.intItemUOMId
				AND IU.ysnStockUnit = 1
			JOIN dbo.tblICItem I ON I.intItemId = S.intItemId
			WHERE S.intItemId = @intItemId
				AND IL.intLocationId = @intLocationId
				AND EXISTS (
					SELECT *
					FROM @tblMFProductionStageLocation PS
					WHERE PS.intProductionStageLocationId = (
							CASE 
								WHEN @intConsumptionMethodId = 3
									THEN 0
								ELSE S.intStorageLocationId
								END
							)
					)
				AND S.dblOnHand - S.dblUnitReserved > 0
		END
		ELSE
			/* Lot Tracked */
			BEGIN
				/* Substitute Item. */
				IF @strPickPreference = 'Substitute Item' AND @ysnConsumptionByRatio = 0
					BEGIN
						INSERT INTO @tblLot 
						(
							strLotNumber
						  , intLotId
						  , intItemId
						  , dblQty
						  , dblIssuedQuantity
						  , dblWeightPerUnit
						  , intItemUOMId
						  , intItemIssuedUOMId
						  , ysnSubstituteItem
						  , dblSubstituteRatio
						  , dblMaxSubstituteRatio
						  , intStorageLocationId
						  , intSubLocationId
						)
						SELECT L.strLotNumber
							 , L.intLotId
							 , L.intItemId
							 , (CASE WHEN L.intWeightUOMId IS NOT NULL THEN L.dblWeight
									 ELSE L.dblQty
								END) 
								/* Set 0 if Allow Negative is set to True. */
								- CASE WHEN ItemLocation.intAllowNegativeInventory = 1 THEN 0
									   ELSE ISNULL((SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
											   FROM tblICStockReservation SR
											   JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
											   WHERE SR.intLotId = L.intLotId
												 AND SR.intTransactionId <> @intWorkOrderId
												 AND SR.strTransactionId <> @strWorkOrderNo
												 AND ISNULL(ysnPosted, 0) = 0), 0)
								  END
							 , (CASE WHEN L.intWeightUOMId IS NOT NULL THEN L.dblQty
									 ELSE L.dblQty / (ISNULL(NULLIF(L.dblWeightPerQty, 0), 1))	
								END) 
								/* Set 0 if Allow Negative is set to True. */
								- CASE WHEN ItemLocation.intAllowNegativeInventory = 1 THEN 0
									   ELSE ISNULL((SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
											   FROM tblICStockReservation SR
											   JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
											   WHERE SR.intLotId = L.intLotId
												 AND SR.intTransactionId <> @intWorkOrderId
												 AND SR.strTransactionId <> @strWorkOrderNo
												 AND ISNULL(ysnPosted, 0) = 0), 0) / (ISNULL(NULLIF(L.dblWeightPerQty, 0), 1))
								  END
							 , ISNULL(NULLIF(L.dblWeightPerQty, 0), 1)
							 , ISNULL(NULLIF(L.intWeightUOMId, 0), L.intItemUOMId)
							 , L.intItemUOMId
							 , 1 AS ysnSubstituteItem
							 , SI.dblSubstituteRatio
							 , SI.dblMaxSubstituteRatio
							 , L.intStorageLocationId
							 , L.intSubLocationId
						FROM dbo.tblICLot L
						JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId AND SL.ysnAllowConsume = 1 AND L.dblQty > 0
						JOIN dbo.tblICRestriction R ON R.intRestrictionId = ISNULL(SL.intRestrictionId, R.intRestrictionId) AND R.strInternalCode = 'STOCK'
						JOIN @tblSubstituteItem SI ON L.intItemId = SI.intSubstituteItemId AND SI.intItemId = @intItemId
						JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
						JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
						JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1) AND BS.strPrimaryStatus = 'Active'
						JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
						JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
						OUTER APPLY (SELECT TOP 1 ISNULL(intAllowNegativeInventory, 0) AS intAllowNegativeInventory
									 FROM tblICItemLocation ICItemLocation
									 WHERE ICItemLocation.intItemId = @intItemId AND ICItemLocation.intLocationId = @intLocationId) AS ItemLocation
						WHERE SI.intItemId = @intItemId 
						  AND L.intLocationId = @intLocationId
						  AND LS.strPrimaryStatus = 'Active'
						  AND ISNULL(L.dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
						  AND EXISTS 
						  (
								SELECT *
								FROM @tblMFProductionStageLocation PS
								WHERE PS.intProductionStageLocationId = (CASE WHEN @intConsumptionMethodId = 3 THEN 0
																			  ELSE L.intStorageLocationId
																		 END)
						  )
						  AND L.dblQty > 0
						  AND L.strLotNumber IN (SELECT WI.strLotNumber
												 FROM @tblMFWorkOrderInputLot WI)
						ORDER BY CASE WHEN @ysnPickByLotCode = 0 THEN ISNULL(L.dtmManufacturedDate, L.dtmDateCreated)
									  ELSE CONVERT(INT, Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits))
								 END ASC;

					/* End of Substitute Item. */
					END

				INSERT INTO @tblLot 
				(
					strLotNumber
				  , intLotId
				  , intItemId
				  , dblQty
				  , dblIssuedQuantity
				  , dblWeightPerUnit
				  , intItemUOMId
				  , intItemIssuedUOMId
				  , ysnSubstituteItem
				  , intStorageLocationId
				  , intSubLocationId
				)
				SELECT L.strLotNumber
					 , L.intLotId
					 , L.intItemId
					 , (CASE WHEN L.intWeightUOMId IS NOT NULL THEN L.dblWeight
							 ELSE L.dblQty
						END) 
						/* Set 0 if Allow Negative is set to True. */
						- CASE WHEN ItemLocation.intAllowNegativeInventory = 1 THEN 0
							   ELSE ISNULL((SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
											FROM tblICStockReservation SR
											JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
											WHERE SR.intLotId = L.intLotId
											  AND SR.intTransactionId <> @intWorkOrderId
											  AND SR.strTransactionId <> @strWorkOrderNo
											  AND ISNULL(ysnPosted, 0) = 0), 0)
						  END
					 , (CASE WHEN L.intWeightUOMId IS NOT NULL THEN L.dblQty
							 ELSE dblQty / (ISNULL(NULLIF(L.dblWeightPerQty, 0), 1))
						END) 
						/* Set 0 if Allow Negative is set to True. */
						- CASE WHEN ItemLocation.intAllowNegativeInventory = 1 THEN 0
							   ELSE ISNULL((SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
											FROM tblICStockReservation SR
											JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
											WHERE SR.intLotId = L.intLotId
											  AND SR.intTransactionId <> @intWorkOrderId
											  AND SR.strTransactionId <> @strWorkOrderNo
											  AND ISNULL(ysnPosted, 0) = 0), 0) / (ISNULL(NULLIF(L.dblWeightPerQty, 0), 1))
						  END
					 , ISNULL(NULLIF(L.dblWeightPerQty, 0), 1)
					 , ISNULL(NULLIF(L.intWeightUOMId, 0), L.intItemUOMId)
					 , L.intItemUOMId
					 , 0 AS ysnSubstituteItem
					 , L.intStorageLocationId
					 , L.intSubLocationId
				FROM dbo.tblICLot L
				JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId AND SL.ysnAllowConsume = 1 AND L.intItemId = @intItemId AND L.dblQty > 0
				JOIN dbo.tblICRestriction R ON R.intRestrictionId = IsNULL(SL.intRestrictionId, R.intRestrictionId) AND R.strInternalCode = 'STOCK'
				JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
				JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
				JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1) AND BS.strPrimaryStatus = 'Active'
				JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
				JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
				OUTER APPLY (SELECT TOP 1 ISNULL(intAllowNegativeInventory, 0) AS intAllowNegativeInventory
							 FROM tblICItemLocation ICItemLocation
							 WHERE ICItemLocation.intItemId = @intItemId AND ICItemLocation.intLocationId = @intLocationId) AS ItemLocation
				WHERE L.intItemId = @intItemId 
				  AND L.intLocationId = @intLocationId
				  AND LS.strPrimaryStatus = 'Active'
				  AND ISNULL(L.dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
				  AND EXISTS 
				  (
						SELECT *
						FROM @tblMFProductionStageLocation PS
						WHERE PS.intProductionStageLocationId = (CASE WHEN @intConsumptionMethodId = 3 THEN 0
																	  ELSE L.intStorageLocationId
																 END)
				  )
				  AND L.dblQty > 0
				  AND L.strLotNumber IN (SELECT WI.strLotNumber
										 FROM @tblMFWorkOrderInputLot WI)
				  ORDER BY CASE WHEN @ysnPickByLotCode = 0 THEN ISNULL(L.dtmManufacturedDate, L.dtmDateCreated)
								ELSE CONVERT(INT, Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits))
						   END ASC;

				/* Substitute Item. */
				IF @strPickPreference = 'Substitute Item' AND @ysnConsumptionByRatio = 0
					BEGIN
						INSERT INTO @tblLot 
						(
							strLotNumber
						  , intLotId
						  , intItemId
						  , dblQty
						  , dblIssuedQuantity
						  , dblWeightPerUnit
						  , intItemUOMId
						  , intItemIssuedUOMId
						  , ysnSubstituteItem
						  , dblSubstituteRatio
						  , dblMaxSubstituteRatio
						  , intStorageLocationId
						  , intSubLocationId
						)
						SELECT L.strLotNumber
							 , L.intLotId
							 , L.intItemId
							 , (CASE WHEN L.intWeightUOMId IS NOT NULL THEN L.dblWeight
									 ELSE L.dblQty
								END) 
								/* Set 0 if Allow Negative is set to True. */
								- CASE WHEN ItemLocation.intAllowNegativeInventory = 1 THEN 0
									   ELSE ISNULL((SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
													FROM tblICStockReservation SR
													JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
													WHERE SR.intLotId = L.intLotId
													  AND SR.intTransactionId <> @intWorkOrderId
													  AND SR.strTransactionId <> @strWorkOrderNo
													  AND ISNULL(ysnPosted, 0) = 0), 0)
								  END
							 , (CASE WHEN L.intWeightUOMId IS NOT NULL THEN L.dblQty
									 ELSE L.dblQty / (ISNULL(NULLIF(L.dblWeightPerQty, 0), 1))
								END) 
								/* Set 0 if Allow Negative is set to True. */
								- CASE WHEN ItemLocation.intAllowNegativeInventory = 1 THEN 0
									   ELSE ISNULL((SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
													FROM tblICStockReservation SR
													JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
													WHERE SR.intLotId = L.intLotId
													  AND SR.intTransactionId <> @intWorkOrderId
													  AND SR.strTransactionId <> @strWorkOrderNo
													  AND ISNULL(ysnPosted, 0) = 0), 0) / (ISNULL(NULLIF(L.dblWeightPerQty, 0), 1))
								  END
							 , ISNULL(NULLIF(L.dblWeightPerQty, 0), 1)
							 , ISNULL(NULLIF(L.intWeightUOMId, 0), L.intItemUOMId)
							 , L.intItemUOMId
							 , 1 AS ysnSubstituteItem
							 , SI.dblSubstituteRatio
							 , SI.dblMaxSubstituteRatio
							 , L.intStorageLocationId
							 , L.intSubLocationId
						FROM dbo.tblICLot L
						JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId AND SL.ysnAllowConsume = 1 AND L.dblQty > 0
						JOIN dbo.tblICRestriction R ON R.intRestrictionId = ISNULL(SL.intRestrictionId, R.intRestrictionId) AND R.strInternalCode = 'STOCK'
						JOIN @tblSubstituteItem SI ON L.intItemId = SI.intSubstituteItemId AND SI.intItemId = @intItemId
						JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
						JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
						JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1) AND BS.strPrimaryStatus = 'Active'
						JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
						JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
						OUTER APPLY (SELECT TOP 1 ISNULL(intAllowNegativeInventory, 0) AS intAllowNegativeInventory
									 FROM tblICItemLocation ICItemLocation
									 WHERE ICItemLocation.intItemId = @intItemId AND ICItemLocation.intLocationId = @intLocationId) AS ItemLocation
						WHERE SI.intItemId = @intItemId
						  AND L.intLocationId = @intLocationId
						  AND LS.strPrimaryStatus = 'Active'
						  AND ISNULL(L.dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
						  AND EXISTS 
						  ( 
								SELECT *
								FROM @tblMFProductionStageLocation PS
								WHERE PS.intProductionStageLocationId = (CASE WHEN @intConsumptionMethodId = 3 THEN 0
																			  ELSE L.intStorageLocationId
																		 END)
						  )
						  AND L.dblQty > 0
						  AND L.strLotNumber NOT IN (SELECT WI.strLotNumber
													 FROM @tblMFWorkOrderInputLot WI)
						  ORDER BY CASE WHEN @ysnPickByLotCode = 0 THEN ISNULL(L.dtmManufacturedDate, L.dtmDateCreated)
										ELSE CONVERT(INT, Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits))
								   END ASC

					/* End of Substitute Item. */
					END

				INSERT INTO @tblLot 
				(
					strLotNumber
				 , intLotId
				 , intItemId
				 , dblQty
				 , dblIssuedQuantity
				 , dblWeightPerUnit
				 , intItemUOMId
				 , intItemIssuedUOMId
				 , ysnSubstituteItem
				 , intStorageLocationId
				 , intSubLocationId
				)
				SELECT L.strLotNumber
					 , L.intLotId
					 , L.intItemId
					 , (CASE WHEN L.intWeightUOMId IS NOT NULL THEN L.dblWeight
							 ELSE L.dblQty
						END) 
						/* Set 0 if Allow Negative is set to True. */
						- CASE WHEN ItemLocation.intAllowNegativeInventory = 1 THEN 0 
							   ELSE ISNULL((SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
									   FROM tblICStockReservation SR
									   JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
									   WHERE SR.intLotId = L.intLotId
										 AND SR.intTransactionId <> @intWorkOrderId
										 AND SR.strTransactionId <> @strWorkOrderNo
										 AND ISNULL(ysnPosted, 0) = 0), 0)
						  END
					 , (CASE WHEN L.intWeightUOMId IS NOT NULL THEN L.dblQty
							 ELSE L.dblQty / (ISNULL(NULLIF(L.dblWeightPerQty, 0), 1))
						END) 
						/* Set 0 if Allow Negative is set to True. */
						- CASE WHEN ItemLocation.intAllowNegativeInventory = 1 THEN 0 
							   ELSE ISNULL((SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
									   FROM tblICStockReservation SR
									   JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
									   WHERE SR.intLotId = L.intLotId
										 AND SR.intTransactionId <> @intWorkOrderId
										 AND SR.strTransactionId <> @strWorkOrderNo
										 AND ISNULL(ysnPosted, 0) = 0), 0) / (ISNULL(NULLIF(L.dblWeightPerQty, 0), 1))
						  END
					 , ISNULL(NULLIF(L.dblWeightPerQty, 0), 1)
					 , ISNULL(NULLIF(L.intWeightUOMId, 0), L.intItemUOMId)
					 , L.intItemUOMId
					 , 0 AS ysnSubstituteItem
					 , L.intStorageLocationId
					 , L.intSubLocationId
				FROM dbo.tblICLot L
				JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId AND SL.ysnAllowConsume = 1 AND L.intItemId = @intItemId AND L.dblQty > 0
				JOIN dbo.tblICRestriction R ON R.intRestrictionId = IsNULL(SL.intRestrictionId, R.intRestrictionId) AND R.strInternalCode = 'STOCK'
				JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId 
				JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
				JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1) AND BS.strPrimaryStatus = 'Active'
				JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
				JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
				OUTER APPLY (SELECT TOP 1 ISNULL(intAllowNegativeInventory, 0) AS intAllowNegativeInventory
							 FROM tblICItemLocation ICItemLocation
							 WHERE ICItemLocation.intItemId = @intItemId AND ICItemLocation.intLocationId = @intLocationId) AS ItemLocation
				WHERE L.intItemId = @intItemId
				  AND L.intLocationId = @intLocationId
				  AND LS.strPrimaryStatus = 'Active'
				  AND ISNULL(L.dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
				  AND EXISTS 
				  (
						SELECT *
						FROM @tblMFProductionStageLocation PS
						WHERE PS.intProductionStageLocationId = (CASE WHEN @intConsumptionMethodId = 3 THEN 0
																	  ELSE L.intStorageLocationId
																 END)
				  )
				  AND L.dblQty > 0
				  AND L.strLotNumber NOT IN (SELECT WI.strLotNumber
											 FROM @tblMFWorkOrderInputLot WI)
				  ORDER BY CASE WHEN @ysnPickByLotCode = 0 THEN ISNULL(L.dtmManufacturedDate, L.dtmDateCreated)
								ELSE CONVERT(INT, Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits))
				  END ASC

				  /* Check if there's lot and consume excess is true. */
				  IF NOT EXISTS (SELECT * FROM @tblLot) AND @ysnExcessConsumptionAllowed = 1
						BEGIN
							INSERT INTO @tblLot 
							(
								strLotNumber
							  , intLotId
							  , intItemId
							  , dblQty
							  , dblIssuedQuantity
							  , dblWeightPerUnit
							  , intItemUOMId
							  , intItemIssuedUOMId
							  , ysnSubstituteItem
							  , intStorageLocationId
							  , intSubLocationId
							)
							SELECT TOP 1 L.strLotNumber
									   , L.intLotId
									   , L.intItemId
									   , (CASE WHEN L.intWeightUOMId IS NOT NULL THEN L.dblWeight
											   ELSE L.dblQty
										  END) 
										  /* Set 0 if Allow Negative is set to True. */
										  - CASE WHEN ItemLocation.intAllowNegativeInventory = 1 THEN 0 
												 ELSE ISNULL((SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
														 FROM tblICStockReservation SR
														 JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
														 WHERE SR.intLotId = L.intLotId
														   AND SR.intTransactionId <> @intWorkOrderId
														   AND SR.strTransactionId <> @strWorkOrderNo
														   AND ISNULL(ysnPosted, 0) = 0), 0)
											END
									   , (CASE WHEN L.intWeightUOMId IS NOT NULL THEN L.dblQty
											   ELSE L.dblQty / (ISNULL(NULLIF(L.dblWeightPerQty, 0), 1))
										  END) 
										   /* Set 0 if Allow Negative is set to True. */
										  - CASE WHEN ItemLocation.intAllowNegativeInventory = 1 THEN 0 
												 ELSE ISNULL((SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
														 FROM tblICStockReservation SR
														 JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
														 WHERE SR.intLotId = L.intLotId
														   AND SR.intTransactionId <> @intWorkOrderId
														   AND SR.strTransactionId <> @strWorkOrderNo
														   AND ISNULL(ysnPosted, 0) = 0), 0) / (ISNULL(NULLIF(L.dblWeightPerQty, 0), 1))
											END
									   , ISNULL(NULLIF(L.dblWeightPerQty, 0), 1)
									   , ISNULL(NULLIF(L.intWeightUOMId, 0), L.intItemUOMId)
									   , L.intItemUOMId
									   , 0 AS ysnSubstituteItem
									   , L.intStorageLocationId
									   , L.intSubLocationId
							FROM dbo.tblICLot L
							JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId AND SL.ysnAllowConsume = 1 AND L.intItemId = @intItemId AND L.dblQty = 0
							JOIN dbo.tblICRestriction R ON R.intRestrictionId = IsNULL(SL.intRestrictionId, R.intRestrictionId) AND R.strInternalCode = 'STOCK'
							JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
							JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1) AND BS.strPrimaryStatus = 'Active'
							JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
							JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
							OUTER APPLY (SELECT TOP 1 ISNULL(intAllowNegativeInventory, 0) AS intAllowNegativeInventory
										 FROM tblICItemLocation ICItemLocation
										 WHERE ICItemLocation.intItemId = @intItemId AND ICItemLocation.intLocationId = @intLocationId) AS ItemLocation
							WHERE L.intItemId = @intItemId AND L.intLocationId = @intLocationId
							  AND LS.strPrimaryStatus = 'Active'
							  AND ISNULL(L.dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
							  AND EXISTS 
							  (
									SELECT *
									FROM @tblMFProductionStageLocation PS
									WHERE PS.intProductionStageLocationId = (CASE WHEN @intConsumptionMethodId = 3 THEN 0
																				  ELSE L.intStorageLocationId
																			 END)
							  )
							  AND L.dblQty = 0
							  ORDER BY IsNULL(L.dtmManufacturedDate, L.dtmDateCreated) DESC

							  /* Check if there's lot staged. */
							  IF EXISTS (SELECT * FROM @tblLot)
									BEGIN
										SELECT @strLotNumber			= strLotNumber
											 , @intWeightUOMId			= intItemUOMId
											 , @dblWeightPerQty			= dblWeightPerUnit
											 , @intStorageLocationId1	= intStorageLocationId
											 , @intItemIssuedUOMId		= intItemIssuedUOMId
										FROM @tblLot

										SELECT @dblAdjustByQuantity = [dbo].[fnMFConvertQuantityToTargetItemUOM](@intRecipeItemUOMId, @intWeightUOMId, @dblReqQty)

										/* Retrieve Storage Location . */
										IF @intConsumptionMethodId = 2
											BEGIN
												SELECT @intSubLocationId = intSubLocationId
												FROM tblICStorageLocation
												WHERE intStorageLocationId = @intStorageLocationId
											END
										ELSE
											BEGIN
												SELECT @intStorageLocationId	= intStorageLocationId
													 , @intSubLocationId		= intSubLocationId
												FROM tblICLot
												WHERE strLotNumber = @strLotNumber AND intStorageLocationId = @intStorageLocationId1
											
											/* End of Retrieve Storage Location . */
											END

										SELECT @dblAdjustByQuantity = @dblAdjustByQuantity / (CASE WHEN @intWeightUOMId IS NULL THEN 1
																								   ELSE @dblWeightPerQty
																							  END)
					
										EXEC [uspICInventoryAdjustment_CreatePostQtyChange] @intItemId					= @intItemId
																						  , @dtmDate					= @dtmCurrentDateTime
																						  , @intLocationId				= @intLocationId
																						  , @intSubLocationId			= @intSubLocationId
																						  , @intStorageLocationId		= @intStorageLocationId
																						  , @strLotNumber				= @strLotNumber
																						  /* New Values */
																						  , @dblAdjustByQuantity		= @dblAdjustByQuantity
																						  , @dblNewUnitCost				= NULL
																						  , @intItemUOMId				= @intItemIssuedUOMId
																						  /* Parameters used for linking or FK Relationship*/
																						  , @intSourceId				= 1
																						  , @intSourceTransactionTypeId = 8
																						  , @intEntityUserSecurityId	= @intUserId
																						  , @intInventoryAdjustmentId	= @intInventoryAdjustmentId OUTPUT

										UPDATE @tblLot
										SET dblQty				= dblQty + (@dblAdjustByQuantity *  ISNULL(NULLIF(@dblWeightPerQty, 0), 1))
										  , dblIssuedQuantity	= dblIssuedQuantity + @dblAdjustByQuantity

								/* End of Check if there's lot staged. */
								END

						/* End of Check if there's lot and consume excess is true. */
						END

			IF NOT EXISTS (SELECT * FROM @tblLot) AND @ysnExcessConsumptionAllowed = 1
				/* Stage Lot starts here. */
				BEGIN
					DECLARE @ItemsThatNeedLotId AS dbo.ItemLotTableType

					IF OBJECT_ID('tempdb..#GeneratedLotItems') IS NOT NULL
						BEGIN
							DROP TABLE #GeneratedLotItems
						END

					CREATE TABLE #GeneratedLotItems 
					(
						intLotId			INT
					  , strLotNumber		NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
					  , intDetailId			INT
					  , intParentLotId		INT
					  , strParentLotNumber	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
					);

					/* Create and validate the lot numbers. */
					SELECT @strLifeTimeType		= strLifeTimeType
						 , @intLifeTime			= intLifeTime
						 , @strLotTracking		= strLotTracking
						 , @intCategoryId		= intCategoryId
					FROM dbo.tblICItem
					WHERE intItemId = @intItemId;

					SELECT @intItemUOMId = intItemUOMId
					FROM tblICItemUOM
					WHERE ysnStockUnit = 1 AND intItemId = @intItemId;

					IF @strLifeTimeType = 'Years'
						BEGIN
							SET @dtmExpiryDate = DATEADD(yy, @intLifeTime, @dtmCurrentDateTime);
						END
					ELSE IF @strLifeTimeType = 'Months' AND @ysnLifeTimeByEndOfMonth = 0
						BEGIN
							SET @dtmExpiryDate = DATEADD(mm, @intLifeTime, @dtmCurrentDateTime);
						END
					ELSE IF @strLifeTimeType = 'Months' AND @ysnLifeTimeByEndOfMonth = 1
						BEGIN
							SET @dtmExpiryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, DATEADD(mm, @intLifeTime, @dtmCurrentDateTime)) + 1, 0));
						END
					ELSE IF @strLifeTimeType = 'Days'
						BEGIN
							SET @dtmExpiryDate = DATEADD(dd, @intLifeTime, @dtmCurrentDateTime);
						END
					ELSE IF @strLifeTimeType = 'Hours'
						BEGIN
							SET @dtmExpiryDate = DATEADD(hh, @intLifeTime, @dtmCurrentDateTime);
						END
					ELSE IF @strLifeTimeType = 'Minutes'
						BEGIN
							SET @dtmExpiryDate = DATEADD(mi, @intLifeTime, @dtmCurrentDateTime);
						END
					ELSE
						BEGIN
							SET @dtmExpiryDate = DATEADD(yy, 1, @dtmCurrentDateTime);
						END

					SELECT @intItemLocationId = intItemLocationId
					FROM dbo.tblICItemLocation
					WHERE intItemId = @intItemId;

					/* Create and validate the lot numbers. */
					IF @strLotTracking <> 'Yes - Serial Number'
						BEGIN
							SELECT @intSubLocationId = @intSubLocationId
							FROM dbo.tblICStorageLocation
							WHERE intStorageLocationId = @intStorageLocationId

							EXEC dbo.uspMFGeneratePatternId @intCategoryId			= @intCategoryId
														  , @intItemId				= @intItemId
														  , @intManufacturingId		= @intManufacturingCellId
														  , @intSubLocationId		= @intSubLocationId
														  , @intLocationId			= @intLocationId
														  , @intOrderTypeId			= NULL
														  , @intBlendRequirementId	= NULL
														  , @intPatternCode			= 24
														  , @ysnProposed			= 0
														  , @strPatternString		= @strLotNumber OUTPUT
														  , @intShiftId				= @intBusinessShiftId
						END

					/* Retrieve Storage Location. */
					IF @intConsumptionMethodId = 2
						/* Consume [By Location] */
						BEGIN
							SELECT @intSubLocationId = intSubLocationId
							FROM tblICStorageLocation
							WHERE intStorageLocationId = @intStorageLocationId
						END
					ELSE
						BEGIN
							SELECT @intStorageLocationId = intNewLotBin
							FROM tblSMCompanyLocationSubLocation
							WHERE intCompanyLocationId = @intLocationId

							SELECT @intSubLocationId = intSubLocationId
							FROM tblICStorageLocation
							WHERE intStorageLocationId = @intStorageLocationId
						END
					/* End of Retrieve Storage Location. */

					/* Staging Lot */
					INSERT INTO @ItemsThatNeedLotId 
					(
						intLotId
					  , strLotNumber
					  , strLotAlias
					  , intItemId
					  , intItemLocationId
					  , intSubLocationId
					  , intStorageLocationId
					  , dblQty
					  , intItemUOMId
					  , dblWeight
					  , intWeightUOMId
					  , dtmExpiryDate
					  , dtmManufacturedDate
					  , intOriginId
					  , intGradeId
					  , strBOLNo
					  , strVessel
					  , strReceiptNumber
					  , strMarkings
					  , strNotes
					  , intEntityVendorId
					  , strVendorLotNo
					  , strGarden
					  , intDetailId
					  , ysnProduced
					  , strTransactionId
					  , strSourceTransactionId
					  , intSourceTransactionTypeId
					)
					SELECT intLotId						= NULL
						 , strLotNumber					= @strLotNumber
						 , strLotAlias					= NULL
						 , intItemId					= @intItemId
						 , intItemLocationId			= @intItemLocationId
						 , intSubLocationId				= @intSubLocationId
						 , intStorageLocationId			= @intStorageLocationId
						 , dblQty						= [dbo].[fnMFConvertQuantityToTargetItemUOM](@intRecipeItemUOMId, @intItemUOMId, @dblReqQty)
						 , intItemUOMId					= @intItemUOMId
						 , dblWeight					= NULL
						 , intWeightUOMId				= NULL
						 , dtmExpiryDate				= @dtmExpiryDate
						 , dtmManufacturedDate			= @dtmCurrentDateTime
						 , intOriginId					= NULL
						 , intGradeId					= NULL
						 , strBOLNo						= NULL
						 , strVessel					= NULL
						 , strReceiptNumber				= NULL
						 , strMarkings					= NULL
						 , strNotes						= NULL
						 , intEntityVendorId			= NULL
						 , strVendorLotNo				= NULL
						 , strGarden					= NULL
						 , intDetailId					= @intWorkOrderId
						 , ysnProduced					= 1
						 , strTransactionId				= @strWorkOrderNo
						 , strSourceTransactionId		= @strWorkOrderNo
						 , intSourceTransactionTypeId	= 8

					/* Create Lot. */
					EXEC dbo.uspICCreateUpdateLotNumber @ItemsThatNeedLotId
													  , @intUserId

					SELECT TOP 1 @intLotId = intLotId
					FROM #GeneratedLotItems
					WHERE intDetailId = @intWorkOrderId

					INSERT INTO @tblLot 
					(
						strLotNumber
					  , intLotId
					  , intItemId
					  , dblQty
					  , dblIssuedQuantity
					  , dblWeightPerUnit
					  , intItemUOMId
					  , intItemIssuedUOMId
					  , ysnSubstituteItem
					  , intStorageLocationId
					  , intSubLocationId
					)
					SELECT L.strLotNumber
						 , L.intLotId
						 , L.intItemId
						 /* dblQty */
						 , (CASE WHEN L.intWeightUOMId IS NOT NULL THEN L.dblWeight
								 ELSE L.dblQty
							END)
						 , (CASE WHEN L.intWeightUOMId IS NOT NULL THEN L.dblQty
								 ELSE L.dblQty / (
													CASE WHEN L.dblWeightPerQty = 0 OR L.dblWeightPerQty IS NULL THEN 1
														 ELSE L.dblWeightPerQty
													END
												 )
							END)
						 , ISNULL(NULLIF(L.dblWeightPerQty, 0), 1)
						 , ISNULL(NULLIF(L.intWeightUOMId, 0), L.intItemUOMId)
						 , L.intItemUOMId
						 , 0 AS ysnSubstituteItem
						 , L.intStorageLocationId
						 , L.intSubLocationId
					FROM dbo.tblICLot L
					JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
													AND SL.ysnAllowConsume		= 1
													AND L.intItemId				= @intItemId
													AND L.dblQty				> 0
					JOIN dbo.tblICRestriction R ON R.intRestrictionId = ISNULL(SL.intRestrictionId, R.intRestrictionId) AND R.strInternalCode = 'STOCK'
					JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
					JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
					JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1) AND BS.strPrimaryStatus = 'Active'
					JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
					JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
					WHERE L.intItemId = @intItemId
					  AND L.intLocationId = @intLocationId
					  AND LS.strPrimaryStatus = 'Active'
					  AND ISNULL(L.dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
					  AND EXISTS 
						  (
							SELECT *
							FROM @tblMFProductionStageLocation PS
							WHERE PS.intProductionStageLocationId = (CASE WHEN @intConsumptionMethodId = 3 THEN 0
																		  ELSE L.intStorageLocationId
																	 END)
						  )
					  AND L.dblQty > 0
					ORDER BY CASE WHEN @ysnPickByLotCode = 0 THEN ISNULL(L.dtmManufacturedDate, L.dtmDateCreated)
								  ELSE CONVERT(INT, Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits))
							 END ASC

				/* End of Stage Lot starts here. */
				END
			END

			IF (@strCycleCountbasedonRecipeTolerance = 'True' OR @strInstantConsumption = 'True') 
				AND EXISTS (SELECT SUM([dbo].[fnMFConvertQuantityToTargetItemUOM](intItemUOMId, @intRecipeItemUOMId, dblQty))
							FROM @tblLot L
							HAVING SUM([dbo].[fnMFConvertQuantityToTargetItemUOM](intItemUOMId, @intRecipeItemUOMId, dblQty)) < @dblLowerToleranceReqQty)
				BEGIN
					/* Validation of enough stock for Required Quantity */
					IF @ysnExcessConsumptionAllowed = 0
						BEGIN
							DECLARE @intUnitMeasureId		INT
								  , @strUnitMeasure			NVARCHAR(50)
								  , @intLotUnitMeasureId	INT
								  , @strLotUnitMeasure		NVARCHAR(50)
								  , @intLotItemUOMId		INT

							SELECT @strQty = CONVERT(DECIMAL(24, 4), SUM([dbo].[fnMFConvertQuantityToTargetItemUOM](intItemUOMId, @intRecipeItemUOMId, dblQty)))
							FROM @tblLot

							SELECT @strReqQty = CONVERT(DECIMAL(24, 4), @dblReqQty)

							SELECT @strItemNo = strItemNo
							FROM dbo.tblICItem
							WHERE intItemId = @intItemId

							SELECT @intUnitMeasureId = intUnitMeasureId
							FROM dbo.tblICItemUOM
							WHERE intItemUOMId = @intRecipeItemUOMId

							SELECT @strUnitMeasure = ' ' + strUnitMeasure
							FROM dbo.tblICUnitMeasure
							WHERE intUnitMeasureId = @intUnitMeasureId

							RAISERROR 
							(
								'Item %s is having %s%s quantity which is less than the required quantity %s%s.'
							   , 11
							   , 1
							   , @strItemNo
							   , @strQty
							   , @strUnitMeasure
							   , @strReqQty
							   , @strUnitMeasure
							)
						END
				END

				SELECT @intLotRecordId = Min(intLotRecordId)
				FROM @tblLot
				WHERE dblQty > 0

				WHILE (@intLotRecordId IS NOT NULL)
					/* Second Loop Start. */
					BEGIN
						SELECT @intLotId				= NULL
							 , @intLotItemId			= NULL
							 , @dblQty					= NULL
							 , @ysnSubstituteItem		= NULL
							 , @dblMaxSubstituteRatio	= NULL
							 , @dblSubstituteRatio		= NULL
							 , @intItemUOMId			= NULL
							 , @intItemIssuedUOMId		= NULL
							 , @intStageLocationId		= NULL

						SELECT @intLotId = intLotId
							,@intLotItemId = intItemId
							,@dblQty = dblQty
							,@ysnSubstituteItem = ysnSubstituteItem
							,@dblMaxSubstituteRatio = dblMaxSubstituteRatio
							,@dblSubstituteRatio = dblSubstituteRatio
							,@intItemUOMId = intItemUOMId
							,@intItemIssuedUOMId = intItemIssuedUOMId
							,@intStageLocationId = intStorageLocationId
						FROM @tblLot
						WHERE intLotRecordId = @intLotRecordId

						IF @ysnSubstituteItem = 1 AND @ysnConsumptionByRatio = 0
							BEGIN
								SELECT @dblReqQty = @dblReqQty * (@dblMaxSubstituteRatio / 100) * @dblSubstituteRatio

								SELECT @intUnitMeasureId = intUnitMeasureId
								FROM tblICItemUOM
								WHERE intItemUOMId = @intRecipeItemUOMId

								SELECT @intRecipeItemUOMId = intItemUOMId
								FROM tblICItemUOM
								WHERE intItemId = @intLotItemId AND intUnitMeasureId = @intUnitMeasureId
							END

						IF EXISTS (SELECT SUM(dblQty)
								   FROM @tblLot 
								   HAVING SUM(dblQty) < 
								   (
										CASE WHEN @ysnSubstituteItem = 0 THEN [dbo].[fnMFConvertQuantityToTargetItemUOM](@intRecipeItemUOMId, MIN(intItemUOMId), @dblLowerToleranceReqQty)
											 ELSE @dblLowerToleranceReqQty
										END)
								   )
							BEGIN
								IF @ysnExcessConsumptionAllowed = 1
									BEGIN
										SELECT @dblAdjustByQuantity = [dbo].[fnMFConvertQuantityToTargetItemUOM](@intRecipeItemUOMId, MIN(intItemUOMId), @dblReqQty) - SUM(dblQty)
										FROM @tblLot

										SELECT @strLotNumber	= strLotNumber
											 , @intWeightUOMId	= intItemUOMId
											 , @dblWeightPerQty = dblWeightPerUnit
										FROM @tblLot

										IF @intConsumptionMethodId = 2
											BEGIN
												SELECT @intSubLocationId = intSubLocationId
												FROM tblICStorageLocation
												WHERE intStorageLocationId = @intStorageLocationId
											END
										ELSE
											BEGIN
												SELECT @intStorageLocationId = intStorageLocationId
													,@intSubLocationId = intSubLocationId
												FROM tblICLot
												WHERE strLotNumber = @strLotNumber
											END

										/* Consume [By Location]. */
										SET @dblAdjustByQuantity = @dblAdjustByQuantity / (CASE WHEN @intWeightUOMId IS NULL THEN 1 
																								ELSE @dblWeightPerQty
																						   END);
										
										EXEC [uspICInventoryAdjustment_CreatePostQtyChange] @intItemId					= @intLotItemId
																						  , @dtmDate					= @dtmCurrentDateTime
																						  , @intLocationId				= @intLocationId
																						  , @intSubLocationId			= @intSubLocationId
																						  , @intStorageLocationId		= @intStorageLocationId
																						  , @strLotNumber				= @strLotNumber
																						  /* New Values. */
																						  , @dblAdjustByQuantity		= @dblAdjustByQuantity
																						  , @dblNewUnitCost				= NULL
																						  , @intItemUOMId				= @intItemIssuedUOMId
																						  /* Value for linking or FK (foreign key) relationships*/
																						  , @intSourceId				= 1
																						  , @intSourceTransactionTypeId = 8
																						  , @intEntityUserSecurityId	= @intUserId
																						  , @intInventoryAdjustmentId	= @intInventoryAdjustmentId OUTPUT

										SELECT @dblQty = @dblQty + @dblAdjustByQuantity * (CASE WHEN @dblWeightPerQty IS NULL OR @dblWeightPerQty = 0 THEN 1
																								ELSE @dblWeightPerQty
																						   END)
									END
							END

						SELECT @intSequenceNo = Max(intSequenceNo) + 1
						FROM dbo.tblMFWorkOrderConsumedLot
						WHERE intWorkOrderId = @intWorkOrderId

						IF (@dblQty >= [dbo].[fnMFConvertQuantityToTargetItemUOM](@intRecipeItemUOMId, @intItemUOMId, @dblReqQty))
							BEGIN
								INSERT INTO dbo.tblMFWorkOrderConsumedLot 
								(
									intWorkOrderId
								  , intItemId
								  , intLotId
								  , dblQuantity
								  , intItemUOMId
								  , dblIssuedQuantity
								  , intItemIssuedUOMId
								  , intBatchId
								  , intSequenceNo
								  , dtmCreated
								  , intCreatedUserId
								  , dtmLastModified
								  , intLastModifiedUserId
								  , intShiftId
								  , dtmActualInputDateTime
								  , intStorageLocationId
								  , intSubLocationId
							   )
							   SELECT @intWorkOrderId
									, @intLotItemId
									, intLotId
									, [dbo].[fnMFConvertQuantityToTargetItemUOM](@intRecipeItemUOMId, @intItemUOMId, @dblReqQty)
									, intItemUOMId
									, [dbo].[fnMFConvertQuantityToTargetItemUOM](@intRecipeItemUOMId, @intItemUOMId, @dblReqQty) 
									  / (CASE WHEN dblWeightPerUnit = 0 OR dblWeightPerUnit IS NULL THEN 1
											  ELSE dblWeightPerUnit
										 END
										)		
									, intItemIssuedUOMId
									, @intBatchId
									, ISNULL(@intSequenceNo, 1)
									, @dtmCurrentDateTime
									, @intUserId
									, @dtmCurrentDateTime
									, @intUserId
									, @intBusinessShiftId
									, @dtmBusinessDate
									, intStorageLocationId
									, intSubLocationId
							   FROM @tblLot
							   WHERE intLotRecordId = @intLotRecordId

							   SELECT @intWorkOrderConsumedLotId = SCOPE_IDENTITY();

							   SELECT @dblPhysicalCount = [dbo].[fnMFConvertQuantityToTargetItemUOM](@intRecipeItemUOMId, @intItemUOMId, @dblReqQty)

							   EXEC dbo.uspMFAdjustInventory @dtmDate					= @dtmCurrentDateTime
														   , @intTransactionTypeId		= 8
														   , @intItemId					= @intItemId
														   , @intSourceLotId			= @intLotId
														   , @intDestinationLotId		= NULL
														   , @dblQty					= @dblPhysicalCount
														   , @intItemUOMId				= @intItemUOMId
														   , @intOldItemId				= NULL
														   , @dtmOldExpiryDate			= NULL
														   , @dtmNewExpiryDate			= NULL
														   , @intOldLotStatusId			= NULL
														   , @intNewLotStatusId			= NULL
														   , @intUserId					= @intUserId
														   , @strNote					= NULL
														   , @strReason					= NULL
														   , @intLocationId				= @intLocationId
														   , @intInventoryAdjustmentId	= NULL
														   , @intStorageLocationId		= @intStageLocationId
														   , @intDestinationStorageLocationId = NULL
														   , @intWorkOrderInputLotId	= NULL
														   , @intWorkOrderProducedLotId = NULL
														   , @intWorkOrderId			= @intWorkOrderId
														   , @intWorkOrderConsumedLotId = @intWorkOrderConsumedLotId

							   /* Create Production Summary/Cycle Count if not exists. */
							   IF NOT EXISTS (SELECT * 
											  FROM tblMFProductionSummary 
											  WHERE intWorkOrderId = @intWorkOrderId
												AND intItemId = @intLotItemId
												AND ISNULL(intMachineId, 0) = CASE WHEN intMachineId IS NOT NULL THEN IsNULL(@intMachineId, 0)
																				   ELSE ISNULL(intMachineId, 0)
																			  END
												AND intItemTypeId IN (1, 3)
												AND ISNULL(intMainItemId, @intMainItemId) = @intMainItemId)
									BEGIN
										SELECT @intCategoryId = intCategoryId
										FROM tblICItem
										WHERE intItemId = @intLotItemId

										INSERT INTO tblMFProductionSummary 
										(
											intWorkOrderId
										  , intItemId
										  , dblOpeningQuantity
										  , dblOpeningOutputQuantity
										  , dblOpeningConversionQuantity
										  , dblInputQuantity
										  , dblConsumedQuantity
										  , dblOutputQuantity
										  , dblOutputConversionQuantity
										  , dblCountQuantity
										  , dblCountOutputQuantity
										  , dblCountConversionQuantity
										  , dblCalculatedQuantity
										  , intCategoryId
										  , intItemTypeId
										  , intMachineId
										  , intStageLocationId
										  , dblUpperToleranceQty
										  , dblLowerToleranceQty
										  , intMainItemId
										)
										SELECT @intWorkOrderId
											 , @intLotItemId
											 , 0
											 , 0
											 , 0
											 , 0
											 , @dblReqQty
											 , 0
											 , 0
											 , 0
											 , 0
											 , 0
											 , 0
											 , @intCategoryId
											 , CASE WHEN @ysnSubstituteItem = 1 THEN 3
													ELSE 1
											   END
											 , @intMachineId
											 , @intStageLocationId
											 , Round(@dblUpperToleranceReqQty,@intNoOfDecimalPlacesOnConsumption)
											 , Round(@dblLowerToleranceReqQty,@intNoOfDecimalPlacesOnConsumption)
											 , @intMainItemId

									/* End of Create Production Summary/Cycle Count if not exists. */
									END
								ELSE
									/* Update Production Summary/Cycle Count if exists. */
									BEGIN
										UPDATE tblMFProductionSummary
										SET dblConsumedQuantity		= dblConsumedQuantity + @dblReqQty
										  , intStageLocationId		= @intStageLocationId
										  , dblUpperToleranceQty	= Round(@dblUpperToleranceReqQty, @intNoOfDecimalPlacesOnConsumption)
										  , dblLowerToleranceQty	= Round(@dblLowerToleranceReqQty, @intNoOfDecimalPlacesOnConsumption)
										WHERE intWorkOrderId = @intWorkOrderId
											AND intItemId = @intLotItemId
											AND ISNULL(intMachineId, 0) = CASE WHEN intMachineId IS NOT NULL THEN IsNULL(@intMachineId, 0)
																			   ELSE ISNULL(intMachineId, 0)
																		  END
											AND intItemTypeId IN (1, 3)
											AND ISNULL(intMainItemId, @intMainItemId)=@intMainItemId;

									/* End of Update Production Summary/Cycle Count if exists. */
									END

								UPDATE @tblLot
								SET dblQty = dblQty - [dbo].[fnMFConvertQuantityToTargetItemUOM](@intRecipeItemUOMId, @intItemUOMId, @dblReqQty)
								WHERE intLotRecordId = @intLotRecordId

								IF @ysnSubstituteItem = 1 AND @dblMaxSubstituteRatio <> 100 AND @ysnConsumptionByRatio = 0
									BEGIN
										SELECT @dblReqQty = (@dblReqQty / @dblSubstituteRatio * 100 / @dblMaxSubstituteRatio) * (100 - @dblMaxSubstituteRatio) / 100

										SELECT @dblLowerToleranceReqQty = (@dblLowerToleranceReqQty / @dblSubstituteRatio * 100 / @dblMaxSubstituteRatio) * (100 - @dblMaxSubstituteRatio) / 100
									END
								ELSE
									BEGIN
										GOTO NextItem
									END
						END
					ELSE
						BEGIN
							INSERT INTO dbo.tblMFWorkOrderConsumedLot 
							(
								intWorkOrderId
							  , intItemId
							  , intLotId
							  , dblQuantity
							  , intItemUOMId
							  , dblIssuedQuantity
							  , intItemIssuedUOMId
							  , intBatchId
							  , intSequenceNo
							  , dtmCreated
							  , intCreatedUserId
							  , dtmLastModified
							  , intLastModifiedUserId
							  , intShiftId
							  , dtmActualInputDateTime
							  , intStorageLocationId
							  , intSubLocationId
							)
							SELECT @intWorkOrderId
								 , @intLotItemId
								 , intLotId
								 , @dblQty
								 , intItemUOMId
								 , @dblQty / (CASE WHEN dblWeightPerUnit = 0 OR dblWeightPerUnit IS NULL THEN 1
												   ELSE dblWeightPerUnit
											  END)
								 , intItemIssuedUOMId
								 , @intBatchId
								 , ISNULL(@intSequenceNo, 1)
								 , @dtmCurrentDateTime
								 , @intUserId
								 , @dtmCurrentDateTime
								 , @intUserId
								 , @intBusinessShiftId
								 , @dtmBusinessDate
								 , intStorageLocationId
								 , intSubLocationId
							FROM @tblLot
							WHERE intLotRecordId = @intLotRecordId

							SELECT @intWorkOrderConsumedLotId = SCOPE_IDENTITY();

							SELECT @dblPhysicalCount = [dbo].[fnMFConvertQuantityToTargetItemUOM](@intRecipeItemUOMId, @intItemUOMId, @dblReqQty);

							EXEC dbo.uspMFAdjustInventory @dtmDate						= @dtmCurrentDateTime
														, @intTransactionTypeId			= 8
														, @intItemId					= @intItemId
														, @intSourceLotId				= @intLotId
														, @intDestinationLotId			= NULL
														, @dblQty						= @dblQty
														, @intItemUOMId					= @intItemUOMId
														, @intOldItemId					= NULL
														, @dtmOldExpiryDate				= NULL
														, @dtmNewExpiryDate				= NULL
														, @intOldLotStatusId			= NULL
														, @intNewLotStatusId			= NULL
														, @intUserId					= @intUserId
														, @strNote						= NULL
														, @strReason					= NULL
														, @intLocationId				= @intLocationId
														, @intInventoryAdjustmentId		= NULL
														, @intStorageLocationId			= @intStageLocationId
														, @intDestinationStorageLocationId = NULL
														, @intWorkOrderInputLotId		= NULL
														, @intWorkOrderProducedLotId	= NULL
														, @intWorkOrderId				= @intWorkOrderId
														, @intWorkOrderConsumedLotId	= @intWorkOrderConsumedLotId

							/* Create Production Summary/Cycle Count if not exists. */
							IF NOT EXISTS (SELECT *
										   FROM tblMFProductionSummary
										   WHERE intWorkOrderId = @intWorkOrderId
											 AND intItemId = @intLotItemId
											 AND ISNULL(intMachineId, 0) = CASE WHEN intMachineId IS NOT NULL THEN ISNULL(@intMachineId, 0)
																				ELSE IsNULL(intMachineId, 0)
																		   END
											 AND intItemTypeId IN (1, 3)
											 AND ISNULL(intMainItemId, @intMainItemId) = @intMainItemId)
								BEGIN
									SELECT @intCategoryId = intCategoryId
									FROM tblICItem
									WHERE intItemId = @intLotItemId;

									INSERT INTO tblMFProductionSummary 
									(
										intWorkOrderId
									  , intItemId
									  , dblOpeningQuantity
									  , dblOpeningOutputQuantity
									  , dblOpeningConversionQuantity
									  , dblInputQuantity
									  , dblConsumedQuantity
									  , dblOutputQuantity
									  , dblOutputConversionQuantity
									  , dblCountQuantity
									  , dblCountOutputQuantity
									  , dblCountConversionQuantity
									  , dblCalculatedQuantity
									  , intCategoryId
									  , intItemTypeId
									  , intMachineId
									  , intStageLocationId
									  , intMainItemId
									)
									SELECT @intWorkOrderId
										 , @intLotItemId
										 , 0
										 , 0
										 , 0
										 , 0
										 , [dbo].[fnMFConvertQuantityToTargetItemUOM](@intItemUOMId, @intRecipeItemUOMId, @dblQty)
										 , 0
										 , 0
										 , 0
										 , 0
										 , 0
										 , 0
										 , @intCategoryId
										 , CASE WHEN @ysnSubstituteItem = 1 THEN 3
										  	  ELSE 1
										   END
										 , @intMachineId
										 , @intStageLocationId
										 , @intMainItemId

								/* End of Create Production Summary/Cycle Count if not exists. */
								END
							ELSE
								/* Update Production Summary/Cycle Count if exists. */
								BEGIN
									UPDATE tblMFProductionSummary
									SET dblConsumedQuantity = dblConsumedQuantity + [dbo].[fnMFConvertQuantityToTargetItemUOM](@intItemUOMId, @intRecipeItemUOMId, @dblQty)
									  , intStageLocationId	= @intStageLocationId
									WHERE intWorkOrderId = @intWorkOrderId
									  AND intItemId = @intLotItemId
									  AND ISNULL(intMachineId, 0) = CASE WHEN intMachineId IS NOT NULL THEN ISNULL(@intMachineId, 0)
																		 ELSE ISNULL(intMachineId, 0)
																	END
									  AND intItemTypeId IN (1, 3)
									  AND ISNULL(intMainItemId, @intMainItemId) = @intMainItemId

								/* End of Update Production Summary/Cycle Count if exists. */
								END

							UPDATE @tblLot
							SET dblQty = 0
							WHERE intLotRecordId = @intLotRecordId

							IF @ysnSubstituteItem = 1 AND @ysnConsumptionByRatio = 0
								BEGIN
									SELECT @dblReqQty = (@dblReqQty / @dblSubstituteRatio * 100 / @dblMaxSubstituteRatio) - (@dblQty / @dblSubstituteRatio * 100 / @dblMaxSubstituteRatio)

									SELECT @dblLowerToleranceReqQty = (@dblLowerToleranceReqQty / @dblSubstituteRatio * 100 / @dblMaxSubstituteRatio) - (@dblQty / @dblSubstituteRatio * 100 / @dblMaxSubstituteRatio)
								END
							ELSE
								BEGIN
									SELECT @dblReqQty = @dblReqQty - [dbo].[fnMFConvertQuantityToTargetItemUOM](@intItemUOMId, @intRecipeItemUOMId, @dblQty)

									SELECT @dblLowerToleranceReqQty = @dblLowerToleranceReqQty - [dbo].[fnMFConvertQuantityToTargetItemUOM](@intItemUOMId, @intRecipeItemUOMId, @dblQty)
								END
						END

						SELECT @intLotRecordId = Min(intLotRecordId)
						FROM @tblLot
						WHERE dblQty > 0 AND intLotRecordId > @intLotRecordId
				
					END

				NextItem:

				SELECT @intItemRecordId = Min(intItemRecordId)
				FROM @tblItem
				WHERE intItemRecordId > @intItemRecordId
		
			/* End of Second Loop Start. */
			END

			/* Validate if there's Stage Item  that is not available*/
			IF @strAllInputItemsMandatoryforConsumption = 'True' AND EXISTS (SELECT *
																			 FROM dbo.tblMFWorkOrderRecipeItem ri
																			 WHERE ri.intWorkOrderId = @intWorkOrderId
																			   AND ri.intRecipeItemTypeId = 1
																			   AND 
																			   (
																					(ri.ysnYearValidationRequired = 1 AND @dtmCurrentDate BETWEEN ri.dtmValidFrom AND ri.dtmValidTo)
																				 OR (ri.ysnYearValidationRequired = 0 AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom) AND DATEPART(dy, ri.dtmValidTo))
																			   )
																			   AND ri.intConsumptionMethodId <> 4
																			   AND ri.ysnPartialFillConsumption = (CASE WHEN @ysnFillPartialPallet = 1 THEN 1
																														ELSE ri.ysnPartialFillConsumption
																												   END)
																			   AND NOT EXISTS (SELECT *
																							   FROM tblMFWorkOrderConsumedLot WC
																							   WHERE 
																							   (
																									WC.intItemId = ri.intItemId OR WC.intItemId IN 
																																				(
																																					SELECT SI.intSubstituteItemId
																																					FROM dbo.tblMFWorkOrderRecipeSubstituteItem SI
																																					WHERE SI.intRecipeItemId = ri.intRecipeItemId
																																					  AND SI.intWorkOrderId = ri.intWorkOrderId
																																					  AND SI.intRecipeId = ri.intRecipeId
																																				)
																								)
																			   AND WC.intWorkOrderId = @intWorkOrderId
																			   AND ISNULL(WC.intBatchId, @intBatchId) = @intBatchId))
				BEGIN
					SELECT @intInputItemId = ri.intItemId
					FROM dbo.tblMFWorkOrderRecipeItem ri
					WHERE ri.intWorkOrderId = @intWorkOrderId
					  AND ri.intRecipeItemTypeId = 1
					  AND (
				(
					ri.ysnYearValidationRequired = 1
					AND @dtmCurrentDate BETWEEN ri.dtmValidFrom
						AND ri.dtmValidTo
					)
				OR (
					ri.ysnYearValidationRequired = 0
					AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom)
						AND DATEPART(dy, ri.dtmValidTo)
					)
				)
			AND ri.intConsumptionMethodId <> 4
			AND NOT EXISTS (
				SELECT *
				FROM tblMFWorkOrderConsumedLot WC
				WHERE (
						WC.intItemId = ri.intItemId
						OR WC.intItemId IN (
							SELECT SI.intSubstituteItemId
							FROM dbo.tblMFWorkOrderRecipeSubstituteItem SI
							WHERE SI.intRecipeItemId = ri.intRecipeItemId
								AND SI.intWorkOrderId = ri.intWorkOrderId
								AND SI.intRecipeId = ri.intRecipeId
							)
						)
					AND WC.intWorkOrderId = @intWorkOrderId
					AND IsNULL(WC.intBatchId, @intBatchId) = @intBatchId
				)

		SELECT @strItemNo = strItemNo
		FROM dbo.tblICItem
		WHERE intItemId = @intInputItemId

		RAISERROR (
				'The input lots for the item %s are expired / inactive / unavailable. Cannot produce.'
				,11
				,1
				,@strItemNo
				)

		RETURN
	END

	IF @intRecipeTypeId = 3
		AND NOT EXISTS (
			SELECT *
			FROM tblMFWorkOrderConsumedLot
			WHERE intWorkOrderId = @intWorkOrderId
				AND IsNULL(intBatchId, @intBatchId) = @intBatchId
			)
	BEGIN
		RAISERROR (
				'Enough quantity is not available in the production staging location for one or more raw materials.'
				,11
				,1
				)

		RETURN
	END

	IF @intTransactionCount = 0
		COMMIT TRAN
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
