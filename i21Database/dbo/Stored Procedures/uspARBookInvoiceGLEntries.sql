CREATE PROCEDURE [dbo].[uspARBookInvoiceGLEntries]
     @BatchId           NVARCHAR(40)
    ,@UserId            INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE @GLPost RecapTableType
INSERT INTO @GLPost
SELECT * FROM #ARInvoiceGLEntries WHERE [ysnIsUnposted] = 0
IF EXISTS(SELECT TOP 1 NULL FROM @GLPost)
    BEGIN
        EXEC dbo.uspGLBookEntries
                @GLEntries  = @GLPost
                ,@ysnPost   = 1
    END

	--IF @post = 0   
	--BEGIN
	
	--	BEGIN TRY

	--		UPDATE GLD
	--		SET
	--			GLD.ysnIsUnposted = 1
	--		FROM
	--			tblGLDetail GLD
	--		INNER JOIN
	--			(SELECT intInvoiceId, strInvoiceNumber FROM @PostInvoiceData WHERE [intInvoiceDetailId] IS NULL) PID
	--				ON PID.intInvoiceId = GLD.intTransactionId
	--				AND PID.strInvoiceNumber = GLD.strTransactionId

	--		IF EXISTS(SELECT TOP 1 NULL FROM @GLEntries)	
	--			EXEC	dbo.uspGLBookEntries
	--					@GLEntries		= @GLEntries
	--					,@ysnPost		= @post
	--					,@XACT_ABORT_ON = @raiseError
						
	--	END TRY
	--	BEGIN CATCH
	--		SELECT @ErrorMerssage = ERROR_MESSAGE()										
	--		GOTO Do_Rollback
	--	END CATCH
			
	--	BEGIN TRY			
	--		DECLARE @UnPostICInvoiceData TABLE  (
	--			intInvoiceId int PRIMARY KEY,
	--			strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	--			UNIQUE (intInvoiceId)
	--		);

	--		DECLARE @intTransactionId INT
	--				,@strTransactionId NVARCHAR(80);
			
	--		--INSERT INTO @UnPostICInvoiceData(intInvoiceId, strTransactionId)
	--		--SELECT DISTINCT
	--		--	 PID.intInvoiceId
	--		--	,PID.strInvoiceNumber
	--		--FROM
	--		--	(SELECT intInvoiceId, strInvoiceNumber FROM @PostInvoiceData) PID
	--		--INNER JOIN
	--		--	(SELECT intInvoiceId, intItemId, intItemUOMId FROM dbo.tblARInvoiceDetail WITH (NOLOCK)) ARID
	--		--		ON PID.intInvoiceId = ARID.intInvoiceId					
	--		--INNER JOIN
	--		--	(SELECT intInvoiceId, intCompanyLocationId, strTransactionType FROM dbo.tblARInvoice WITH (NOLOCK)) ARI
	--		--		ON ARID.intInvoiceId = ARI.intInvoiceId	AND strTransactionType IN ('Invoice', 'Credit Memo', 'Credit Note', 'Cash')				 	
	--		--INNER JOIN
	--		--	(SELECT intItemUOMId FROM dbo.tblICItemUOM WITH (NOLOCK) ) ItemUOM 
	--		--		ON ItemUOM.intItemUOMId = ARID.intItemUOMId
	--		--LEFT OUTER JOIN
	--		--	(SELECT intItemId, intLocationId, strType FROM dbo.vyuICGetItemStock WITH (NOLOCK)) IST
	--		--		ON ARID.intItemId = IST.intItemId 
	--		--		AND ARI.intCompanyLocationId = IST.intLocationId 
	--		INSERT INTO @UnPostICInvoiceData(intInvoiceId, strTransactionId)
	--		SELECT DISTINCT
	--				PID.intInvoiceId
	--			,PID.strInvoiceNumber
	--		FROM
	--			@PostInvoiceData PID
	--		INNER JOIN
	--			(SELECT intInvoiceId, intItemId, intItemUOMId FROM dbo.tblARInvoiceDetail WITH (NOLOCK)) ARID
	--				ON PID.intInvoiceId = ARID.intInvoiceId					
	--		INNER JOIN
	--			(SELECT intInvoiceId, intCompanyLocationId, strTransactionType FROM dbo.tblARInvoice WITH (NOLOCK)) ARI
	--				ON ARID.intInvoiceId = ARI.intInvoiceId	 
	--		INNER JOIN
	--			(SELECT intItemUOMId FROM dbo.tblICItemUOM WITH (NOLOCK) ) ItemUOM 
	--				ON ItemUOM.intItemUOMId = ARID.intItemUOMId
	--		LEFT OUTER JOIN
	--			(SELECT intItemId, intLocationId, strType FROM dbo.vyuICGetItemStock WITH (NOLOCK)) IST
	--				ON ARID.intItemId = IST.intItemId 
	--				AND ARI.intCompanyLocationId = IST.intLocationId 

	--		WHERE 
	--			strTransactionType IN ('Invoice', 'Credit Memo', 'Credit Note', 'Cash')				 	
	--			AND (ARID.intItemId IS NOT NULL OR ARID.intItemId <> 0)
	--			AND ISNULL(IST.strType,'') NOT IN ('Non-Inventory','Service','Other Charge','Software')

	--		WHILE EXISTS(SELECT TOP 1 NULL FROM @UnPostICInvoiceData ORDER BY intInvoiceId)
	--		BEGIN
				
	--			DECLARE @intTransactionIdIC INT
	--					,@strTransactionIdIC NVARCHAR(80)
	--					,@WStorageCount INT
	--					,@WOStorageCount INT
					
	--			SELECT TOP 1 @intTransactionIdIC = intInvoiceId, @strTransactionIdIC = strTransactionId 
	--			FROM	@UnPostICInvoiceData ORDER BY intInvoiceId

	--			SELECT @WStorageCount = COUNT(1) FROM tblARInvoiceDetail WITH (NOLOCK) WHERE intInvoiceId = @intTransactionIdIC AND (ISNULL(intItemId, 0) <> 0) AND (ISNULL(intStorageScheduleTypeId,0) <> 0)	
	--			SELECT @WOStorageCount = COUNT(1) FROM tblARInvoiceDetail WITH (NOLOCK) WHERE intInvoiceId = @intTransactionIdIC AND (ISNULL(intItemId, 0) <> 0) AND (ISNULL(intStorageScheduleTypeId,0) = 0)
	--			IF @WOStorageCount > 0
	--			BEGIN
	--				-- Unpost onhand stocks. 
	--				EXEC	dbo.uspICUnpostCosting
	--							@intTransactionIdIC
	--							,@strTransactionIdIC
	--							,@batchIdUsed
	--							,@userId
	--							,@recap 
	--			END

	--			IF @WStorageCount > 0 
	--			BEGIN 
	--				-- Unpost storage stocks. 
	--				EXEC	dbo.uspICUnpostStorage
	--						@intTransactionId
	--						,@strTransactionId
	--						,@batchIdUsed
	--						,@userId
	--						,@recap
	--			END					
										
	--			DELETE FROM @UnPostICInvoiceData 
	--			WHERE	intInvoiceId = @intTransactionIdIC 
	--					AND strTransactionId = @strTransactionIdIC 												
	--		END								 
																
	--	END TRY
	--	BEGIN CATCH
	--		SELECT @ErrorMerssage = ERROR_MESSAGE()										
	--		GOTO Do_Rollback
	--	END CATCH										
				
	--END     
