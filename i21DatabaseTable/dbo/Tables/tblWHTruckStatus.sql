CREATE TABLE [dbo].[tblWHTruckStatus]
(
	[intTruckStatusId] INT NOT NULL PRIMARY KEY, 
	[intConcurrencyId] INT NOT NULL,
    [strInternalCode] NVARCHAR(32) COLLATE Latin1_General_CI_AS NOT NULL,  
    [strTruckStatus] NVARCHAR(32) COLLATE Latin1_General_CI_AS NOT NULL, 
    [ysnIsDefault] BIT NULL DEFAULT 0, 
    [ysnLocked] BIT NULL DEFAULT 1, 
    [intCreatedUserId] INT NULL, 
    [dtmCreated] DATETIME NULL DEFAULT Getdate()
)
