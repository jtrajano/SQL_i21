CREATE PROCEDURE dbo.uspCMSyncBankDepositTaskDetail
(
@intTaskDetailId INT
)
AS

declare @tempTable TABLE(
	intTaskDetailId INT,
	intTransactionId int,
	dblAmount decimal(18,6),
	intGLAccountId int,
	strDescription nvarchar(400),
	dtmDate DATETIME,
	intBankAccountId INT,
	intEntityId INT
)
declare 
	
	@intTransactionId int,
	@dblAmount decimal(18,6),
	@intGLAccountId int,
	@strDescription nvarchar(400),
	@dtmDate DATETIME,
	@intBankAccountId INT,
	@intEntityId INT,
	@strTransactionId NVARCHAR(40),
	@intStartingNumberId INT,
	@BankTransaction BankTransactionTable,
	@BankTransactionDetail	BankTransactionDetailTable,
	@intNewTransactionId INT,
	@intTaskId INT

	SELECT 
	@intTaskId = intTaskId,
	@intTransactionId=intTransactionId,
	@dblAmount=dblAmount,
	@intGLAccountId=intGLAccountId,
	@strDescription=strDescription,
	@dtmDate=dtmDate,
	@intBankAccountId=intBankAccountId,
	@intEntityId=intEntityId FROM tblCMResponsiblePartyTaskDetail
	WHERE intTaskDetailId = @intTaskDetailId

	IF @intTransactionId IS NULL
	BEGIN 
		SELECT TOP 1 @intStartingNumberId = intStartingNumberId 
		FROM dbo.tblSMStartingNumber 
		WHERE strTransactionType = 'Bank Deposit'

		EXEC uspSMGetStartingNumber @intStartingNumberId, @strTransactionId OUT


		INSERT INTO @BankTransaction(
		[intBankAccountId]
		,intTaskId
		, [strTransactionId]
		, [intCurrencyId]
		, [intBankTransactionTypeId]
		, [dtmDate]
		, [dblAmount]
		, strAmountInWords
		, [strMemo]
		--, [intCompanyLocationId] 
		, [intEntityId]
		, [intCreatedUserId]
		, [intLastModifiedUserId]) 
		SELECT
		@intBankAccountId
		,@intTaskId
		,@strTransactionId
		,3
		,1
		,@dtmDate
		,@dblAmount
		,dbo.fnConvertNumberToWord(@dblAmount)
		,@strDescription
		,@intEntityId
		,@intEntityId
		,@intEntityId
		
		--GETTING THE DETAIL
	INSERT INTO @BankTransactionDetail(
		  [intTransactionId]
		
		, [dtmDate]
		, [intGLAccountId]
		, [strDescription]
		, [dblDebit]
		, [dblCredit]
		, [intEntityId]
	)
	SELECT 
		  [intTransactionId]	= 0
		, [dtmDate]				= @dtmDate
		, [intGLAccountId]		= @intGLAccountId
		, [strDescription]		= @strDescription
		, [dblDebit]			= 0
		, [dblCredit]			= @dblAmount
		, [intEntityId]			= @intEntityId

		EXEC dbo.uspCMCreateBankTransactionEntries @BankTransactionEntries			= @BankTransaction
												 , @BankTransactionDetailEntries	= @BankTransactionDetail
												 , @intTransactionId				= @intNewTransactionId OUT

		UPDATE tblCMResponsiblePartyTaskDetail SET intTransactionId = @intNewTransactionId 
		where intTaskDetailId = @intTaskDetailId
		DELETE FROM @BankTransaction
		DELETE FROM @BankTransactionDetail
	END
	ELSE
	BEGIN
		-- edit here
		UPDATE tblCMBankTransaction 
		SET dblAmount = @dblAmount
		, strAmountInWords = dbo.fnConvertNumberToWord(@dblAmount)
		,strMemo=@strDescription
		,dtmDate=@dtmDate
		,intBankAccountId=@intBankAccountId
		,intEntityId=@intEntityId
		where @intTransactionId = intTransactionId
		AND ysnPosted = 0

		update A
		SET
		intGLAccountId=@intGLAccountId,
		dblCredit = @dblAmount
		FROM
		tblCMBankTransactionDetail A join tblCMBankTransaction B ON
		A.intTransactionId = B.intTransactionId
		WHERE A.intTransactionId = @intTransactionId
		AND B.ysnPosted = 0
	END