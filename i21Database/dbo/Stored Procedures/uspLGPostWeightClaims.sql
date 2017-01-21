CREATE PROCEDURE uspLGPostWeightClaims
	@intWeightClaimsId INT,
	@intEntityUserSecurityId INT,
	@ysnPost BIT
AS
BEGIN
	UPDATE tblLGWeightClaim
	SET ysnPosted = @ysnPost
		,dtmPosted = GETDATE()
	WHERE intWeightClaimId = @intWeightClaimsId
END