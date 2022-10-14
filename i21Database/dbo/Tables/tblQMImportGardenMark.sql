CREATE TABLE [dbo].[tblQMImportGardenMark]
( 
	[intImportGardenMarkId]		INT NOT NULL  IDENTITY, 
	[intImportLogId]			INT			  NOT NULL,
    [intGardenMarkId]           INT           NULL,
    [strGardenMark]			    NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strOrigin]		            NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strCountry]		        NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strProducer]               NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strProductLine]            NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [dtmCertifiedDate] 			DATETIME NULL,
	[dtmExpiryDate] 			DATETIME NULL,
    [ysnSuccess]                BIT NULL,
    [strLogResult]              NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]		    INT NOT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblQMImportGardenMark_intImportGardenMarkId] PRIMARY KEY CLUSTERED ([intImportGardenMarkId] ASC),    
    CONSTRAINT [FK_tblQMImportGardenMark_tblQMImportLog] FOREIGN KEY ([intImportLogId]) REFERENCES [dbo].[tblQMImportLog]([intImportLogId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblQMImportGardenMark_tblQMGardenMark_intGardenMarkId] FOREIGN KEY ([intGardenMarkId]) REFERENCES [dbo].[tblQMGardenMark] ([intGardenMarkId])
);
GO
CREATE INDEX [idx_tblQMImportGardenMark_intImportLogId] ON [dbo].[tblQMImportGardenMark] (intImportLogId)
GO