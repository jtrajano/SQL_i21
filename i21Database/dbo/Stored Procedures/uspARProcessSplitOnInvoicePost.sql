CREATE PROCEDURE [dbo].[uspARProcessSplitOnInvoicePost]
     @PostDate DATETIME
    ,@UserId  INT
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF

--IF @post = 1 AND @recap = 0
--BEGIN
--	DECLARE @SplitInvoiceData TABLE([intInvoiceId] INT)

--	INSERT INTO @SplitInvoiceData
--	SELECT 
--		intInvoiceId
--	FROM
--		dbo.tblARInvoice ARI WITH (NOLOCK)
--	WHERE
--		ARI.[ysnSplitted] = 0 
--		AND ISNULL(ARI.[intSplitId], 0) > 0
--		AND EXISTS(SELECT NULL FROM @PostInvoiceData PID WHERE PID.[intInvoiceId] = ARI.[intInvoiceId])
--		AND ARI.strTransactionType IN ('Invoice', 'Cash', 'Debit Memo')

--	WHILE EXISTS(SELECT NULL FROM @SplitInvoiceData)
--		BEGIN
--			DECLARE @invoicesToAdd NVARCHAR(MAX) = NULL, @intSplitInvoiceId INT

--			SELECT TOP 1 @intSplitInvoiceId = intInvoiceId FROM @SplitInvoiceData ORDER BY intInvoiceId

--			EXEC dbo.uspARProcessSplitInvoice @intSplitInvoiceId, @userId, @invoicesToAdd OUT

--			DELETE FROM @PostInvoiceData WHERE intInvoiceId = @intSplitInvoiceId

--			IF (ISNULL(@invoicesToAdd, '') <> '')
--				BEGIN
--                    DELETE FROM @InvoiceIds

--                    INSERT INTO @InvoiceIds
--                        ([intHeaderId]
--                        ,[ysnPost]
--                        ,[ysnRecap]
--                        ,[strBatchId]
--                        ,[ysnAccrueLicense])
--                    SELECT
--                            [intHeaderId]      = ARI.[intInvoiceId]
--                        ,[ysnPost]          = @post
--                        ,[ysnRecap]         = @recap
--                        ,[strBatchId]       = @batchIdUsed
--                        ,[ysnAccrueLicense]	= @accrueLicense
--                    FROM
--                        tblARInvoice ARI
--                    WHERE
--                        EXISTS(SELECT NULL FROM dbo.fnGetRowsFromDelimitedValues(@invoicesToAdd) DV WHERE DV.[intID] = ARI.[intInvoiceId])
--                        AND NOT EXISTS(SELECT NULL FROM @PostInvoiceData PID WHERE PID.[intInvoiceId] = ARI.[intInvoiceId])

--                    INSERT INTO @PostInvoiceData 
--                    SELECT *
--                    FROM [dbo].[fnARGetInvoiceDetailsForPosting]
--                        (@InvoiceIds        --@InvoiceIds
--                        ,@batchIdUsed       --@BatchId
--                        ,@userId            --@UserId
--                        ,NULL               --@IntegrationLogId
--                        )					
--				END

--			DELETE FROM @SplitInvoiceData WHERE intInvoiceId = @intSplitInvoiceId
--		END
--END
DECLARE @ForInsertion NVARCHAR(MAX)
DECLARE @ForDeletion NVARCHAR(MAX)

DECLARE @SplitInvoiceData [InvoicePostingTable]
INSERT INTO @SplitInvoiceData
SELECT *
FROM
    #ARPostInvoiceHeader
WHERE
	[ysnSplitted] = 0
    AND ISNULL([intSplitId], 0) > 0
    AND [strTransactionType] IN ('Invoice', 'Cash', 'Debit Memo')

