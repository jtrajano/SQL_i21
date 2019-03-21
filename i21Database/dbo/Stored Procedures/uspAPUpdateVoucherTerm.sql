CREATE PROCEDURE [dbo].[uspAPUpdateVoucherTerm]
	@userId INT,
	@termId INT
AS

BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	CREATE TABLE #tmpDataChange
	(
		intBillId INT,
		intTermsId INT,
		intNewTermsId INT,
		dtmDueDate DATETIME,
		dtmNewDueDate DATETIME,
		dblDiscount DECIMAL(18,2),
		dblNewDiscount DECIMAL(18,2),
		dtmDeferredInterestDate DATETIME,
		dtmNewDeferredInterestDate DATETIME
	)

	UPDATE A
		SET 
			A.intTermsId = @termId,
			A.dtmDueDate = ISNULL(dbo.fnGetDueDateBasedOnTerm(A.dtmDate, A.intTermsId), A.dtmDueDate),
			A.dblDiscount = CASE WHEN A.ysnDiscountOverride = 1 THEN A.dblDiscount ELSE dbo.fnGetDiscountBasedOnTerm(GETDATE(), A.dtmDate, A.intTermsId, A.dblTotal) END,
			A.dtmDeferredInterestDate = (CASE WHEN term.ysnDeferredPay = 1 THEN A.dtmBillDate ELSE NULL END)
	OUTPUT 
		inserted.intBillId,
		deleted.intTermsId, inserted.intTermsId,
		deleted.dtmDueDate, inserted.dtmDueDate,
		deleted.dblDiscount, inserted.dblDiscount,
		deleted.dtmDeferredInterestDate, inserted.dtmDeferredInterestDate
	INTO #tmpDataChange
	FROM tblAPBill A
	INNER JOIN tblAPBillEdit B
		ON A.intBillId = B.intBillId
	INNER JOIN tblSMTerm term
		ON term.intTermID = A.intTermsId
	AND B.intEntityId = @userId

	-- DECLARE @strDescription AS NVARCHAR(100) 
	-- ,@actionType AS NVARCHAR(50)
	-- ,@billId AS NVARCHAR(50);
	-- DECLARE @billCounter INT = 0;
	-- DECLARE @totalRecords INT = 0;

	-- SELECT @totalRecords = COUNT(*) FROM #tmpDataChange

	-- WHILE(@billCounter != (@totalRecords))
	-- BEGIN
	-- 	SELECT TOP(1)
	-- 		@billId = CAST(A.intBillId AS NVARCHAR(50))
	-- 		@from = 

	-- 	EXEC dbo.uspSMAuditLog 
	-- 	@screenName = 'AccountsPayable.view.Voucher'		-- Screen Namespace
	-- 	,@keyValue = @billId								-- Primary Key Value of the Voucher. 
	-- 	,@entityId = @userId									-- Entity Id.
	-- 	,@actionType = 'Updated'                       -- Action Type
	-- 	,@changeDescription = @strDescription				-- Description
	-- 	,@fromValue = ''									-- Previous Value
	-- 	,@toValue = ''									-- New Value

	-- SET @billCounter = @billCounter + 1
	-- DELETE FROM #tmpPostBillData WHERE intBillId = @billId
	-- END

END