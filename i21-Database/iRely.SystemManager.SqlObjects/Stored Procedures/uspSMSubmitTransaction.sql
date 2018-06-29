CREATE PROCEDURE [dbo].[uspSMSubmitTransaction]
  @type NVARCHAR(250),
  @recordId INT,
  @transactionNo NVARCHAR(250),
  @transactionEntityId INT,
  @currentUserEntityId INT,
  @locationId INT = NULL,
  @currencyId INT = NULL,
  @amount DECIMAL = NULL,
  @dueDate DATETIME = NULL,
  @submitType NVARCHAR(250) = NULL,
  @approverConfiguration ApprovalConfigurationType READONLY
AS
BEGIN
	DECLARE @countValue INT = 0
	DECLARE @approvalFor NVARCHAR(50) = ''
	DECLARE @approvalForId INT = NULL
	DECLARE @screenId INT = (select top 1 intScreenId from tblSMScreen where strNamespace = @type)

	DECLARE @transactionId INT = NULL
	DECLARE @submitApprovalId INT
	DECLARE @waitingForApprovalId INT

	DECLARE @Approvers TABLE
	(
	  intApprovalListUserSecurityId INT, 
	  intApprovalListId INT,
	  intEntityUserSecurityId INT NULL,
	  intApproverLevel INT,
	  intAlternateEntityUserSecurityId INT NULL,
	  intApproverGroupId INT NULL,
	  dblAmountOver NUMERIC(18,6),
	  dblAmountLessThanEqual NUMERIC(18,6),
	  ysnEmailApprovalRequest BIT
	)
	
	IF @countValue = 0 --FIRST LEVEL - ENTITY
	BEGIN
		INSERT INTO @Approvers (
			intApprovalListUserSecurityId, 
			intApprovalListId,
			intEntityUserSecurityId,
			intApproverLevel,
			intAlternateEntityUserSecurityId,
			intApproverGroupId,
			dblAmountOver,
			dblAmountLessThanEqual,
			ysnEmailApprovalRequest
		) 
		SELECT 
			intApprovalListUserSecurityId, 
			em.intApprovalListId,
			intEntityUserSecurityId,
			intApproverLevel,
			intAlternateEntityUserSecurityId,
			intApproverGroupId,
			dblAmountOver,
			dblAmountLessThanEqual,
			ysnEmailApprovalRequest
		FROM tblEMEntityRequireApprovalFor em
			INNER JOIN tblSMApprovalList c on c.intApprovalListId = em.intApprovalListId
			INNER JOIN tblSMApprovalListUserSecurity d on d.intApprovalListId = c.intApprovalListId
		WHERE 
			em.intScreenId = @screenId and
			em.intEntityId = @transactionEntityId and 
			( 
				--TODO: Ignore Amount logic is not yet applied
				(d.dblAmountLessThanEqual = 0 and d.dblAmountOver = 0) or
				(d.dblAmountLessThanEqual = 0 and (d.dblAmountOver > 0 and @amount > d.dblAmountOver)) or
				((d.dblAmountLessThanEqual > 0 and @amount <= d.dblAmountLessThanEqual) and d.dblAmountOver = 0) or
				(d.dblAmountLessThanEqual > 0 and d.dblAmountOver > 0 and @amount <= d.dblAmountLessThanEqual and @amount > d.dblAmountOver)
			)

		SELECT @countValue=count(*) FROM @Approvers

		SELECT @approvalFor = 'ENTITY'
		
		SELECT TOP 1 @approvalForId = intEntityRequireApprovalForId 
		FROM tblEMEntityRequireApprovalFor a 
			INNER JOIN tblSMScreen b ON a.intScreenId = b.intScreenId and a.intEntityId = @transactionEntityId
		WHERE b.strNamespace = @type

	END
	-- TODO: Didn't add the Portal User checking here

	IF @countValue = 0 --SECOND LEVEL - COMPANY LOCATION
	BEGIN
		INSERT INTO @Approvers (
			intApprovalListUserSecurityId, 
			intApprovalListId,
			intEntityUserSecurityId,
			intApproverLevel,
			intAlternateEntityUserSecurityId,
			intApproverGroupId,
			dblAmountOver,
			dblAmountLessThanEqual,
			ysnEmailApprovalRequest
		) 
		SELECT 
			intApprovalListUserSecurityId, 
			smLocation.intApprovalListId,
			intEntityUserSecurityId,
			intApproverLevel,
			intAlternateEntityUserSecurityId,
			intApproverGroupId,
			dblAmountOver,
			dblAmountLessThanEqual,
			ysnEmailApprovalRequest
		FROM tblSMCompanyLocationRequireApprovalFor smLocation
			inner join tblSMApprovalList c ON c.intApprovalListId = smLocation.intApprovalListId
			inner join tblSMApprovalListUserSecurity d ON d.intApprovalListId = c.intApprovalListId
		WHERE
			smLocation.intScreenId = @screenId and
			smLocation.intCompanyLocationId = @locationId and 
			(
				--TODO: Ignore Amount logic is not yet applied
				(d.dblAmountLessThanEqual = 0 and d.dblAmountOver = 0) or
				(d.dblAmountLessThanEqual = 0 and (d.dblAmountOver > 0 and @amount > d.dblAmountOver)) or
				((d.dblAmountLessThanEqual > 0 and @amount <= d.dblAmountLessThanEqual) and d.dblAmountOver = 0) or
				(d.dblAmountLessThanEqual > 0 and d.dblAmountOver > 0 and @amount <= d.dblAmountLessThanEqual and @amount > d.dblAmountOver)
			)

		SELECT @countValue=COUNT(*) FROM @Approvers

		SELECT @approvalFor = 'LOCATION'

		SELECT TOP 1 @approvalForId = intCompanyLocationRequireApprovalForId FROM tblSMCompanyLocationRequireApprovalFor a 
			inner join tblSMScreen b ON a.intScreenId = b.intScreenId and intCompanyLocationId = @locationId
		WHERE b.strNamespace = @type
	END

	IF @countValue = 0 --THIRD LEVEL - USER
	BEGIN
		INSERT INTO @Approvers (
			intApprovalListUserSecurityId, 
			intApprovalListId,
			d.intEntityUserSecurityId,
			intApproverLevel,
			intAlternateEntityUserSecurityId,
			intApproverGroupId,
			dblAmountOver,
			dblAmountLessThanEqual,
			ysnEmailApprovalRequest
		) 
		SELECT 
			intApprovalListUserSecurityId, 
			smUser.intApprovalListId,
			d.intEntityUserSecurityId,
			intApproverLevel,
			intAlternateEntityUserSecurityId,
			intApproverGroupId,
			dblAmountOver,
			dblAmountLessThanEqual,
			ysnEmailApprovalRequest
		FROM tblSMUserSecurityRequireApprovalFor smUser
			inner join tblSMApprovalList c on c.intApprovalListId = smUser.intApprovalListId
			inner join tblSMApprovalListUserSecurity d on d.intApprovalListId = c.intApprovalListId
		WHERE
			smUser.intScreenId = @screenId and
			smUser.intEntityUserSecurityId = @currentUserEntityId and 
			(
				--TODO: Ignore Amount logic is not yet applied
				(d.intEntityUserSecurityId IS NULL OR d.intEntityUserSecurityId <> @currentUserEntityId) and 
				(d.dblAmountLessThanEqual = 0 and d.dblAmountOver = 0) or
				(d.dblAmountLessThanEqual = 0 and (d.dblAmountOver > 0 and @amount > d.dblAmountOver)) or
				((d.dblAmountLessThanEqual > 0 and @amount <= d.dblAmountLessThanEqual) and d.dblAmountOver = 0) or
				(d.dblAmountLessThanEqual > 0 and d.dblAmountOver > 0 and @amount <= d.dblAmountLessThanEqual and @amount > d.dblAmountOver)
			)

		SELECT @countValue=count(*) FROM @Approvers

		SELECT @approvalFor = 'USER'

		SELECT TOP 1 @approvalForId = intUserSecurityReqApprovalForId 
		FROM tblSMUserSecurityRequireApprovalFor a 
			inner join tblSMScreen b ON a.intScreenId = b.intScreenId and intEntityUserSecurityId = @currentUserEntityId
		WHERE b.strNamespace = @type
	END

	PRINT('done w/ approvers')
	
	-- Get transaction id
	SELECT TOP 1 
		@transactionId = intTransactionId 
	FROM tblSMTransaction 
	WHERE intScreenId = @screenId and intRecordId = @recordId

	IF ISNULL(@transactionId, 0) = 0
		BEGIN
			INSERT INTO tblSMTransaction (
				intScreenId, 
				intRecordId, 
				strTransactionNo, 
				intEntityId, 
				intApprovalForId, 
				strApprovalFor, 
				dblAmount, 
				intCurrencyId, 
				strApprovalStatus
			)
			SELECT 
				@screenId, 
				@recordId, 
				@transactionNo, 
				@transactionEntityId, 
				@approvalForId, 
				@approvalFor, 
				@amount, 
				@currencyId, 
				'Wating for Approval' 

			SELECT @transactionId = SCOPE_IDENTITY() 

			PRINT('creating transaction')
		END
	ELSE
		BEGIN
			UPDATE tblSMTransaction
			SET intApprovalForId = @approvalForId,
				strApprovalFor = @approvalFor,
				dblAmount = @amount,
				intCurrencyId = @currencyId,
				strApprovalStatus = 'Wating for Approval'
			WHERE intTransactionId = @transactionId

			PRINT('updating transaction')
		END

	--Delete Approval History
	DELETE FROM tblSMApprovalHistory
	WHERE intApprovalId = ISNULL((
		SELECT TOP 1 intApprovalId FROM tblSMApproval A 
			INNER JOIN tblSMTransaction B ON A.intTransactionId = B.intTransactionId
		WHERE A.intTransactionId = @transactionId AND (B.strApprovalStatus IN ('Approved','Closed','Waiting for Submit') AND (A.strStatus = 'Approved' OR A.strStatus = 'Rejected'))
	), 0)

	--Update previous approval entry to ysnCurrent = 0
	--TODO: Verify if setting to ysnCurrent = 0 for all entries is the right thing to do
	UPDATE tblSMApproval
	SET ysnCurrent = 0 
	WHERE intTransactionId = @transactionId 
		  --and 
		  --strStatus = 'Waiting for Submit' or 
		  --strStatus = 'No Need for Approval' and 
		  --intSubmittedById = @submittedByEntityId and 
		  --ysnCurrent = 1

	DECLARE @forResubmit BIT = ISNULL((SELECT 1 FROM tblSMApproval WHERE strStatus = 'Submitted' and intTransactionId = @transactionId), 0)
	DECLARE @submitScreenId INT = ISNULL((SELECT TOP 1 intScreenId from tblSMScreen where strNamespace = ISNULL(@submitType, @type)), 0)
	DECLARE @maxOrder INT = ISNULL((SELECT MAX(intOrder) from tblSMApproval where intTransactionId = @transactionId), 0)

	-- Increment this
	SELECT @maxOrder = @maxOrder + 1

	-- Insert submitted entry
	INSERT INTO tblSMApproval(
		dtmDate, 
		dblAmount, 
		dtmDueDate, 
		intApproverId, 
		intSubmittedById, 
		strStatus, 
		strTransactionNumber, 
		ysnCurrent, 
		intScreenId, 
		ysnVisible, 
		intOrder,
		intTransactionId
	)
	SELECT 
		GETUTCDATE(), 
		@amount, 
		@dueDate, 
		NULL, 
		@currentUserEntityId, 
		CASE WHEN @forResubmit = 1 THEN 'Resubmitted' ELSE 'Submitted' END, 
		@transactionNo,
		1,
		@submitScreenId, 
		1, 
		@maxOrder,
		@transactionId

	PRINT('created submitted entry')

	SELECT @submitApprovalId = SCOPE_IDENTITY()  

	DECLARE @approverListId INT
	DECLARE @approverId INT
	DECLARE @approverGroupId INT
	DECLARE @alternateUserId INT
	DECLARE @emailRequest BIT

	DECLARE @firstApprover BIT = 1
	DECLARE @requireForApproval BIT = 0
	DECLARE @requireForApprovalOnce BIT = 0

	WHILE EXISTS(SELECT 1 FROM @Approvers)
	BEGIN
		SELECT TOP 1 
			@approverId = CASE WHEN ISNULL(intApproverGroupId, 0) <> 0 THEN NULL ELSE intEntityUserSecurityId END,
			@approverGroupId = intApproverGroupId,
			@alternateUserId = intAlternateEntityUserSecurityId,
			@emailRequest = ysnEmailApprovalRequest,
			@approverListId = intApprovalListUserSecurityId
		FROM @Approvers ORDER BY intApproverLevel

		PRINT('1st loop')

		PRINT (@approverId)
		PRINT (@currentUserEntityId)

		IF (@approverId = @currentUserEntityId) 	
		BEGIN
			PRINT('continued 1st loop - current user is the approver (should not insert new submit record)')
			DELETE FROM @Approvers WHERE intApprovalListUserSecurityId = @approverListId
			CONTINUE
		END	

		PRINT('start 1st loop')

		SELECT @maxOrder = @maxOrder + 1

		-- Insert no need for approval entry
		INSERT INTO tblSMApproval(
			dtmDate, 
			dblAmount, 
			dtmDueDate, 
			intApproverId, 
			intAlternateApproverId,
			intApproverGroupId,
			intSubmittedById, 
			strStatus, 
			strTransactionNumber, 
			ysnEmail,
			ysnCurrent, 
			intScreenId, 
			ysnVisible, 
			intOrder,
			intTransactionId
		)
		SELECT 
			GETUTCDATE(), 
			@amount, 
			@dueDate, 
			@approverId, 
			@alternateUserId,
			@approverGroupId,
			@currentUserEntityId, 
			'Waiting for Approval',
			@transactionNo,
			@emailRequest,
			@firstApprover,
			@submitScreenId, 
			CASE WHEN @firstApprover = 1 THEN 1 ELSE 0 END,
			CASE WHEN @firstApprover = 1 THEN @maxOrder ELSE -1 END,
			@transactionId

		SET @waitingForApprovalId = SCOPE_IDENTITY()

		EXEC uspSMAddApprovalsForTransaction
				@approverId = @approverId, 
				@approverGroupId = @approverGroupId, 
				@screenId = @screenId, 
				@submitApprovalId = @submitApprovalId, 
				@waitingForApprovalId = @waitingForApprovalId, 
				@approverConfiguration = @approverConfiguration,
				@result = @requireForApproval OUTPUT

		IF @firstApprover = 1 AND @requireForApproval = 1 
		BEGIN
			PRINT('first approver and require approval')

			--SET other approvers to 0 for the next loop
			SET @firstApprover = 0

			UPDATE tblSMApproval
			SET ysnCurrent = 0
			WHERE intApprovalId = @submitApprovalId
		END

		IF @requireForApproval = 1 AND @requireForApprovalOnce = 0
		BEGIN
			SET @requireForApprovalOnce = 1
		END
	   
		DELETE FROM @Approvers WHERE intApprovalListUserSecurityId = @approverListId  
	END

	IF @requireForApprovalOnce = 0
		BEGIN
			PRINT('no need for approval')

			UPDATE tblSMTransaction
			SET strApprovalStatus = 'No Need for Approval' WHERE intTransactionId = @transactionId

			DELETE FROM tblSMApproval WHERE intApprovalId = @waitingForApprovalId
			-- Increment this
			SELECT @maxOrder = @maxOrder + 1

			-- Insert no need for approval entry
			INSERT INTO tblSMApproval(
				dtmDate, 
				dblAmount, 
				dtmDueDate, 
				intApproverId, 
				intSubmittedById, 
				strStatus, 
				strTransactionNumber, 
				ysnCurrent, 
				intScreenId, 
				ysnVisible, 
				intOrder,
				intTransactionId
			)
			SELECT 
				GETUTCDATE(), 
				@amount, 
				@dueDate, 
				@approverId, 
				@currentUserEntityId, 
				'No Need for Approval',
				@transactionNo,
				1,
				@submitScreenId, 
				1,
				@maxOrder,
				@transactionId
		END
END