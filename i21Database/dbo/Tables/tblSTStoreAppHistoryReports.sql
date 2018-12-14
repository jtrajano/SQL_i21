CREATE TABLE [dbo].[tblSTStoreAppHistoryReports](
    [intStoreAppHistoryReportId] [int] IDENTITY(1,1) NOT NULL,    
	[strReportType] [nvarchar](50) NOT NULL, -- If Upload or Download
    [intStoreNo] [int] NULL,
    [strLocalFolderPath] [nvarchar](500) NULL,
    [strLocalFilename] [nvarchar](100) NULL,
    [strServerFolderPath] [nvarchar](500) NULL,
    [strServerFilename] [nvarchar](100) NULL,
    [strFilePrefix] [nvarchar](20) NULL,
    [dtmShiftCloseDate] [datetime] NULL,
    [dtmDateUploaded] [datetime] NULL,
    [ysnUploadSuccess] [bit] NOT NULL,
	[ysnDownloadSuccess] [bit] NOT NULL,
    [strRemark] [nvarchar](1000) NULL,
    [intConcurrencyId] [int] NOT NULL,
)
