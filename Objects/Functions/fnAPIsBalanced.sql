CREATE FUNCTION [dbo].[fnAPIsBalanced]()
RETURNS BIT
AS
BEGIN
	DECLARE @apBalance DECIMAL(18,6)
	DECLARE @apGLBalance DECIMAL(18,6)
	DECLARE @isBalanced BIT = 0;

	SELECT
		@apBalance = SUM(A.dblTotal) + SUM(A.dblInterest) - SUM(A.dblAmountPaid) - SUM(A.dblDiscount)
FROM vyuAPPayables A
INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId

SELECT
	@apGLBalance = SUM(ISNULL(A.dblCredit,0)) - SUM(ISNULL(A.dblDebit, 0))
FROM tblGLDetail A
INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
WHERE D.intAccountCategoryId = 1
AND A.ysnIsUnposted = 0

IF @apBalance = @apGLBalance SET @isBalanced = 1

RETURN @isBalanced;

END
