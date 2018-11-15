CREATE PROCEDURE [dbo].[uspAPUpdatePaymentTotal]
	@paymentIds AS Id READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- --UPDATE PAYMENT DETAIL
-- UPDATE A
-- 	SET A.dblTotal = 
-- FROM tblAPPaymentDetail A
-- INNER JOIN @paymentIds B ON A.intPaymentId = B.intId
-- INNER JOIN tblAPPayment C ON A.intPaymentId = C.intPaymentId
-- WHERE C.ysnPosted = 0

