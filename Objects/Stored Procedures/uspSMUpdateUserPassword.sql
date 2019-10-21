CREATE PROCEDURE [dbo].[uspSMUpdateUserPassword]
	@policyId int
AS
BEGIN
	UPDATE tblSMUserSecurity 
	SET ysnSecurityPolicyUpdated = 1 
	WHERE intSecurityPolicyId = @policyId
END