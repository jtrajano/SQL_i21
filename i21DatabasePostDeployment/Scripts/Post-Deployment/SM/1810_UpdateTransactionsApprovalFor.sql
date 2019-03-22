GO
	PRINT N'START UPDATE APPROVAL TRANSACTION REFERENCE'

	
	--Select all transaction which approval status is "Waiting for Approval"--

	IF OBJECT_ID('tempdb..#TempSMTransaction') IS NOT NULL
		DROP TABLE #TempSMTransaction

	IF OBJECT_ID('tempdb..#TempSMApprovalListUserSecurity') IS NOT NULL
		DROP TABLE #TempSMApprovalListUserSecurity


	Create TABLE #TempSMTransaction
	(
		[intTransactionId]		INT													NOT NULL,
		[intScreenId]			[int]												NOT NULL,
		[strTransactionNo]		[nvarchar](50)	COLLATE Latin1_General_CI_AS		NULL,
		[intEntityId]			[int]												NULL, 
		[strApprovalStatus]		[nvarchar](150) COLLATE Latin1_General_CI_AS		NULL,
		[intApprovalForId]		[int]												NULL,
		[strApprovalFor]		[nvarchar](150) COLLATE Latin1_General_CI_AS		NULL,
		[ysnOnceApproved]		[bit]												NULL
	)

	Create TABLE #TempSMApprovalListUserSecurity
	(
		[intApprovalListUserSecurityId]		INT				NOT NULL,
		[intApprovalListId]					[int]			NOT NULL,
		[intEntityUserSecurityId]			[int]			NULL, 
		[intApproverGroupId]				[int]			NULL
	)

	-- Get all "Waiting for Approval" records without linking
	INSERT INTO #TempSMTransaction(intTransactionId, intScreenId, strTransactionNo, intEntityId, strApprovalStatus, ysnOnceApproved, intApprovalForId, strApprovalFor)
	SELECT intTransactionId, intScreenId, strTransactionNo, intEntityId, strApprovalStatus, ysnOnceApproved, intApprovalForId, strApprovalFor
	FROM tblSMTransaction
	WHERE strApprovalStatus = 'Waiting for Approval' and intApprovalForId IS NULL

	DECLARE transaction_cursor CURSOR FOR
	SELECT intTransactionId, intEntityId, intScreenId
	FROM #TempSMTransaction


	DECLARE @intTransactionId INT
	DECLARE @intEntityId INT 
	DECLARE @intApprovalListId INT 
	DECLARE @intScreenId INT
	DECLARE @hasSameApprovalApprovers BIT
	
	DECLARE @approverCount INT 
	DECLARE @approverGroupCount INT
	DECLARE @userSecurityCount INT
	DECLARE @userSecurityGroupCount INT
	
	DECLARE @intApprovalForId INT
	DECLARE @intUserSecurityRequireApprovalForId INT

	OPEN transaction_cursor
	FETCH NEXT FROM transaction_cursor into @intTransactionId, @intEntityId, @intScreenId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--Level 1: Entity
		--check if entity approval details (tblEMEntityRequireApprovalFor) is the same with intApproverId/intApproverGroupId of tblSMApproval
		IF @intEntityId IS NOT NULL
		BEGIN
			delete from #TempSMApprovalListUserSecurity
			SET @hasSameApprovalApprovers = 0
			SET @approverCount = 0
			SET @approverGroupCount = 0
			SET @userSecurityCount = 0
			SET @userSecurityGroupCount = 0
			SET @intApprovalForId = 0
			SET @intApprovalListId = NULL
	
			select @intApprovalListId = intApprovalListId, @intApprovalForId = intEntityRequireApprovalForId 
			from tblEMEntityRequireApprovalFor 
			where intEntityId = @intEntityId and intScreenId = @intScreenId
			
			IF @intApprovalListId IS NOT NULL
			BEGIN
				--get all approvers using approvalListId
				INSERT INTO #TempSMApprovalListUserSecurity(intApprovalListUserSecurityId, intApprovalListId, intEntityUserSecurityId, intApproverGroupId)
				SELECT intApprovalListUserSecurityId, intApprovalListId, intEntityUserSecurityId, intApproverGroupId
				FROM tblSMApprovalListUserSecurity
				WHERE intApprovalListId = @intApprovalListId

				--compare approver count if the same
				IF EXISTS(SELECT TOP 1 1 FROM #TempSMApprovalListUserSecurity)
				BEGIN
					--normal approver--
					select @approverCount = count(distinct intApproverId) 
					from tblSMApproval a 
					where a.intApproverId in (
						select intEntityUserSecurityId from #TempSMApprovalListUserSecurity
					)
					and intTransactionId = @intTransactionId and strStatus = 'Waiting for Approval'

					select @userSecurityCount = count(distinct intEntityUserSecurityId)
					from #TempSMApprovalListUserSecurity

					--group approver--
					select @approverGroupCount = count(distinct intApproverGroupId) 
					from tblSMApproval a 
					where a.intApproverGroupId in (
						select intApproverGroupId from #TempSMApprovalListUserSecurity
					)
					and intTransactionId = @intTransactionId and strStatus = 'Waiting for Approval'

					select @userSecurityGroupCount = count(distinct intApproverGroupId)
					from #TempSMApprovalListUserSecurity

					--update if the same
					if @approverCount = @userSecurityCount and @approverGroupCount = @userSecurityGroupCount
					BEGIN
						SET @hasSameApprovalApprovers = 1

						UPDATE tblSMTransaction SET 
							intApprovalForId = @intApprovalForId,
							strApprovalFor = 'ENTITY'
						WHERE intTransactionId = @intTransactionId
					END

				END
			END
		END

		--Level 3: User
		--check if user approval details (tblSMUserSecurityRequireApprovalFor) is the same with intApproverId/intApproverGroupId of tblSMApproval
		IF @hasSameApprovalApprovers = 0
		BEGIN
			delete from #TempSMApprovalListUserSecurity
			SET @hasSameApprovalApprovers = 0
			SET @approverCount = 0
			SET @approverGroupCount = 0
			SET @userSecurityCount = 0
			SET @userSecurityGroupCount = 0
			SET @intApprovalForId = 0
			SET @intApprovalListId = NULL
	
			--set intEntityId from submitter in tblSMApproval which should be the last submitter
			select top 1 @intEntityId = intSubmittedById 
			from tblSMApproval 
			where intTransactionId = @intTransactionId and (strStatus = 'Submitted' or strStatus = 'Resubmitted')
			order by intApprovalId desc

			select @intApprovalListId = intApprovalListId, @intApprovalForId = intUserSecurityReqApprovalForId 
			from tblSMUserSecurityRequireApprovalFor 
			where intEntityUserSecurityId = @intEntityId and intScreenId = @intScreenId
			
			IF @intApprovalListId IS NOT NULL
			BEGIN
				--get all approvers using approvalListId
				INSERT INTO #TempSMApprovalListUserSecurity(intApprovalListUserSecurityId, intApprovalListId, intEntityUserSecurityId, intApproverGroupId)
				SELECT intApprovalListUserSecurityId, intApprovalListId, intEntityUserSecurityId, intApproverGroupId
				FROM tblSMApprovalListUserSecurity
				WHERE intApprovalListId = @intApprovalListId

				--compare approver count if the same
				IF EXISTS(SELECT TOP 1 1 FROM #TempSMApprovalListUserSecurity)
				BEGIN
					--normal approver--
					select @approverCount = count(distinct intApproverId) 
					from tblSMApproval a 
					where a.intApproverId in (
						select intEntityUserSecurityId from #TempSMApprovalListUserSecurity
					)
					and intTransactionId = @intTransactionId and strStatus = 'Waiting for Approval'

					select @userSecurityCount = count(distinct intEntityUserSecurityId)
					from #TempSMApprovalListUserSecurity

					--group approver--
					select @approverGroupCount = count(distinct intApproverGroupId) 
					from tblSMApproval a 
					where a.intApproverGroupId in (
						select intApproverGroupId from #TempSMApprovalListUserSecurity
					)
					and intTransactionId = @intTransactionId and strStatus = 'Waiting for Approval'

					select @userSecurityGroupCount = count(distinct intApproverGroupId)
					from #TempSMApprovalListUserSecurity

					--update if the same
					if @approverCount = @userSecurityCount and @approverGroupCount = @userSecurityGroupCount
					BEGIN
						SET @hasSameApprovalApprovers = 1

						UPDATE tblSMTransaction SET 
							intApprovalForId = @intApprovalForId,
							strApprovalFor = 'USER'
						WHERE intTransactionId = @intTransactionId
					END

				END
			END
		END

		

	FETCH NEXT FROM transaction_cursor into @intTransactionId, @intEntityId, @intScreenId
	END

	CLOSE transaction_cursor
	DEALLOCATE transaction_cursor


	PRINT N'END UPDATE APPROVAL TRANSACTION REFERENCE'

GO