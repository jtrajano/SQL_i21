CREATE PROCEDURE [dbo].[uspCMImportBTransferFromBStmnt]  
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
        SET ANSI_WARNINGS OFF  
      
        DECLARE @IMPORT_STATUS_NOMATCHFOUND AS INT = 2,  
                @IMPORT_STATUS_MATCHFOUND AS INT = 1  
  
  
        DECLARE @tblTemp TABLE(  
            intLineNo int,
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
            intBankStatementImportId INT  
        );  
        DECLARE @ErrorTable TABLE(  
            intId INT IDENTITY(1,1),  
            strError NVARCHAR(MAX),  
            intBankStatementImportId int  
        )  
        DECLARE @ErrorMessage nvarchar(500);  
         
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
  
  
  
        INSERT INTO @tblTemp (intLineNo,intResponsibleBankAccountId ,intBankStatementImportId,dtmDate,dblAmount,strBankDescription)  
        SELECT  
        intLineNo,
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
            GOTO ExitHere;  
  
       
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
      
        DECLARE @intTransactionIdTemp INT   
        DECLARE @strID VARCHAR(50)   
        declare @NewSequenceValue table (id int)  ;

        INSERT INTO @tblTemp1(intBankStatementImportId)  
        SELECT intBankStatementImportId FROM @tblTemp  
		declare @intTaskId int
       
        WHILE EXISTS (SELECT TOP 1 1 FROM @tblTemp)   
        BEGIN   
             BEGIN TRY  
                EXEC uspSMGetStartingNumber @intStartingNumberId = 12, @intCompanyLocationId = null, @strID = @strID OUT   

                SELECT TOP 1 @intTransactionIdTemp = intTransactionId FROM @tblTemp  
               
                INSERT INTO dbo.tblCMResponsiblePartyTaskSequence 
                        OUTPUT inserted.TaskId into @NewSequenceValue(id) values(1)
                
				select @intTaskId = MAX(id) from @NewSequenceValue

                INSERT INTO tblCMResponsiblePartyTask(  
                    intTaskId,  
                    strTaskId,  
                    intBankStatementImportId,  
                    intResponsibleBankAccountId,  
                    intEntityId,  
                    strTransactionId,   
                    dblAmount,  
                    strBankStatementImportId)  
                SELECT   
                    @intTaskId,  
                    'Task-' +  CONVERT(nvarchar(20), @intTaskId)  ,  
                    intBankStatementImportId,  
                    [intBankAccountIdTo],   
                    intResponsibleEntityId,   
                    @strID,   
                    dblAmount,  
                    @strBankStatementImportId  
                FROM  @tblTemp  A   
                
                WHERE @intTransactionIdTemp = intTransactionId  


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
                    [intConcurrencyId],  
                    intTaskId  
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
                    [dtmCreated]                = @dtmCurrent,   
                    [ysnRecurring]              = 0,   
                    [dblRate]                   = 1,   
                    [intFiscalPeriodId]         = F.intGLFiscalYearPeriodId, -- remove this in 20.1  
                    [intConcurrencyId]          = 1,  
                    @intTaskId
                FROM @tblTemp T  
                CROSS APPLY dbo.fnGLGetFiscalPeriod([dtmDate]) F -- remove this in 20.1  
                WHERE @intTransactionIdTemp = intTransactionId  
        
                INSERT INTO tblCMBankStatementImportLogDetail(intLineNo, intImportBankStatementLogId, strTransactionId,intBankStatementImportId, strTaskId)
			    SELECT intLineNo, @intImportLogId, @strID, intBankStatementImportId,'Task-' +  CONVERT(nvarchar(20), @intTaskId)
                FROM @tblTemp  A   
                WHERE @intTransactionIdTemp = intTransactionId 

                DELETE FROM  @tblTemp WHERE @intTransactionIdTemp  = intTransactionId 
            END TRY  
            BEGIN CATCH  
                INSERT INTO #tblCMBankStatementImportLogDetail(intLineNo,intImportBankStatementLogId, strCategory, strError,intBankStatementImportId)  
                SELECT intLineNo,@intImportLogId, 'Bank Transfer creation', ERROR_MESSAGE(), intBankStatementImportId
                FROM @tblTemp B   
                WHERE @intTransactionIdTemp = intTransactionId 
            END CATCH   
        END   --END WHILE
    
    ExitHere:  

    -- Mark matched so that the next procedure will not select it ignoring error  
    IF EXISTS(SELECT TOP 1 1 FROM @tblTemp1)  
    UPDATE BS   
    SET intImportStatus = @IMPORT_STATUS_MATCHFOUND  
    FROM tblCMBankStatementImport BS  
    JOIN @tblTemp1 T  
    ON T.intBankStatementImportId = BS.intBankStatementImportId  
  
END  
  