CREATE TABLE [dbo].[tblARCustomerFailedImport]
(
	[intCustomerFailedImportId]			INT IDENTITY(1,1) NOT NULL,
	[strCustomerNumber]					NVARCHAR(100) NOT NULL,
	[strReason]							NVARCHAR(MAX) NULL
	CONSTRAINT [PK_tblARCustomerFailedImport] PRIMARY KEY  CLUSTERED ([intCustomerFailedImportId] ASC)
)
