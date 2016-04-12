CREATE TABLE [dbo].[tblMBMeterReadingDetail]
(
	[intMeterReadingDetailId] INT NOT NULL , 
    [intMeterReadingId] INT NOT NULL, 
    [intItemId] INT NOT NULL, 
    [dblGrossPrice] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblNetPrice] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblCurrentReading] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblCurrentDollars] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblMBMeterReadingDetail] PRIMARY KEY ([intMeterReadingDetailId]), 
    CONSTRAINT [FK_tblMBMeterReadingDetail_tblMBMeterReading] FOREIGN KEY ([intMeterReadingId]) REFERENCES [tblMBMeterReading]([intMeterReadingId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblMBMeterReadingDetail_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)
