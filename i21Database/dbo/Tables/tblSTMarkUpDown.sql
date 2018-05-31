CREATE TABLE [dbo].[tblSTMarkUpDown]
(
	[intMarkUpDownId] INT NOT NULL IDENTITY, 
    [intStoreId] INT NOT NULL, 
    [dtmMarkUpDownDate] DATETIME NULL, 
    [intShiftNo] INT NULL, 
    [strType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strAdjustmentType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intCheckoutId] INT NULL, 
	[strMarkUpDownNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strBatchId] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NULL,
    CONSTRAINT [PK_tblSTMarkUpDown] PRIMARY KEY CLUSTERED ([intMarkUpDownId] ASC), 
	--CONSTRAINT [AK_tblSTMarkUpDown_strMarkUpDownNumber] UNIQUE ([strMarkUpDownNumber]),
	CONSTRAINT [AK_tblSTMarkUpDown_intStoreId_dtmMarkUpDownDate_intShiftNo] UNIQUE NONCLUSTERED ([intStoreId],[dtmMarkUpDownDate],[intShiftNo] ASC), 
    CONSTRAINT [FK_tblSTMarkUpDown_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]), 
	CONSTRAINT [FK_tblSTMarkUpDown_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]), 
)
