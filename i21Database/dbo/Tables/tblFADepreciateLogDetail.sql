CREATE TABLE tblFADepreciateLogDetail
(
    intLogId INT,
    intLogDetailId INT IDENTITY(1,1) NOT NULL,
    strTransactionId NVARCHAR(20) COLLATE Latin1_General_CI_AS  NULL,
    strAssetId NVARCHAR(20) COLLATE Latin1_General_CI_AS  NULL,
    strBook NVARCHAR(20) COLLATE Latin1_General_CI_AS  NULL,
    dtmDate DATETIME NULL,
    strResult NVARCHAR(200) COLLATE Latin1_General_CI_AS  NULL,
    ysnError BIT NULL,
    strLedgerName NVARCHAR(255) NULL,
    CONSTRAINT [PK_tblFADepreciateLogDetail] PRIMARY KEY CLUSTERED 
(
	[intLogDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
