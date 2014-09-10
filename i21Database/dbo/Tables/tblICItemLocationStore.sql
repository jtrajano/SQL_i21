CREATE TABLE [dbo].[tblICItemLocationStore]
(
	[intItemLocationStoreId] INT NOT NULL IDENTITY, 
    [intLocationId] INT NOT NULL, 
    [intStoreId] INT NOT NULL, 
    [intItemId] INT NOT NULL, 
    CONSTRAINT [PK_tblICItemLocationStore] PRIMARY KEY CLUSTERED ([intItemLocationStoreId]) 
)
