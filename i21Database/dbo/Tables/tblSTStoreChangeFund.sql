CREATE TABLE [dbo].[tblSTStoreChangeFund]
(
	[intStoreChangeFundId]		INT				NOT NULL						IDENTITY, 
	[intStoreId]				INT				NOT NULL, 
	[strDescription]			NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL, 
	[dblValue]					NUMERIC(18,6)	NULL, 
    [intConcurrencyId]			INT				NOT NULL,
	CONSTRAINT [PK_tblSTStoreChangeFund] PRIMARY KEY CLUSTERED ([intStoreChangeFundId]),
	CONSTRAINT [FK_tblSTStoreChangeFund_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]) ON DELETE CASCADE,
)
