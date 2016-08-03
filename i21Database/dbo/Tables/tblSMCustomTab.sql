CREATE TABLE [dbo].[tblSMCustomTab] (
    [intCustomTabId]			INT             PRIMARY KEY IDENTITY (1, 1) NOT NULL,
    [intScreenId]				INT             NOT NULL,
    [strDescription]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTabName]				NVARCHAR (50)	COLLATE Latin1_General_CI_AS NULL,
	[strLayout]					NVARCHAR (50)	COLLATE Latin1_General_CI_AS NULL,
    [ysnBuild]					BIT             NOT NULL DEFAULT 0,	
    [intConcurrencyId]			INT				NOT NULL DEFAULT (1),
	CONSTRAINT [FK_tblSMCustomTab_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [tblSMScreen]([intScreenId]),
	CONSTRAINT [UC_Screen_Tab] UNIQUE (intScreenId, strTabName)
);

