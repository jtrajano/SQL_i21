CREATE PROC [dbo].[uspRKM2MGLPost]  
		@intM2MInquiryId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @GLEntries AS RecapTableType
	DECLARE @batchId NVARCHAR(100)
	DECLARE @strBatchId NVARCHAR(100)
	DECLARE @ErrMsg NVARCHAR(Max)

DECLARE @intCommodityId int
DECLARE @dtmCurrenctGLPostDate DATETIME
DECLARE @dtmPreviousGLPostDate DATETIME
DECLARE @dtmGLReverseDate DATETIME
DECLARE @dtmPrviousGLReverseDate DATETIME
SELECT @intCommodityId = intCommodityId,@dtmCurrenctGLPostDate=dtmGLPostDate,@dtmGLReverseDate=dtmGLReverseDate FROM tblRKM2MInquiry where intM2MInquiryId=@intM2MInquiryId
SELECT TOP 1 @dtmPreviousGLPostDate=dtmGLPostDate,@dtmPrviousGLReverseDate=dtmGLReverseDate  FROM tblRKM2MInquiry where ysnPost=1 and intCommodityId=@intCommodityId order by dtmGLPostDate desc

IF (@dtmGLReverseDate IS NULL)
BEGIN
RAISERROR('Please save the record before posting.',16,1)
END

IF (convert(datetime,@dtmCurrenctGLPostDate) <= convert(datetime,@dtmPrviousGLReverseDate))
BEGIN
RAISERROR('Current date cannot less than the previous post date',16,1)
END

