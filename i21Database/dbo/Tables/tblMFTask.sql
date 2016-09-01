	CREATE TABLE [dbo].[tblMFTask] (
		 [intTaskId] INT NOT NULL IDENTITY PRIMARY KEY
		,[intConcurrencyId] INT NOT NULL
		,[strTaskNo] NVARCHAR(64) COLLATE Latin1_General_CI_AS NULL
		,[intTaskTypeId] INT NOT NULL
		,[intTaskStateId] INT NOT NULL
		,[intOrderHeaderId] INT NULL
		,[intOrderDetailId] INT NULL
		,[intLoadId] INT NULL
		,[intLoadDetailId] INT NULL
		,[intAssigneeId] INT NULL
		,[intTaskPriorityId] INT NOT NULL
		,[dtmReleaseDate] DATETIME NULL
		,[intFromStorageLocationId] INT NULL
		,[intToStorageLocationId] INT NULL
		,[intItemId] INT NOT NULL
		,[intLotId] INT NOT NULL
		,[dblQty] NUMERIC(18, 6) NULL
		,[intItemUOMId] INT NULL
	    ,[dblWeight] NUMERIC(18, 6) NULL
		,[intWeightUOMId] INT NULL
	    ,[dblWeightPerQty] NUMERIC(18, 6) NULL
		,[dblPickQty] NUMERIC(18, 6) NULL
		,[strComment] NVARCHAR(2048) COLLATE Latin1_General_CI_AS NULL
		,[intCreatedUserId] INT NULL
		,[dtmCreated] DATETIME NULL DEFAULT GetDate()
		,[intLastModifiedUserId] INT NULL
		,[dtmLastModified] DATETIME NULL DEFAULT GetDate()
		
		,CONSTRAINT [FK_tblMFTask_tblMFTaskType_intTaskTypeId] FOREIGN KEY ([intTaskTypeId]) REFERENCES [tblMFTaskType]([intTaskTypeId])
		,CONSTRAINT [FK_tblMFTask_tblLGLoad_intLoadId] FOREIGN KEY ([intLoadId]) REFERENCES [tblLGLoad]([intLoadId])
		,CONSTRAINT [FK_tblMFTask_tblLGLoadDetail_intLoadDetailId] FOREIGN KEY ([intLoadDetailId]) REFERENCES [tblLGLoadDetail]([intLoadDetailId])
		,CONSTRAINT [FK_tblMFTask_tblMFOrderHeader_intOrderHeaderId] FOREIGN KEY ([intOrderHeaderId]) REFERENCES [tblMFOrderHeader]([intOrderHeaderId]) ON DELETE CASCADE
		,CONSTRAINT [FK_tblMFTask_tblMFOrderDetail_intOrderDetailId] FOREIGN KEY ([intOrderDetailId]) REFERENCES [tblMFOrderDetail]([intOrderDetailId]) 
		,CONSTRAINT [FK_tblMFTask_tblMFTaskPriority_intTaskPriorityId] FOREIGN KEY ([intTaskPriorityId]) REFERENCES [tblMFTaskPriority]([intTaskPriorityId])
		,CONSTRAINT [FK_tblMFTask_tblMFTaskState_intTaskStateId] FOREIGN KEY ([intTaskStateId]) REFERENCES [tblMFTaskState]([intTaskStateId])
		,CONSTRAINT [FK_tblMFTask_tblICLot_intLotId] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId])
		,CONSTRAINT [FK_tblMFTask_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
		)
