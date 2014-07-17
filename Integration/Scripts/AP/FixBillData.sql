GO

IF EXISTS(SELECT 1 FROM tblAPBill A
		INNER JOIN apivcmst B
			ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = B.apivc_ivc_no COLLATE Latin1_General_CI_AS
			AND A.ysnPaid = 0 AND apivc_status_ind = 'P')
BEGIN

	--Fix bill which is unpaid but already paid in origin
	UPDATE tblAPBill
	SET ysnPaid = 1
	FROM tblAPBill A
	INNER JOIN apivcmst B
	ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = B.apivc_ivc_no COLLATE Latin1_General_CI_AS
	AND A.ysnPaid = 0 AND apivc_status_ind = 'P'

	--Fix bill imported as Bill but it was a debit memo
	--Update strBillId
	DECLARE @tmpBillIds TABLE (intBillId INT, intTransactionType VARCHAR(1))

	INSERT INTO @tmpBillIds
	SELECT intBillId, apivc_trans_type
		FROM tblAPBill A
		INNER JOIN apivcmst B
			ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = B.apivc_ivc_no COLLATE Latin1_General_CI_AS
		WHERE LEFT(strBillId,3) <> 'BL-' OR apivc_trans_type = 'C'

	WHILE EXISTS(SELECT 1 FROM @tmpBillIds)
	BEGIN
		
		DECLARE @id INT
		DECLARE @type VARCHAR(1)
		DECLARE @billId NVARCHAR(50)

		SELECT TOP 1 @id = intBillId, @type = intTransactionType FROM @tmpBillIds
		
		IF(@type <> 'C')
		EXEC uspSMGetStartingNumber 9, @billId OUT
		ELSE
		EXEC uspSMGetStartingNumber 17, @billId OUT

		UPDATE tblAPBill
		SET strBillId = @billId,
		dblTotal = CASE WHEN @type = 'C' THEN dblTotal * -1 ELSE dblTotal END,
		dblAmountDue = CASE WHEN @type = 'C' THEN dblAmountDue * -1 ELSE dblAmountDue END
		WHERE intBillId = @id

		DELETE FROM @tmpBillIds
		WHERE intBillId = @id

	END

END

GO