--=====================================================================================================================================
-- 	RENAME FIELD
---------------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournal]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dtmDateEntered' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dtmJournalDate' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal'))
    BEGIN
        EXEC sp_rename 'tblGLJournal.dtmJournalDate', 'dtmDateEntered' , 'COLUMN'
    END
END
GO