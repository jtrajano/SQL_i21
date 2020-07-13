CREATE PROCEDURE [dbo].[uspARBookInvoiceGLEntries]
     @Post              BIT				= 0
	,@BatchId           NVARCHAR(40)
    ,@UserId            INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF
SET XACT_ABORT ON  

DECLARE  @InitTranCount				INT
		,@CurrentTranCount			INT
		,@Savepoint					NVARCHAR(32)
		,@CurrentSavepoint			NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARPostInvoice' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF @InitTranCount = 0
	BEGIN TRANSACTION
ELSE
	SAVE TRANSACTION @Savepoint

BEGIN TRY

DECLARE @GLPost RecapTableType
INSERT INTO @GLPost
    ([dtmDate]
    ,[strBatchId]
    ,[intAccountId]
    ,[dblDebit]
    ,[dblCredit]
    ,[dblDebitUnit]
    ,[dblCreditUnit]
    ,[strDescription]
    ,[strCode]
    ,[strReference]
    ,[intCurrencyId]
    ,[dblExchangeRate]
    ,[dtmDateEntered]
    ,[dtmTransactionDate]
    ,[strJournalLineDescription]
    ,[intJournalLineNo]
    ,[ysnIsUnposted]
    ,[intUserId]
    ,[intEntityId]
    ,[strTransactionId]
    ,[intTransactionId]
    ,[strTransactionType]
    ,[strTransactionForm]
    ,[strModuleName]
    ,[intConcurrencyId]
    ,[dblDebitForeign]
    ,[dblDebitReport]
    ,[dblCreditForeign]
    ,[dblCreditReport]
    ,[dblReportingRate]
    ,[dblForeignRate]
    ,[intCurrencyExchangeRateTypeId]
    ,[strRateType]
    ,[strDocument]
    ,[strComments]
    ,[strSourceDocumentId]
    ,[intSourceLocationId]
    ,[intSourceUOMId]
    ,[dblSourceUnitDebit]
    ,[dblSourceUnitCredit]
    ,[intCommodityId]
    ,[intSourceEntityId]
    ,[ysnRebuild]
)
SELECT
     [dtmDate]
    ,[strBatchId]
    ,[intAccountId]
    ,[dblDebit]
    ,[dblCredit]
    ,[dblDebitUnit]
    ,[dblCreditUnit]
    ,[strDescription]
    ,[strCode]
    ,[strReference]
    ,[intCurrencyId]
    ,[dblExchangeRate]
    ,[dtmDateEntered]
    ,[dtmTransactionDate]
    ,[strJournalLineDescription]
    ,[intJournalLineNo]
    ,[ysnIsUnposted]
    ,[intUserId]
    ,[intEntityId]
    ,[strTransactionId]
    ,[intTransactionId]
    ,[strTransactionType]
    ,[strTransactionForm]
    ,[strModuleName]
    ,[intConcurrencyId]
    ,[dblDebitForeign]
    ,[dblDebitReport]
    ,[dblCreditForeign]
    ,[dblCreditReport]
    ,[dblReportingRate]
    ,[dblForeignRate]
    ,[intCurrencyExchangeRateTypeId]
    ,[strRateType]
    ,[strDocument]
    ,[strComments]
    ,[strSourceDocumentId]
    ,[intSourceLocationId]
    ,[intSourceUOMId]
    ,[dblSourceUnitDebit]
    ,[dblSourceUnitCredit]
    ,[intCommodityId]
    ,[intSourceEntityId]
    ,[ysnRebuild]
FROM
	#ARInvoiceGLEntries


EXEC dbo.uspGLBookEntries
         @GLEntries         = @GLPost
        ,@ysnPost           = @Post
        ,@SkipGLValidation	= 1
        ,@SkipICValidation	= 1
		

