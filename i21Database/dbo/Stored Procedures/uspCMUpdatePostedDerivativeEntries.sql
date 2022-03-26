CREATE PROCEDURE [dbo].[uspCMUpdatePostedDerivativeEntries](
	@PostCommissionDerivativeEntry PostCommissionDerivativeEntryTable READONLY,
	@intSuccessfulCount INT = 0 OUTPUT
)
AS

	IF EXISTS(SELECT TOP 1 1 FROM @PostCommissionDerivativeEntry)
	BEGIN
		-- Update Half-turn
		IF EXISTS(SELECT TOP 1 1 FROM @PostCommissionDerivativeEntry WHERE strCommissionRateType = 'Half-turn')
		BEGIN
			UPDATE A
				SET 
					 A.ysnCommissionOverride = ISNULL(B.ysnCommissionOverride, A.ysnCommissionOverride)
					,A.ysnPosted = ISNULL(B.ysnPosted, A.ysnPosted)
					,A.dblCommission = ISNULL(B.dblCommission, A.dblCommission)
			FROM tblRKFutOptTransaction A
			INNER JOIN @PostCommissionDerivativeEntry B
				ON B.intTransactionId = A.intFutOptTransactionId AND B.strInternalTradeNo = A.strInternalTradeNo
			WHERE B.strCommissionRateType = 'Half-turn' AND ISNULL(A.ysnPosted, 0) = 0 

			SELECT @intSuccessfulCount = @@ROWCOUNT;
		END

		-- Update Round-turn
		IF EXISTS(SELECT TOP 1 1 FROM @PostCommissionDerivativeEntry WHERE strCommissionRateType = 'Round-turn')
		BEGIN
			DECLARE @tblDerivativeEntry Id
			
			INSERT INTO @tblDerivativeEntry
			SELECT
				D.intLFutOptTransactionId
			FROM tblRKMatchFuturesPSHeader H
			INNER JOIN tblRKMatchFuturesPSDetail D
				ON D.intMatchFuturesPSHeaderId = H.intMatchFuturesPSHeaderId
			INNER JOIN @PostCommissionDerivativeEntry P
				ON P.intTransactionId = H.intMatchFuturesPSHeaderId
			WHERE P.strCommissionRateType = 'Round-turn'
			UNION ALL
			SELECT
				D.intSFutOptTransactionId
			FROM tblRKMatchFuturesPSHeader H
			INNER JOIN tblRKMatchFuturesPSDetail D
				ON D.intMatchFuturesPSHeaderId = H.intMatchFuturesPSHeaderId
			INNER JOIN @PostCommissionDerivativeEntry P
				ON P.intTransactionId = H.intMatchFuturesPSHeaderId
			WHERE P.strCommissionRateType = 'Round-turn'

			UPDATE A
				SET A.ysnPosted = 1
			FROM tblRKFutOptTransaction A
			INNER JOIN @tblDerivativeEntry B
				ON B.intId = A.intFutOptTransactionId
			WHERE ISNULL(A.ysnPosted, 0) = 0

			SELECT @intSuccessfulCount = @@ROWCOUNT;
		END
	END

RETURN 0
