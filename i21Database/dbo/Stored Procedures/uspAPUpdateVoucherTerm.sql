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

	UPDATE A
		SET 
			A.intTermsId = @termId,
			A.dtmDueDate = ISNULL(dbo.fnGetDueDateBasedOnTerm(A.dtmDate, A.intTermsId), A.dtmDueDate),
			A.dblDiscount = CASE WHEN A.ysnDiscountOverride = 1 THEN A.dblDiscount ELSE dbo.fnGetDiscountBasedOnTerm(GETDATE(), A.dtmDate, A.intTermsId, A.dblTotal) END,
			A.dtmDeferredInterestDate = (CASE WHEN term.ysnDeferredPay = 1 THEN A.dtmBillDate ELSE NULL END)
	FROM tblAPBill A
	INNER JOIN tblAPBillEdit B
		ON A.intBillId = B.intBillId
	INNER JOIN tblSMTerm term
		ON term.intTermID = A.intTermsId
	AND B.intEntityId = @userId

END