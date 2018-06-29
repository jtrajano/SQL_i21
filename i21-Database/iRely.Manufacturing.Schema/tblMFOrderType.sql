	CREATE TABLE [dbo].[tblMFOrderType] (
		 [intOrderTypeId] INT NOT NULL IDENTITY
		,[intConcurrencyId] INT NOT NULL
		,[strInternalCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		,[strOrderType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		,[ysnDefault] BIT NULL
		,[ysnLocked] BIT NULL
		,[intOrderDirectionRef] INT
		,[intLastUpdateId] INT NOT NULL
		,[dtmLastUpdateOn] DATETIME NOT NULL
		
		,CONSTRAINT [PK_tblMFOrderType_intOrderTypeId] PRIMARY KEY ([intOrderTypeId])
		)