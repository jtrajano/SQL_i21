CREATE PROCEDURE [dbo].[uspFAReversePreviousAssetTransaction]
 @Id    AS Id READONLY, 
 @ysnRecap   AS BIT    = 0,  
 @intEntityId  AS INT    = 1,  
 @ysnReverseCurrentDate BIT = 0,
 @strBatchId   AS NVARCHAR(100),
 @intSuccessfulCount AS INT = 0 OUTPUT
 
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  

DECLARE @IdGood Id
DECLARE @IdGLDetail Id
-- Asset Table
DECLARE @tblAsset TABLE (
    intAssetId INT,
    strAssetId NVARCHAR(100) COLLATE Latin1_General_CI_AS,
    ysnDisposed BIT,
    ysnDepreciated BIT,
    ysnAcquired BIT,
    ysnProcessed BIT
)
-- table for asset's transactions
DECLARE @tblTransactions TABLE (
	intAssetId INT,
	strTransaction NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strTransactionId NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	dtmTransactionDate DATETIME
)
-- table for asset's transactions to be reversed
DECLARE @tblTransactionIds TABLE (
	strTransactionId NVARCHAR(100) COLLATE Latin1_General_CI_AS
)

DECLARE 
    @intCount INT, 
    @ErrorMsg NVARCHAR(MAX),
    @intCurrentAssetId INT,
    @ysnAcquired BIT = 0,
	@ysnDepreciated BIT = 0,
	@ysnDisposed BIT = 0,
	@dtmDepreciationToDate DATETIME,
	@dtmFiscalPeriodStartDate DATETIME,
	@dtmFiscalPeriodEndDate DATETIME,
    @intFiscalPeriodId INT

INSERT INTO @tblAsset
SELECT
    FA.intAssetId,
    FA.strAssetId,
    FA.ysnDisposed,
    FA.ysnDepreciated,
    FA.ysnAcquired,
    0
FROM tblFAFixedAsset FA
JOIN 
    @Id Id ON Id.intId = FA.intAssetId

-- Process each asset in Asset Table
WHILE EXISTS(SELECT TOP 1 1 FROM @tblAsset WHERE ysnProcessed = 0)
BEGIN
    SELECT TOP 1 
        @intCurrentAssetId = intAssetId
        ,@ysnDisposed = ysnDisposed
        ,@ysnDepreciated = ysnDepreciated
        ,@ysnAcquired = ysnAcquired 
    FROM @tblAsset 
    WHERE ysnProcessed = 0

    -- Get all asset's transactions -> include Purchase transaction from tblGLDetail
    BEGIN
        WITH FA AS (
	        SELECT 
		        intAssetId
		        ,strAssetId
	        FROM tblFAFixedAsset
	        GROUP BY intAssetId, strAssetId
        ),
        G AS (
	        SELECT 
		        dtmDepreciationToDate
		        ,intAssetId
		        ,strTransaction
		        ,strTransactionId
	        FROM tblFAFixedAssetDepreciation 
	        WHERE intBookId = 1
	        GROUP BY 
                dtmDepreciationToDate
                ,intAssetId
                ,strTransaction
                ,strTransactionId
        )
        INSERT INTO @tblTransactions
        SELECT
	        FA.intAssetId,
	        GL.strTransactionType strTransaction, 
	        GL.strTransactionId,
	        GL.dtmTransactionDate
         FROM FA
         LEFT JOIN tblGLDetail GL 
            ON GL.intTransactionId = FA.intAssetId AND GL.strReference = FA.strAssetId
         WHERE 
            GL.strTransactionType = 'Purchase'
            AND GL.ysnIsUnposted = 0
            AND FA.intAssetId = @intCurrentAssetId
         GROUP BY 
	        FA.intAssetId, 
	        GL.strTransactionType, 
	        GL.strTransactionId,
	        GL.dtmTransactionDate
        UNION ALL
        SELECT
	        G.intAssetId,
	        G.strTransaction,
	        G.strTransactionId,
	        G.dtmDepreciationToDate
        FROM G 
        WHERE G.intAssetId = @intCurrentAssetId
    END

    -- Get most recent transaction date
    SELECT TOP 1 
        @dtmDepreciationToDate = dtmTransactionDate
    FROM @tblTransactions 
    ORDER BY dtmTransactionDate DESC

    -- Get the fiscal period using the most recent transaction date
    SELECT 
	    @dtmFiscalPeriodStartDate = dtmStartDate,
	    @dtmFiscalPeriodEndDate = dtmEndDate,
        @intFiscalPeriodId = intGLFiscalYearPeriodId
    FROM tblGLFiscalYearPeriod 
    WHERE @dtmDepreciationToDate BETWEEN dtmStartDate AND dtmEndDate

    -- Get the most recent transactions using the fiscal period
    IF (@ysnDisposed = 1)
    BEGIN
	    INSERT INTO @tblTransactionIds
	    SELECT 
		    strTransactionId 
	    FROM @tblTransactions
	    WHERE 
		    strTransaction = 'Dispose'
		    AND dtmTransactionDate BETWEEN @dtmFiscalPeriodStartDate AND @dtmFiscalPeriodEndDate
	    ORDER BY dtmTransactionDate DESC

	    GOTO PROCESS_TRANSACTIONS
    END
    IF (@ysnDepreciated = 1)
    BEGIN
	    INSERT INTO @tblTransactionIds
	    SELECT 
		    strTransactionId 
	    FROM @tblTransactions
	    WHERE 
		    strTransaction IN ('Depreciation', 'Basis Adjustment', 'Imported')
		    AND dtmTransactionDate BETWEEN @dtmFiscalPeriodStartDate AND @dtmFiscalPeriodEndDate
	    ORDER BY dtmTransactionDate DESC

	    GOTO PROCESS_TRANSACTIONS
    END
    IF (@ysnAcquired = 1)
    BEGIN
        IF EXISTS(SELECT TOP 1 1 FROM @tblTransactions WHERE strTransaction = 'Place in service')
	        INSERT INTO @tblTransactionIds
	        SELECT 
		        strTransactionId 
	        FROM @tblTransactions
	        WHERE 
		        strTransaction = 'Place in service'
		        AND dtmTransactionDate BETWEEN @dtmFiscalPeriodStartDate AND @dtmFiscalPeriodEndDate
	        ORDER BY dtmTransactionDate DESC
        ELSE
            INSERT INTO @tblTransactionIds
	            SELECT 
		            strTransactionId 
	            FROM @tblTransactions
	            WHERE 
		            strTransaction  = 'Purchase'
		            AND dtmTransactionDate BETWEEN @dtmFiscalPeriodStartDate AND @dtmFiscalPeriodEndDate
	            ORDER BY dtmTransactionDate DESC

	    GOTO PROCESS_TRANSACTIONS
    END
    
    -- Get GL Detail Id of each transations
    PROCESS_TRANSACTIONS:

    INSERT INTO @IdGLDetail
    SELECT 
	    GL.intGLDetailId 
    FROM tblGLDetail GL
    JOIN @tblTransactionIds Transactions
        ON Transactions.strTransactionId = GL.strTransactionId
    WHERE 
	    ysnIsUnposted = 0
    
    DECLARE @intReverseResult INT  
    DECLARE @dtmReverse DATETIME = NULL
    -- Process reversal of transactions
    BEGIN TRY
    IF (@ysnReverseCurrentDate = 1)
        SET @dtmReverse = CAST(CONVERT(NVARCHAR(10), @dtmDepreciationToDate, 101) AS DATETIME)
    
    IF EXISTS(SELECT TOP 1 1 FROM tblGLFiscalYearPeriod where @dtmReverse BETWEEN dtmStartDate AND dtmEndDate 
        AND (ysnFAOpen = 0 OR ysnOpen = 0))
    BEGIN
        RAISERROR('Current fiscal period is closed.', 16,1)
        ROLLBACK TRANSACTION
    END
        IF EXISTS(SELECT 1 FROM @IdGLDetail)
            EXEC @intReverseResult = [dbo].[uspFAReverseMultipleAsset] @strBatchId, @IdGLDetail, @ysnRecap, @dtmReverse, @intEntityId, @intCount OUT  
    END TRY
    BEGIN CATCH
        SELECT @ErrorMsg = ERROR_MESSAGE()
        RAISERROR(@ErrorMsg, 16,1)
        ROLLBACK TRANSACTION
    END CATCH

    IF @intReverseResult <> 0 RETURN --1  
    SET @intSuccessfulCount = @intCount  

    IF ISNULL(@ysnRecap,0) = 0
    BEGIN
        IF (@ysnDisposed = 1)
        BEGIN
            -- Remove assset disposition details
            UPDATE tblFAFixedAsset
            SET 
                ysnDisposed = 0, 
                dtmDispositionDate = NULL, 
                intDispositionNumber = NULL, 
                strDispositionNumber = ''
            WHERE intAssetId = @intCurrentAssetId

            -- Remove Dispose transaction only 
            DELETE tblFAFixedAssetDepreciation
            WHERE 
                intAssetId = @intCurrentAssetId 
                AND strTransaction = 'Dispose'
        END
        ELSE IF (@ysnDepreciated = 1)
        BEGIN
            -- Set FullyDepreciated flag to false if true
            UPDATE BD 
            SET 
                ysnFullyDepreciated = 0
            FROM tblFABookDepreciation BD 
            WHERE 
                intAssetId = @intCurrentAssetId
                AND ysnFullyDepreciated = 1

            -- GAAP 
            -- Get date period from Fiscal Period
            SELECT TOP 1
                @dtmDepreciationToDate = dtmDepreciationToDate
            FROM tblFAFixedAssetDepreciation 
            WHERE 
                intAssetId = @intCurrentAssetId 
                AND intBookId = 1
            ORDER BY dtmDepreciationToDate DESC

            SELECT 
                @dtmFiscalPeriodStartDate = dtmStartDate, 
                @dtmFiscalPeriodEndDate = dtmEndDate 
            FROM [dbo].[fnFAGetMonthPeriodFromDate](@dtmDepreciationToDate, 1)

            DELETE tblFAFixedAssetDepreciation
            WHERE
                intAssetId = @intCurrentAssetId
                AND intBookId = 1
                AND strTransaction IN ('Depreciation', 'Imported')
                AND dtmDepreciationToDate BETWEEN @dtmFiscalPeriodStartDate AND @dtmFiscalPeriodEndDate

            -- If no depreciations left, set depreciated flag to false
            UPDATE FA
            SET
                ysnDepreciated = 0
            FROM tblFAFixedAsset FA
            OUTER APPLY (
                SELECT 
                    COUNT(1) intCount 
                FROM tblFAFixedAssetDepreciation 
                WHERE 
                    intAssetId = @intCurrentAssetId 
                    AND strTransaction IN ('Depreciation', 'Imported')
                    AND intBookId = 1
            ) Depreciation
            WHERE Depreciation.intCount = 0 AND FA.intAssetId = @intCurrentAssetId

            -- Tax
            -- Seperate the reversing of Tax depreciations because tax follows default calendar period while GAAP may not.
            SET @dtmDepreciationToDate = NULL
            IF EXISTS(SELECT TOP 1 1 FROM tblFAFixedAssetDepreciation WHERE intAssetId = @intCurrentAssetId AND intBookId = 2) -- Check if has Tax depreciation
            BEGIN
                -- Get date period from Calendar Period
                SELECT TOP 1 
                    @dtmDepreciationToDate = dtmDepreciationToDate 
                FROM tblFAFixedAssetDepreciation 
                WHERE 
                    intAssetId = @intCurrentAssetId 
                    AND intBookId = 2 
                ORDER BY dtmDepreciationToDate DESC

                SELECT
                    @dtmFiscalPeriodStartDate = dtmStartDate, 
                    @dtmFiscalPeriodEndDate = dtmEndDate 
                FROM [dbo].[fnFAGetMonthPeriodFromDate](@dtmDepreciationToDate, 0)

                DELETE tblFAFixedAssetDepreciation
                WHERE
                    intAssetId = @intCurrentAssetId
                    AND intBookId = 2
                    AND strTransaction IN ('Depreciation', 'Imported')
                    AND dtmDepreciationToDate BETWEEN @dtmFiscalPeriodStartDate AND @dtmFiscalPeriodEndDate

                -- If no depreciations left, set depreciated flag to false
                UPDATE FA
                SET
                    ysnTaxDepreciated = 0
                FROM tblFAFixedAsset FA
                OUTER APPLY (
                    SELECT 
                        COUNT(1) intCount 
                    FROM tblFAFixedAssetDepreciation 
                    WHERE 
                        intAssetId = @intCurrentAssetId
                        AND strTransaction IN ('Depreciation', 'Imported')
                        AND intBookId = 2
                ) Depreciation
                WHERE 
                    Depreciation.intCount = 0 
                    AND FA.intAssetId = @intCurrentAssetId
            END
        END
        ELSE 
        BEGIN
            -- Check latest remaining transaction if Place in service
            IF EXISTS(SELECT TOP 1 1 FROM tblFAFixedAssetDepreciation WHERE strTransaction = 'Place in service' AND intAssetId = @intCurrentAssetId ORDER BY dtmDepreciationToDate)
            BEGIN
                DELETE tblFAFixedAssetDepreciation
                WHERE
                    intAssetId = @intCurrentAssetId
                    AND strTransaction = 'Place in service'
            END
            ELSE
                UPDATE tblFAFixedAsset
                SET 
                    ysnAcquired = 0
                WHERE intAssetId = @intCurrentAssetId
        END

        -- Remove from undepreciated
        DELETE A 
        FROM tblFAFiscalAsset A 
        WHERE 
            A.intFiscalPeriodId = @intFiscalPeriodId
            AND A.intAssetId = @intCurrentAssetId
    END

    UPDATE @tblAsset 
    SET 
        ysnProcessed = 1
    WHERE intAssetId = @intCurrentAssetId
END

RETURN 1