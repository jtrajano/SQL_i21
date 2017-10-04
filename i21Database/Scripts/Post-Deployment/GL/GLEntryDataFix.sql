GO
	PRINT N'Begin Updating dblDebitForeign, dblCreditForeign'
GO
	UPDATE tblGLDetail SET dblDebitForeign =  0 WHERE dblDebitForeign IS NULL
	UPDATE tblGLDetail SET dblCreditForeign =  0 WHERE dblCreditForeign IS NULL
	UPDATE tblGLDetail SET dblDebitReport =  0 WHERE dblDebitReport IS NULL
	UPDATE tblGLDetail SET dblCreditReport =  0 WHERE dblCreditReport IS NULL
	UPDATE tblGLDetail SET dblReportingRate =  0 WHERE dblReportingRate IS NULL
GO
	PRINT N'Finished Updating dblDebitForeign, dblCreditForeign'
GO

	PRINT N'Start updating nmwly added columnt(strDocument, strComments) column in tblGLDetail table'
GO
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
GO
	PRINT N'Finished updating nmwly added columnt(strDocument, strComments) column in tblGLDetail table'
GO