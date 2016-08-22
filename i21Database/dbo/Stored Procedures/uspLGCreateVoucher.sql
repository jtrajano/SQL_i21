CREATE PROCEDURE uspLGCreateVoucher 
     @intLoadId INT
	,@intEntityUserSecurityId INT
AS
BEGIN TRY
	DECLARE @intPurchaseSale INT
	DECLARE @strErrMsg NVARCHAR(MAX)

	BEGIN TRANSACTION

	SELECT @intPurchaseSale = intPurchaseSale
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	IF @intPurchaseSale = 1
	BEGIN
		EXEC uspLGCreateVoucherForInbound @intLoadId = @intLoadId
			,@intEntityUserSecurityId = @intEntityUserSecurityId
	END
	ELSE IF @intPurchaseSale = 2
	BEGIN
		EXEC uspLGCreateVoucherForOutbound @intLoadId = @intLoadId
			,@intEntityUserSecurityId = @intEntityUserSecurityId
	END

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
	SET @strErrMsg = ERROR_MESSAGE()
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH