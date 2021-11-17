GO
IF object_id('tblGLAccountImportDataStaging2') IS NOT NULL   
    DROP TABLE dbo.tblGLAccountImportDataStaging2  
GO

/* BEGIN 21.2  */
--GL-8520 Make Fiscal Period unique
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


IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLDataFixLog WHERE strDescription= 'Update fiscal period name')
BEGIN
    IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLFiscalYearPeriod]') AND type in (N'U')) 
    BEGIN
        UPDATE tblGLFiscalYearPeriod SET strPeriod = DATENAME(MONTH, dtmStartDate) + ' ' + DATENAME(YEAR, dtmStartDate)
        INSERT INTO tblGLDataFixLog(dtmDate, strDescription) VALUES(GETDATE(), 'Update fiscal period name')
    END
END
GO
/* END 21.2  */
