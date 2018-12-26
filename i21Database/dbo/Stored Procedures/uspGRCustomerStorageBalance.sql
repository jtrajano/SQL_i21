CREATE PROCEDURE uspGRCustomerStorageBalance	
	@intEntityId INT = NULL 
	,@intItemId INT = NULL
	,@intLocationId INT = NULL
	,@intDeliverySheetId INT = NULL
	,@intCustomerStorageId INT = NULL
	,@dblBalance DECIMAL(38,20)
	,@intStorageTypeId INT = NULL
	,@intStorageScheduleId INT = NULL
	,@ysnDistribute BIT	
	,@dblGrossQuantity DECIMAL(38,20)
	,@intShipFromLocationId INT = NULL
	,@intShipFromEntityId INT = NULL
	,@newBalance DECIMAL(38,20) OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrMsg NVARCHAR(MAX)

BEGIN TRY
	IF @ysnDistribute = 1
	BEGIN
		UPDATE tblGRCustomerStorage
		SET dblOpenBalance 			= dblOpenBalance + @dblBalance
			, dblOriginalBalance 	= dblOriginalBalance + @dblBalance
			, dblGrossQuantity 		= dblGrossQuantity + @dblGrossQuantity
			, intStorageTypeId 		= @intStorageTypeId
			, intStorageScheduleId 	= @intStorageScheduleId
			, intShipFromLocationId = @intShipFromLocationId
			, intShipFromEntityId	= @intShipFromEntityId
		WHERE intCustomerStorageId 	= @intCustomerStorageId

		SELECT @newBalance = dblOriginalBalance FROM tblGRCustomerStorage WHERE intCustomerStorageId = @intCustomerStorageId
	END
	ELSE
	--undistribute ticket
	BEGIN
		UPDATE tblGRCustomerStorage
		SET dblOpenBalance 			= dblOpenBalance - @dblBalance
			, dblOriginalBalance 	= dblOriginalBalance - @dblBalance
			, dblGrossQuantity 		= dblGrossQuantity - @dblGrossQuantity
		WHERE intEntityId = @intEntityId 
			AND intItemId = @intItemId 
			AND intCompanyLocationId = @intLocationId 
			AND intDeliverySheetId = @intDeliverySheetId
			AND intStorageTypeId = @intStorageTypeId 

		SELECT @newBalance = dblOriginalBalance FROM tblGRCustomerStorage 
		WHERE intEntityId = @intEntityId 
			AND intItemId = @intItemId
			AND intCompanyLocationId = @intLocationId 
			AND intDeliverySheetId = @intDeliverySheetId
			AND intStorageTypeId = @intStorageTypeId 

	END
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH