	CREATE TABLE [dbo].[tblMFOrderDetail] (
		 [intOrderDetailId] INT NOT NULL IDENTITY
		,[intConcurrencyId] INT NOT NULL
		,[intOrderHeaderId] INT NOT NULL
		,[intItemId] INT NOT NULL
		,[dblQty] NUMERIC(18, 6) NOT NULL
		,[intItemUOMId] INT
		,[dblWeight] NUMERIC(18, 6)
		,[intWeightUOMId] INT
		,[dblWeightPerQty] NUMERIC(18, 6)
		,[dblRequiredQty] NUMERIC(18, 6)
		,[intLotId] INT
		,[strLotAlias] NVARCHAR(32) COLLATE Latin1_General_CI_AS NULL
		,[intUnitsPerLayer] INT
		,[intLayersPerPallet] INT
		,[intPreferenceId] INT
		,[intParentLotId] INT
		,[dtmProductionDate] DATETIME
		,[intLineNo] INT
		,[intSanitizationOrderDetailsId] INT
		,[strLineItemNote] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,intStagingLocationId int
		,[intCreatedById] INT NULL
		,[dtmCreatedOn] DATETIME DEFAULT GETDATE() NULL
		,[intLastUpdateById] INT NULL
		,[dtmLastUpdateOn] DATETIME DEFAULT GETDATE() NULL
		
		,CONSTRAINT [PK_tblMFOrderLineItem_intOrderLineItemId] PRIMARY KEY ([intOrderDetailId])
		,CONSTRAINT [FK_tblMFOrderLineItem_tblMFOrderHeader_intOrderHeaderId] FOREIGN KEY ([intOrderHeaderId]) REFERENCES [tblMFOrderHeader]([intOrderHeaderId]) ON DELETE CASCADE
		,CONSTRAINT [FK_tblMFOrderLineItem_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
		)