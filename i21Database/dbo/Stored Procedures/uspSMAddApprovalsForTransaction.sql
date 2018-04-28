CREATE PROCEDURE [dbo].[uspSMAddApprovalsForTransaction]
  @approverId INT,
  @approverGroupId INT,
  @screenId INT,
  @submitApprovalId INT,
  @waitingForApprovalId INT,
  @approverConfiguration ApprovalConfigurationType READONLY,
  @result BIT OUTPUT
AS
BEGIN
	DECLARE @ApproverGroup TABLE
	(
	  intApproverGroupUserSecurityId INT, 
	  intEntityUserSecurityId INT,
	  intApproverLevel INT,
	  intApproverGroupId INT NULL,
	  ysnEmailApprovalRequest BIT,
	  intSort INT
	)

	DECLARE @approverGroupUserId INT
	DECLARE @approverUserId INT
	DECLARE @approverLevel INT
	DECLARE @groupEmailRequest BIT
	DECLARE @groupSort BIT

	SET @result = 1

	IF ISNULL(@approverGroupId, 0) <> 0
	BEGIN
		INSERT INTO @ApproverGroup(
			intApproverGroupUserSecurityId, 
			intEntityUserSecurityId,
			intApproverLevel,
			intApproverGroupId,
			ysnEmailApprovalRequest,
			intSort
		)
		SELECT 
			intApproverGroupUserSecurityId, 
			intEntityUserSecurityId,
			intApproverLevel,
			intApproverGroupId,
			ysnEmailApprovalRequest,
			intSort
		FROM tblSMApproverGroupUserSecurity
		WHERE intApproverGroupId = @approverGroupId

		WHILE EXISTS(SELECT 1 FROM @ApproverGroup)
		BEGIN
			PRINT('approver group - start loop')

			SELECT TOP 1
				@approverGroupUserId = intApproverGroupUserSecurityId,
				@approverUserId = intEntityUserSecurityId,
				@approverLevel = intApproverLevel,
				@groupEmailRequest = ysnEmailApprovalRequest,
				@groupSort = intSort
			FROM @ApproverGroup

			IF [dbo].[fnSMCompareApproverConfiguration](@approverUserId, @screenId, @approverConfiguration) = 1
			BEGIN
				PRINT('approver group - compare passed')

				SET @result = 1

				INSERT INTO tblSMApproverConfigurationForApprovalGroup (
					intApprovalId,
					intApproverId
				)
				SELECT
					@submitApprovalId,
					@approverUserId

				--TODO: First Approver Logic
				INSERT INTO tblSMApproverConfigurationForApprovalGroup (
					intApprovalId,
					intApproverId
				)
				SELECT
					@waitingForApprovalId,
					@approverUserId
			END
			ELSE
			BEGIN
				-- No need for approval
				SET @result = 0
			END

			DELETE FROM @ApproverGroup WHERE intApproverGroupUserSecurityId = @approverGroupUserId
		END

		PRINT('approver group - exit loop')
	END	
	ELSE
	BEGIN
		PRINT('no approver group')

		IF [dbo].[fnSMCompareApproverConfiguration](@approverId, @screenId, @approverConfiguration) = 1
		BEGIN
			PRINT('no approver group - compare passed')

			SET @result = 1

			INSERT INTO tblSMApproverConfigurationForApprovalGroup (
				intApprovalId,
				intApproverId
			)
			SELECT
				@submitApprovalId,
				@approverId

			--TODO: First Approver Logic
			INSERT INTO tblSMApproverConfigurationForApprovalGroup (
				intApprovalId,
				intApproverId
			)
			SELECT
				@waitingForApprovalId,
				@approverId
		END
		ELSE
		BEGIN
			-- No need for approval
			SET @result = 0
		END
	END

	RETURN @result
END