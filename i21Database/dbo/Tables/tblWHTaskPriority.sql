CREATE TABLE [dbo].[tblWHTaskPriority]
(
	[intTaskPriorityId] INT NOT NULL PRIMARY KEY, 
	[intConcurrencyId] INT NOT NULL,
    [strIternalCode] NVARCHAR(32) NOT NULL, 
    [strTaskPriority] NVARCHAR(32) NULL, 
    [ysnIsDefault] BIT NULL DEFAULT 0, 
    [ysnLocked] BIT NULL DEFAULT 1,
	[intCreatedUserId] INT NULL,
	[dtmCreated] DATETIME NULL DEFAULT GetDate()
 )
