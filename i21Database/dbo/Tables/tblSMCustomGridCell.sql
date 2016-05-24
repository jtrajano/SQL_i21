CREATE TABLE [dbo].[tblSMCustomGridCell]
(
	[intCustomGridCellId]       INT             PRIMARY KEY IDENTITY (1, 1) NOT NULL,
    [intCustomGridRowId]		INT             NOT NULL,
	[intCustomGridFieldId]		INT             NOT NULL,
	[strValue]					NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]			INT				NOT NULL DEFAULT (1),
	CONSTRAINT [FK_tblSMCustomGridCell_tblSMCustomGridRow] FOREIGN KEY ([intCustomGridRowId]) REFERENCES [tblSMCustomGridRow]([intCustomGridRowId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMCustomGridCell_tblSMCustomGridField] FOREIGN KEY ([intCustomGridFieldId]) REFERENCES [tblSMCustomGridField]([intCustomGridFieldId])
)
