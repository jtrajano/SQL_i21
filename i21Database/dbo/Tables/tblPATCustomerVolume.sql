CREATE TABLE [dbo].[tblPATCustomerVolume]
(
	[intCustomerVolumeId] INT NOT NULL IDENTITY, 
    [intCustomerPatronId] INT NULL, 
    [intPatronageCategoryId] INT NULL, 
    [intFiscalYear] INT NULL, 
    [dblVolume] NUMERIC(18, 6) NULL, 
	[dblVolumeProcessed] NUMERIC(18, 6) NULL DEFAULT(0),
	[ysnRefundProcessed] BIT NOT NULL DEFAULT 0, -- TODO: Remove in 19.1
	[intRefundCustomerId] INT NULL, -- TODO: Remove in 19.1
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATCustomerVolume] PRIMARY KEY ([intCustomerVolumeId]),
	CONSTRAINT [AK_tblPATCustomerVolume] UNIQUE ([intCustomerPatronId], [intPatronageCategoryId], [intFiscalYear])
)