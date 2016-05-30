CREATE TABLE [dbo].[tblSMCustomGridField]
(
	[intCustomGridFieldId]      INT             PRIMARY KEY IDENTITY (1, 1) NOT NULL,
	[intCustomGridTabId]		INT             NOT NULL,
    [strFieldName]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strDataType]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[ysnBuild]					BIT             NOT NULL DEFAULT 0,	
    [intSort]					INT             NOT NULL DEFAULT (1),
    [intConcurrencyId]			INT				NOT NULL DEFAULT (1),
	CONSTRAINT [FK_tblSMCustomGridField_tblSMCustomGridTab] FOREIGN KEY ([intCustomGridTabId]) REFERENCES [tblSMCustomGridTab]([intCustomGridTabId]) ON DELETE CASCADE
)
