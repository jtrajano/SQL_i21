


CREATE TABLE [dbo].[tblCTErrorImportLogs]
(
	[intErrorImportId] [int] IDENTITY(1,1) NOT NULL, 
	[guiUniqueId] [uniqueidentifier] NULL,
	strErrorMsg [nvarchar](200)  COLLATE Latin1_General_CI_AS NOT NULL,
	strContractNumber [nvarchar](200)  COLLATE Latin1_General_CI_AS NOT NULL,
	intContractSeq INT NOT NULL,
	strImportStatus [nvarchar](200)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL default(1), 
    CONSTRAINT [PK_tblCTErrorImportLogs_intOptionId] PRIMARY KEY ([intErrorImportId])
)
