--This will default the new field date created of bill to bill date.
IF EXISTS(SELECT 1 FROM tblAPBill WHERE dtmDateCreated IS NULL)
BEGIN
	
	UPDATE A
		SET A.dtmDateCreated = A.dtmBillDate
	FROM tblAPBill A
	WHERE dtmDateCreated IS NULL

END

IF EXISTS(SELECT 1 FROM tblAPBillBatch WHERE dtmDateCreated IS NULL)
BEGIN
	
	UPDATE A
		SET A.dtmDateCreated = A.dtmBatchDate
	FROM tblAPBillBatch A
	WHERE dtmDateCreated IS NULL

END

IF EXISTS(SELECT 1 FROM tblAPPayment WHERE dtmDateCreated IS NULL)
BEGIN
	
	UPDATE A
		SET A.dtmDateCreated = A.dtmDatePaid
	FROM tblAPPayment A
	WHERE dtmDateCreated IS NULL

END

IF EXISTS(SELECT 1 FROM tblPOPurchase WHERE dtmDateCreated IS NULL)
BEGIN
	
	UPDATE A
		SET A.dtmDateCreated = A.dtmDate
	FROM tblPOPurchase A
	WHERE dtmDateCreated IS NULL

END