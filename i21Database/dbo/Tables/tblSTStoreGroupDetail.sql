CREATE TABLE [dbo].[tblSTStoreGroupDetail]
(
	[intStoreGroupDetailId] INT NOT NULL IDENTITY, 
    [intStoreGroupId] INT NOT NULL, 
    [intStoreId] INT NOT NULL,
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_intStoreGroupDetailId] PRIMARY KEY CLUSTERED ([intStoreGroupDetailId] ASC),
    CONSTRAINT [AK_tblSTStoreGroupDetail_intStoreGroupId_intStoreId] UNIQUE NONCLUSTERED ([intStoreGroupId], intStoreId ASC),
	CONSTRAINT [FK_tblSTStoreGroupDetail_intStoreGroupId] FOREIGN KEY ([intStoreGroupId]) REFERENCES tblSTStoreGroup([intStoreGroupId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblSTStoreGroupDetail_intStoreId] FOREIGN KEY ([intStoreId]) REFERENCES tblSTStore([intStoreId]),
);
