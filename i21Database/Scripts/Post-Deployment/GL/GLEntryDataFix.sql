--=====================================================================================================================================
-- 	Normalize ysnSystem (default = false | 0)
--  Default Cash Flow to 'NONE'
---------------------------------------------------------------------------------------------------------------------------------------

GO	
	PRINT N'BEGIN Normalize ysnSystem and strCashFlow'
GO

UPDATE tblGLAccount SET ysnSystem = 0 WHERE ysnSystem is NULL
UPDATE tblGLAccount SET strCashFlow = 'None' WHERE  ISNULL(strCashFlow,'') NOT IN ('Finance','Investments','Operations','None')

GO	
	PRINT N'END Normalize ysnSystem and strCashFlow'
GO

--=====================================================================================================================================
-- 	Normalize strJournalType (rename Legacy to Origin)
---------------------------------------------------------------------------------------------------------------------------------------

GO	
	PRINT N'BEGIN Normalize strJournalType'
GO

UPDATE tblGLJournal SET strJournalType = 'Origin Journal' WHERE strJournalType = 'Legacy Journal'
UPDATE tblGLJournal SET strJournalType = 'Adjusted Origin Journal' WHERE strJournalType = 'Adjusted Legacy Journal'

GO	
	PRINT N'END Normalize strJournalType'
GO

--=====================================================================================================================================
-- 	Normalize tblGLDetail Fields (strModuleName, strTransactionType, intTransactionId)
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN Normalize tblGLDetail Fields'
GO

UPDATE tblGLDetail SET strModuleName = 'General Ledger' WHERE strTransactionForm = 'General Journal' AND strModuleName is NULL
UPDATE tblGLDetail SET strModuleName = 'General Ledger' WHERE strTransactionForm = 'Audit Adjustment' AND strModuleName is NULL

UPDATE detail SET strTransactionType = journal.strJournalType,intTransactionId = journal.intJournalId
	FROM tblGLDetail detail JOIN tblGLJournal journal ON detail.strTransactionId = journal.strJournalId
 	WHERE detail.strTransactionType IS NULL OR detail.intTransactionId IS NULL
	
UPDATE detail  SET strDescription = jdetail.strDescription
	FROM tblGLDetail detail JOIN  tblGLJournal journal on detail.strTransactionId = journal.strJournalId
	JOIN tblGLJournalDetail jdetail ON detail.intJournalLineNo = jdetail.intJournalDetailId AND jdetail.intJournalId = journal.intJournalId
	WHERE detail.strDescription IS NULL OR detail.strDescription = ''

--AP
DECLARE @DateRestricion DATETIME = '07-16-2015'
IF EXISTS(
	SELECT TOP 1 1
	FROM tblGLDetail A
	INNER JOIN tblAPPayment B ON A.strTransactionId = B.strPaymentRecordNum
	INNER JOIN tblGLJournal C ON C.intJournalId = B.intPaymentId
	AND A.strCode = 'AP'
	AND A.dtmDateEntered <= @DateRestricion
	)
