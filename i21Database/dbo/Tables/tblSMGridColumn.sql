CREATE TABLE [dbo].[tblSMGridColumn]
(
	[intGridColumnId]			INT             PRIMARY KEY IDENTITY (1, 1) NOT NULL,
	[intCustomTabDetailId]		INT             NOT NULL,
    [strFieldName]				NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
	[strControlType]			NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
	[ysnBuild]					BIT             NOT NULL DEFAULT 0,	
    [intSort]					INT             NOT NULL DEFAULT (1),
    [intConcurrencyId]			INT				NOT NULL DEFAULT (1),
	CONSTRAINT [FK_tblSMGridColumn_tblSMCustomTabDetail] FOREIGN KEY ([intCustomTabDetailId]) REFERENCES [tblSMCustomTabDetail]([intCustomTabDetailId])
)
