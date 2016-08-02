CREATE TABLE [dbo].[tblMBMeterAccountDetail]
(
	[intMeterAccountDetailId] INT NOT NULL IDENTITY, 
    [intMeterAccountId] INT NOT NULL, 
    [strMeterKey] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intItemId] INT NOT NULL, 
    [strWorksheetSequence] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strMeterCustomerId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strMeterFuelingPoint] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strMeterProductNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dblLastMeterReading] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblLastTotalSalesDollar] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblMBMeterAccountDetail] PRIMARY KEY ([intMeterAccountDetailId]), 
    CONSTRAINT [FK_tblMBMeterAccountDetail_tblMBMeterAccount] FOREIGN KEY ([intMeterAccountId]) REFERENCES [tblMBMeterAccount]([intMeterAccountId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblMBMeterAccountDetail_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [AK_tblMBMeterAccountDetail] UNIQUE ([intMeterAccountId], [strMeterKey], [intItemId])
)
