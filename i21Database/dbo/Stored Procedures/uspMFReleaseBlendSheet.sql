CREATE PROCEDURE [dbo].[uspMFReleaseBlendSheet]
	@strXml NVARCHAR(MAX)
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

	DECLARE @idoc INT 
	DECLARE @intWorkOrderId INT
	DECLARE @strNextWONo NVARCHAR(50)
	DECLARE @strDemandNo NVARCHAR(50)
	DECLARE @intBlendRequirementId INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intLocationId INT

	EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml  

	BEGIN TRAN

	DECLARE @tblBlendSheet TABLE
	(
		intWorkOrderId INT,
		intItemId INT,
		intCellId INT,
		dtmDueDate DATETIME,
		dblQtyToProduce NUMERIC(18,6),
		dblBinSize NUMERIC(18,6),
		strComment NVARCHAR(MAX),
		ysnUseTemplate BIT,
		ysnKittingEnabled BIT,
		intLocationId INT,
		intBlendRequirementId INT,
		intItemUOMId INT,
		intUserId INT
	)

	DECLARE @tblItem TABLE
	(
		intRowNo INT IDENTITY(1,1),
		intItemId INT,
		dblReqQty NUMERIC(18,6)
	)

	DECLARE @tblLot TABLE
	(
		intRowNo INT IDENTITY(1,1),
		intLotId INT,
		intItemId INT,
		dblQty NUMERIC(18,6),
		dblIssuedQuantity NUMERIC(18,6),
		dblWeightPerUnit NUMERIC(18,6),
		intItemUOMId INT,
		intItemIssuedUOMId INT,
		intUserId INT,
		intRecipeItemId INT
	)

	DECLARE @tblBSLot TABLE
	(
		intLotId INT,
		dblQty NUMERIC(18,6),
		intUOMId INT,
		dblIssuedQuantity NUMERIC(18,6),
		intIssuedUOMId INT,
		dblWeightPerUnit NUMERIC(18,6),
		intRecipeItemId INT
	)

	INSERT INTO @tblBlendSheet(
			intWorkOrderId
			,intItemId
			,intCellId
			,dtmDueDate
			,dblQtyToProduce
			,dblBinSize
			,strComment
			,ysnUseTemplate
			,ysnKittingEnabled
			,intLocationId
			,intBlendRequirementId
			,intItemUOMId
			,intUserId
	)
	Select 
			intWorkOrderId
			,intItemId
			,intCellId
			,dtmDueDate
			,dblQtyToProduce
			,dblBinSize
			,strComment
			,ysnUseTemplate
			,ysnKittingEnabled
			,intLocationId
			,intBlendRequirementId
			,intItemUOMId
			,intUserId
	FROM OPENXML(@idoc, 'root', 2)  
	WITH ( 
		intWorkOrderId INT, 
		intItemId INT,
		intCellId INT,
		dtmDueDate DATETIME,
		dblQtyToProduce NUMERIC(18,6),
		dblBinSize NUMERIC(18,6),
		strComment NVARCHAR(MAX),
		ysnUseTemplate BIT,
		ysnKittingEnabled BIT,
		intLocationId INT,
		intBlendRequirementId INT,
		intItemUOMId INT,
		intUserId INT
	)
	
	DECLARE	@dblQtyToProduce NUMERIC(18,6)
			,@dblPlannedQuantity NUMERIC(18,6)
			,@intUserId INT
	
	SELECT	@dblPlannedQuantity = dblQtyToProduce
			,@intUserId = intUserId
			,@intLocationId = intLocationId 
	FROM @tblBlendSheet

	INSERT INTO @tblLot(
		intLotId
		,intItemId
		,dblQty
		,dblIssuedQuantity
		,dblWeightPerUnit
		,intItemUOMId
		,intItemIssuedUOMId
		,intUserId
		,intRecipeItemId
	)
	SELECT 
		intLotId
		,intItemId
		,dblQty
		,dblIssuedQuantity
		,dblWeightPerUnit
		,intItemUOMId
		,intItemIssuedUOMId
		,intUserId
		,intRecipeItemId
	FROM OPENXML(@idoc, 'root/lot', 2)  
	WITH (  
		intLotId INT,
		intItemId INT,
		dblQty NUMERIC(18,6),
		dblIssuedQuantity NUMERIC(18,6),
		dblPickedQuantity NUMERIC(18,6),
		dblWeightPerUnit NUMERIC(18,6),
		intItemUOMId INT,
		intItemIssuedUOMId INT,
		intUserId INT,
		intRecipeItemId INT
	)

	UPDATE	@tblBlendSheet 
	SET		dblQtyToProduce = (SELECT SUM(dblQty) FROM @tblLot)

	SELECT	@dblQtyToProduce = dblQtyToProduce
			,@intUserId = intUserId
			,@intLocationId = intLocationId 
	FROM	@tblBlendSheet

	UPDATE	a 
	Set		a.dblWeightPerUnit = b.dblWeightPerQty 
	FROM	@tblLot a JOIN tblICLot b 
				ON a.intLotId = b.intLotId

	DECLARE @intNoOfSheet int
	DECLARE @dblRemainingQtyToProduce numeric(18,6)
	DECLARE @PerBlendSheetQty  numeric(18,6)

	SELECT	@intNoOfSheet= CEILING(@dblPlannedQuantity/dblBinSize)
			,@PerBlendSheetQty = dblBinSize
			,@intWorkOrderId = intWorkOrderId
			,@intBlendRequirementId = intBlendRequirementId
	FROM	@tblBlendSheet

	DECLARE @intRecipeId INT

	SELECT	@intRecipeId = intRecipeId 
	FROM	tblMFRecipe a JOIN @tblBlendSheet b 
				ON a.intItemId = b.intItemId
				AND a.intLocationId = b.intLocationId 
				AND ysnActive = 1

	SELECT	@strDemandNo = strDemandNo 
	FROM	tblMFBlendRequirement 
	WHERE	intBlendRequirementId = @intBlendRequirementId
	
	IF EXISTS (SELECT 1 FROM tblMFWorkOrder WHERE intWorkOrderId = @intWorkOrderId) 
		DELETE FROM tblMFWorkOrder 
		WHERE intWorkOrderId = @intWorkOrderId

	DECLARE @intItemCount INT
	DECLARE @intLotCount INT

	DECLARE @intItemId INT,
			@dblReqQty NUMERIC(18,6),
			@intLotId INT,
			@dblQty NUMERIC(18,6)

	WHILE(@intNoOfSheet > 0)
	BEGIN
		SET @intWorkOrderId = NULL

		--Calculate Required Quantity by Item
		IF (@dblQtyToProduce > @PerBlendSheetQty)
			SELECT @PerBlendSheetQty = @PerBlendSheetQty
		ELSE
			SELECT @PerBlendSheetQty = @dblQtyToProduce

		DELETE FROM @tblItem
		INSERT INTO @tblItem(
				intItemId
				,dblReqQty
		)
		SELECT 
				ri.intItemId
				,(ri.dblCalculatedQuantity * (@PerBlendSheetQty/r.dblQuantity)) AS RequiredQty
		FROM	tblMFRecipeItem ri JOIN tblMFRecipe r 
					ON r.intRecipeId = ri.intRecipeId 
		WHERE	ri.intRecipeId = @intRecipeId 
				AND ri.intRecipeItemTypeId = 1
		UNION
		SELECT	rs.intSubstituteItemId
				,(rs.dblQuantity * (@PerBlendSheetQty/r.dblQuantity)) AS RequiredQty
		FROM	tblMFRecipeSubstituteItem rs JOIN tblMFRecipe r 
					ON r.intRecipeId = rs.intRecipeId 
		WHERE	rs.intRecipeId = @intRecipeId 
				AND rs.intRecipeItemTypeId = 1

		SELECT	@intItemCount = MIN(intRowNo) 
		FROM	@tblItem

		WHILE(@intItemCount IS NOT NULL)
		BEGIN
				SET @intLotCount = NULL
				SET @strNextWONo = NULL

				SELECT	@intItemId = intItemId
						,@dblReqQty = dblReqQty 
				FROM	@tblItem 
				WHERE	intRowNo = @intItemCount

				SELECT	@intLotCount = MIN(intRowNo) 
				FROM	@tblLot 
				WHERE	intItemId = @intItemId 
						AND dblQty > 0
				
				WHILE(@intLotCount IS NOT NULL)
				BEGIN
					SELECT @intLotId = intLotId
							,@dblQty=dblQty 
					FROM	@tblLot 
					WHERE	intRowNo = @intLotCount
			
					IF (@dblQty >= @dblReqQty And @intNoOfSheet>1)
					BEGIN
						INSERT INTO @tblBSLot(
								intLotId
								,dblQty
								,intUOMId
								,dblIssuedQuantity
								,intIssuedUOMId
								,dblWeightPerUnit
								,intRecipeItemId
						)
						SELECT	intLotId
								,@dblReqQty
								,intItemUOMId
								,@dblReqQty / dblWeightPerUnit
								,intItemIssuedUOMId
								,dblWeightPerUnit
								,intRecipeItemId 
						FROM	@tblLot 
						WHERE	intRowNo = @intLotCount

						UPDATE	@tblLot 
						SET		dblQty = dblQty - @dblReqQty 
						WHERE	intRowNo = @intLotCount

						GOTO NextItem
					END
					ELSE
					BEGIN
						INSERT INTO @tblBSLot(
								intLotId
								,dblQty
								,intUOMId
								,dblIssuedQuantity
								,intIssuedUOMId
								,dblWeightPerUnit
								,intRecipeItemId
						)
						SELECT	intLotId
								,@dblQty
								,intItemUOMId
								,@dblQty / dblWeightPerUnit
								,intItemIssuedUOMId
								,dblWeightPerUnit
								,intRecipeItemId 
						from	@tblLot 
						WHERE	intRowNo = @intLotCount

						UPDATE	@tblLot 
						SET		dblQty = 0
						WHERE	intRowNo = @intLotCount
						
						SET		@dblReqQty = @dblReqQty - @dblQty
					End

					SELECT	@intLotCount = MIN(intRowNo) 
					FROM	@tblLot 
					WHERE	intItemId = @intItemId 
							AND dblQty > 0 
							AND intRowNo > @intLotCount	
				END
			
				NextItem:
				SELECT	@intItemCount = MIN(intRowNo) 
				FROM	@tblItem 
				WHERE	intRowNo > @intItemCount
		End

		-- Create the Work Order
		IF (SELECT COUNT(1) FROM tblMFWorkOrder WHERE strWorkOrderNo LIKE @strDemandNo + '%') = 0
			SET @strNextWONo = CONVERT(VARCHAR,@strDemandNo) + '01'
		ELSE
			SELECT	@strNextWONo = CONVERT(VARCHAR,@strDemandNo) + right('00' + CONVERT(VARCHAR,(MAX(CAST(RIGHT(strWorkOrderNo,2) AS INT)))+1),2)  
			FROM	tblMFWorkOrder 
			WHERE	strWorkOrderNo like @strDemandNo + '%'

		INSERT INTO tblMFWorkOrder(
				strWorkOrderNo
				,intItemId
				,dblQuantity
				,intItemUOMId
				,intStatusId
				,intManufacturingCellId
				,intLocationId
				,dblBinSize
				,dtmExpectedDate
				,intExecutionOrder
				,intProductionTypeId
				,dblPlannedQuantity
				,intBlendRequirementId
				,ysnKittingEnabled
				,ysnUseTemplate
				,strComment
				,dtmCreated
				,intCreatedUserId
				,dtmLastModified
				,intLastModifiedUserId
		)
		SELECT 
				@strNextWONo 
				,intItemId
				,@PerBlendSheetQty
				,intItemUOMId
				,9
				,intCellId
				,intLocationId
				,dblBinSize
				,dtmDueDate
				,0
				,1
				,@dblPlannedQuantity
				,intBlendRequirementId
				,ysnKittingEnabled
				,ysnUseTemplate
				,strComment
				,GETDATE()
				,intUserId
				,GETDATE()
				,intUserId
		FROM @tblBlendSheet

		SET @intWorkOrderId = SCOPE_IDENTITY()
	
		--Insert Into Input/Consumed Lot
		INSERT INTO tblMFWorkOrderInputLot(
				intWorkOrderId
				,intLotId
				,dblQuantity
				,intItemUOMId
				,dblIssuedQuantity
				,intItemIssuedUOMId
				,intSequenceNo
				,dtmCreated
				,intCreatedUserId
				,dtmLastModified
				,intLastModifiedUserId
				,intRecipeItemId
		)
		SELECT 
				@intWorkOrderId
				,intLotId
				,dblQty
				,intUOMId
				,dblIssuedQuantity
				,intIssuedUOMId
				,null
				,GETDATE()
				,@intUserId
				,GETDATE()
				,@intUserId
				,intRecipeItemId
		FROM	@tblBSLot

		INSERT INTO tblMFWorkOrderConsumedLot(
				intWorkOrderId
				,intLotId
				,dblQuantity
				,intItemUOMId
				,dblIssuedQuantity
				,intItemIssuedUOMId
				,intSequenceNo
				,dtmCreated
				,intCreatedUserId
				,dtmLastModified
				,intLastModifiedUserId
				,intRecipeItemId
		)
		SELECT 
				@intWorkOrderId
				,intLotId
				,dblQty
				,intUOMId
				,dblIssuedQuantity
				,intIssuedUOMId
				,NULL
				,GetDate()
				,@intUserId
				,GETDATE()
				,@intUserId
				,intRecipeItemId
		FROM @tblBSLot

		UPDATE	tblMFWorkOrder 
		SET		dblQuantity = (
					SELECT	SUM(dblQuantity) 
					FROM	tblMFWorkOrderConsumedLot 
					WHERE	intWorkOrderId = @intWorkOrderId
				) 
		WHERE intWorkOrderId = @intWorkOrderId

		DELETE FROM @tblBSLot

		SELECT @dblQtyToProduce = @dblQtyToProduce - @PerBlendSheetQty
		SET @intNoOfSheet = @intNoOfSheet - 1
	END

	UPDATE	tblMFBlendRequirement 
	SET		dblIssuedQty = (
				SELECT	SUM(dblQuantity) 
				FROM	tblMFWorkOrder 
				WHERE	intBlendRequirementId = @intBlendRequirementId
			) 
	WHERE	intBlendRequirementId = @intBlendRequirementId

	UPDATE	tblMFBlendRequirement 
	SET		intStatusId = 2 
	WHERE	intBlendRequirementId = @intBlendRequirementId 
			AND ISNULL(dblIssuedQty,0) >= dblQuantity

	COMMIT TRAN
	EXEC sp_xml_removedocument @idoc 

END TRY    
BEGIN CATCH  
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 
		ROLLBACK TRANSACTION      
	
	SET @ErrMsg = ERROR_MESSAGE()  
	IF @idoc <> 0 EXEC sp_xml_removedocument @idoc  
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')   
END CATCH  
