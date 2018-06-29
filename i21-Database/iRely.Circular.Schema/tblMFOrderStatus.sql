	CREATE TABLE [dbo].[tblMFOrderStatus] (
		 [intOrderStatusId] INT NOT NULL IDENTITY
		,[intConcurrencyId] INT NOT NULL
		,[strInternalCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		,[strOrderStatus] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		,[ysnDefault] BIT NULL
		,[ysnLocked] BIT NULL
		,[intLastUpdateId] INT NOT NULL
		,[dtmLastUpdateOn] DATETIME NOT NULL
		
		,CONSTRAINT [PK_tblMFOrderStatus_intOrderStatusId] PRIMARY KEY ([intOrderStatusId])
		)