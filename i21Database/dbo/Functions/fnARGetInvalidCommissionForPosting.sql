CREATE FUNCTION [dbo].[fnARGetInvalidCommissionForPosting]
(
	 @Commissions	[dbo].[CommissionPostingTable] READONLY
	,@Post			BIT = 0
	,@Recap			BIT = 0
)
RETURNS @returntable TABLE
(
	 [intCommissionId]			INT				NOT NULL
	,[strCommissionNumber]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[strBatchId]				NVARCHAR(40)	COLLATE Latin1_General_CI_AS	NULL
	,[strPostingError]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL
)
AS
BEGIN
	DECLARE @ZeroDecimal DECIMAL(18,6) = 0

	INSERT @returntable (
		 intCommissionId
		,strCommissionNumber
		,strBatchId
		,strPostingError
	)
	--ZERO AMOUNT
	SELECT intCommissionId
		 ,strCommissionNumber
		 ,strBatchId
		 ,'You cannot post Commission with zero amount.'
	FROM @Commissions
	WHERE dblTotalAmount <= @ZeroDecimal

	UNION ALL

	--ALREADY POSTED
	SELECT intCommissionId
		 ,strCommissionNumber
		 ,strBatchId
		 ,'Commission is already posted!'
	FROM @Commissions
	WHERE ysnPosted = 1
	  AND @Post = 1

	UNION ALL

	--ALREADY PAID
	SELECT intCommissionId
		 ,strCommissionNumber
		 ,strBatchId
		 ,'Commission is already paid!'
	FROM @Commissions
	WHERE ysnPaid = 1
	  AND @Post = 0

	UNION ALL
	  
	--INVALID COMMISSION EXPENSE ACCOUNT
	SELECT intCommissionId
		 ,strCommissionNumber
		 ,strBatchId
		 ,'Commission Expense Account was not set in Sales > Company Configuration!'
	FROM @Commissions
	WHERE ISNULL(intCommissionExpenseAccountId, 0) = 1

	UNION ALL

	--INVALID AP CLEARING ACCOUNT
	SELECT intCommissionId
		 ,strCommissionNumber
		 ,strBatchId
		 ,'AP Clearing Account was not set in Sales > Company Configuration!'
	FROM @Commissions
	WHERE ISNULL(intAPClearingAccountId, 0) = 1
	
	RETURN
END
