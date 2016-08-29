	CREATE TABLE [dbo].[tblMFOrderHeader] (
		 [intOrderHeaderId] INT NOT NULL IDENTITY
		,[intConcurrencyId] INT NOT NULL
		,[intOrderStatusId] INT NOT NULL
		,[intOrderTypeId] INT NOT NULL
		,[intOrderDirectionId] INT NOT NULL
		,[strOrderNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
		,[strReferenceNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
		,[intStagingLocationId] INT NULL
		,[strComment] NVARCHAR(2048) COLLATE Latin1_General_CI_AS NULL
		,[dtmOrderDate] DATETIME NULL
		,[intCreatedById] INT NULL
		,[dtmCreatedOn] DATETIME DEFAULT GETDATE() NOT NULL
		,[intLastUpdateById] INT NULL
		,[dtmLastUpdateOn] DATETIME DEFAULT GETDATE() NOT NULL
		
		,CONSTRAINT [PK_tblMFOrderHeader_intOrderHeaderId] PRIMARY KEY ([intOrderHeaderId])
		,CONSTRAINT [FK_tblMFOrderHeader_tblMFOrderStatus_intOrderStatusId] FOREIGN KEY ([intOrderStatusId]) REFERENCES [tblMFOrderStatus]([intOrderStatusId])
		,CONSTRAINT [FK_tblMFOrderHeader_tblMFOrderType_intOrderTypeId] FOREIGN KEY ([intOrderTypeId]) REFERENCES [tblMFOrderType]([intOrderTypeId])
		,CONSTRAINT [FK_tblMFOrderHeader_tblMFOrderDirection_intOrderDirectionId] FOREIGN KEY ([intOrderDirectionId]) REFERENCES [tblMFOrderDirection]([intOrderDirectionId])
		)