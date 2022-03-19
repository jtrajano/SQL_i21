CREATE PROCEDURE [dbo].[uspCMUpdatePostedDerivativeEntries]
	@PostCommissionDerivativeEntry PostCommissionDerivativeEntryTable READONLY,
	@intSuccesfulCount INT = 0 OUTPUT
AS

	IF EXISTS(SELECT TOP 1 1 FROM @PostCommissionDerivativeEntry)
	BEGIN
		UPDATE A
			SET 
				A.ysnCommissionExempt = ISNULL(B.ysnCommissionExempt, A.ysnCommissionExempt)
				,A.ysnCommissionOverride = ISNULL(B.ysnCommissionOverride, A.ysnCommissionOverride)
				,A.ysnPosted = ISNULL(B.ysnPosted, A.ysnPosted)
				,A.dblCommission = ISNULL(B.dblCommission, A.dblCommission)
		FROM tblRKFutOptTransaction A
		INNER JOIN @PostCommissionDerivativeEntry B
			ON B.intTransactionId = A.intFutOptTransactionId

		SELECT @intSuccesfulCount = @@ROWCOUNT;
	END

RETURN 0
