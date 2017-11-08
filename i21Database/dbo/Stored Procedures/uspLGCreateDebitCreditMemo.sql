CREATE PROCEDURE uspLGCreateDebitCreditMemo 
	 @intWeightClaimId INT
	,@intEntityUserSecurityId INT
	,@intNewId INT OUTPUT
	,@intMemoType INT OUTPUT
AS
BEGIN TRY
	DECLARE @strErrorMessage NVARCHAR(MAX)
	DECLARE @intErrorSeverity INT
	DECLARE @intErrorState INT
	DECLARE @intLoadId INT
	DECLARE @intPurchaseSale INT

	SELECT @intLoadId = intLoadId
	FROM tblLGWeightClaim
	WHERE intWeightClaimId = @intWeightClaimId

	SELECT @intPurchaseSale = intPurchaseSale
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	SET @intMemoType = @intPurchaseSale

	IF (@intPurchaseSale = 1)
	BEGIN
		EXEC uspLGCreateVoucherForWeightClaims 
			 @intWeightClaimId = @intWeightClaimId
			,@intEntityUserSecurityId = @intEntityUserSecurityId
			,@strBillId = @intNewId OUTPUT
	END
	ELSE IF (@intPurchaseSale = 2)
	BEGIN
		EXEC uspLGCreateInvoiceForWeightClaims 
			 @intWeightClaimId = @intWeightClaimId
			,@intUserId = @intEntityUserSecurityId
			,@NewInvoiceId = @intNewId OUTPUT
	END

END TRY

BEGIN CATCH
	SELECT @strErrorMessage = ERROR_MESSAGE(),
		   @intErrorSeverity = ERROR_SEVERITY(),
		   @intErrorState = ERROR_STATE();

	RAISERROR (@strErrorMessage,@intErrorSeverity,@intErrorState)
END CATCH