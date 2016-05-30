CREATE TABLE [dbo].[tblSMCustomGridTab] (
    [intCustomGridTabId]        INT             PRIMARY KEY IDENTITY (1, 1) NOT NULL,
	[intCustomGridId]			INT             NOT NULL,
    [strTabName]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intSort]					INT             NOT NULL,
    [intConcurrencyId]			INT				NOT NULL DEFAULT (1),
	CONSTRAINT [FK_tblSMCustomGridTab_tblSMCustomGrid] FOREIGN KEY ([intCustomGridId]) REFERENCES [tblSMCustomGrid]([intCustomGridId]) ON DELETE CASCADE
);
