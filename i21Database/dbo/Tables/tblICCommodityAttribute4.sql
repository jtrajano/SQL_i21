CREATE TABLE [dbo].[tblICCommodityAttribute4]
(
	[intCommodityAttributeId4] INT NOT NULL IDENTITY,
	[intCommodityId] INT NOT NULL , 
	[strAttribute4] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intConcurrencyId] INT NULL DEFAULT ((0)),
	[dtmDateCreated] DATETIME NULL,
    [dtmDateModified] DATETIME NULL,
    [intCreatedByUserId] INT NULL,
    [intModifiedByUserId] INT NULL, 
	CONSTRAINT [PK_tblICCommodityAttribute4] PRIMARY KEY ([intCommodityAttributeId4]), 
)
