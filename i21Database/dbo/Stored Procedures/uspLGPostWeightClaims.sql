CREATE PROCEDURE uspLGPostWeightClaims
	@intWeightClaimsId INT,
	@intEntityUserSecurityId INT,
	@ysnPost BIT
AS
BEGIN TRY
DECLARE @strErrMsg NVARCHAR(MAX)
DECLARE @intBillId INT
DECLARE @actionType NVARCHAR(10)

SET @actionType = CASE WHEN @ysnPost = 1 THEN 'Posted' WHEN @ysnPost = 0 THEN 'Unposted' END

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

	EXEC uspSMAuditLog
        @keyValue = @intWeightClaimsId,
        @screenName = 'Logistics.view.WeightClaims',
        @entityId = @intEntityUserSecurityId,
        @actionType = @actionType

END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH