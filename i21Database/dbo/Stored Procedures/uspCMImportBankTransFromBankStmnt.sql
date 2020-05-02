CREATE PROCEDURE [dbo].[uspCMImportBankTransFromBankStmnt] 
    @strBankStatementImportId NVARCHAR(40), 
    @rCount INT OUTPUT AS BEGIN DECLARE @IMPORT_STATUS_MATCHFOUND AS INT = 1 
    SET  @rCount = 0;

    DECLARE @tblTemp TABLE(
        intBankStatementImportId INT,
        intResponsibleBankAccountId INT,
        
        dtmDate DATETIME,
        dblAmount DECIMAL(18,6),

        intGLAccountIdFrom INT,  
        intBankAccountIdFrom INT, 
        intResponsibleEntityId INT,
	    intGLAccountIdTo INT,
        intBankAccountIdTo INT
    );
    
    WITH UnmatchedTrans AS (
    SELECT 
        intBankStatementImportId, 
        strBankDescription 
    FROM 
        tblCMBankStatementImport 
    WHERE 
        @IMPORT_STATUS_MATCHFOUND <> ISNULL(intImportStatus, 0) 
        AND @strBankStatementImportId = strBankStatementImportId
		AND strBankTransactionCreated  IS NULL
    ) 

    INSERT INTO @tblTemp (intResponsibleBankAccountId ,intBankStatementImportId,dtmDate,dblAmount)
    SELECT
    intResponsibleBankAccountId =  CASE WHEN CHARINDEX(W.strContainText, ISNULL(U.strBankDescription, '')) > 0
        THEN W.intBankAccountId ELSE NULL END 
    ,CM.intBankStatementImportId
    ,CM.dtmDate
    ,CM.dblAmount
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
    

    DELETE FROM @tblTemp WHERE intResponsibleBankAccountId IS NULL

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
    

    UPDATE tblCMBankStatementImport
    SET intResponsibleBankAccountId= TE.intResponsibleBankAccountId
    FROM tblCMBankStatementImport 
    JOIN @tblTemp TE ON TE.intBankStatementImportId = tblCMBankStatementImport.intBankStatementImportId

    DECLARE @dtmCurrentDate DATETIME DECLARE @tblCMBankTransferTemp TABLE(
        [intTransactionId] [int] IDENTITY(1, 1) NOT NULL, 
        [dtmDate] [datetime] NOT NULL, 
        [intBankTransactionTypeId] [int] NOT NULL, 
        [dblAmount] [decimal](18, 6) NOT NULL, 
        [strDescription] [nvarchar](255) NULL, 
        [intBankAccountIdFrom] [int] NOT NULL, 
        [intGLAccountIdFrom] [int] NOT NULL, 
        [strReferenceFrom] [nvarchar](150) NULL, 
        [intBankAccountIdTo] [int] NOT NULL, 
        [intGLAccountIdTo] [int] NOT NULL, 
        [strReferenceTo] [nvarchar](150) NULL, 
        [ysnPosted] [bit] NOT NULL, 
        [intEntityId] [int] NULL, 
        [intCreatedUserId] [int] NULL, 
        [dtmCreated] [datetime] NULL, 
        [intLastModifiedUserId] [int] NULL, 
        [dtmLastModified] [datetime] NULL, 
        [ysnRecurring] [bit] NOT NULL, 
        [ysnDelete] [bit] NULL, 
        [dtmDateDeleted] [datetime] NULL, 
        [dblRate] [decimal](18, 6) NULL, 
        [intCurrencyExchangeRateTypeId] [int] NULL, 
        [dblHistoricRate] [decimal](18, 6) NULL, 
        [intConcurrencyId] [int] NOT NULL, 
        [intBankStatementId] [int] NULL, 
        [intBankStatementImportId] [int] NULL
    ) 
    SET @dtmCurrentDate = GETDATE() 
    
    INSERT INTO @tblCMBankTransferTemp (
        [dtmDate], 
        [intBankTransactionTypeId], 
        [dblAmount], 
        [strDescription], 
        [intBankAccountIdFrom], 
        [intGLAccountIdFrom], 
        [strReferenceFrom], 
        [intBankAccountIdTo], 
        [intGLAccountIdTo], 
        [strReferenceTo], 
        [ysnPosted], 
        [intEntityId], 
        [intCreatedUserId], 
        [dtmCreated], 
        [intLastModifiedUserId], 
        [dtmLastModified], 
        [ysnRecurring], 
        [ysnDelete], 
        [dtmDateDeleted], 
        [dblRate], 
        [intCurrencyExchangeRateTypeId], 
        [dblHistoricRate], 
        [intConcurrencyId]
--        intBankStatementImportId
    ) 
    SELECT 
        MIN(dtmDate), 
        4, 
        SUM(dblAmount), 
        'Imported from ' + @strBankStatementImportId,
        intBankAccountIdFrom, 
        intGLAccountIdFrom, 
        '', 
        intBankAccountIdTo, 
        intGLAccountIdTo, 
        '', 
        0 , 
        intResponsibleEntityId, 
        intResponsibleEntityId, 
        @dtmCurrentDate, 
        intResponsibleEntityId, 
        @dtmCurrentDate, 
        0, 
        0, 
        0, 
        1, 
        NULL, 
        1, 
        1 
        --Import.intBankStatementImportId 
    FROM @tblTemp  
	GROUP BY  intGLAccountIdTo, intBankAccountIdFrom,intResponsibleEntityId,intGLAccountIdFrom, intBankAccountIdTo
    
    SELECT @rCount = COUNT(1) FROM @tblCMBankTransferTemp 
    
    DECLARE @intTransactionIdTemp INT DECLARE @strID VARCHAR(50) 

	    
	

    WHILE EXISTS (SELECT TOP 1 1 FROM @tblCMBankTransferTemp) 
    BEGIN 
        EXEC uspSMGetStartingNumber @intStartingNumberId = 12, @intCompanyLocationId = null, @strID = @strID OUT 
        SELECT TOP 1 @intTransactionIdTemp = intTransactionId FROM @tblCMBankTransferTemp
		
        
        INSERT INTO tblCMBankTransfer(
            [strTransactionId], [dtmDate], [intBankTransactionTypeId], 
            [dblAmount], [strDescription], [intBankAccountIdFrom], 
            [intGLAccountIdFrom], [strReferenceFrom], 
            [intBankAccountIdTo], [intGLAccountIdTo], 
            [strReferenceTo], [ysnPosted], [intEntityId], 
            [intCreatedUserId], [dtmCreated], 
            [intLastModifiedUserId], [dtmLastModified], 
            [ysnRecurring], [ysnDelete], [dtmDateDeleted], 
            [dblRate], [intCurrencyExchangeRateTypeId], 
            [dblHistoricRate], [intConcurrencyId], 
            intBankStatementImportId
        ) 
        SELECT 
            @strID, 
            [dtmDate], 
            intBankTransactionTypeId, 
            dblAmount, 
            @strBankStatementImportId, 
            [intBankAccountIdFrom], 
            [intGLAccountIdFrom], 
            [strReferenceFrom], 
            [intBankAccountIdTo], 
            [intGLAccountIdTo], 
            [strReferenceTo], 
            [ysnPosted], 
            [intEntityId], 
            [intCreatedUserId], 
            [dtmCreated], 
            [intLastModifiedUserId], 
            [dtmLastModified], 
            [ysnRecurring], 
            [ysnDelete], 
            [dtmDateDeleted], 
            [dblRate], 
            [intCurrencyExchangeRateTypeId], 
            [dblHistoricRate], 
            [intConcurrencyId], 
            intBankStatementImportId 
        FROM @tblCMBankTransferTemp 
		WHERE @intTransactionIdTemp = intTransactionId

        UPDATE S
        SET strBankTransactionCreated = @strID
        FROM
        tblCMBankStatementImport S 
        JOIN @tblTemp A ON A.intBankStatementImportId = S.intBankStatementImportId
        JOIN @tblCMBankTransferTemp B
        ON A.intGLAccountIdTo = B.intGLAccountIdTo 
        AND A.intBankAccountIdFrom = B.intBankAccountIdFrom
        AND A.intResponsibleEntityId = B.intEntityId
        AND A.intGLAccountIdFrom = B.intGLAccountIdFrom
        AND A.intBankAccountIdTo = B.intBankAccountIdTo
        WHERE @intTransactionIdTemp = intTransactionId

        DELETE FROM  @tblCMBankTransferTemp WHERE @intTransactionIdTemp  = intTransactionId
    END 

END

