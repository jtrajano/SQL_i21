CREATE TABLE [dbo].[tblSMFieldValue]
(
	[intFieldValueId]			INT				PRIMARY KEY IDENTITY (1, 1) NOT NULL,
    [intRowId]					INT				NOT NULL,
	[intCustomTabDetailId]		INT             NOT NULL,
	[strValue]					NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]			INT				NOT NULL DEFAULT (1),
	CONSTRAINT [FK_tblSMFieldValue_tblSMRow] FOREIGN KEY ([intRowId]) REFERENCES [tblSMRow]([intRowId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMFieldValue_tblSMScreenDesignerDetail] FOREIGN KEY ([intCustomTabDetailId]) REFERENCES [tblSMCustomTabDetail]([intCustomTabDetailId])
)


