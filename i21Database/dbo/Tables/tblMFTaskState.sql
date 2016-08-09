	CREATE TABLE [dbo].[tblMFTaskState] (
		 [intTaskStateId] INT NOT NULL PRIMARY KEY IDENTITY
		,[intConcurrencyId] INT NOT NULL
		,[strInternalCode] NVARCHAR(32) COLLATE Latin1_General_CI_AS NOT NULL
		,[strTaskState] NVARCHAR(32) COLLATE Latin1_General_CI_AS NULL
		,[intCreatedUserId] INT NULL
		,[dtmCreated] DATETIME NULL DEFAULT GetDate()
		)