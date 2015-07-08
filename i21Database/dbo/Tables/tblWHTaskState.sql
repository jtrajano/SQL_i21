CREATE TABLE [dbo].[tblWHTaskState]
(
	[intTaskStateId] INT NOT NULL PRIMARY KEY, 
	[intConcurrencyId] INT NOT NULL,
    [strIternalCode] NVARCHAR(32) COLLATE Latin1_General_CI_AS NOT NULL,
    [strTaskState] NVARCHAR(32) COLLATE Latin1_General_CI_AS NULL,
    [ysnIsDefault] BIT NULL DEFAULT 0, 
    [ysnLocked] BIT NULL DEFAULT 1,
	[intCreatedUserId] INT NULL,
	[dtmCreated] DATETIME NULL DEFAULT GetDate()
	)
