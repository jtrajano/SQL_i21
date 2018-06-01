--=====================================================================================================================================
-- 	Normalize ysnSystem (default = false | 0)
--  Default Cash Flow to 'NONE'
---------------------------------------------------------------------------------------------------------------------------------------

--=====================================================================================================================================
-- 	Normalize tblGLDetail Fields (strModuleName, strTransactionType, intTransactionId)
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN Normalize tblGLDetail Fields'
GO

	UPDATE tblGLDetail SET dblDebitForeign =  0 WHERE dblDebitForeign IS NULL
	UPDATE tblGLDetail SET dblCreditForeign =  0 WHERE dblCreditForeign IS NULL
	UPDATE tblGLDetail SET dblDebitReport =  0 WHERE dblDebitReport IS NULL
	UPDATE tblGLDetail SET dblCreditReport =  0 WHERE dblCreditReport IS NULL
	UPDATE tblGLDetail SET dblReportingRate =  0 WHERE dblReportingRate IS NULL

	--Applied on 17.1
	UPDATE G SET strComments = B.strComments 
	FROM tblGLDetail G 
	JOIN tblGLJournalDetail B 
	ON G.intJournalLineNo = B.intJournalDetailId
	JOIN tblGLJournal C 
	ON B.intJournalId = C.intJournalId 
	WHERE B.intJournalId = G.intTransactionId 
	AND C.strJournalId = G.strTransactionId 
	AND ISNULL(G.strComments,'') = ''

	UPDATE G SET strDocument = B.strDocument 
	FROM tblGLDetail G 
	JOIN tblGLJournalDetail B 
	ON G.intJournalLineNo = B.intJournalDetailId 
	JOIN tblGLJournal C
	ON B.intJournalId = C.intJournalId 
	WHERE B.intJournalId = G.intTransactionId 
	AND C.strJournalId = G.strTransactionId 
	AND ISNULL(G.strDocument,'') = ''

	UPDATE A
	SET A.strComments = B.strReference
	FROM tblGLDetail A
	JOIN tblAPBill B ON A.intTransactionId = B.intBillId
	AND A.strTransactionId = B.strBillId
	AND ISNULL(A.strComments,'') = ''

	UPDATE A
	SET A.strDocument = B.strVendorOrderNumber
	FROM tblGLDetail A
	JOIN tblAPBill B ON A.intTransactionId = B.intBillId 
	AND A.strTransactionId = B.strBillId
	AND ISNULL(A.strDocument,'') = ''

	--FOR MULTICOMPANY
	DECLARE @intMultCompanyId INT
	SELECT TOP 1 @intMultCompanyId = C.intMultiCompanyId FROM 
	tblSMMultiCompany MC join tblSMCompanySetup C ON C.intMultiCompanyId = MC.intMultiCompanyId
	UPDATE tblGLDetail set intMultiCompanyId = @intMultCompanyId WHERE intMultiCompanyId IS NULL
	UPDATE tblGLJournal set intCompanyId = @intMultCompanyId WHERE intCompanyId IS NULL
	UPDATE tblGLJournalDetail set intCompanyId = @intMultCompanyId WHERE intCompanyId IS NULL
GO


PRINT 'Started Update tblGLAccountGroup strAccountType' --http://jira.irelyserver.com/browse/GL-6310
GO
UPDATE A SET A.strAccountType= B.strAccountType 
FROM tblGLAccountGroup A
JOIN tblGLAccountGroup B ON A.intParentGroupId =B.intAccountGroupId
WHERE (A.strAccountType is null OR LEN(RTRIM(A.strAccountType)) = 0) and (B.strAccountType IS NOT NULL 
AND LEN(RTRIM(B.strAccountType)) > 0)

GO
PRINT 'Finished Update tblGLAccountGroup strAccountType'
GO