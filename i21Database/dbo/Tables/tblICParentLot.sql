CREATE TABLE [dbo].[tblICParentLot]
(
	[intParentLotId] INT NOT NULL IDENTITY(1,1), 
    [strParentLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strParentLotAlias] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intItemId] INT NOT NULL, 
    [intLocationId] INT NOT NULL, 
	[dblQty] NUMERIC(18, 6) NOT NULL, 
    [intItemUOMId] INT NOT NULL, 
    [dblWeight] NUMERIC(18, 6) NULL DEFAULT 0, 
    [intWeightUOMId] INT NULL,
	[dblWeightPerQty] NUMERIC(38,20) DEFAULT 1,
    [dtmExpiryDate] DATETIME NULL, 
	[intLotStatusId] INT NOT NULL DEFAULT 1,
    [dtmDateCreated] DATETIME NULL, 
    [intCreatedUserId] INT NULL, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblICParentLot_intConcurrencyId] DEFAULT 0,
	CONSTRAINT [PK_tblICParentLot_intParentLotId] PRIMARY KEY ([intParentLotId]),
	CONSTRAINT [UQ_tblICParentLot_strParentLotId] UNIQUE ([strParentLotNumber],[intLocationId]),
	CONSTRAINT [FK_tblICParentLot_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblICParentLot_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
	CONSTRAINT [FK_tblICParentLot_tblICItemUOM_intWeightUOMId] FOREIGN KEY ([intWeightUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
	CONSTRAINT [FK_tblICParentLot_tblSMCompanyLocation_intLocationId] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId])
)
