CREATE TABLE [dbo].[tblSMComboBoxValue] (
    [intComboBoxValueId]		INT            IDENTITY (1, 1) NOT NULL,
    [intCustomTabDetailId]		INT            NULL,
	[intGridColumnId]			INT            NULL,
	[intDocumentTypeFieldId]	INT            NULL,
    [strValue]					NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intSort]					INT            NOT NULL,
    [intConcurrencyId]			INT            NOT NULL,
    CONSTRAINT [PK_tblSMComboBoxValue] PRIMARY KEY CLUSTERED ([intComboBoxValueId] ASC),
    CONSTRAINT [FK_tblSMComboBoxValue_tblSMCustomTabDetail] FOREIGN KEY ([intCustomTabDetailId]) REFERENCES [dbo].[tblSMCustomTabDetail] ([intCustomTabDetailId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMComboBoxValue_tblSMGridColumn] FOREIGN KEY ([intGridColumnId]) REFERENCES [dbo].[tblSMGridColumn] ([intGridColumnId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMComboBoxValue_tblSMDocumentTypeField] FOREIGN KEY ([intDocumentTypeFieldId]) REFERENCES [dbo].[tblSMDocumentTypeField] ([intDocumentTypeFieldId]) ON DELETE CASCADE
);