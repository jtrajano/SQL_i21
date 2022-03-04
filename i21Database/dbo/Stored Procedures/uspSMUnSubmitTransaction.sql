CREATE PROCEDURE [dbo].[uspSMUnSubmitTransaction]
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
				'Wating for Submit' 

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
				strApprovalStatus = 'Wating for Submit'
			WHERE intTransactionId = @transactionId

			PRINT('updating transaction')
		END

	--transactionNo is missing when the transaction was created using [uspSMAuditLog]
	--i.e. voucher was created in IR or other modules
	IF ISNULL(@transactionNo, '') != '' AND ISNULL((SELECT TOP 1 strTransactionNo FROM tblSMTransaction WHERE intTransactionId = @transactionId), '') = ''
	BEGIN
		UPDATE tblSMTransaction
		SET strTransactionNo = @transactionNo
		WHERE intTransactionId = @transactionId
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
		'Waiting for Submit',
		1,
		@submitScreenId, 
		1, 
		@maxOrder,
		@transactionId

	PRINT('created waiting for submit entry')

END