CREATE TABLE [dbo].[tblWHTaskType]
(
	[intTaskTypeId] INT NOT NULL PRIMARY KEY, 
	[intConcurrencyId] INT NOT NULL,
    [strIternalCode] NVARCHAR(32) NOT NULL, 
    [strTaskType] NVARCHAR(32) NULL, 
    [ysnIsDefault] BIT NULL DEFAULT 0, 
    [ysnLocked] BIT NULL DEFAULT 1,
	[intCreatedUserId] INT NULL,
	[dtmCreated] DATETIME NULL DEFAULT GetDate()
)
