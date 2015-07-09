CREATE TABLE [dbo].[tblARCustomerFailedImport]
(
	[intCustomerFailedImportId]			INT IDENTITY(1,1) NOT NULL,
	[strCustomerNumber]					NVARCHAR(100)  COLLATE Latin1_General_CI_AS  NOT NULL,
	[strReason]							NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS  NULL
	CONSTRAINT [PK_tblARCustomerFailedImport] PRIMARY KEY  CLUSTERED ([intCustomerFailedImportId] ASC)
)
