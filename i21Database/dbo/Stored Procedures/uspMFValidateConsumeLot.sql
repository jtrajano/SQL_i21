CREATE PROCEDURE [dbo].uspMFValidateConsumeLot 
(
	@intLotId				INT
  , @dblConsumeQty			NUMERIC(38, 20)
  , @intConsumeUOMKey		INT
  , @intUserId				INT
  , @intWorkOrderId			INT
  , @ysnNegativeQtyAllowed	BIT = 0
)
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

	DECLARE @ErrMsg						NVARCHAR(MAX)
		  , @strSecondaryStatus			NVARCHAR(50)
		  , @dtmExpiryDate				DATETIME
		  , @strLotNumber				NVARCHAR(50)
		  , @intLocationId				INT
		  , @intWOLocationId			INT
		  , @dblOnHand					NUMERIC(38, 20)
		  , @strName					NVARCHAR(50)
		  , @strUnitMeasure				NVARCHAR(50)
		  , @intItemId					INT
		  , @strItemNo					NVARCHAR(50)
		  , @strProductItemNo			NVARCHAR(50)
		  , @dblTotalQtyToBeConsumed	NUMERIC(38, 20)
		  , @dblQtyConsumedSoFar		NUMERIC(38, 20)
		  , @strStatus					NVARCHAR(50)
		  , @strConsumeQty				NVARCHAR(50)
		  , @strOnHand					NVARCHAR(50)


	IF @dblConsumeQty <= 0 AND @ysnNegativeQtyAllowed = 0
		BEGIN
			SELECT @strConsumeQty=@dblConsumeQty
			RAISERROR 
			(
				'The requested consume quantity of %s is invalid. Please attempt to consume a positive quantity less than or equal to input lot quantity.'
			   , 11
			   , 1
			   , @strConsumeQty
			)

			RETURN;
		END

	SELECT @intWOLocationId = intLocationId
	FROM dbo.tblMFWorkOrder W
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @dtmExpiryDate		= dtmExpiryDate
		 , @strLotNumber		= strLotNumber
		 , @intLocationId		= intLocationId
		 , @dblOnHand			= (CASE WHEN Lot.intWeightUOMId IS NOT NULL THEN Lot.dblWeight ELSE dblQty END)
		 , @intItemId			= Lot.intItemId
		 , @strItemNo			= Item.strItemNo
		 , @strStatus			= Item.strStatus
		 , @strSecondaryStatus	= LotStatus.strSecondaryStatus
	FROM dbo.tblICLot AS Lot
	LEFT JOIN tblICItem AS Item ON Lot.intItemId = Item.intItemId
	LEFT JOIN tblICLotStatus AS LotStatus ON Lot.intLotStatusId = LotStatus.intLotStatusId
	WHERE intLotId = @intLotId

	SELECT @strUnitMeasure = UOM.strUnitMeasure
	FROM tblICItemUOM AS ItemUOM
	LEFT JOIN tblICUnitMeasure AS UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	WHERE ItemUOM.intItemUOMId =  @intConsumeUOMKey;

	/* Quarantined Lot Validation. */
	IF @strSecondaryStatus <> 'Active'
		BEGIN
			RAISERROR 
			(
				'Lot ''%s'' is in quarantine. You are not allowed to consume a quantity from a quarantined lot.'
			  , 11
			  , 1
			  , @strLotNumber
			)

			RETURN;
		END
	/* End of Quarantined Lot Validation. */
	
	IF @intWOLocationId <> @intLocationId
		BEGIN
			RAISERROR 
			(
				'The lot ''%s'' is not available for consumption.'
			  , 11
			  , 1
			  , @strLotNumber
			)

			RETURN;
		END

	/* Expired Lot Validation. */
	IF @dtmExpiryDate IS NOT NULL AND @dtmExpiryDate < GETDATE()
		BEGIN
			RAISERROR 
			(
				'The Lot ''%s'' is expired. You cannot consume.'
			  , 11
			  , 1
			  , @strLotNumber
			)

			RETURN
		END
	/* End of Expired Lot Validation. */
	

	IF @dblConsumeQty > @dblOnHand AND @ysnNegativeQtyAllowed = 0
		BEGIN
			SELECT @strConsumeQty = @dblConsumeQty;

			SELECT @strOnHand = @dblOnHand;
			
			RAISERROR 
			(
				'The attempted consumption quantity of %s %s of material ''%s'' from lot ''%s'' is more than the lot''s queued quantity of %s %s. The transaction will not be allowed to proceed.'
			  , 11
			  , 1
			  , @strConsumeQty
			  , @strUnitMeasure
			  , @strItemNo
			  , @strLotNumber
			  , @strOnHand
			  , @strUnitMeasure
		    )

			RETURN;
		END

	IF @strStatus = 'InActive'
		BEGIN
			RAISERROR 
			(
				'The specified item ''%s'' is InActive. The transaction can not proceed.'
			  , 11
			  , 1
			  , @strItemNo
			)
		END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH

