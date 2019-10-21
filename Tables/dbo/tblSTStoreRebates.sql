CREATE TABLE [dbo].[tblSTStoreRebates]
(
	[intStoreRebateId] INT NOT NULL IDENTITY,
    [intStoreId] INT NOT NULL, 
    [intCategoryId] INT NOT NULL, 
    [ysnTobacco] BIT NOT NULL DEFAULT ((0)),
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTStoreRebates] PRIMARY KEY CLUSTERED ([intStoreRebateId] ASC),
    CONSTRAINT [AK_tblSTStoreRebates_intStoreId_intCategoryId] UNIQUE NONCLUSTERED ([intStoreId],[intCategoryId] ASC), 
    CONSTRAINT [FK_tblSTStoreRebates_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSTStoreRebates_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]),
);