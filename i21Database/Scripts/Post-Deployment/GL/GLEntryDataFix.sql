--=====================================================================================================================================
-- 	Normalize ysnSystem (default = false | 0)
---------------------------------------------------------------------------------------------------------------------------------------

GO	
	PRINT N'BEGIN Normalize ysnSystem'
GO

UPDATE tblGLAccount SET ysnSystem = 0 WHERE ysnSystem is NULL

GO	
	PRINT N'END Normalize ysnSystem'
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

UPDATE tblGLDetail SET strTransactionType = X.strJournalType,
						 intTransactionId = X.intJournalId
	FROM (SELECT strJournalType, intJournalId, strJournalId FROM tblGLJournal) X 
	WHERE X.strJournalId = tblGLDetail.strTransactionId AND (strTransactionType IS NULL OR intTransactionId IS NULL)
	
	
UPDATE A SET strDescription = B.strDescription
	FROM tblGLDetail A INNER JOIN tblGLJournal B
	ON A.strTransactionId = B.strJournalId
	AND A.strModuleName = 'General Ledger'
	AND (A.strDescription IS NULL OR A.strDescription = '')


--AP
IF EXISTS(
	SELECT TOP 1 1
	FROM tblGLDetail A
	INNER JOIN tblAPPayment B ON A.strTransactionId = B.strPaymentRecordNum
	INNER JOIN tblGLJournal C ON C.intJournalId = B.intPaymentId
	AND A.strCode = 'AP')
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


	UPDATE A set strDescription = 'Posted Payment - Interest' 
	FROM tblGLDetail A 
	INNER JOIN [dbo].tblAPPayment B ON A.strTransactionId = B.strPaymentRecordNum
	INNER JOIN tblAPPaymentDetail C ON B.intPaymentId = C.intPaymentId
	INNER JOIN tblAPVendor D ON B.intEntityVendorId = D.intEntityVendorId
	INNER JOIN tblAPPreference E ON A.intAccountId = E.intInterestAccountId
	INNER JOIN tblGLAccount F ON F.intAccountId = B.intAccountId
	INNER JOIN tblGLJournal G ON G.intJournalId = B.intPaymentId	
	AND A.strDescription = 'Posted Payment - Interest' 
	AND A.strCode = 'AP'
	WHERE 1 = (CASE WHEN C.dblAmountDue = ((C.dblPayment + C.dblDiscount) - C.dblInterest) THEN 1 ELSE 0 END)
		AND C.dblInterest <> 0 AND C.dblPayment > 0
		
	-- update bill
	UPDATE A SET strDescription = B.strReference
	FROM tblGLDetail A INNER JOIN 
	[dbo].tblAPBill B ON A.strTransactionId = B.strBillId
	INNER JOIN tblGLJournal C ON C.intJournalId = B.intBillId
	AND C.intJournalId = B.intBillId
	AND A.strDescription <> B.strReference
	
END	

--AR
IF EXISTS(
		SELECT TOP 1 1 FROM tblGLDetail A
		INNER JOIN tblARPayment B ON A.strTransactionId = B.strRecordNumber
		INNER JOIN tblGLJournal C ON B.intPaymentId = C.intJournalId)
BEGIN

	UPDATE A SET strDescription = GLAccnt.strDescription
	from tblGLDetail A
	INNER JOIN tblARPayment B ON A.strTransactionId = B.strRecordNumber 
	INNER JOIN tblGLAccount GLAccnt ON B.intAccountId = GLAccnt.intAccountId
	INNER JOIN tblARCustomer C ON B.[intEntityCustomerId] = C.[intEntityCustomerId]
	INNER JOIN tblSMPreferences D ON CONVERT(NVARCHAR(50), A.intAccountId) =  D.strValue AND D.strPreference IN ('DefaultARAccount' ,'DefaultARDiscountAccount')
	INNER JOIN tblGLJournal E ON E.intJournalId = B.intPaymentId
	WHERE A.strDescription <> GLAccnt.strDescription
		 
	-- select B.strNotes 
	UPDATE A SET strDescription = B.strNotes
	FROM tblGLDetail A
	INNER JOIN tblARPayment B ON A.strTransactionId = B.strRecordNumber AND A.strDescription <> B.strNotes
	INNER JOIN tblGLAccount GLAccnt ON B.intAccountId = GLAccnt.intAccountId
	INNER JOIN tblARCustomer C ON B.[intEntityCustomerId] = C.[intEntityCustomerId]
	INNER JOIN tblGLJournal E ON E.intJournalId = B.intPaymentId
	WHERE  CONVERT(NVARCHAR(50), A.intAccountId) NOT IN(SELECT strValue FROM tblSMPreferences WHERE strPreference IN( 'DefaultARAccount','DefaultARDiscountAccount'))
		 			
		--SELECT B.strComments
	UPDATE A SET strDescription = B.strComments
	FROM tblGLDetail A 
	INNER JOIN tblARInvoice B  ON A.strTransactionId = B.strInvoiceNumber AND A.strDescription <> B.strComments
	INNER JOIN tblGLJournal C ON C.intJournalId = B.intInvoiceId AND C.intJournalId =B.intInvoiceId
	
END

--CM
IF EXISTS(
	SELECT TOP 1 1
	FROM tblGLDetail B INNER JOIN
	tblGLAccount A ON A.intAccountId = B.intAccountId
	INNER JOIN tblGLJournal C ON C.intJournalId = B.intTransactionId
	WHERE B.strModuleName = 'Cash Management')
BEGIN
	UPDATE B SET strDescription = A.strDescription
	FROM tblGLDetail B INNER JOIN
	tblGLAccount A ON A.intAccountId = B.intAccountId
	INNER JOIN tblGLJournal C ON C.intJournalId = B.intTransactionId
	WHERE B.strModuleName = 'Cash Management'
END
PRINT N'END Normalize tblGLDetail Fields'

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