DECLARE @GLUnPost RecapTableType
INSERT INTO @GLUnPost
SELECT * FROM #ARInvoiceGLEntries WHERE [ysnIsUnposted] = 1
IF EXISTS(SELECT TOP 1 NULL FROM @GLUnPost)
    BEGIN
        EXEC dbo.uspGLBookEntries
                @GLEntries  = @GLUnPost
                ,@ysnPost   = 0

        UPDATE GLD
        SET GLD.[ysnIsUnposted] = 1
        FROM
            tblGLDetail GLD
        INNER JOIN
            @GLUnPost PID
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
            [ysnPost] = 0
            AND [ysnRecap] = 0
            AND [strTransactionType] IN ('Invoice', 'Credit Memo', 'Credit Note', 'Cash')				 	
            AND [intItemId] IS NOT NULL
            AND ISNULL([strItemType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software')

        WHILE EXISTS(SELECT TOP 1 NULL FROM @UnPostICInvoiceData ORDER BY intInvoiceId)
        BEGIN				
					
			SELECT TOP 1 
                 @intTransactionIdIC = [intInvoiceId]
                ,@strTransactionIdIC = [strTransactionId]
			FROM
                @UnPostICInvoiceData
            ORDER BY
                [intInvoiceId]

            SELECT @WStorageCount = COUNT(1) FROM #ARPostInvoiceDetail WHERE [ysnPost] = 0 AND [ysnRecap] = 0 AND [intInvoiceId] = @intTransactionIdIC AND (ISNULL([intItemId], 0) <> 0) AND (ISNULL([intStorageScheduleTypeId],0) <> 0)	
            SELECT @WOStorageCount = COUNT(1) FROM #ARPostInvoiceDetail WHERE [ysnPost] = 0 AND [ysnRecap] = 0 AND [intInvoiceId] = @intTransactionIdIC AND (ISNULL([intItemId], 0) <> 0) AND (ISNULL([intStorageScheduleTypeId],0) = 0)
            IF @WOStorageCount > 0
            BEGIN
                -- Unpost onhand stocks. 
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

        --Recap = 1
		DELETE FROM  @UnPostICInvoiceData
        INSERT INTO @UnPostICInvoiceData
            ([intInvoiceId]
            ,[strTransactionId])
        SELECT DISTINCT
             [intInvoiceId]
            ,[strInvoiceNumber]
        FROM
            #ARPostInvoiceDetail
        WHERE
            [ysnPost] = 0
            AND [ysnRecap] = 1
            AND [strTransactionType] IN ('Invoice', 'Credit Memo', 'Credit Note', 'Cash')				 	
            AND [intItemId] IS NOT NULL
            AND ISNULL([strItemType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software')

        WHILE EXISTS(SELECT TOP 1 NULL FROM @UnPostICInvoiceData ORDER BY intInvoiceId)
        BEGIN					
			SELECT TOP 1 
                 @intTransactionIdIC = [intInvoiceId]
                ,@strTransactionIdIC = [strTransactionId]
			FROM
                @UnPostICInvoiceData
            ORDER BY
                [intInvoiceId]

            SELECT @WStorageCount = COUNT(1) FROM #ARPostInvoiceDetail WHERE [ysnPost] = 0 AND [ysnRecap] = 1 AND [intInvoiceId] = @intTransactionIdIC AND (ISNULL([intItemId], 0) <> 0) AND (ISNULL([intStorageScheduleTypeId],0) <> 0)	
            SELECT @WOStorageCount = COUNT(1) FROM #ARPostInvoiceDetail WHERE [ysnPost] = 0 AND [ysnRecap] = 1 AND [intInvoiceId] = @intTransactionIdIC AND (ISNULL([intItemId], 0) <> 0) AND (ISNULL([intStorageScheduleTypeId],0) = 0)
            IF @WOStorageCount > 0
            BEGIN
                -- Unpost onhand stocks. 
                EXEC dbo.uspICUnpostCosting
                         @intTransactionIdIC
                        ,@strTransactionIdIC
                        ,@BatchId
                        ,@UserId
                        ,1
            END

            IF @WStorageCount > 0 
            BEGIN 
                -- Unpost storage stocks. 
                EXEC dbo.uspICUnpostStorage
                         @intTransactionId
                        ,@strTransactionId
                        ,@BatchId
                        ,@UserId
                        ,1
            END					
										
            DELETE FROM @UnPostICInvoiceData 
            WHERE	intInvoiceId = @intTransactionIdIC 
				AND strTransactionId = @strTransactionIdIC 												
        END	
    END

RETURN 0
