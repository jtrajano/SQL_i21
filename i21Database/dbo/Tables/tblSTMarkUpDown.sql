CREATE TABLE [dbo].[tblSTMarkUpDown]
(
	[intMarkUpDownId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intStoreId] INT NOT NULL, 
    [dtmMarkUpDownDate] DATETIME NULL, 
    [intShiftNo] INT NULL, 
    [strType] NVARCHAR(50) NULL, 
    [strAdjustmentType] NVARCHAR(50) NULL, 
    [intConcurrencyId] INT NULL,
	CONSTRAINT [AK_tblSTMarkUpDown_intStoreId_dtmMarkUpDownDate_intShiftNo] UNIQUE NONCLUSTERED ([intStoreId],[dtmMarkUpDownDate],[intShiftNo] ASC), 
    CONSTRAINT [FK_tblSTMarkUpDown_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]), 
	)
