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

				-- Validate if Derivatives have other bank transactions (partially matched posted commissions)
				IF NOT EXISTS(SELECT 1 FROM tblCMBankTransactionDetail B
					JOIN tblCMBankTransaction A ON A.intTransactionId = B.intTransactionId
					JOIN @PostCommissionDerivativeEntry C ON C.strInternalTradeNo = B.strSourceTransactionId
					WHERE A.strTransactionId <> C.strBankTransactionId AND A.ysnPosted = 1)
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
			END

			-- Update Round-turn
			IF EXISTS(SELECT TOP 1 1 FROM @PostCommissionDerivativeEntry WHERE intMatchNo IS NOT NULL)
			BEGIN
				DECLARE @tblMatchedDerivativeEntry TABLE(
					intMatchNo INT,
					intFutOptTransactionId INT,
					strBuySell NVARCHAR(10),
					strBankTransactionId NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
				)
				
				-- Split Derivate entries under Matched Derivative
				INSERT INTO @tblMatchedDerivativeEntry
				SELECT
					H.intMatchNo,
					D.intLFutOptTransactionId,
					'Buy',
					strBankTransactionId
				FROM tblRKMatchFuturesPSHeader H
				INNER JOIN tblRKMatchFuturesPSDetail D
					ON D.intMatchFuturesPSHeaderId = H.intMatchFuturesPSHeaderId
				INNER JOIN @PostCommissionDerivativeEntry P
					ON P.intMatchNo = H.intMatchNo
				UNION ALL
				SELECT
					H.intMatchNo,
					D.intSFutOptTransactionId,
					'Sell',
					strBankTransactionId
				FROM tblRKMatchFuturesPSHeader H
				INNER JOIN tblRKMatchFuturesPSDetail D
					ON D.intMatchFuturesPSHeaderId = H.intMatchFuturesPSHeaderId
				INNER JOIN @PostCommissionDerivativeEntry P
					ON P.intMatchNo = H.intMatchNo

				-- Check if each derivative entries have other Matched Derivatives
				DECLARE @tblOtherMatchedDerivatives TABLE(
					intMatchNo INT,
					strBankTransactionId NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
				)
				
				
				INSERT INTO @tblOtherMatchedDerivatives
				SELECT A.intMatchNo, B.strBankTransactionId
				FROM tblRKMatchFuturesPSHeader A
				INNER JOIN tblRKMatchFuturesPSDetail D
					ON D.intMatchFuturesPSHeaderId = A.intMatchFuturesPSHeaderId
				INNER JOIN @tblMatchedDerivativeEntry B
					ON B.intFutOptTransactionId = D.intLFutOptTransactionId
				WHERE B.strBuySell = 'Buy'  AND A.intMatchNo <> B.intMatchNo
				UNION ALL
				SELECT A.intMatchNo, B.strBankTransactionId
				FROM tblRKMatchFuturesPSHeader A
				INNER JOIN tblRKMatchFuturesPSDetail D
					ON D.intMatchFuturesPSHeaderId = A.intMatchFuturesPSHeaderId
				INNER JOIN @tblMatchedDerivativeEntry B
					ON B.intFutOptTransactionId = D.intSFutOptTransactionId
				WHERE B.strBuySell = 'Sell'  AND A.intMatchNo <> B.intMatchNo

				-- Check if other Matched Derivatives have posted Bank Transactions
				-- Update Derivative entries to unposted if none
				IF NOT EXISTS(SELECT 1 FROM @tblOtherMatchedDerivatives A
					INNER JOIN tblCMBankTransactionDetail D ON D.intMatchDerivativeNo = A.intMatchNo
					INNER JOIN tblCMBankTransaction H ON H.intTransactionId = D.intTransactionId 
					WHERE H.strTransactionId <> A.strBankTransactionId AND H.ysnPosted = 1
				)
				BEGIN
					UPDATE A
						SET A.ysnPosted = 0
					FROM tblRKFutOptTransaction A
					INNER JOIN @tblMatchedDerivativeEntry B
						ON B.intFutOptTransactionId = A.intFutOptTransactionId
					WHERE ISNULL(A.ysnPosted, 0) = 1

					SELECT @intSuccessfulCount = @@ROWCOUNT;

				END
				
				-- Update Matched Derivative entry
				UPDATE A
					SET A.ysnCommissionPosted = 0
				FROM tblRKMatchFuturesPSHeader A
				INNER JOIN @PostCommissionDerivativeEntry B
					ON B.intMatchNo = A.intMatchNo
				WHERE ISNULL(A.ysnCommissionPosted, 0) = 1
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
				DELETE @tblDerivativeEntry

				-- Update each derivative entry
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
			IF EXISTS(SELECT TOP 1 1 FROM @PostCommissionDerivativeEntry WHERE strCommissionRateType = 'Round-turn' AND intMatchNo IS NOT NULL)
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

				-- Update each derivative entry
				UPDATE A
					SET A.ysnPosted = 1
				FROM tblRKFutOptTransaction A
				INNER JOIN @tblDerivativeEntry B
					ON B.intId = A.intFutOptTransactionId
				WHERE ISNULL(A.ysnPosted, 0) = 0

				SELECT @intSuccessfulCount = @@ROWCOUNT;

				-- Update Matched Derivative entry
				UPDATE A
					SET A.ysnCommissionPosted = 1
				FROM tblRKMatchFuturesPSHeader A
				INNER JOIN @PostCommissionDerivativeEntry B
					ON B.intMatchNo = A.intMatchNo
				WHERE ISNULL(A.ysnCommissionPosted, 0) = 0
			END
		END
	END

RETURN 0
