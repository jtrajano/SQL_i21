CREATE PROCEDURE [dbo].[uspNRCreateCashEntry]
 @intNoteId int
,@intNoteTransId Int
,@dblAmount decimal(18,6)
, @intGLAccountId Int
, @intTransactionId int = 0	OUTPUT		
AS
BEGIN

	BEGIN TRY

		DECLARE @intBankTransactionTypeId Int
		, @intBankAccountId int			, @intCurrencyId Int		, @dblExchangeRate Decimal(38,20)		, @dtmDate DateTime
		, @strPayee nvarchar(300)		, @intEntityId Int			, @strAddress nvarchar(65)				, @strZipCode nvarchar(42)
		, @strCity  nvarchar(85)		, @strState nvarchar(60)	, @strCountry nvarchar(75)				--, @dblAmount decimal(18,6)
		, @strMemo nvarchar(255)		, @intCreatedUserId Int		, @dtmTranCreated datetime				, @strAmountInWords nvarchar(max)
		, @strDescription nvarchar(255)	, @ErrMsg nvarchar(max)
		
		--Get constant values
		SET @intBankTransactionTypeId = 1 --18
		SET @dblExchangeRate = 1
		
		SELECT @strDescription = strDescription FROM dbo.tblGLAccount 
		Where intAccountId = @intGLAccountId 
		
		
	--Bank accc - GL acc =  Cash acc from GL acc ( only 1 GL cash accpunt will be associated with Banc account GL account)
		--SELECT @intBankAccountId = intAccountId, @strDescription = strDescription FROM dbo.tblGLAccount 
		--Where intAccountId in (Select intGLAccountId From dbo.tblCMBankAccount) 
		--AND intAccountGroupId In (Select intAccountGroupId from dbo.tblGLAccountGroup Where strAccountGroup = 'Cash Accounts')
		
		SELECT @intBankAccountId = intBankAccountId FROM dbo.tblCMBankAccount 
		WHERE intGLAccountId IN (SELECT intAccountId FROM dbo.tblGLAccount WHERE intAccountGroupId IN 
		(Select intAccountGroupId from dbo.tblGLAccountGroup Where strAccountGroup = 'Cash Accounts')
		)
		
		
		
		--Get currency Id
		SET @intCurrencyId = (
					SELECT TOP 1 intCurrencyID FROM tblSMCurrency 
					WHERE intCurrencyID = (CASE WHEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency') > 0 
					THEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency')
					  ELSE (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = 'USD') END)
					  )
	    
		-- Get customer related details and information              
		SELECT @strPayee = strCustomerNumber, @intEntityId = C.intEntityId	, @strAddress = Loc.strAddress
		, @strCity = Loc.strCity , @strCountry = strCountry	, @strState = Loc.strState , @strZipCode = Loc.strZipCode  
		From dbo.tblNRNote N
		JOIN dbo.tblARCustomer C On N.intCustomerId = C.intCustomerId
		INNER JOIN tblARCustomerToContact as CusToCon ON C.intDefaultContactId = CusToCon.intARCustomerToContactId
		LEFT JOIN tblEntityContact as Con ON CusToCon.intContactId = Con.intContactId
		LEFT JOIN tblEntityLocation as Loc ON C.intDefaultLocationId = Loc.intEntityLocationId
		WHERE N.intNoteId = @intNoteId
		
		-- Get Note related details
		SELECT @strMemo = strDescriptionName
		FROM dbo.tblNRNote N
		JOIN dbo.tblNRNoteDescription ND ON ND.intDescriptionId = N.intDescriptionId
		WHERE N.intNoteId = @intNoteId
	        
		-- Get Note Receive payment transaction related details
		SELECT @dtmDate = dtmNoteTranDate--, @dblAmount = dblTransAmount
		, @intEntityId = intLastModifiedUserId 	, @dtmTranCreated = dtmNoteTranDate
		FROM dbo.tblNRNoteTransaction 
		WHERE intNoteTransId = @intNoteTransId
		
		SELECT @intCreatedUserId = intUserSecurityID FROM dbo.tblSMUserSecurity Where intEntityId = @intEntityId
		
		SET @strAmountInWords = dbo.fnConvertNumberToWord(@dblAmount)

		--INSERT into tblCMBankTransaction
		INSERT INTO [dbo].[tblCMBankTransaction]
			   ([strTransactionId]           ,[intBankTransactionTypeId]           ,[intBankAccountId]           ,[intCurrencyId]----------1			
			   ,[dblExchangeRate]            ,[dtmDate]					           ,[strPayee]			         ,[intPayeeId]-------------2
			   ,[strAddress]	             ,[strZipCode]			               ,[strCity]		             ,[strState]---------------3
			   ,[strCountry]	             ,[dblAmount]				           ,[strAmountInWords]           ,[strMemo]----------------4
			   ,[strReferenceNo]             ,[dtmCheckPrinted]			           ,[ysnCheckToBePrinted]        ,[ysnCheckVoid]-----------5
			   ,[ysnPosted]		             ,[strLink]					           ,[ysnClr]		             ,[dtmDateReconciled]------6
			   ,[intBankStatementImportId]   ,[intBankFileAuditId]	               ,[strSourceSystem]            ,[intEntityId]------------7
			   ,[intCreatedUserId]           ,[intCompanyLocationId]	           ,[dtmCreated]	             ,[intLastModifiedUserId]--8
			   ,[dtmLastModified]            ,[intConcurrencyId])
		 VALUES
			   (@intNoteTransId              ,@intBankTransactionTypeId            ,@intBankAccountId            ,@intCurrencyId-----------1
			   ,@dblExchangeRate             ,@dtmDate					           ,@strPayee		             ,@intEntityId-------------2
			   ,@strAddress			         ,@strZipCode				           ,@strCity		             ,@strState----------------3
			   ,@strCountry			         ,@dblAmount				           ,@strAmountInWords            ,@strMemo-----------------4
			   ,''				             ,NULL						           ,0				             ,0  ----------------------5
			   ,0				             ,@intNoteId				           ,0				             ,NULL --------------------6
			   ,NULL			             ,NULL						           ,NULL			             ,@intEntityId ------------7
			   ,@intCreatedUserId            ,NULL						           ,@dtmTranCreated	             ,@intCreatedUserId -------8
			   ,GETDATE()		             ,1)
	    
		SELECT @intTransactionId = @@IDENTITY       
	      
	         
		INSERT INTO [dbo].[tblCMBankTransactionDetail]
			   ([intTransactionId]           ,[dtmDate]           ,[intGLAccountId]           ,[strDescription]
			   ,[dblDebit]			         ,[dblCredit]         ,[intUndepositedFundId]     ,[intEntityId]
			   ,[intCreatedUserId]           ,[dtmCreated]        ,[intLastModifiedUserId]    ,[dtmLastModified]
			   ,[intConcurrencyId])
		 VALUES
			   (@intTransactionId            ,@dtmDate            ,@intGLAccountId          ,@strDescription
			   ,0				             ,@dblAmount          ,NULL				          ,NULL
			   ,@intCreatedUserId            ,@dtmTranCreated     ,@intCreatedUserId          ,GETDATE()
			   ,1)
	   
		
	--if @isSuccessful = 0
		DECLARE @ysnPost Bit, @ysnRecap Bit, @isSuccessful Bit, @message_id int
		SET @ysnPost = 1 --Post, 0 for Unpost
		SET @ysnRecap = 0 -- Recap
		EXEC dbo.uspCMPostBankDeposit @ysnPost, @ysnRecap, @intNoteTransId, @intCreatedUserId, @intEntityId, @isSuccessful, @message_id
	

		
	END TRY 
	BEGIN CATCH       
	 --IF XACT_STATE() != 0 ROLLBACK TRANSACTION    
	 SET @ErrMsg = ERROR_MESSAGE()      
	 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
	END CATCH
	
		
	
END