--PURGE ALL PAYABLE COMPLETED FOR YEAR 2017 BELOW
IF EXISTS(SELECT 1 FROM tblAPVoucherPayableCompleted 
			WHERE YEAR(ISNULL(dtmDate,dtmDateEntered)) <= 2017) 
	AND OBJECT_ID(N'tblAPVoucherPayableCompleted2017') IS NULL
BEGIN
	SELECT
		*
	INTO tblAPVoucherPayableCompleted2017
	FROM tblAPVoucherPayableCompleted 
	WHERE YEAR(ISNULL(dtmDate,dtmDateEntered)) <= 2017

	DELETE A
	FROM tblAPVoucherPayableCompleted A
	WHERE YEAR(ISNULL(dtmDate,dtmDateEntered)) <= 2017

	SELECT * FROM tblAPVoucherPayableCompleted
END