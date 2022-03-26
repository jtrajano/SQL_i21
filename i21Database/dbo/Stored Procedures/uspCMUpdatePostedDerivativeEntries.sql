CREATE PROCEDURE [dbo].[uspCMUpdatePostedDerivativeEntries](
	@PostCommissionDerivativeEntry PostCommissionDerivativeEntryTable READONLY,
	@ysnPost BIT = 0,
	@intSuccessfulCount INT = 0 OUTPUT
)
AS
	DECLARE @tblDerivativeEntry Id

	IF (ISNULL(@ysnPost, 0) = 0)
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM @PostCommissionDerivativeEntry)
		BEGIN
			-- Update Half-turn
			IF EXISTS(SELECT TOP 1 1 FROM @PostCommissionDerivativeEntry WHERE strInternalTradeNo IS NOT NULL)
			BEGIN
				UPDATE A
					SET 
						A.ysnPosted = 0
				FROM tblRKFutOptTransaction A
				INNER JOIN @PostCommissionDerivativeEntry B
					ON B.strInternalTradeNo = A.strInternalTradeNo
				WHERE ISNULL(A.ysnPosted, 0) = 1

				SELECT @intSuccessfulCount = @@ROWCOUNT;
			END

			-- Update Round-turn
			IF EXISTS(SELECT TOP 1 1 FROM @PostCommissionDerivativeEntry WHERE intMatchNo IS NOT NULL)
			BEGIN
				
				DELETE @tblDerivativeEntry
				INSERT INTO @tblDerivativeEntry
				SELECT
					D.intLFutOptTransactionId
				FROM tblRKMatchFuturesPSHeader H
				INNER JOIN tblRKMatchFuturesPSDetail D
					ON D.intMatchFuturesPSHeaderId = H.intMatchFuturesPSHeaderId
				INNER JOIN @PostCommissionDerivativeEntry P
					ON P.intMatchNo = H.intMatchNo
				UNION ALL
				SELECT
					D.intSFutOptTransactionId
				FROM tblRKMatchFuturesPSHeader H
				INNER JOIN tblRKMatchFuturesPSDetail D
					ON D.intMatchFuturesPSHeaderId = H.intMatchFuturesPSHeaderId
				INNER JOIN @PostCommissionDerivativeEntry P
					ON P.intMatchNo = H.intMatchNo

				UPDATE A
					SET A.ysnPosted = 0
				FROM tblRKFutOptTransaction A
				INNER JOIN @tblDerivativeEntry B
					ON B.intId = A.intFutOptTransactionId
				WHERE ISNULL(A.ysnPosted, 0) = 1

				SELECT @intSuccessfulCount = @@ROWCOUNT;
			END
		END
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM @PostCommissionDerivativeEntry)
		BEGIN
			-- Update Half-turn
			IF EXISTS(SELECT TOP 1 1 FROM @PostCommissionDerivativeEntry WHERE strCommissionRateType = 'Half-turn')
			BEGIN
				UPDATE A
					SET 
						 A.ysnCommissionOverride = ISNULL(B.ysnCommissionOverride, A.ysnCommissionOverride)
						,A.ysnPosted = 1
						,A.dblCommission = ISNULL(B.dblCommission, A.dblCommission)
				FROM tblRKFutOptTransaction A
				INNER JOIN @PostCommissionDerivativeEntry B
					ON B.strInternalTradeNo = A.strInternalTradeNo
				WHERE B.strCommissionRateType = 'Half-turn' AND ISNULL(A.ysnPosted, 0) = 0 

				SELECT @intSuccessfulCount = @@ROWCOUNT;
			END

			-- Update Round-turn
			IF EXISTS(SELECT TOP 1 1 FROM @PostCommissionDerivativeEntry WHERE strCommissionRateType = 'Round-turn')
			BEGIN
				DELETE @tblDerivativeEntry

				INSERT INTO @tblDerivativeEntry
				SELECT
					D.intLFutOptTransactionId
				FROM tblRKMatchFuturesPSHeader H
				INNER JOIN tblRKMatchFuturesPSDetail D
					ON D.intMatchFuturesPSHeaderId = H.intMatchFuturesPSHeaderId
				INNER JOIN @PostCommissionDerivativeEntry P
					ON P.intMatchNo = H.intMatchNo
				WHERE P.strCommissionRateType = 'Round-turn'
				UNION ALL
				SELECT
					D.intSFutOptTransactionId
				FROM tblRKMatchFuturesPSHeader H
				INNER JOIN tblRKMatchFuturesPSDetail D
					ON D.intMatchFuturesPSHeaderId = H.intMatchFuturesPSHeaderId
				INNER JOIN @PostCommissionDerivativeEntry P
					ON P.intMatchNo =  H.intMatchNo
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
	END

RETURN 0