BEGIN
	--update payment
	UPDATE A SET A.strDescription ='Posted Payment'
	from tblGLDetail A
	INNER JOIN [dbo].tblAPPayment B on A.strTransactionId = B.strPaymentRecordNum
	INNER JOIN tblAPVendor C ON B.intEntityVendorId = C.intEntityVendorId
	inner join tblAPPaymentDetail D ON B.intPaymentId = D.intPaymentId
	INNER JOIN  tblGLJournal E ON E.intJournalId = B.intPaymentId
	AND A.strCode = 'AP'
	AND A.strDescription <> 'Posted Payment'
	WHERE D.dblPayment <> 0 AND A.intAccountId NOT IN
	(
		SELECT intWithholdAccountId FROM tblAPPreference union
		select intDiscountAccountId FROM tblAPPreference UNION
		SELECT intInterestAccountId FROM tblAPPreference
	)
	AND A.dtmDateEntered <= @DateRestricion

	UPDATE 	A SET strDescription='Posted Payment - Withheld' FROM tblGLDetail A
	INNER JOIN  [dbo].tblAPPayment B
	ON A.strTransactionId = B.strPaymentRecordNum
	INNER JOIN [dbo].tblGLAccount GLAccnt ON B.intAccountId = GLAccnt.intAccountId
	INNER JOIN tblAPVendor C ON B.intEntityVendorId = B.intEntityVendorId AND C.ysnWithholding = 1
	INNER JOIN tblAPPreference D ON A.intAccountId = D.intWithholdAccountId
	INNER JOIN tblGLAccount E ON E.intAccountId = A.intAccountId
	INNER JOIN tblGLJournal F ON F.intJournalId =B.intPaymentId
	AND A.strDescription <> 'Posted Payment - Withheld'
	AND A.strCode = 'AP'
	AND A.dtmDateEntered <= @DateRestricion

	UPDATE A SET strDescription = 'Posted Payment - Discount'
	from tblGLDetail A
	INNER JOIN [dbo].tblAPPayment B ON A.strTransactionId = B.strPaymentRecordNum
	INNER JOIN tblAPPaymentDetail C	ON B.intPaymentId = C.intPaymentId
	INNER JOIN tblAPVendor D ON B.intEntityVendorId = D.intEntityVendorId
	INNER JOIN tblAPPreference E ON A.intAccountId = E.intDiscountAccountId
	INNER JOIN tblGLJournal F ON F.intJournalId = B.intPaymentId
	AND A.strDescription <> 'Posted Payment - Discount'
	AND A.strCode = 'AP'
	WHERE	1 = (CASE WHEN C.dblAmountDue = ((C.dblPayment + C.dblDiscount) - C.dblInterest) THEN 1 ELSE 0 END)
	AND C.dblDiscount <> 0 AND C.dblPayment > 0
	AND A.dtmDateEntered <= @DateRestricion


	UPDATE A set strDescription = 'Posted Payment - Interest'
	FROM tblGLDetail A
	INNER JOIN [dbo].tblAPPayment B ON A.strTransactionId = B.strPaymentRecordNum
	INNER JOIN tblAPPaymentDetail C ON B.intPaymentId = C.intPaymentId
	INNER JOIN tblAPVendor D ON B.intEntityVendorId = D.intEntityVendorId
	INNER JOIN tblAPPreference E ON A.intAccountId = E.intInterestAccountId
	INNER JOIN tblGLAccount F ON F.intAccountId = B.intAccountId
	INNER JOIN tblGLJournal G ON G.intJournalId = B.intPaymentId
	AND A.strDescription <> 'Posted Payment - Interest'
	AND A.strCode = 'AP'
	WHERE 1 = (CASE WHEN C.dblAmountDue = ((C.dblPayment + C.dblDiscount) - C.dblInterest) THEN 1 ELSE 0 END)
		AND C.dblInterest <> 0 AND C.dblPayment > 0
	AND A.dtmDateEntered <= @DateRestricion

	-- update bill
	UPDATE A SET strDescription = B.strReference
	FROM tblGLDetail A INNER JOIN
	[dbo].tblAPBill B ON A.strTransactionId = B.strBillId
	INNER JOIN tblGLJournal C ON C.intJournalId = B.intBillId
	AND A.strDescription <> B.strReference
	AND A.dtmDateEntered <= @DateRestricion

END

--AR
IF EXISTS(
		SELECT TOP 1 1 FROM tblGLDetail A
		INNER JOIN tblARPayment B ON A.strTransactionId = B.strRecordNumber
		INNER JOIN tblGLJournal C ON B.intPaymentId = C.intJournalId
		AND A.dtmDateEntered <= @DateRestricion
		)
