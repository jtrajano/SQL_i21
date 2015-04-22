CREATE PROCEDURE [dbo].[uspAPVoidPayment]
	@paymentId INT,
	@voidDate DATETIME
AS
BEGIN

	DECLARE @newPaymentId INT;
	DECLARE @description NVARCHAR(200) = 'Void transaction for ';

	--Duplicate payment
	SELECT
	*
	INTO #tmpPayment
	FROM tblAPPayment A
	WHERE A.intPaymentId = @paymentId

	ALTER TABLE #tmpPayment DROP COLUMN intPaymentId

	INSERT INTO tblAPPayment
	SELECT * FROM #tmpPayment

	--Get the generated primary key
	SET @newPaymentId = SCOPE_IDENTITY();

	SELECT
	*
	INTO #tmpPaymentDetail
	FROM tblAPPaymentDetail
	WHERE intPaymentId = @paymentId

	--Update foreign key
	ALTER TABLE #tmpPayment DROP COLUMN intPaymentDetailId
	UPDATE A
		SET A.intPaymentId = @newPaymentId
	FROM #tmpPayment A

	--update the new payment
	UPDATE A
		SET A.dtmDatePaid = @voidDate
		,A.strNotes = CASE WHEN ISNULL(A.strNotes,'') = '' THEN  @description + A.strPaymentRecordNum ELSE ' ' + @description + A.strPaymentRecordNum END
		,A.strPaymentRecordNum = A.strPaymentRecordNum + 'V'
	FROM tblAPPayment A
	WHERE A.intPaymentId = @newPaymentId



END