CREATE PROCEDURE [dbo].[uspARApproveCommission]
	  @intCommissionId		INT
    , @intApprovalListId	INT
	, @intApproverEntityId	INT
	, @strReason			NVARCHAR(MAX) = NULL
	, @nextApproverId		INT			  = NULL OUTPUT
AS

IF ISNULL(@intCommissionId, 0) = 0
	BEGIN
		RAISERROR('Commission Id is Required!', 16, 1);
		RETURN 0;
	END

IF ISNULL(@intApprovalListId, 0) = 0
	BEGIN
		RAISERROR('Approval List Id is Required!', 16, 1);
		RETURN 0;
	END

IF ISNULL(@intApproverEntityId, 0) = 0
	BEGIN
		RAISERROR('Approver Entity Id is Required!', 16, 1);
		RETURN 0;
	END

DECLARE @intMaxApproverLevel		INT = 0
	  , @intCurrentApproverLevel	INT = 0
	  , @intNextApproverId			INT = 0

SELECT @intMaxApproverLevel = ISNULL(MAX(intApproverLevel), 0) 
FROM tblSMApprovalListUserSecurity 
WHERE intApprovalListId = @intApprovalListId

SELECT TOP 1
	@intCurrentApproverLevel = ISNULL(intApproverLevel, 0)
FROM tblSMApprovalListUserSecurity
WHERE intApprovalListId = @intApprovalListId
AND intEntityUserSecurityId = @intApproverEntityId

IF @intMaxApproverLevel = @intCurrentApproverLevel
	BEGIN
		UPDATE tblARCommission 
		SET ysnApproved = 1
		  , intApproverEntityId = NULL
		  , strReason = @strReason 
		WHERE intCommissionId = @intCommissionId
	END
ELSE
	BEGIN
		SELECT TOP 1
			@intNextApproverId	= intEntityUserSecurityId
		  , @nextApproverId		= intEntityUserSecurityId
		FROM tblSMApprovalListUserSecurity
		WHERE intApprovalListId = @intApprovalListId
		AND intApproverLevel = @intCurrentApproverLevel + 1

		UPDATE tblARCommission SET intApproverEntityId = @intNextApproverId, strReason = @strReason WHERE intCommissionId = @intCommissionId
	END