GO
	PRINT 'BEGIN FRD 1610'
GO

--IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intBudgetCode' AND OBJECT_ID = OBJECT_ID(N'tblFRBudget')) 
--BEGIN
--    DELETE tblFRBudget WHERE intBudgetCode NOT IN (SELECT intBudgetCode FROM tblGLBudgetCode)
--END
--GO

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intBudgetCode' AND OBJECT_ID = OBJECT_ID(N'tblFRColumnDesign')) 
BEGIN
    UPDATE tblFRColumnDesign SET intBudgetCode = NULL WHERE intBudgetCode NOT IN (SELECT intBudgetCode FROM tblFRBudgetCode) AND intBudgetCode IS NOT NULL
END
GO

GO
	PRINT 'END FRD 1610'
GO

