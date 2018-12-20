CREATE TABLE [dbo].[tblSTStoreAppHistoryReports](
    [intStoreAppHistoryReportId] [int] IDENTITY(1,1) NOT NULL,    
	[strReportType] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL, -- If Upload or Download
    [intStoreNo] [int] NULL,
    [strLocalFolderPath] [nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
    [strLocalFilename] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
    [strServerFolderPath] [nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
    [strServerFilename] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
    [strFilePrefix] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
    [dtmShiftCloseDate] [datetime] NULL,
    [dtmDateUploaded] [datetime] NULL,
    [ysnUploadSuccess] [bit] NOT NULL,
	[ysnDownloadSuccess] [bit] NOT NULL,
    [strRemark] [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] [int] NOT NULL,
)