WHILE EXISTS(SELECT NULL FROM @SplitInvoiceData)
BEGIN
    DECLARE  @invoicesToAdd     NVARCHAR(MAX) = NULL
            ,@intSplitInvoiceId INT
            ,@Post              BIT
            ,@Recap             BIT
            ,@BatchId           NVARCHAR(40)
            ,@AccrueLicense     BIT

    SELECT TOP 1 
         @intSplitInvoiceId	= [intInvoiceId]
        ,@Post              = [ysnPost]
        ,@Recap             = [ysnRecap]
        ,@BatchId           = [strBatchId]          
        ,@AccrueLicense     = [ysnAccrueLicense]
    FROM
        @SplitInvoiceData
    ORDER BY
        [intInvoiceId]

    EXEC dbo.uspARProcessSplitInvoice @intSplitInvoiceId, @UserId, @invoicesToAdd OUT

    SELECT @ForDeletion = ISNULL(@ForDeletion, '') + ISNULL(CONVERT(NVARCHAR(20), @intSplitInvoiceId), '') + ','
	SELECT @ForInsertion = ISNULL(@ForInsertion, '') + ISNULL(CONVERT(NVARCHAR(20), @invoicesToAdd), '') + ','

	DECLARE @TempInvoiceIds AS [InvoiceId]
	DELETE FROM @TempInvoiceIds

	INSERT INTO @TempInvoiceIds
		([intHeaderId]
		,[ysnPost]
		,[ysnRecap]
		,[strBatchId]
		,[ysnAccrueLicense])
	SELECT
		[intHeaderId]   = ARI.[intInvoiceId]
		,[ysnPost]          = @Post
		,[ysnRecap]         = @Recap
		,[strBatchId]       = @BatchId
		,[ysnAccrueLicense]	= @AccrueLicense
	FROM
	tblARInvoice ARI
	WHERE
		ARI.intInvoiceId <> @intSplitInvoiceId
		AND EXISTS(SELECT NULL FROM dbo.fnGetRowsFromDelimitedValues(@ForInsertion) DV WHERE DV.[intID] = ARI.[intInvoiceId])

	WHILE EXISTS(SELECT NULL FROM @TempInvoiceIds)
	BEGIN
		DECLARE @TempInvoiceId INT
		SELECT TOP 1 @TempInvoiceId = [intHeaderId] FROM @TempInvoiceIds
		EXEC dbo.[uspSOUpdateOrderShipmentStatus] @TempInvoiceId, 'Invoice', 1
		DELETE FROM @TempInvoiceIds WHERE [intHeaderId] = @TempInvoiceId
	END

	DELETE FROM @SplitInvoiceData WHERE intInvoiceId = @intSplitInvoiceId
END

IF (ISNULL(@ForDeletion, '') <> '')
	BEGIN
        DELETE FROM #ARPostInvoiceHeader
        WHERE 
            [intInvoiceId] IN (SELECT [intID] FROM dbo.fnGetRowsFromDelimitedValues(@ForDeletion))
        DELETE FROM #ARPostInvoiceDetail
        WHERE 
            [intInvoiceId] IN (SELECT [intID] FROM dbo.fnGetRowsFromDelimitedValues(@ForDeletion))
	END

IF (ISNULL(@ForInsertion, '') <> '')
	BEGIN
		DECLARE @InvoiceIds AS [InvoiceId]
        DELETE FROM @InvoiceIds

        INSERT INTO @InvoiceIds
            ([intHeaderId]
            ,[ysnPost]
            ,[ysnRecap]
            ,[strBatchId]
            ,[ysnAccrueLicense])
        SELECT
             [intHeaderId]   = ARI.[intInvoiceId]
            ,[ysnPost]          = @Post
            ,[ysnRecap]         = @Recap
            ,[strBatchId]       = @BatchId
            ,[ysnAccrueLicense]	= @AccrueLicense
        FROM
            tblARInvoice ARI
        WHERE
            EXISTS(SELECT NULL FROM dbo.fnGetRowsFromDelimitedValues(@ForInsertion) DV WHERE DV.[intID] = ARI.[intInvoiceId])
            AND NOT EXISTS(SELECT NULL FROM #ARPostInvoiceHeader PID WHERE PID.[intInvoiceId] = ARI.[intInvoiceId])

        --INSERT INTO #ARPostInvoiceData 
        --SELECT *
        --FROM [dbo].[fnARGetInvoiceDetailsForPosting]
        --        (@InvoiceIds   --@InvoiceIds
        --        ,@BatchId      --@BatchId
        --        ,@UserId       --@UserId
        --        ,NULL          --@IntegrationLogId
        --        )
		--DELETE FROM @InvoiceIds		
		EXEC [dbo].[uspARPopulateInvoiceDetailForPosting]
			 @Param             = NULL
			,@BeginDate         = NULL
			,@EndDate           = NULL
			,@BeginTransaction  = NULL
			,@EndTransaction    = NULL
			,@IntegrationLogId  = NULL
			,@InvoiceIds        = @InvoiceIds
			,@Post              = @Post
			,@Recap             = @Recap
			,@PostDate          = @PostDate
			,@BatchId           = @BatchId
			,@AccrueLicense     = 0
			,@TransType         = NULL
			,@UserId            = @UserId	
			

	END


RETURN 0
