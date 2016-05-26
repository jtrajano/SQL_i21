CREATE FUNCTION [dbo].[fnAPCreatePaymentDetail]
(
	@paymentId		INT,
	@voucherIds			Id READONLY
)
RETURNS @returntable TABLE
(
	[intPaymentId]      INT             NOT NULL,
    [intBillId]         INT             NOT NULL,
    [intAccountId]      INT             NOT NULL,
    [dblDiscount]       DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblAmountDue]      DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblPayment]        DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblInterest]       DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dblTotal]			DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblWithheld]		DECIMAL(18, 6) NOT NULL DEFAULT 0
)
AS
BEGIN

	DECLARE @intPaymentId INT = @paymentId;

	INSERT @returntable
	SELECT
		[intPaymentId]		=	@intPaymentId ,
		[intBillId]         =	A.intBillId,
		[intAccountId]      =	A.intAccountId,
		[dblDiscount]       =	A.dblDiscount,
		[dblAmountDue]      =	A.dblAmountDue,
		[dblPayment]        =	A.dblPayment,
		[dblInterest]       =	A.dblInterest,
		[dblTotal]			=	A.dblTotal,
		[dblWithheld]		=	A.dblWithheld
	FROM tblAPBill A
	INNER JOIN  voucherIds B ON A.intBillId = B.intId

	RETURN;
END
