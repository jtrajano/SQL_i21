CREATE PROCEDURE uspLGPostWeightClaims
	@intWeightClaimsId INT,
	@intEntityUserSecurityId INT,
	@ysnPost BIT
AS
BEGIN TRY
DECLARE @strErrMsg NVARCHAR(MAX)
DECLARE @intBillId INT

	IF EXISTS (SELECT 1 FROM tblLGWeightClaimDetail WHERE intWeightClaimId = @intWeightClaimsId AND ISNULL(intBillId,0) <> 0)
	BEGIN 
		SELECT @intBillId = intBillId FROM tblLGWeightClaimDetail WHERE intWeightClaimId = @intWeightClaimsId
		IF EXISTS(SELECT 1 FROM tblAPBill WHERE intBillId = @intBillId)
		BEGIN
			IF(@ysnPost = 0) 
				RAISERROR('Voucher has been created for the weight claim. Cannot unpost.',16,1)
		END
	END

	UPDATE tblLGWeightClaim
	SET ysnPosted = @ysnPost
		,dtmPosted = GETDATE()
	WHERE intWeightClaimId = @intWeightClaimsId
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH