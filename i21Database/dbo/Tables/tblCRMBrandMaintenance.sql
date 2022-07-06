CREATE TABLE [dbo].[tblCRMBrandMaintenance]
(
	[intBrandMaintenanceId]					INT IDENTITY(1,1)	NOT NULL,
	[strBrand]								NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int]				NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMBrandMaintenance] PRIMARY KEY CLUSTERED ([intBrandMaintenanceId] ASC),
	CONSTRAINT [UQ_tblCRMBrandMaintenance_strBrand] UNIQUE ([strBrand])
)

GO