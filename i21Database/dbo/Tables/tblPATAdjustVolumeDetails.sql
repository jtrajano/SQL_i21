CREATE TABLE [dbo].[tblPATAdjustVolumeDetails]
(
	[intAdjustmentDetailId] INT NOT NULL IDENTITY, 
    [intAdjustmentId] INT NULL,
	[intCustomerVolumeId] INT NULL,
	[intFiscalYearId] INT NULL,
    [intPatronageCategoryId] INT NULL, 
    [dblQuantityAvailable] NUMERIC(18, 6) NULL, 
    [dblQuantityAdjusted] NUMERIC(18, 6) NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATAdjustVolumeDetails] PRIMARY KEY ([intAdjustmentDetailId]), 
    CONSTRAINT [FK_tblPATAdjustVolumeDetails_tblPATAdjustVolume] FOREIGN KEY ([intAdjustmentId]) REFERENCES [tblPATAdjustVolume]([intAdjustmentId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblPATAdjustVolumeDetails_tblPATCustomerVolume] FOREIGN KEY ([intCustomerVolumeId]) REFERENCES [tblPATCustomerVolume]([intCustomerVolumeId])
)
