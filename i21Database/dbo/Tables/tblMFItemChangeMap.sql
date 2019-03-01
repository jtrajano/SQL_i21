CREATE TABLE tblMFItemChangeMap
(
	[intItemChangeId] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFItemChangeMap_intConcurrencyId] DEFAULT 0, 
	[intFromItemCategoryId] INT,
	[intToItemCategoryId] INT,

	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblMFItemChangeMap_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblMFItemChangeMap_dtmLastModified] DEFAULT GetDate()
)
