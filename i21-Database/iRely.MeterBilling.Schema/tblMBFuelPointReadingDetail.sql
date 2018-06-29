CREATE TABLE [dbo].[tblMBFuelPointReadingDetail]
(
	[intFuelPointReadingDetailId] INT NOT NULL IDENTITY, 
    [intFuelPointReadingId] INT NOT NULL, 
    [strFuelingPoint] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strProductNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblVolume] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblPrice] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblMBFuelPointReadingDetail] PRIMARY KEY ([intFuelPointReadingDetailId]), 
    CONSTRAINT [FK_tblMBFuelPointReadingDetail_tblMBFuelPointReading] FOREIGN KEY ([intFuelPointReadingId]) REFERENCES [tblMBFuelPointReading]([intFuelPointReadingId]) ON DELETE CASCADE
)
