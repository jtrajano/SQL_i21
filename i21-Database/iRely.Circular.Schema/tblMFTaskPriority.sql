	CREATE TABLE [dbo].[tblMFTaskPriority] (
		 [intTaskPriorityId] INT NOT NULL PRIMARY KEY IDENTITY
		,[intConcurrencyId] INT NOT NULL
		,[strInternalCode] NVARCHAR(32) COLLATE Latin1_General_CI_AS NOT NULL
		,[strTaskPriority] NVARCHAR(32) COLLATE Latin1_General_CI_AS NULL
		,[ysnIsDefault] BIT NULL DEFAULT 0
		,[ysnLocked] BIT NULL DEFAULT 1
		,[intCreatedUserId] INT NULL
		,[dtmCreated] DATETIME NULL DEFAULT GetDate()
		)