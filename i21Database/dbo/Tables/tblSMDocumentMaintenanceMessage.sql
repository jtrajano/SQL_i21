CREATE TABLE [dbo].[tblSMDocumentMaintenanceMessage]
(
	[intDocumentMaintenanceMessageId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intDocumentMaintenanceId] INT NOT NULL, 
	[strHeaderFooter]		NVARCHAR(25)  COLLATE Latin1_General_CI_AS NULL,
    [intCharacterLimit] INT NOT NULL, 
    [strMessage] NVARCHAR(MAX) NOT NULL, 
    [ysnRecipe] BIT NOT NULL DEFAULT 0,
	[ysnQuote] BIT NOT NULL DEFAULT 0,
	[ysnSalesOrder] BIT NOT NULL DEFAULT 0,
	[ysnPickList] BIT NOT NULL DEFAULT 0,
	[ysnBOL] BIT NOT NULL DEFAULT 0,
	[ysnInvoice] BIT NOT NULL DEFAULT 0,
	[ysnScaleTicket] BIT NOT NULL DEFAULT 0, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMDocumentMaintenanceMessage_tblSMDocumentMaintenance] FOREIGN KEY ([intDocumentMaintenanceId]) REFERENCES [tblSMDocumentMaintenance]([intDocumentMaintenanceId]) ON DELETE CASCADE
)
