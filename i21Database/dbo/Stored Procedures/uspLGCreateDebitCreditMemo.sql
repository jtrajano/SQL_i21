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
	ELSE IF (@intPurchaseSale = 3)
	BEGIN
		DECLARE @intContractDetaild INT
		DECLARE @intContractTypeId INT
		
		SET @intMemoType = NULL
		
		SELECT @intContractDetaild = intContractDetailId
		FROM tblLGWeightClaimDetail
		WHERE intWeightClaimId = @intWeightClaimId

		SELECT @intContractTypeId = CH.intContractTypeId
		FROM tblCTContractHeader CH
		JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
		WHERE CD.intContractDetailId = @intContractDetaild

		IF(@intContractTypeId = 1)
		BEGIN
			EXEC uspLGCreateVoucherForWeightClaims 
				 @intWeightClaimId = @intWeightClaimId
				,@intEntityUserSecurityId = @intEntityUserSecurityId
				,@strBillId = @intNewId OUTPUT
			SET @intMemoType = 1
		END
		ELSE 
		BEGIN
			EXEC uspLGCreateInvoiceForWeightClaims 
				 @intWeightClaimId = @intWeightClaimId
				,@intUserId = @intEntityUserSecurityId
				,@NewInvoiceId = @intNewId OUTPUT
			SET @intMemoType = 2
		END
	END

END TRY

BEGIN CATCH
	SELECT @strErrorMessage = ERROR_MESSAGE(),
		   @intErrorSeverity = ERROR_SEVERITY(),
		   @intErrorState = ERROR_STATE();

	RAISERROR (@strErrorMessage,@intErrorSeverity,@intErrorState)
END CATCH