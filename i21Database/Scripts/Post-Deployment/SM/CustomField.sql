print('/*******************  BEGIN Creating Custom Field Tables *******************/')
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('cstEntity'))
BEGIN
	print('/*******************  BEGIN Creating Entity Custom Table *******************/')
	EXEC('
		CREATE TABLE [dbo].[cstEntity]
		(
			[intId] INT NOT NULL,
			CONSTRAINT [PK_cstEntity] PRIMARY KEY CLUSTERED ([intId] ASC),
			CONSTRAINT [FK_cstEntity_tblEMEntity] FOREIGN KEY ([intId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]) ON DELETE CASCADE
		);
	')
	print('/*******************  END Creating Entity Custom Table *******************/')
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('cstGLJournal'))
BEGIN
	print('/*******************  BEGIN Creating Journal Custom Table *******************/')
	EXEC('
		CREATE TABLE [dbo].[cstGLJournal] (
			[intId] INT NOT NULL,
			CONSTRAINT [PK_cstGLJournal] PRIMARY KEY CLUSTERED ([intId] ASC),
			CONSTRAINT [FK_cstGLJournal_cstGLJournal] FOREIGN KEY ([intId]) REFERENCES [dbo].[tblGLJournal] ([intJournalId]) ON DELETE CASCADE
		);
	')
	print('/*******************  END Creating Journal Custom Table *******************/')
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('cstGLAccount'))
BEGIN
	print('/*******************  BEGIN Creating Account Custom Table *******************/')
	EXEC('
		CREATE TABLE [dbo].[cstGLAccount] (
			[intId] INT NOT NULL,
			CONSTRAINT [PK_cstGLAccount] PRIMARY KEY CLUSTERED ([intId] ASC),
			CONSTRAINT [FK_cstGLAccount.tblGLAccount_intAccountId] FOREIGN KEY ([intId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]) ON DELETE CASCADE
		);
	')
	print('/*******************  END Creating Account Custom Table *******************/')
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('cstLGLoad'))
BEGIN
    print('/*******************  BEGIN Creating Load Custom Table *******************/')
    EXEC('
        CREATE TABLE [dbo].[cstLGLoad]
        (
            [intId] INT NOT NULL,
            CONSTRAINT [PK_cstLGLoad] PRIMARY KEY CLUSTERED ([intId] ASC),
            CONSTRAINT [FK_cstLGLoad_tblLGLoad] FOREIGN KEY ([intId]) REFERENCES [dbo].[tblLGLoad] ([intLoadId]) ON DELETE CASCADE
        );
    ')
    print('/*******************  END Creating Load Custom Table *******************/')
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('cstEntityContact'))
BEGIN
	print('/*******************  BEGIN Creating Entity Contact Custom Table *******************/')
	EXEC('
		CREATE TABLE [dbo].[cstEntityContact]
		(
			[intId] INT NOT NULL,
			CONSTRAINT [PK_cstEntityContact] PRIMARY KEY CLUSTERED ([intId] ASC),
			CONSTRAINT [FK_cstEntityContact_tblEMEntity] FOREIGN KEY ([intId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]) ON DELETE CASCADE
		);
	')
	print('/*******************  END Creating Entity Contact Custom Table *******************/')
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('cstMFWorkOrder'))
BEGIN
    print('/*******************  BEGIN Creating Work Order Custom Table *******************/')
    EXEC('
        CREATE TABLE [dbo].[cstMFWorkOrder]
        (
            [intId] INT NOT NULL,
            CONSTRAINT [PK_cstMFWorkOrder] PRIMARY KEY CLUSTERED ([intId] ASC),
            CONSTRAINT [FK_cstMFWorkOrder_tblMFWorkOrder] FOREIGN KEY ([intId]) REFERENCES [dbo].[tblMFWorkOrder] ([intWorkOrderId]) ON DELETE CASCADE
        );
    ')
    print('/*******************  END Creating Work Order Custom Table *******************/')
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('cstMFWorkOrderInputLot'))
BEGIN
    print('/*******************  BEGIN Creating Work Order Consume Custom Table *******************/')
    EXEC('
        CREATE TABLE [dbo].[cstMFWorkOrderInputLot]
        (
            [intId] INT NOT NULL,
            CONSTRAINT [PK_cstMFWorkOrderInputLot] PRIMARY KEY CLUSTERED ([intId] ASC),
            CONSTRAINT [FK_cstMFWorkOrderInputLot_tblMFWorkOrderInputLot] FOREIGN KEY ([intId]) REFERENCES [dbo].[tblMFWorkOrderInputLot] ([intWorkOrderInputLotId]) ON DELETE CASCADE
        );
    ')
    print('/*******************  END Creating Work Order Consume Custom Table *******************/')
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('cstICInventoryReceipt'))
BEGIN
    print('/*******************  BEGIN Creating Inventory Receipt Custom Table *******************/')
    EXEC('
        CREATE TABLE [dbo].[cstICInventoryReceipt]
        (
            [intId] INT NOT NULL,
            CONSTRAINT [PK_cstICInventoryReceipt] PRIMARY KEY CLUSTERED ([intId] ASC),
            CONSTRAINT [FK_cstICInventoryReceipt_tblICInventoryReceipt] FOREIGN KEY ([intId]) REFERENCES [dbo].[tblICInventoryReceipt] ([intInventoryReceiptId]) ON DELETE CASCADE
        );
    ')
    print('/*******************  END Creating Inventory Receipt Custom Table *******************/')
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('cstICItem'))
BEGIN
    print('/*******************  BEGIN Creating Item Custom Table *******************/')
    EXEC('
        CREATE TABLE [dbo].[cstICItem]
        (
            [intId] INT NOT NULL,
            CONSTRAINT [PK_cstICItem] PRIMARY KEY CLUSTERED ([intId] ASC),
            CONSTRAINT [FK_cstICItem_tblICItem] FOREIGN KEY ([intId]) REFERENCES [dbo].[tblICItem] ([intItemId]) ON DELETE CASCADE
        );
    ')
    print('/*******************  END Creating Item Custom Table *******************/')
END

GO
print('/*******************  END Creating Custom Field Tables *******************/')
