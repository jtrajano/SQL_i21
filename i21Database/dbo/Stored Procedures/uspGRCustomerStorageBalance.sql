CREATE PROCEDURE uspGRCustomerStorageBalance	
	@intEntityId INT = NULL 
	,@intItemId INT = NULL
	,@intLocationId INT = NULL
	,@intDeliverySheetId INT = NULL
	,@intCustomerStorageId INT = NULL
	,@dblBalance DECIMAL(18,6)
	,@ysnDistribute BIT	
	,@newBalance DECIMAL(18,6) OUTPUT
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
		SET dblOpenBalance = dblOpenBalance + @dblBalance
			, dblOriginalBalance = dblOriginalBalance + @dblBalance
		WHERE intCustomerStorageId = @intCustomerStorageId

		SELECT @newBalance = dblOriginalBalance FROM tblGRCustomerStorage WHERE intCustomerStorageId = @intCustomerStorageId
	END
	ELSE
	--undistribute ticket
	BEGIN
		UPDATE tblGRCustomerStorage
		SET dblOpenBalance = dblOpenBalance - @dblBalance
			, dblOriginalBalance = dblOriginalBalance - @dblBalance
		WHERE intEntityId = @intEntityId AND intItemId = @intItemId AND intCompanyLocationId = @intLocationId AND intDeliverySheetId = @intDeliverySheetId

		SELECT @newBalance = dblOriginalBalance FROM tblGRCustomerStorage WHERE intEntityId = @intEntityId AND intItemId = @intItemId AND intCompanyLocationId = @intLocationId AND intDeliverySheetId = @intDeliverySheetId
	END
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH