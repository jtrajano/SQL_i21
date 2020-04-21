CREATE PROCEDURE [dbo].[uspRKReassignMatchDerivatives]
    @Ids Id READONLY
    , @intUserId INT

AS

BEGIN
    DECLARE @ErrMsg NVARCHAR(MAX)

    SELECT *
	INTO #tmpMatchDerivatives
    FROM (
        SELECT intFutOptTransactionId = md.intLFutOptTransactionId
            , intMatchFuturesPSDetailId
            , intMatchFuturesPSHeaderId
            , md.dblMatchQty
            , dblFutCommission
        FROM @Ids id
        LEFT JOIN tblRKMatchFuturesPSDetail md ON md.intLFutOptTransactionId = id.intId

        UNION ALL 
		SELECT intFutOptTransactionId = md.intSFutOptTransactionId
            , intMatchFuturesPSDetailId
            , intMatchFuturesPSHeaderId
            , md.dblMatchQty
            , dblFutCommission
        FROM @Ids id
        LEFT JOIN tblRKMatchFuturesPSDetail md ON md.intSFutOptTransactionId = id.intId
    ) tbl
	WHERE ISNULL(intFutOptTransactionId, 0) <> 0

    DECLARE @intFutOptTransactionId INT
        , @intFutOptTransactionHeaderId INT
        , @intUnMatchedTransactionId INT
        , @intUnMatchedTransactionHeaderId INT
        , @intMatchFuturesPSDetailId INT
        , @intMatchFuturesPSHeaderId INT
        , @dblOrigCommission NUMERIC(18, 6)
        , @dblNewCommission NUMERIC(18, 6)
        , @dblOldCommission NUMERIC(18, 6)
        , @dblMatchQty NUMERIC(18, 6)
        , @dblMatchDerivative NUMERIC(18, 6)
        , @dblUnmatched NUMERIC(18, 6)
        , @dblNewMatchQty NUMERIC(18, 6)
        , @strMatchedDerivative NVARCHAR(50)
        , @strUnmatchedDerivative NVARCHAR(50)

    WHILE EXISTS(SELECT TOP 1 1 FROM #tmpMatchDerivatives)
    BEGIN
        SELECT TOP 1 @intFutOptTransactionId = intFutOptTransactionId
            , @intMatchFuturesPSDetailId = intMatchFuturesPSDetailId
            , @intMatchFuturesPSHeaderId = intMatchFuturesPSHeaderId
            , @dblMatchQty = dblMatchQty
			, @dblOrigCommission = dblFutCommission
        FROM #tmpMatchDerivatives

        SELECT TOP 1 @strMatchedDerivative = strInternalTradeNo
            , @dblMatchDerivative = dblNoOfContract
            , @intFutOptTransactionHeaderId = intFutOptTransactionHeaderId
        FROM tblRKFutOptTransaction
        WHERE intFutOptTransactionId = @intFutOptTransactionId

        SELECT TOP 1 @intUnMatchedTransactionId = intFutOptTransactionId
            , @intUnMatchedTransactionHeaderId = intFutOptTransactionHeaderId
            , @strUnmatchedDerivative = strInternalTradeNo
            , @dblUnmatched = dblNoOfContract
        FROM tblRKFutOptTransaction
        WHERE intFutOptTransactionId IN (SELECT intId FROM @Ids)
            AND intFutOptTransactionId <> @intFutOptTransactionId

        IF (@dblMatchQty > @dblMatchDerivative)
        BEGIN
            SET @dblNewMatchQty = @dblMatchQty - @dblMatchDerivative

            IF (@dblNewMatchQty <> @dblUnmatched)
            BEGIN
                SET @ErrMsg = @strMatchedDerivative + ' is previously matched. The reassigned derivative ' + @strUnmatchedDerivative + ' does not fulfill this match derivative.'
                RAISERROR(@ErrMsg, 16, 1)
            END

			IF (@dblOrigCommission = 0)
			BEGIN
				SET @dblOldCommission = 0
				SET @dblNewCommission = 0
			END
			ELSE
			BEGIN
				SET @dblOldCommission = (@dblOrigCommission / @dblMatchQty) * @dblMatchDerivative
				SET @dblNewCommission = @dblOrigCommission - @dblOldCommission
			END
            

            EXEC uspRKMatchDerivativesHistoryInsert @intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId
                , @action = 'DELETE'
                , @userId = @intUserId

            UPDATE tblRKMatchFuturesPSDetail
            SET dblMatchQty = @dblMatchDerivative
                , dblFutCommission = @dblOldCommission
            WHERE intMatchFuturesPSDetailId = @intMatchFuturesPSDetailId

            INSERT INTO tblRKMatchFuturesPSDetail(intMatchFuturesPSHeaderId
                , dblMatchQty
                , dblFutCommission
                , intLFutOptTransactionId
                , intSFutOptTransactionId
                , dtmMatchedDate
                , intLFutOptTransactionHeaderId
                , intSFutOptTransactionHeaderId
                , intConcurrencyId)
            SELECT intMatchFuturesPSHeaderId
                , @dblUnmatched
                , @dblNewCommission
                , intLFutOptTransactionId = CASE WHEN intLFutOptTransactionId = @intFutOptTransactionId THEN @intUnMatchedTransactionId ELSE intLFutOptTransactionId END
                , intSFutOptTransactionId = CASE WHEN intSFutOptTransactionId = @intFutOptTransactionId THEN @intUnMatchedTransactionId ELSE intSFutOptTransactionId END
                , dtmMatchedDate
                , intLFutOptTransactionHeaderId = CASE WHEN intLFutOptTransactionHeaderId = @intFutOptTransactionHeaderId THEN @intUnMatchedTransactionHeaderId ELSE intLFutOptTransactionHeaderId END
                , intSFutOptTransactionHeaderId = CASE WHEN intSFutOptTransactionHeaderId = @intFutOptTransactionHeaderId THEN @intUnMatchedTransactionHeaderId ELSE intSFutOptTransactionHeaderId END
                , 1
            FROM tblRKMatchFuturesPSDetail
            WHERE intMatchFuturesPSDetailId = @intMatchFuturesPSDetailId

            EXEC uspRKMatchDerivativesHistoryInsert @intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId
                , @action = 'ADD'
                , @userId = @intUserId
        END
    
        DELETE FROM #tmpMatchDerivatives
        WHERE intFutOptTransactionId = @intFutOptTransactionId
            AND intMatchFuturesPSDetailId = @intMatchFuturesPSDetailId
            AND intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId
    END  
END