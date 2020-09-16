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

--TO CORRECT THE IDENTITY SEQUENCE WHEN THE tblAPVoucherPayable HAS BEEN RESEED ONCE RECREATED
DECLARE @identitySequence INT = 1;
SELECT @identitySequence = MAX(intVoucherPayableId) FROM tblAPVoucherPayableTaxStaging
IF @identitySequence > (SELECT IDENT_CURRENT('tblAPVoucherPayable'))
BEGIN
	DBCC CHECKIDENT ('tblAPVoucherPayable', RESEED, @identitySequence)
END