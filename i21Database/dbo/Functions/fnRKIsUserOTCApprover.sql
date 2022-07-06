CREATE FUNCTION [dbo].[fnRKIsUserOTCApprover]
(
	@intUserId INT
)
RETURNS BIT
AS
BEGIN
	DECLARE @ysnApprover BIT = 0

	IF EXISTS (SELECT TOP 1 '' FROM tblSMUserSecurityRequireApprovalFor SRAF
				JOIN tblSMScreen screen
					ON screen.intScreenId = SRAF.intScreenId
					AND screen.strScreenId = 'Derivative Entry'
				LEFT JOIN tblSMApprovalListUserSecurity approvalList
					ON approvalList.intApprovalListId = SRAF.intApprovalListId
				LEFT JOIN tblSMApproverGroupUserSecurity approvalgroup
					ON approvalgroup.intApproverGroupId = approvalList.intApproverGroupId
				WHERE approvalList.intEntityUserSecurityId = @intUserId OR approvalgroup.intEntityUserSecurityId = @intUserId
			)
	BEGIN 
		SELECT @ysnApprover = 1
	END

	RETURN @ysnApprover
END