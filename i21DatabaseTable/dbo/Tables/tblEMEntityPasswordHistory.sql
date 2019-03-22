CREATE TABLE [dbo].[tblEMEntityPasswordHistory]
(
	[intEntityPasswordHistoryId] INT IDENTITY (1, 1) NOT NULL,
	[intEntityId]                   INT NOT NULL,    
    [strPassword]                   NVARCHAR (500)   COLLATE Latin1_General_CI_AS  NULL,
	[dtmDateChange]					DATETIME DEFAULT(GETDATE()) NOT NULL,
    [intConcurrencyId]              INT CONSTRAINT [DF_tblEMEntityPasswordHistory_intConcurrencyId] DEFAULT ((0)) NOT NULL,

	CONSTRAINT [FK_tblEMEntityPasswordHistory_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId]) ON DELETE CASCADE,
    CONSTRAINT [PK_tblEMEntityPasswordHistory] PRIMARY KEY CLUSTERED ([intEntityPasswordHistoryId] ASC)
)
