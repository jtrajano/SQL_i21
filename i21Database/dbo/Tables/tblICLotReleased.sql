CREATE TABLE [dbo].[tblICLotReleased]
(
	[intLotReleasedId] INT NOT NULL IDENTITY 
    ,[intItemId] INT NOT NULL 
	,[intLocationId] INT NOT NULL 
    ,[intItemLocationId] INT NOT NULL 
    ,[intItemUOMId] INT NOT NULL
	,[intLotId] INT NULL
	,[intSubLocationId] INT NULL
	,[intStorageLocationId] INT NULL
    ,[dblQty] NUMERIC(38, 20) NOT NULL DEFAULT ((0))
	,[intParentLotId] INT NULL
    ,[intTransactionId] INT NULL
    ,[strTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    ,[intSort] INT NULL
	,[intInventoryTransactionType] INT NULL
    ,[intConcurrencyId] INT NULL DEFAULT ((0))
	,[ysnPosted] BIT NULL DEFAULT((0))
	,[intCompanyId] INT NULL
	,[dtmDate] DATETIME NULL
    ,[dtmDateCreated] DATETIME NULL
    ,[dtmDateModified] DATETIME NULL
    ,[intCreatedByUserId] INT NULL
    ,[intModifiedByUserId] INT NULL
    ,CONSTRAINT [PK_tblICLotReleased] PRIMARY KEY ([intLotReleasedId])
    ,CONSTRAINT [FK_tblICLotReleased_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
	,CONSTRAINT [FK_tblICLotReleased_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId])
    ,CONSTRAINT [FK_tblICLotReleased_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId])
    ,CONSTRAINT [FK_tblICLotReleased_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId])
)
GO 

CREATE NONCLUSTERED INDEX [IX_tblICLotReleased]
	ON [dbo].[tblICLotReleased]([intItemId] ASC, [intLocationId] ASC, [intLotId] ASC, [intSubLocationId] ASC, [intStorageLocationId] ASC)

GO