CREATE PROCEDURE [dbo].[uspAPUpdateBillAmounts]
	@billId INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @query NVARCHAR(500) = '', @filter NVARCHAR(100) = '';

SET @query = '
UPDATE A
	SET A.dblDiscount = ISNULL(B.dblDiscount, 0)
	,A.dblInterest = ISNULL(B.dblInterest,0)
	,A.dblWithheld = ISNULL(B.dblWithheld,0)
	,A.dblPayment = ISNULL(B.dblPayment,0)
FROM tblAPBill A
INNER JOIN vyuAPBillPayment B ON A.intBillId = B.intBillId
WHERE A.intTransactionType = 1'

IF @billId IS NOT NULL
BEGIN
	SET @filter = 'AND A.intBillId = @billId';
	SET @query = @query + ' ' + @filter
	EXEC sp_executesql @query, N'@billId INT', @billId = @billId;
END
ELSE
BEGIN
	EXEC sp_executesql @query 
END

RETURN;

