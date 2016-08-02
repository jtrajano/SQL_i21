CREATE TABLE [dbo].[tblSMCommentMaintenanceComment]
(
	[intCommentMaintenanceCommentId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intCommentMaintenanceId] INT NOT NULL, 
    [intCharacterLimit] INT NOT NULL, 
    [strComment] NVARCHAR(300) NOT NULL, 
    [ysnRecipe] BIT NOT NULL DEFAULT 0,
	[ysnQoute] BIT NOT NULL DEFAULT 0,
	[ysnSalesOrder] BIT NOT NULL DEFAULT 0,
	[ysnPickList] BIT NOT NULL DEFAULT 0,
	[ysnBOL] BIT NOT NULL DEFAULT 0,
	[ysnInvoice] BIT NOT NULL DEFAULT 0,
	[ysnScaleTicket] BIT NOT NULL DEFAULT 0, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMCommentMaintenanceComment_tblSMCommentMaintenance] FOREIGN KEY ([intCommentMaintenanceId]) REFERENCES [tblSMCommentMaintenance]([intCommentMaintenanceId]) ON DELETE CASCADE
)
