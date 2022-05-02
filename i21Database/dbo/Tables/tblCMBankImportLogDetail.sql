CREATE TABLE [dbo].[tblCMBankImportLogDetail]
(
	[intImportLogId]		INT NULL,
	[intImportLogDetailId]	INT IDENTITY(1,1) NOT NULL,
	[strBankName]           NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
	[strRTN]                NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[intLineNo]				INT NULL,
	[strEvent]				NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblBankImportImportLogDetail] PRIMARY KEY CLUSTERED ([intImportLogDetailId] ASC)
 WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
