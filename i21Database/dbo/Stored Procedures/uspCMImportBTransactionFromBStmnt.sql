CREATE PROCEDURE [dbo].[uspCMImportBTransactionFromBStmnt]
@strBankStatementImportId NVARCHAR(40),
@intEntityId INT,
@intImportLogId INT,
@dtmCurrent DATETIME
AS
BEGIN

		SET QUOTED_IDENTIFIER OFF
		SET ANSI_NULLS ON
		SET NOCOUNT ON
		SET XACT_ABORT ON
		SET ANSI_WARNINGS ON

        DECLARE @tblTemp TABLE(
            intBankStatementImportId INT,
            intResponsibleBankAccountId INT,
			strBankDescription NVARCHAR(max) COLLATE Latin1_General_CI_AS NULL,
			strBankAccountNo NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL ,
			strReferenceNo NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
			strDebitCredit NVARCHAR(2) COLLATE Latin1_General_CI_AS NULL,
            dtmDate DATETIME,
            dblAmount DECIMAL(18,6)
        );
		DECLARE @intBankStatementImportId INT
		DECLARE @strBankDescription NVARCHAR(255)
		DECLARE @strBankAccountNo NVARCHAR(20)
		DECLARE @strReferenceNo NVARCHAR(50)
		DECLARE @strDebitCredit NVARCHAR(2)
		DECLARE @count INT
		DECLARE @bankTransaction AS BankTransactionTable;
		DECLARE @BankTransactionDetailEntries BankTransactionDetailTable
		DECLARE @strGLAccountId nvarchar(30)
		DECLARE @_Type nvarchar(50),@ReferenceNumber nvarchar(50)
		DECLARE @Loc table (Loc int)
		DECLARE @strID NVARCHAR(20)
		DECLARE @GL_Primary NVARCHAR(20)
		DECLARE @intBankAccountId INT
		DECLARE @ErrorMessage nvarchar(500)
		DECLARE  @IMPORT_STATUS_NOMATCHFOUND AS INT = 2 

		DECLARE @tblTempMacReportXRef table(
			_Type nvarchar(50),
			[Description_Contains] nvarchar(max)COLLATE Latin1_General_CI_AS NULL,
			AccountNumber nvarchar(50)COLLATE Latin1_General_CI_AS NULL,
			_Reference nvarchar(50)COLLATE Latin1_General_CI_AS NULL,
			CR_DR_Equals nvarchar(20)COLLATE Latin1_General_CI_AS NULL,
			GL_Primary nvarchar(20)COLLATE Latin1_General_CI_AS NULL,
			Bank_Acct nvarchar(50)COLLATE Latin1_General_CI_AS NULL,
			X_Ref_Field nvarchar(50)COLLATE Latin1_General_CI_AS NULL,
			X_Ref_Position int,
			X_Ref_Length tinyint,
			_ReferenceNot nvarchar(50)COLLATE Latin1_General_CI_AS NULL
		)
		DECLARE @tblTempMacReportXRef2 table(
			_Type nvarchar(50),
			[Description_Contains] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
			AccountNumber nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
			_Reference nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
			CR_DR_Equals nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
			GL_Primary nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
			Bank_Acct nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
			X_Ref_Field nvarchar(50)COLLATE Latin1_General_CI_AS NULL,
			X_Ref_Position int,
			X_Ref_Length tinyint,
			_ReferenceNot nvarchar(50)COLLATE Latin1_General_CI_AS NULL
		)
		DECLARE @ErrorTable TABLE(
			intId INT IDENTITY(1,1),
			strError NVARCHAR(MAX),
			intBankStatementImportId int
		)
		DECLARE @strError NVARCHAR(100)
  		--DECLARE @trancount int;
		--DECLARE @xstate int;
		--SET @trancount = @@trancount;
		

		-- if @trancount = 0
        --     BEGIN TRANSACTION
        -- else
        --     SAVE TRANSACTION uspCMImportBXfer;
		

		-- GET UNMATCHED RECORD IN BANK STATEMENT TABLE ( NOT IN TASK)

		INSERT INTO @tblTemp (intBankStatementImportId, strBankDescription,strBankAccountNo, strReferenceNo, strDebitCredit, dtmDate, dblAmount)
        SELECT 
			S.intBankStatementImportId,
            S.strBankDescription,
			S.strBankAccountNo,
			S.strReferenceNo,
			S.strDebitCredit,
			S.dtmDate,
			S.dblAmount
        FROM 
            tblCMBankStatementImport S LEFT JOIN
			tblCMResponsiblePartyTask T on T.intBankStatementImportId = S.intBankStatementImportId
        WHERE 
            @IMPORT_STATUS_NOMATCHFOUND = ISNULL(intImportStatus, 0) 
            AND @strBankStatementImportId = S.strBankStatementImportId
			AND T.intBankStatementImportId IS NULL


        IF NOT EXISTS (SELECT TOP 1 1 FROM @tblTemp)
			GOTO EndProcedure;

		
		
		WHILE EXISTS(SELECT TOP 1 1 FROM @tblTemp)
		BEGIN 
		
			SELECT TOP 1 
			@intBankStatementImportId= A.intBankStatementImportId , 
			@strBankDescription = strBankDescription, 
			@strBankAccountNo = A.strBankAccountNo,
			@strDebitCredit = strDebitCredit,
			@strReferenceNo = strReferenceNo
			FROM @tblTemp A 

			SELECT @intBankAccountId = intBankAccountId FROM vyuCMBankAccount  WHERE strBankAccountNo = @strBankAccountNo

			IF @intBankAccountId IS NULL 
			BEGIN
				-- SET @strError = @strBankAccountNo + ' is not an existing bank account'
				insert into @ErrorTable select @strBankAccountNo + ' is not an existing bank account', @intBankStatementImportId
			 	GOTO NextLoop;
			END

			insert into @tblTempMacReportXRef(_Type,[Description_Contains],AccountNumber,_Reference,CR_DR_Equals,GL_Primary,Bank_Acct,X_Ref_Field,X_Ref_Position,X_Ref_Length,_ReferenceNot)
			SELECT [Type],[Description_Contains],AccountNumber,Reference,CR_DR_Equals,GL_Primary,Bank_Acct,X_Ref_Field,X_Ref_Position,X_Ref_Length,ReferenceNot FROM tblCMMacReportXRef 
			WHERE CHARINDEX( Description_Contains,   @strBankDescription ,1 ) > 0
			
			select @count=count(1) from @tblTempMacReportXRef

			IF @count  = 0 GOTO NextLoop;
			IF @count  = 1 GOTO Proceed_Here;

			
			IF @count > 1
			BEGIN 
				insert into @tblTempMacReportXRef2(_Type,[Description_Contains],AccountNumber,_Reference,CR_DR_Equals,GL_Primary,Bank_Acct,X_Ref_Field,X_Ref_Position,X_Ref_Length,_ReferenceNot)
				SELECT _Type,[Description_Contains],AccountNumber,_Reference,CR_DR_Equals,GL_Primary,Bank_Acct,X_Ref_Field,X_Ref_Position,X_Ref_Length,_ReferenceNot FROM @tblTempMacReportXRef 
				WHERE
				--CHARINDEX( Description_Contains,   @strBankDescription ,1 ) > 0 and
				AccountNumber = CASE WHEN AccountNumber = '*' then AccountNumber ELSE @strBankAccountNo END

				select @count=count(1) from @tblTempMacReportXRef2

				IF @count  = 0 GOTO NextLoop;
				IF @count  = 1 GOTO Proceed_Here2;
								
				DELETE FROM @tblTempMacReportXRef

				insert into @tblTempMacReportXRef
				SELECT * FROM @tblTempMacReportXRef2 WHERE
				_Reference = CASE WHEN _Reference = '*' then _Reference ELSE @strReferenceNo END
				
				select @count=count(1) from @tblTempMacReportXRef

				IF @count  = 0 GOTO NextLoop;
				IF @count  = 1 GOTO Proceed_Here;
				
				DELETE FROM @tblTempMacReportXRef WHERE
				_ReferenceNot IS NOT NULL AND _ReferenceNot = @strReferenceNo

				select @count=count(1) from @tblTempMacReportXRef

				IF @count  = 0 GOTO NextLoop;
				IF @count  = 1 GOTO Proceed_Here;

				DELETE FROM @tblTempMacReportXRef2

				insert into @tblTempMacReportXRef2
				SELECT * FROM @tblTempMacReportXRef WHERE
				CR_DR_Equals= case when CR_DR_Equals = '*' then CR_DR_Equals else @strDebitCredit end


				select @count=count(1) from @tblTempMacReportXRef2
					
				IF @count  = 0 or @count > 1 GOTO NextLoop;
				IF @count  = 1 GOTO Proceed_Here2;
			
			END


			Proceed_Here2:

			DELETE FROM @tblTempMacReportXRef

			INSERT INTO @tblTempMacReportXRef
			SELECT * FROM @tblTempMacReportXRef2

			Proceed_Here:
			

			SELECT @_Type=_Type, @GL_Primary= GL_Primary,  
			@ReferenceNumber = SUBSTRING( @strBankDescription, X_Ref_Position, X_Ref_Length)  FROM @tblTempMacReportXRef
			
			
			INSERT INTO @Loc 
			EXEC('SELECT Loc FROM tblCMLocXRef where [' + @_Type + '] = ''' + '' + @ReferenceNumber + '''')

		    SELECT TOP 1 @strGLAccountId =	@GL_Primary + '-' +   RIGHT('000' + cast( Loc as nvarchar(3)),3)
			FROM @Loc
			

			IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccount where strAccountId = @strGLAccountId)
			BEGIN
				INSERT INTO @ErrorTable select @strGLAccountId +' is not an existing GL account id', @intBankStatementImportId
				GOTO NextLoop;
				--SET @strError = @strGLAccountId +' is not an existing GL account id'
			END
			

			EXEC uspSMGetStartingNumber @intStartingNumberId = 13, @intCompanyLocationId = null, @strID = @strID OUT 

			select strBankAccountNo from @tblTemp where intBankStatementImportId = @intBankStatementImportId

			
			INSERT INTO @bankTransaction (
				[strTransactionId]         
				,[intBankTransactionTypeId] 
				,[intBankAccountId]         
				,[intCurrencyId]            
				,[dblExchangeRate]          
				,[dtmDate]    
				,intCompanyLocationId
				,[dblAmount]                
				,[strMemo]                  
				,[intEntityId]			   
				,[intCreatedUserId]         
				,[dtmCreated]               
				,[intConcurrencyId] )
			SELECT
				[strTransactionId]			=	@strID        
				,[intBankTransactionTypeId] =	5
				,[intBankAccountId]			=	@intBankAccountId
				,[intCurrencyId]			=	3           
				,[dblExchangeRate]			=	1        
				,[dtmDate]					=	T.dtmDate    
				,[intCompanyLocationId]		=	SM.intCompanyLocationId
				,[dblAmount]                =	T.dblAmount
				,[strMemo]					=	'Automated Daily Deposits'
				,[intEntityId]				=	@intEntityId			   
				,[intCreatedUserId]         =	@intEntityId
				,[dtmCreated]				=	@dtmCurrent               
				,[intConcurrencyId]			=	1 
			FROM
			@tblTemp T
			OUTER APPLY(
				SELECT TOP 1  intCompanyLocationId from tblSMCompanyLocation SM join @Loc L on L.Loc = cast( SM.strLocationNumber as int)
			)SM
			where @intBankStatementImportId = intBankStatementImportId


			INSERT INTO @BankTransactionDetailEntries
				([dtmDate]
				,[intGLAccountId]
				,[strDescription]
				,[dblDebit]
				,[dblCredit]
				,[intEntityId]
				,[intCreatedUserId]
				,[dtmCreated]
				,[intConcurrencyId])
			SELECT
				[dtmDate]				=	T.dtmDate
				,[intGLAccountId]		=	GL.intAccountId
				,[strDescription]		=	GL.strDescription
				,[dblDebit]				=	CASE WHEN T.strDebitCredit = 'DR' THEN T.dblAmount ELSE 0 END				
				,[dblCredit]			=	CASE WHEN T.strDebitCredit = 'CR' THEN T.dblAmount ELSE 0 END		
				,[intEntityId]			=	@intEntityId
				,[intCreatedUserId]		=	@intEntityId
				,[dtmCreated]			=	@dtmCurrent			
				,[intConcurrencyId]		=	1
			FROM @tblTemp T
			OUTER APPLY(
				SELECT TOP 1 intAccountId, strDescription FROM tblGLAccount WHERE strAccountId = @strGLAccountId
			)GL

			where @intBankStatementImportId = intBankStatementImportId


			EXEC uspCMCreateBankTransactionEntries
            @BankTransactionEntries = @bankTransaction,
	        @BankTransactionDetailEntries = @BankTransactionDetailEntries

			DELETE FROM @bankTransaction
			DELETE FROM @BankTransactionDetailEntries

			insert into tblCMBankStatementImportLogDetail(intImportBankStatementLogId, strTransactionId,intBankStatementImportId)
			select @intImportLogId, @strID, @intBankStatementImportId

			NextLoop:
			DELETE FROM @tblTempMacReportXRef
			DELETE FROM @tblTempMacReportXRef2
			DELETE FROM @tblTemp WHERE @intBankStatementImportId =intBankStatementImportId

		END -- END WHILE
		
		IF EXISTS(SELECT TOP 1 1 FROM @ErrorTable)
			INSERT INTO #tblCMBankStatementImportLogDetail(intImportBankStatementLogId, strCategory, strError,intBankStatementImportId)
			SELECT @intImportLogId, 'Bank Transaction creation', strError, intBankStatementImportId from @ErrorTable

		-- IF( @ErrorMessage <> 'Error Details')
		-- 	INSERT INTO ##tblCMBankStatementImportLogDetail(intImportBankStatementLogId, strCategory, strError,intBankStatementImportId)
		-- 	SELECT @intImportLogId, 'Bank Transaction creation', @ErrorMessage,  @intBankStatementImportId
	

		EndProcedure:


END
