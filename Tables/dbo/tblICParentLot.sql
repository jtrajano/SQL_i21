CREATE TABLE [dbo].[tblICParentLot]
(
	[intParentLotId] INT NOT NULL IDENTITY(1,1), 
    [strParentLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strParentLotAlias] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intItemId] INT NOT NULL, 
    [dtmExpiryDate] DATETIME NULL, 
	[intLotStatusId] INT NOT NULL DEFAULT 1,
    [dtmDateCreated] DATETIME NULL, 
    [intCreatedUserId] INT NULL, 
	[intCreatedEntityId] INT NULL,
	[intCompanyId] INT NULL,
	[dtmDateModified] DATETIME NULL,
	[intCreatedByUserId] INT NULL,
	[intModifiedByUserId] INT NULL,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblICParentLot_intConcurrencyId] DEFAULT 0,
	CONSTRAINT [PK_tblICParentLot_intParentLotId] PRIMARY KEY ([intParentLotId]),
	CONSTRAINT [UQ_tblICParentLot_strParentLotId] UNIQUE ([strParentLotNumber]),
	CONSTRAINT [FK_tblICParentLot_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblICParentLot_tblICLotStatus_intLotStatusId] FOREIGN KEY ([intLotStatusId]) REFERENCES [tblICLotStatus]([intLotStatusId])
)
