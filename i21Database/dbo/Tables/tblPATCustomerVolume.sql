CREATE TABLE [dbo].[tblPATCustomerVolume]
(
	[intCustomerVolumeId] INT NOT NULL IDENTITY, 
    [intCustomerPatronId] INT NULL, 
    [intPatronageCategoryId] INT NULL, 
    [intFiscalYear] INT NULL, 
	[dtmLastActivityDate] DATETIME NULL,
    [dblVolume] NUMERIC(18, 6) NULL, 
	[ysnRefundProcessed] BIT NOT NULL DEFAULT 0,
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATCustomerVolume] PRIMARY KEY ([intCustomerVolumeId])
)