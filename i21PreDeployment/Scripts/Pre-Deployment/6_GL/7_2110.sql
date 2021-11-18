GO
IF object_id('tblGLAccountImportDataStaging2') IS NOT NULL   
    DROP TABLE dbo.tblGLAccountImportDataStaging2  
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDataFixLog]') AND type in (N'U')) 
    CREATE TABLE [dbo].[tblGLDataFixLog](
	[intLogId] [int] IDENTITY(1,1) NOT NULL,
	[dtmDate] [datetime] NULL,
	[strDescription] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblGLDataFixLog] PRIMARY KEY CLUSTERED 
    (
        [intLogId] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    GO

/* add data fixes before the constraint is applied*/
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLDataFixLog WHERE strDescription= 'Update fiscal period name.')
BEGIN
    UPDATE tblGLFiscalYearPeriod SET strPeriod = DATENAME(MONTH, dtmStartDate) + ' ' + DATENAME(YEAR, dtmStartDate)
    INSERT INTO tblGLDataFixLog(dtmDate, strDescription) VALUES(GETDATE(), 'Update fiscal period name.')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLDataFixLog WHERE strDescription= 'Remove orphaned fiscal period.')
BEGIN
	DELETE FROM tblGLFiscalYearPeriod WHERE intFiscalYearId NOT IN(SELECT intFiscalYearId FROM tblGLFiscalYear)
	INSERT INTO tblGLDataFixLog(dtmDate, strDescription) VALUES(GETDATE(), 'Remove orphaned fiscal period.')
END
