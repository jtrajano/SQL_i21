CREATE PROCEDURE uspLGCreateVoucher 
	 @intLoadId INT
	,@intEntityUserSecurityId INT
	,@intNewBillId INT OUTPUT

AS
BEGIN TRY
	DECLARE @intPurchaseSale INT
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intBillId INT

	BEGIN TRANSACTION

	SELECT @intPurchaseSale = intPurchaseSale
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	IF @intPurchaseSale = 1
	BEGIN
		EXEC uspLGCreateVoucherForInbound 
		        @intLoadId = @intLoadId
			   ,@intEntityUserSecurityId = @intEntityUserSecurityId
			   ,@intBillId = @intBillId OUTPUT
	END
	ELSE IF @intPurchaseSale IN (2,3)
	BEGIN
		EXEC uspLGCreateVoucherForOutbound 
				@intLoadId = @intLoadId
			   ,@intEntityUserSecurityId = @intEntityUserSecurityId
			   ,@intBillId = @intBillId OUTPUT
	END

	SET @intNewBillId = ISNULL(@intBillId,0)

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
	SET @strErrMsg = ERROR_MESSAGE()
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH