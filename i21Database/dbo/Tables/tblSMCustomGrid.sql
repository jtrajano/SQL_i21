CREATE TABLE [dbo].[tblSMCustomGrid] (
    [intCustomGridId]           INT             PRIMARY KEY IDENTITY (1, 1) NOT NULL,
    [intScreenId]				INT             NOT NULL,
    [strDescription]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [ysnBuild]					BIT             NOT NULL DEFAULT 0,	
    [intConcurrencyId]			INT				NOT NULL DEFAULT (1),
	CONSTRAINT [FK_tblSMCustomGrid_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [tblSMScreen]([intScreenId])
);