BEGIN

	UPDATE A SET strDescription = GLAccnt.strDescription
	from tblGLDetail A
	INNER JOIN tblARPayment B ON A.strTransactionId = B.strRecordNumber
	INNER JOIN tblGLAccount GLAccnt ON B.intAccountId = GLAccnt.intAccountId
	INNER JOIN tblARCustomer C ON B.[intEntityCustomerId] = C.[intEntityCustomerId]
	INNER JOIN tblSMPreferences D ON CONVERT(NVARCHAR(50), A.intAccountId) =  D.strValue AND D.strPreference IN ('DefaultARAccount' ,'DefaultARDiscountAccount')
	INNER JOIN tblGLJournal E ON E.intJournalId = B.intPaymentId
	WHERE A.strDescription <> GLAccnt.strDescription
	AND A.dtmDateEntered <= @DateRestricion

	-- select B.strNotes
	UPDATE A SET strDescription = B.strNotes
	FROM tblGLDetail A
	INNER JOIN tblARPayment B ON A.strTransactionId = B.strRecordNumber AND A.strDescription <> B.strNotes
	INNER JOIN tblGLAccount GLAccnt ON B.intAccountId = GLAccnt.intAccountId
	INNER JOIN tblARCustomer C ON B.[intEntityCustomerId] = C.[intEntityCustomerId]
	INNER JOIN tblGLJournal E ON E.intJournalId = B.intPaymentId
	WHERE  CONVERT(NVARCHAR(50), A.intAccountId) NOT IN(SELECT strValue FROM tblSMPreferences WHERE strPreference IN( 'DefaultARAccount','DefaultARDiscountAccount'))
	AND A.dtmDateEntered <= @DateRestricion

		--SELECT B.strComments
	UPDATE A SET strDescription = B.strComments
	FROM tblGLDetail A
	INNER JOIN tblARInvoice B  ON A.strTransactionId = B.strInvoiceNumber AND A.strDescription <> B.strComments
	INNER JOIN tblGLJournal C ON C.intJournalId = B.intInvoiceId AND C.intJournalId =B.intInvoiceId
	AND A.dtmDateEntered <= @DateRestricion

END

--CM
IF EXISTS(
	SELECT TOP 1 1
	FROM tblGLDetail B INNER JOIN
	tblGLAccount A ON A.intAccountId = B.intAccountId
	INNER JOIN tblGLJournal C ON C.intJournalId = B.intTransactionId
	WHERE B.strModuleName = 'Cash Management'
	AND B.dtmDateEntered <= @DateRestricion
	)
BEGIN
	UPDATE B SET strDescription = A.strDescription
	FROM tblGLDetail B INNER JOIN
	tblGLAccount A ON A.intAccountId = B.intAccountId
	INNER JOIN tblGLJournal C ON C.intJournalId = B.intTransactionId
	WHERE B.strModuleName = 'Cash Management'
	AND B.dtmDateEntered <= @DateRestricion
END

GO
	PRINT N'END Normalize tblGLDetail Fields'
GO

--=====================================================================================================================================
-- 	Update Transaction Type to Recurring if strTransactionType is equal to Template  GL-1769
---------------------------------------------------------------------------------------------------------------------------------------

GO	
	PRINT N'BEGIN Update Transaction Type to Recurring if strTransactionType is equal to Template '
GO
  PRINT N'Begin Update tblGLDetail.strCode based on tblGLJournal.strSourceType'
GO
    UPDATE A
    SET A.strCode = RTRIM (B.strSourceType)
    FROM tblGLDetail A INNER JOIN tblGLJournal B ON A.strTransactionId = B.strJournalId
    WHERE A.strTransactionType IN( 'Origin Journal', 'Adjusted Origin Journal' )
    AND A.strCode <> B.strSourceType
GO
    PRINT N'End Update tblGLDetail.strCode based on tblGLJournal.strSourceType'
GO
	PRINT N'BEGIN Updating Transaction Type to Recurring if strTransactionType is equal to Template '
GO

	UPDATE tblGLJournal SET strTransactionType = 'Recurring' WHERE strTransactionType ='Template'

GO	
	PRINT N'END Updating Transaction Type to Recurring if strTransactionType is equal to Template '
GO

GO
	PRINT N'Begin updating fiscalyear/period id in tblGLJournal' -- USED BY General Journal Reversal
GO
	UPDATE j SET intFiscalPeriodId = f.intGLFiscalYearPeriodId, intFiscalYearId = f.intFiscalYearId
	FROM tblGLJournal j, tblGLFiscalYearPeriod f
	WHERE j.dtmDate >= f.dtmStartDate and j.dtmDate <= f.dtmEndDate
	AND j.ysnPosted = 1
GO
	PRINT N'End updating fiscalyear/period id in tblGLJournal'
GO
	PRINT N'Begin Updating tblGLDetail.strCode based on tblGLJournal.strSourceType'
GO
	UPDATE A
    SET A.strCode = RTRIM (B.strSourceType)
	FROM tblGLDetail A INNER JOIN tblGLJournal B ON A.strTransactionId = B.strJournalId
	WHERE A.strTransactionType IN( 'Origin Journal', 'Adjusted Origin Journal' )
	AND A.strCode <> B.strSourceType
GO
	PRINT N'End Updating tblGLDetail.strCode based on tblGLJournal.strSourceType'
GO

	


