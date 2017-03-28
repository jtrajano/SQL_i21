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

IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'tblGLViewCache' AND type = 'U')
	DROP TABLE [dbo].[tblGLViewCache]
GO
	PRINT N'END Normalize tblGLDetail Fields'
GO
