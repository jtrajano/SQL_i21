CREATE TABLE [dbo].[tblSMFieldValue]
(
	[intFieldValueId]			INT				PRIMARY KEY IDENTITY (1, 1) NOT NULL,
    [intTabRowId]				INT				NOT NULL,
	[intCustomTabDetailId]		INT             NOT NULL,
	[strValue]					NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]			INT				NOT NULL DEFAULT (1),
	CONSTRAINT [FK_tblSMFieldValue_tblSMTabRow] FOREIGN KEY ([intTabRowId]) REFERENCES [tblSMTabRow]([intTabRowId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMFieldValue_tblSMCustomTabDetail] FOREIGN KEY ([intCustomTabDetailId]) REFERENCES [tblSMCustomTabDetail]([intCustomTabDetailId])
)