IF @Post = 0
    BEGIN
        UPDATE GLD
        SET GLD.[ysnIsUnposted] = 1
        FROM
            tblGLDetail GLD
        INNER JOIN
            @GLPost PID
                ON PID.[intTransactionId] = GLD.[intTransactionId]
                AND PID.[strTransactionId] = GLD.[strTransactionId]

        DECLARE @UnPostICInvoiceData TABLE
            ([intInvoiceId]     INT PRIMARY KEY
            ,[strTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS
            ,UNIQUE (intInvoiceId));

        DECLARE @intTransactionId INT
               ,@strTransactionId NVARCHAR(80);
			
	--INSERT INTO @UnPostICInvoiceData(intInvoiceId, strTransactionId)
	--SELECT DISTINCT
	--	 PID.intInvoiceId
	--	,PID.strInvoiceNumber
	--FROM
	--	(SELECT intInvoiceId, strInvoiceNumber FROM @PostInvoiceData) PID
	--INNER JOIN
	--	(SELECT intInvoiceId, intItemId, intItemUOMId FROM dbo.tblARInvoiceDetail WITH (NOLOCK)) ARID
	--		ON PID.intInvoiceId = ARID.intInvoiceId					
	--INNER JOIN
	--	(SELECT intInvoiceId, intCompanyLocationId, strTransactionType FROM dbo.tblARInvoice WITH (NOLOCK)) ARI
	--		ON ARID.intInvoiceId = ARI.intInvoiceId	AND strTransactionType IN ('Invoice', 'Credit Memo', 'Credit Note', 'Cash')				 	
	--INNER JOIN
	--	(SELECT intItemUOMId FROM dbo.tblICItemUOM WITH (NOLOCK) ) ItemUOM 
	--		ON ItemUOM.intItemUOMId = ARID.intItemUOMId
	--LEFT OUTER JOIN
	--	(SELECT intItemId, intLocationId, strType FROM dbo.vyuICGetItemStock WITH (NOLOCK)) IST
	--		ON ARID.intItemId = IST.intItemId 
	--		AND ARI.intCompanyLocationId = IST.intLocationId 
	    DECLARE @intTransactionIdIC INT
	           ,@strTransactionIdIC NVARCHAR(80)
	           ,@WStorageCount      INT
	           ,@WOStorageCount     INT
        --Recap = 0
        INSERT INTO @UnPostICInvoiceData
            ([intInvoiceId]
            ,[strTransactionId])
        SELECT DISTINCT
             [intInvoiceId]
            ,[strInvoiceNumber]
        FROM
            #ARPostInvoiceDetail
        WHERE
		    [strTransactionType] IN ('Invoice', 'Credit Memo', 'Credit Note', 'Cash')				 	
            AND [intItemId] IS NOT NULL
            AND ISNULL([strItemType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software')

		DELETE FROM @GLPost
        WHILE EXISTS(SELECT TOP 1 NULL FROM @UnPostICInvoiceData ORDER BY intInvoiceId)
        BEGIN				
					
			SELECT TOP 1 
                 @intTransactionIdIC = [intInvoiceId]
                ,@strTransactionIdIC = [strTransactionId]
			FROM
                @UnPostICInvoiceData
            ORDER BY
                [intInvoiceId]

            SELECT @WStorageCount = COUNT(1) FROM #ARPostInvoiceDetail WHERE [intInvoiceId] = @intTransactionIdIC AND (ISNULL([intItemId], 0) <> 0) AND (ISNULL([intStorageScheduleTypeId],0) <> 0)	
            SELECT @WOStorageCount = COUNT(1) FROM #ARPostInvoiceDetail WHERE [intInvoiceId] = @intTransactionIdIC AND (ISNULL([intItemId], 0) <> 0) AND (ISNULL([intStorageScheduleTypeId],0) = 0)
            IF @WOStorageCount > 0
            BEGIN
				-- Unpost onhand stocks. 
				INSERT INTO @GLPost (
						[dtmDate] 
						,[strBatchId]
						,[intAccountId]
						,[dblDebit]
						,[dblCredit]
						,[dblDebitUnit]
						,[dblCreditUnit]
						,[strDescription]
						,[strCode]
						,[strReference]
						,[intCurrencyId]
						,[dblExchangeRate]
						,[dtmDateEntered]
						,[dtmTransactionDate]
						,[strJournalLineDescription]
						,[intJournalLineNo]
						,[ysnIsUnposted]
						,[intUserId]
						,[intEntityId]
						,[strTransactionId]
						,[intTransactionId]
						,[strTransactionType]
						,[strTransactionForm]
						,[strModuleName]
						,[intConcurrencyId]
						,[dblDebitForeign]	
						,[dblDebitReport]	
						,[dblCreditForeign]	
						,[dblCreditReport]	
						,[dblReportingRate]	
						,[dblForeignRate]
						,[strRateType]
				)
                EXEC dbo.uspICUnpostCosting
                         @intTransactionIdIC
                        ,@strTransactionIdIC
                        ,@BatchId
                        ,@UserId
                        ,0 
            END

            IF @WStorageCount > 0 
            BEGIN 
                -- Unpost storage stocks. 
                EXEC dbo.uspICUnpostStorage
                         @intTransactionId
                        ,@strTransactionId
                        ,@BatchId
                        ,@UserId
                        ,0
            END					
										
            DELETE FROM @UnPostICInvoiceData 
            WHERE	intInvoiceId = @intTransactionIdIC 
				AND strTransactionId = @strTransactionIdIC 												
        END

		IF EXISTS (SELECT TOP 1 1 FROM @GLPost) 
		BEGIN
			EXEC dbo.uspGLBookEntries
					 @GLEntries         = @GLPost
					,@ysnPost           = @Post
					,@SkipGLValidation	= 1
					,@SkipICValidation	= 1
		END 

  --      --Recap = 1
		--DELETE FROM  @UnPostICInvoiceData
  --      INSERT INTO @UnPostICInvoiceData
  --          ([intInvoiceId]
  --          ,[strTransactionId])
  --      SELECT DISTINCT
  --           [intInvoiceId]
  --          ,[strInvoiceNumber]
  --      FROM
  --          #ARPostInvoiceDetail
  --      WHERE
  --          [ysnPost] = 0
  --          AND [ysnRecap] = 1
  --          AND [strTransactionType] IN ('Invoice', 'Credit Memo', 'Credit Note', 'Cash')				 	
  --          AND [intItemId] IS NOT NULL
  --          AND ISNULL([strItemType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software')

  --      WHILE EXISTS(SELECT TOP 1 NULL FROM @UnPostICInvoiceData ORDER BY intInvoiceId)
  --      BEGIN					
		--	SELECT TOP 1 
  --               @intTransactionIdIC = [intInvoiceId]
  --              ,@strTransactionIdIC = [strTransactionId]
		--	FROM
  --              @UnPostICInvoiceData
  --          ORDER BY
  --              [intInvoiceId]

  --          SELECT @WStorageCount = COUNT(1) FROM #ARPostInvoiceDetail WHERE [ysnPost] = 0 AND [ysnRecap] = 1 AND [intInvoiceId] = @intTransactionIdIC AND (ISNULL([intItemId], 0) <> 0) AND (ISNULL([intStorageScheduleTypeId],0) <> 0)	
  --          SELECT @WOStorageCount = COUNT(1) FROM #ARPostInvoiceDetail WHERE [ysnPost] = 0 AND [ysnRecap] = 1 AND [intInvoiceId] = @intTransactionIdIC AND (ISNULL([intItemId], 0) <> 0) AND (ISNULL([intStorageScheduleTypeId],0) = 0)
  --          IF @WOStorageCount > 0
  --          BEGIN
  --              -- Unpost onhand stocks. 
  --              EXEC dbo.uspICUnpostCosting
  --                       @intTransactionIdIC
  --                      ,@strTransactionIdIC
  --                      ,@BatchId
  --                      ,@UserId
  --                      ,1
  --          END

  --          IF @WStorageCount > 0 
  --          BEGIN 
  --              -- Unpost storage stocks. 
  --              EXEC dbo.uspICUnpostStorage
  --                       @intTransactionId
  --                      ,@strTransactionId
  --                      ,@BatchId
  --                      ,@UserId
  --                      ,1
  --          END					
										
  --          DELETE FROM @UnPostICInvoiceData 
  --          WHERE	intInvoiceId = @intTransactionIdIC 
		--		AND strTransactionId = @strTransactionIdIC 												
  --      END	
    END

END TRY
BEGIN CATCH
    DECLARE @ErrorMerssage NVARCHAR(MAX)
	SELECT @ErrorMerssage = ERROR_MESSAGE()					
    IF @InitTranCount = 0
        IF (XACT_STATE()) <> 0
			ROLLBACK TRANSACTION
	ELSE
		IF (XACT_STATE()) <> 0
			ROLLBACK TRANSACTION @Savepoint
												
	RAISERROR(@ErrorMerssage, 11, 1)
		
	GOTO Post_Exit
END CATCH


IF @InitTranCount = 0
	BEGIN
		IF (XACT_STATE()) = -1
			ROLLBACK TRANSACTION
		IF (XACT_STATE()) = 1
			COMMIT TRANSACTION
		RETURN 1;
	END	


Post_Exit:
	RETURN 0;