--IF EXISTS(SELECT 1 FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedGainOnBasisId,0) = 0)
--RAISERROR('Unrealized Gain On Basis cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
--IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedGainOnFuturesId,0) = 0)
--RAISERROR('Unrealized Gain On Futures cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
--IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedGainOnCashId,0) = 0)
--RAISERROR('Unrealized Gain On Cash cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
--IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedLossOnBasisId,0) = 0)
--RAISERROR('Unrealized Loss On Basis cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
--IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedLossOnFuturesId,0) = 0)
--RAISERROR('Unrealized Loss On Futures cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
--IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedLossOnCashId,0) = 0)
--RAISERROR('Unrealized Loss On Cash cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
--IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedGainOnInventoryBasisIOSId,0) = 0)
--RAISERROR('Unrealized Gain On Inventory Basis IOS cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
--IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedGainOnInventoryFuturesIOSId,0) = 0)
--RAISERROR('Unrealized Gain On Inventory Futures IOS cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
--IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedGainOnInventoryCashIOSId,0) = 0)
--RAISERROR('Unrealized Gain On Inventory Cash IOS cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
--IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedLossOnInventoryBasisIOSId,0) = 0)
--RAISERROR('Unrealized Loss On Inventory Basis IOS cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
--IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedLossOnInventoryFuturesIOSId,0) = 0)
--RAISERROR('Unrealized Loss On Inventory Futures IOS cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
--IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedLossOnInventoryCashIOSId,0) = 0)
--RAISERROR('Unrealized Loss On Inventory Cash IOS cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
--IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedGainOnInventoryIntransitIOSId,0) = 0)
--RAISERROR('Unrealized Gain On Inventory Intransit IOS cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
--IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedLossOnInventoryIntransitIOSId,0) = 0)
--RAISERROR('Unrealized Gain On Inventory Intransit IOS cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)

--============================================================
-- SETUP VALIDATION
--=============================================================

SELECT * INTO #tmpPostRecap
FROM tblRKM2MPostRecap 
WHERE intM2MInquiryId = @intM2MInquiryId

DECLARE @tblResult  TABLE (
	Result nvarchar(200)
)


WHILE EXISTS (SELECT TOP 1 1 FROM #tmpPostRecap)
BEGIN

	DECLARE @strTransactionId NVARCHAR(50)
			,@strContractNumber NVARCHAR(50)
			,@intContractSeq NVARCHAR(20)
			,@intUsedCommoidtyId INT
			,@intUseCompanyLocationId INT
			,@strCommodityCode NVARCHAR(100)
			,@intM2MTransactionId INT
			,@strTransactionType NVARCHAR(100)
			,@dblAmount NUMERIC(18,6)

	SELECT TOP 1 
		@intM2MTransactionId = intM2MTransactionId
		,@strTransactionId = strTransactionId
		,@strTransactionType = strTransactionType
		,@dblAmount = (dblDebit + dblCredit)
	FROM #tmpPostRecap

	
	IF @strTransactionType = 'Mark To Market-Futures Derivative' OR @strTransactionType = 'Mark To Market-Futures Derivative Offset'
	BEGIN

		--Get the used Commodity and Location in the Derivative Entry
		SELECT 
			@intUsedCommoidtyId = DE.intCommodityId
			,@strCommodityCode = C.strCommodityCode
			,@intUseCompanyLocationId = DE.intLocationId 
		FROM tblRKFutOptTransaction  DE
			INNER JOIN tblICCommodity C ON DE.intCommodityId = C.intCommodityId
		WHERE strInternalTradeNo = @strTransactionId

	END
	ELSE
	BEGIN

		--Parse strTransactionId to get strContractNumber and intContractSeq
		--Before dash(-) is the contract number after that is the contract sequence
		SET @strContractNumber = SUBSTRING(@strTransactionId,0,CHARINDEX('-',@strTransactionId))
		SET @intContractSeq = SUBSTRING(@strTransactionId,CHARINDEX('-',@strTransactionId) + 1,LEN(@strTransactionId) - CHARINDEX('-',@strTransactionId)) 

		--Get the used Commodity and Location in the Contract
		SELECT 
			@intUsedCommoidtyId = H.intCommodityId
			,@strCommodityCode = C.strCommodityCode
			,@intUseCompanyLocationId = D.intCompanyLocationId 
		FROM tblCTContractHeader  H
			INNER JOIN tblCTContractDetail D ON H.intContractHeaderId = D.intContractHeaderId
			INNER JOIN tblICCommodity C ON H.intCommodityId = C.intCommodityId
		WHERE 
			H.strContractNumber = @strContractNumber 
			AND D.intContractSeq = @intContractSeq

	END

	DECLARE @strPrimaryAccountCode NVARCHAR(50)
			,@strLocationAccountCode NVARCHAR(50)
			,@strLOBAccountCode NVARCHAR(50)
			,@intAccountIdFromCompPref INT
			,@strAccountNumberToBeUse NVARCHAR(50)
			,@strErrorMessage NVARCHAR(200)

	SELECT @intAccountIdFromCompPref = (CASE WHEN @strTransactionType = 'Mark To Market-Basis' OR @strTransactionType = 'Mark To Market-Basis Intransit' THEN
												case when isnull(@dblAmount,0) >= 0 then compPref.intUnrealizedGainOnBasisId else compPref.intUnrealizedLossOnBasisId end
											 WHEN @strTransactionType = 'Mark To Market-Basis Offset' OR @strTransactionType = 'Mark To Market-Basis Intransit Offset' THEN
												case when isnull(@dblAmount,0) >= 0 then compPref.intUnrealizedGainOnInventoryBasisIOSId else compPref.intUnrealizedLossOnInventoryBasisIOSId end
											 WHEN @strTransactionType = 'Mark To Market-Futures Derivative' OR @strTransactionType = 'Mark To Market-Futures'  OR @strTransactionType = 'Mark To Market-Futures Intransit' THEN
												case when isnull(@dblAmount,0) >= 0 then compPref.intUnrealizedGainOnFuturesId else compPref.intUnrealizedLossOnFuturesId end
											 WHEN @strTransactionType = 'Mark To Market-Futures Derivative Offset' OR @strTransactionType = 'Mark To Market-Futures Offset' OR @strTransactionType = 'Mark To Market-Futures Intransit Offset' THEN
												case when isnull(@dblAmount,0) >= 0 then compPref.intUnrealizedGainOnInventoryFuturesIOSId else compPref.intUnrealizedLossOnInventoryFuturesIOSId end
											 WHEN @strTransactionType = 'Mark To Market-Cash' OR @strTransactionType = 'Mark To Market-Cash Intransit' THEN
												case when isnull(@dblAmount,0) >= 0 then compPref.intUnrealizedGainOnCashId else compPref.intUnrealizedLossOnCashId end
											 WHEN @strTransactionType = 'Mark To Market-Cash Offset' OR @strTransactionType = 'Mark To Market-Futures Intransit Offset' THEN
												case when isnull(@dblAmount,0) >= 0 then compPref.intUnrealizedGainOnInventoryCashIOSId else compPref.intUnrealizedLossOnInventoryCashIOSId end
											 WHEN @strTransactionType = 'Mark To Market-Ratio' THEN
												case when isnull(@dblAmount,0) >= 0 then compPref.intUnrealizedGainOnRatioId else compPref.intUnrealizedLossOnRatioId end
											 WHEN @strTransactionType = 'Mark To Market-Ratio Offset' THEN
												case when isnull(@dblAmount,0) >= 0 then compPref.intUnrealizedGainOnInventoryRatioIOSId else compPref.intUnrealizedLossOnInventoryRatioIOSId end
											 ELSE
												0
										END)
	FROM tblRKCompanyPreference compPref

	IF ISNULL(@intAccountIdFromCompPref,0) = 0
	BEGIN
		GOTO No_GL_Setup_In_Comp_Pref
	END

	--Get the account code for Primary
	SET @strPrimaryAccountCode = ''
	select 
	@strPrimaryAccountCode = acct.[Primary Account]
	from vyuGLAccountView acct
	WHERE
	 acct.intAccountId = @intAccountIdFromCompPref


	--Get the account code for Location
	SET @strLocationAccountCode = ''
	SELECT 
	@strLocationAccountCode = acctSgmt.strCode
	FROM tblSMCompanyLocation compLoc
	LEFT OUTER JOIN tblGLAccountSegment acctSgmt ON compLoc.intProfitCenter = acctSgmt.intAccountSegmentId
	WHERE intCompanyLocationId = @intUseCompanyLocationId

	--If LOB is setup on GL Account Structure. intStructureType 5 is equal to Line of Bussiness on default data
	IF EXISTS (SELECT TOP 1 1 FROM tblGLAccountStructure WHERE intStructureType = 5)
	BEGIN

		--Check if there is LOB setup for commodity
		IF NOT EXISTS (SELECT TOP 1 * FROM tblICCommodity com INNER JOIN tblSMLineOfBusiness lob ON com.intLineOfBusinessId = lob.intLineOfBusinessId WHERE intCommodityId = @intUsedCommoidtyId)
		BEGIN
			GOTO No_LOB_Setup
		END

		--Get the account code for LOB
		SET @strLOBAccountCode = ''
		SELECT 
		@strLOBAccountCode = acctSgmt.strCode
		FROM tblICCommodity com
		INNER JOIN tblSMLineOfBusiness lob ON com.intLineOfBusinessId = lob.intLineOfBusinessId
		LEFT OUTER JOIN tblGLAccountSegment acctSgmt ON lob.intSegmentCodeId = acctSgmt.intAccountSegmentId
		WHERE intCommodityId = @intUsedCommoidtyId

		IF ISNULL(@strLOBAccountCode,'') = ''
		BEGIN
			GOTO No_LOB_Segment
		END

		--Build the account number with LOB
		SET @strAccountNumberToBeUse = ''

		IF ISNULL(@strPrimaryAccountCode,'') <> '' AND ISNULL(@strLocationAccountCode,'') <> '' AND ISNULL(@strLOBAccountCode,'') <> '' 
		BEGIN
			SET @strAccountNumberToBeUse =  @strPrimaryAccountCode +'-'+ @strLocationAccountCode +'-'+ @strLOBAccountCode
		END
	END 
	ELSE
	BEGIN
		--Build the account number without LOB
		SET @strAccountNumberToBeUse = ''

		IF ISNULL(@strPrimaryAccountCode,'') <> '' AND ISNULL(@strLocationAccountCode,'') <> ''
		BEGIN
			SET @strAccountNumberToBeUse =  @strPrimaryAccountCode +'-'+ @strLocationAccountCode
		END
	END

	--Check if GL Account Number exists. If not throw an error.
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLAccount WHERE strAccountId = ISNULL(@strAccountNumberToBeUse,''))
	BEGIN
		INSERT INTO @tblResult(Result)
		VALUES('GL Account Number ' + @strAccountNumberToBeUse + ' does not exist.')
		GOTO Delete_Routine
	END
	ELSE
	BEGIN
		DECLARE @intAccountIdToBeUse INT
		SELECT TOP 1 @intAccountIdToBeUse = intAccountId FROM tblGLAccount WHERE strAccountId = ISNULL(@strAccountNumberToBeUse,'')
		
		--Update the Post Recap table to the right GL Account
		UPDATE tblRKM2MPostRecap SET
			intAccountId = @intAccountIdToBeUse
			,strAccountId = @strAccountNumberToBeUse
		WHERE intM2MTransactionId = @intM2MTransactionId

		GOTO Delete_Routine
	END
	

No_GL_Setup_In_Comp_Pref:
	IF @strTransactionType = 'Mark To Market-Basis' OR @strTransactionType = 'Mark To Market-Basis Intransit' 
	BEGIN
		IF isnull(@dblAmount,0) >= 0 
		BEGIN 
			SET @strErrorMessage = 'Unrealized Gain On Basis cannot be blank. Please set up the default account(s) in Company Configuration Risk Management GL Account tab.'
		END
		ELSE
		BEGIN
			SET @strErrorMessage = 'Unrealized Loss On Basis cannot be blank. Please set up the default account(s) in Company Configuration Risk Management GL Account tab.'
		END
	END
	IF @strTransactionType = 'Mark To Market-Basis Offset' OR @strTransactionType = 'Mark To Market-Basis Intransit Offset' 
	BEGIN
		IF isnull(@dblAmount,0) >= 0 
		BEGIN 
			SET @strErrorMessage = 'Unrealized Gain On Basis (Inventory Offset) cannot be blank. Please set up the default account(s) in Company Configuration Risk Management GL Account tab.'
		END
		ELSE
		BEGIN
			SET @strErrorMessage = 'Unrealized Loss On Basis (Inventory Offset) cannot be blank. Please set up the default account(s) in Company Configuration Risk Management GL Account tab.'
		END
		
	END	
	IF @strTransactionType = 'Mark To Market-Futures Derivative' OR @strTransactionType = 'Mark To Market-Futures'  OR @strTransactionType = 'Mark To Market-Futures Intransit'
	BEGIN
		IF isnull(@dblAmount,0) >= 0 
		BEGIN 
			SET @strErrorMessage = 'Unrealized Gain On Futures cannot be blank. Please set up the default account(s) in Company Configuration Risk Management GL Account tab.'
		END
		ELSE
		BEGIN
			SET @strErrorMessage = 'Unrealized Loss On Futures cannot be blank. Please set up the default account(s) in Company Configuration Risk Management GL Account tab.'
		END
	END
	IF @strTransactionType = 'Mark To Market-Futures Derivative Offset' OR @strTransactionType = 'Mark To Market-Futures Offset' OR @strTransactionType = 'Mark To Market-Futures Intransit Offset'
	BEGIN
		IF isnull(@dblAmount,0) >= 0 
		BEGIN 
			SET @strErrorMessage = 'Unrealized Gain On Futures (Inventory Offset) cannot be blank. Please set up the default account(s) in Company Configuration Risk Management GL Account tab.'
		END
		ELSE
		BEGIN
			SET @strErrorMessage = 'Unrealized Loss On Futures (Inventory Offset) cannot be blank. Please set up the default account(s) in Company Configuration Risk Management GL Account tab.'
		END
	END	
	IF @strTransactionType = 'Mark To Market-Cash' OR @strTransactionType = 'Mark To Market-Cash Intransit' 
	BEGIN
		IF isnull(@dblAmount,0) >= 0 
		BEGIN 
			SET @strErrorMessage = 'Unrealized Gain On Cash cannot be blank. Please set up the default account(s) in Company Configuration Risk Management GL Account tab.'
		END
		ELSE
		BEGIN
			SET @strErrorMessage = 'Unrealized Loss On Cash cannot be blank. Please set up the default account(s) in Company Configuration Risk Management GL Account tab.'
		END
	END
	IF @strTransactionType = 'Mark To Market-Cash Offset' OR @strTransactionType = 'Mark To Market-Futures Intransit Offset'
	BEGIN
		IF isnull(@dblAmount,0) >= 0 
		BEGIN 
			SET @strErrorMessage = 'Unrealized Gain On Cash (Inventory Offset) cannot be blank. Please set up the default account(s) in Company Configuration Risk Management GL Account tab.'
		END
		ELSE
		BEGIN
			SET @strErrorMessage = 'Unrealized Loss On Cash (Inventory Offset) cannot be blank. Please set up the default account(s) in Company Configuration Risk Management GL Account tab.'
		END
	END	
	IF @strTransactionType = 'Mark To Market-Ratio'
	BEGIN
		IF isnull(@dblAmount,0) >= 0 
		BEGIN 
			SET @strErrorMessage = 'Unrealized Gain On Ratio cannot be blank. Please set up the default account(s) in Company Configuration Risk Management GL Account tab.'
		END
		ELSE
		BEGIN
			SET @strErrorMessage = 'Unrealized Loss On Ratio cannot be blank. Please set up the default account(s) in Company Configuration Risk Management GL Account tab.'
		END
	END
	IF @strTransactionType = 'Mark To Market-Ratio Offset' 
	BEGIN
		IF isnull(@dblAmount,0) >= 0 
		BEGIN 
			SET @strErrorMessage = 'Unrealized Gain On Ratio (Inventory Offset) cannot be blank. Please set up the default account(s) in Company Configuration Risk Management GL Account tab.'
		END
		ELSE
		BEGIN
			SET @strErrorMessage = 'Unrealized Loss On Ratio (Inventory Offset) cannot be blank. Please set up the default account(s) in Company Configuration Risk Management GL Account tab.'
		END
	END	

	INSERT INTO @tblResult(Result)
	VALUES(@strErrorMessage)

	GOTO Delete_Routine

No_LOB_Segment:
	INSERT INTO @tblResult(Result)
	VALUES('Segment is missing on  Line of Business setup for commodity: ' + @strCommodityCode)

	GOTO Delete_Routine

No_LOB_Setup:
	INSERT INTO @tblResult(Result)
	VALUES('No Line of Business setup for commodity ' + @strCommodityCode)

	GOTO Delete_Routine


Delete_Routine:
	DELETE FROM #tmpPostRecap WHERE intM2MTransactionId = @intM2MTransactionId

END

IF (SELECT COUNT(Result) FROM @tblResult) > 0  
BEGIN
	SELECT DISTINCT * from @tblResult

	GOTO Exit_Routine
END



BEGIN TRANSACTION
	IF (@batchId IS NULL)
	BEGIN
		EXEC uspSMGetStartingNumber 3, @batchId OUT
	END

	SET @strBatchId = @batchId

	INSERT INTO @GLEntries (
		 [dtmDate]
		,[strBatchId]
		,[intAccountId]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[strDescription]
		,[intCurrencyId]
		,[dtmTransactionDate]
		,[strTransactionId]
		,[intTransactionId]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intConcurrencyId]
		,[dblExchangeRate]
		,[dtmDateEntered]
		,[ysnIsUnposted]
		,[strCode]
		,[strReference]  
		,[intEntityId]
		,[intUserId]      
		,[intSourceLocationId]
		,[intSourceUOMId]
		)
	SELECT [dtmDate]
		,@batchId
		,[intAccountId]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[strDescription]
		,[intCurrencyId]
		,[dtmTransactionDate]
		,[strTransactionId]
		,[intTransactionId]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intConcurrencyId]
		,[dblExchangeRate]
		,[dtmDateEntered]
		,[ysnIsUnposted]
		,'RK'
		,[strReference]  
		,[intEntityId]
		,[intUserId]  
		,[intSourceLocationId]
		,[intSourceUOMId]
	FROM tblRKM2MPostRecap
	WHERE intM2MInquiryId = @intM2MInquiryId

	EXEC dbo.uspGLBookEntries @GLEntries,1 --@ysnPost

	UPDATE tblRKM2MPostRecap SET ysnIsUnposted=1,strBatchId=@strBatchId WHERE intM2MInquiryId = @intM2MInquiryId
	UPDATE tblRKM2MInquiry SET ysnPost=1,dtmPostedDateTime=getdate(),strBatchId=@batchId,dtmUnpostedDateTime=null WHERE intM2MInquiryId = @intM2MInquiryId

	COMMIT TRAN	
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION
	IF @ErrMsg != ''
	BEGIN
		RAISERROR (
				@ErrMsg
				,16
				,1
				,'WITH NOWAIT'
				)
	END
END CATCH

Exit_Routine: