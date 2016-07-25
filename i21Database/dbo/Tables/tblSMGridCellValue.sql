CREATE TABLE [dbo].[tblSMGridCellValue]
(
	[intGridCellValueId]		INT				PRIMARY KEY IDENTITY (1, 1) NOT NULL,
    [intRowId]					INT				NOT NULL,
	[intGridColumnId]			INT             NOT NULL,
	[strValue]					NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]			INT				NOT NULL DEFAULT (1),
	CONSTRAINT [FK_tblSMGridCell_tblSMRow] FOREIGN KEY ([intRowId]) REFERENCES [tblSMRow]([intRowId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMGridCell_tblSMGridColumn] FOREIGN KEY ([intGridColumnId]) REFERENCES [tblSMGridColumn]([intGridColumnId])
)
