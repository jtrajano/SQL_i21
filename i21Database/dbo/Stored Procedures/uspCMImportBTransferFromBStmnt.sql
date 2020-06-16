CREATE PROCEDURE uspCMImportBTransferFromBStmnt
    @strBankStatementImportId NVARCHAR(40),
    @intEntityId INT,
    @rCount INT = 0 OUTPUT
    AS
    BEGIN 
        
		SET QUOTED_IDENTIFIER OFF
		SET ANSI_NULLS ON
		SET NOCOUNT ON
		SET XACT_ABORT ON
		SET ANSI_WARNINGS OFF
    
        DECLARE @IMPORT_STATUS_NOMATCHFOUND AS INT = 2,
                @IMPORT_STATUS_MATCHFOUND AS INT = 1

        SET  @rCount = 0;

        DECLARE @tblTemp TABLE(
            intTransactionId int IDENTITY(1,1),
            intBankStatementImportId INT,
            intResponsibleBankAccountId INT,
            dtmDate DATETIME,
            dblAmount DECIMAL(18,6),
            intGLAccountIdFrom INT,  
            intBankAccountIdFrom INT, 
            intResponsibleEntityId INT,
            intGLAccountIdTo INT,
            intBankAccountIdTo INT,
            strBankDescription nvarchar(max)
        );
        DECLARE @tblTemp1 TABLE(
            -- intTransactionId int IDENTITY(1,1),
            intBankStatementImportId INT
            -- intResponsibleBankAccountId INT,
            -- dtmDate DATETIME,
            -- dblAmount DECIMAL(18,6),
            -- intGLAccountIdFrom INT,  
            -- intBankAccountIdFrom INT, 
            -- intResponsibleEntityId INT,
            -- intGLAccountIdTo INT,
            -- intBankAccountIdTo INT,
            -- strBankDescription nvarchar(max)
        );
        DECLARE @ErrorTable TABLE(
			intId INT IDENTITY(1,1),
			strError NVARCHAR(MAX),
			intBankStatementImportId int
		)
        DECLARE @ErrorMessage nvarchar(500)
        DECLARE @dtmCurrentDate DATETIME 
        SET @dtmCurrentDate = GETDATE() 

        BEGIN TRANSACTION;

        
    
        WITH UnmatchedTrans AS (
        SELECT 
            intBankStatementImportId, 
            strBankDescription 
        FROM 
            tblCMBankStatementImport 
        WHERE 
             @IMPORT_STATUS_MATCHFOUND <> ISNULL(intImportStatus, 0) 
            AND @strBankStatementImportId = strBankStatementImportId
        ) 



        INSERT INTO @tblTemp (intResponsibleBankAccountId ,intBankStatementImportId,dtmDate,dblAmount,strBankDescription)
        SELECT
        intResponsibleBankAccountId =  CASE WHEN CHARINDEX(W.strContainText, ISNULL(U.strBankDescription, '')) > 0
            THEN W.intBankAccountId ELSE NULL END 
        ,CM.intBankStatementImportId
        ,CM.dtmDate
        ,CM.dblAmount
        ,U.strBankDescription
        FROM tblCMBankStatementImport CM 
        JOIN UnmatchedTrans U ON U.intBankStatementImportId = CM.intBankStatementImportId OUTER APPLY(
            SELECT 
                A.intBankAccountId, 
                B.strContainText 
            FROM 
                tblCMBankAccount A 
            JOIN tblCMResponsibleParty B ON A.intBankAccountId = B.intBankAccountIdTo 
            WHERE ISNULL(strContainText, '') <> ''
        ) W 
    
        -- Exit when no match found
        IF NOT EXISTS(SELECT TOP 1 1 FROM @tblTemp)
        BEGIN
            INSERT INTO @ErrorTable(strError)
            SELECT 'No match found' 
            GOTO ExitHere;
        END

     
        UPDATE @tblTemp
        SET  
        intBankAccountIdFrom = B.intBankAccountIdFrom, 
        intGLAccountIdFrom = CMBankFrom.intGLAccountId, 
        intBankAccountIdTo = B.intBankAccountIdTo, 
        intGLAccountIdTo =   A.intGLAccountId,
        intResponsibleEntityId = A.intResponsibleEntityId
        FROM @tblTemp Import
        JOIN tblCMBankAccount A ON A.intBankAccountId = Import.intResponsibleBankAccountId 
        JOIN tblCMResponsibleParty B ON A.intBankAccountId = B.intBankAccountIdTo 
        OUTER APPLY(
            SELECT TOP 1 intGLAccountId 
            FROM 
                tblCMBankAccount 
            WHERE 
                intBankAccountId = B.intBankAccountIdFrom
        ) CMBankFrom 
    
        DELETE FROM @tblTemp WHERE intResponsibleEntityId IS NULL
        
        
        IF EXISTS(SELECT TOP 1 1 FROM @ErrorTable)
            GOTO ExitHere;
       

        -- DECLARE @tblCMBankTransferTemp TABLE(
        --     [intTransactionId] [int] IDENTITY(1, 1) NOT NULL, 
        --     [dtmDate] [datetime] NOT NULL, 
        --     [intBankTransactionTypeId] [int] NOT NULL, 
        --     [dblAmount] [decimal](18, 6) NOT NULL, 
        --     [strDescription] [nvarchar](255) NULL, 
        --     [intBankAccountIdFrom] [int] NOT NULL, 
        --     [intGLAccountIdFrom] [int] NOT NULL, 
        --     [strReferenceFrom] [nvarchar](150) NULL, 
        --     [intBankAccountIdTo] [int] NOT NULL, 
        --     [intGLAccountIdTo] [int] NOT NULL, 
        --     [strReferenceTo] [nvarchar](150) NULL, 
        --     [ysnPosted] [bit] NOT NULL, 
        --     [intEntityId] [int] NULL, 
        --     [intCreatedUserId] [int] NULL, 
        --     [dtmCreated] [datetime] NULL, 
        --     [intLastModifiedUserId] [int] NULL, 
        --     [dtmLastModified] [datetime] NULL, 
        --     [ysnRecurring] [bit] NOT NULL, 
        --     [ysnDelete] [bit] NULL, 
        --     [dtmDateDeleted] [datetime] NULL, 
        --     [dblRate] [decimal](18, 6) NULL, 
        --     [intCurrencyExchangeRateTypeId] [int] NULL, 
        --     [dblHistoricRate] [decimal](18, 6) NULL, 
        --     [intConcurrencyId] [int] NOT NULL, 
        --     [intBankStatementId] [int] NULL
        -- ) 
        
    
        -- INSERT INTO @tblCMBankTransferTemp (
        --     [dtmDate], 
        --     [intBankTransactionTypeId], 
        --     [dblAmount], 
        --     [strDescription],   
        --     [intBankAccountIdFrom], 
        --     [intGLAccountIdFrom], 
        --     [strReferenceFrom], 
        --     [intBankAccountIdTo], 
        --     [intGLAccountIdTo], 
        --     [strReferenceTo], 
        --     [ysnPosted], 
        --     [intEntityId], 
        --     [intCreatedUserId], 
        --     [dtmCreated], 
        --     [intLastModifiedUserId], 
        --     [dtmLastModified], 
        --     [ysnRecurring], 
        --     [ysnDelete], 
        --     [dtmDateDeleted], 
        --     [dblRate], 
        --     [intCurrencyExchangeRateTypeId], 
        --     [dblHistoricRate], 
        --     [intConcurrencyId]
        --     ) 
        -- SELECT 
        --     MIN(dtmDate), 
        --     4, 
        --     SUM(dblAmount), 
        --     'Imported from ' + @strBankStatementImportId,
        --     intBankAccountIdFrom, 
        --     intGLAccountIdFrom, 
        --     '', 
        --     intBankAccountIdTo, 
        --     intGLAccountIdTo, 
        --     '', 
        --     0 , 
        --     intResponsibleEntityId, 
        --     intResponsibleEntityId, 
        --     @dtmCurrentDate, 
        --     intResponsibleEntityId, 
        --     @dtmCurrentDate, 
        --     0, 
        --     0, 
        --     0, 
        --     1, 
        --     NULL, 
        --     1, 
        --     1 
        -- FROM @tblTemp  
        -- GROUP BY  intGLAccountIdTo, intBankAccountIdFrom,intResponsibleEntityId,intGLAccountIdFrom, intBankAccountIdTo

        
        
    
    DECLARE @intTransactionIdTemp INT 
    DECLARE @strID VARCHAR(50) 

    INSERT INTO @tblTemp1(intBankStatementImportId)
    SELECT intBankStatementImportId FROM @tblTemp



    WHILE EXISTS (SELECT TOP 1 1 FROM @tblTemp) 
    BEGIN 
        BEGIN TRY
            
                EXEC uspSMGetStartingNumber @intStartingNumberId = 12, @intCompanyLocationId = null, @strID = @strID OUT 

                SELECT TOP 1 @intTransactionIdTemp = intTransactionId FROM @tblTemp
                
                INSERT INTO tblCMBankTransfer(
                    [strTransactionId], 
                    [dtmDate], 
                    [intBankTransactionTypeId], 
                    [dblAmount], 
                    [strDescription], 
                    [intBankAccountIdFrom], 
                    [intGLAccountIdFrom], 
                    [intBankAccountIdTo], 
                    [intGLAccountIdTo], 
                    [ysnPosted],
                    [intEntityId], 
                    [intCreatedUserId], 
                    [dtmCreated], 
                    [ysnRecurring], 
                    [dblRate], 
                    [intFiscalPeriodId],-- remove this in 20.1
                    [intConcurrencyId]
                ) 
                SELECT 
                    [strTransactionId]          = @strID, 
                    [dtmDate]                   = T.dtmDate, 
                    [intBankTransactionTypeId]  = 4, 
                    [dblAmount]                 = T.dblAmount, 
                    [strDescription]            = 'Imported from ' + @strBankStatementImportId, 
                    [intBankAccountIdFrom]      = T.intBankAccountIdFrom, 
                    [intGLAccountIdFrom]        = T.intGLAccountIdFrom, 
                    [intBankAccountIdTo]        = T.intBankAccountIdTo, 
                    [intGLAccountIdTo]          = T.intGLAccountIdTo, 
                    [ysnPosted]                 = 0, 
                    [intEntityId]               = @intEntityId, 
                    [intCreatedUserId]          = @intEntityId, 
                    [dtmCreated]                = @dtmCurrentDate, 
                    [ysnRecurring]              = 0, 
                    [dblRate]                   = 1, 
                    [intFiscalPeriodId]         = F.intGLFiscalYearPeriodId, -- remove this in 20.1
                    [intConcurrencyId]          = 1
                FROM @tblTemp T
                CROSS APPLY dbo.fnGLGetFiscalPeriod([dtmDate]) F -- remove this in 20.1
                WHERE @intTransactionIdTemp = intTransactionId

                
                -- FOR THE TASK TABLE
                INSERT INTO tblCMResponsiblePartyTask(
                    intBankStatementImportId,
                    intResponsibleBankAccountId,
                    intEntityId,
                    strTransactionId, 
                    dblAmount,
                    strBankStatementImportId)
                SELECT 
                    intBankStatementImportId,
                     [intBankAccountIdTo], 
                     intResponsibleEntityId, 
                     @strID, 
                     dblAmount,
                     @strBankStatementImportId
                FROM  @tblTemp  A 
                WHERE @intTransactionIdTemp = intTransactionId

                
                -- LOG THE IMPORTING

                -- INSERT INTO tblCMBankStatementImportLog(strCategory, strTransactionId, dtmDateCreated,intEntityId,strBankStatementImportId)
                -- SELECT 'Bank Transfer creation',@strID, @dtmCurrentDate,@intEntityId, @strBankStatementImportId
                -- from @tblCMBankTransferTemp A 
                -- WHERE @intTransactionIdTemp = intTransactionId
            

            

        END TRY
        BEGIN CATCH
            SELECT  @ErrorMessage = ERROR_MESSAGE() 
					INSERT INTO @ErrorTable (strError,intBankStatementImportId ) 
                    SELECT @ErrorMessage, intBankStatementImportId
                    FROM @tblTemp B 
                    WHERE @intTransactionIdTemp = intTransactionId

        END CATCH
        DELETE FROM  @tblTemp WHERE @intTransactionIdTemp  = intTransactionId
       


    END 

    ExitHere:

    IF EXISTS (SELECT TOP 1 1 FROM @ErrorTable)
	BEGIN

		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;

		INSERT INTO tblCMBankStatementImportLog(strCategory, strError,intEntityId,intBankStatementImportId, dtmDateCreated, strBankStatementImportId)
			select 'Bank Transfer creation', strError, @intEntityId, intBankStatementImportId,@dtmCurrentDate, @strBankStatementImportId from @ErrorTable
	END
	ELSE
	BEGIN 
		IF @@TRANCOUNT > 0 
			COMMIT TRANSACTION;
	END

    SELECT @rCount = COUNT(1) FROM tblCMResponsiblePartyTask WHERE strBankStatementImportId = @strBankStatementImportId

    --logs all matches to bank statement import log
    


    -- Mark matched so that the next procedure will not select it ignoring error
    IF EXISTS(SELECT TOP 1 1 FROM @tblTemp1)
    UPDATE BS 
    SET intImportStatus = @IMPORT_STATUS_MATCHFOUND
    FROM tblCMBankStatementImport BS
    JOIN @tblTemp1 T
    ON T.intBankStatementImportId = BS.intBankStatementImportId


END

