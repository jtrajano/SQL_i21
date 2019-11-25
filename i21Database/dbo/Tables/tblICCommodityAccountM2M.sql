/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICCommodityAccountM2M]
	(
		[intCommodityAccountM2MId] INT NOT NULL IDENTITY, 
		[intCommodityId] INT NOT NULL, 
		[intAccountCategoryId] INT NOT NULL,
		[intAccountId] INT NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)),
		[dtmDateCreated] DATETIME NULL,
        [dtmDateModified] DATETIME NULL,
        [intCreatedByUserId] INT NULL,
        [intModifiedByUserId] INT NULL,
		CONSTRAINT [PK_tblICCommodityAccountM2M] PRIMARY KEY ([intCommodityAccountM2MId]), 
		CONSTRAINT [FK_tblICCommodityAccountM2M_tblICCommodity] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICCommodityAccountM2M_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId]), 
		CONSTRAINT [AK_tblICCommodityAccountM2M] UNIQUE ([intAccountCategoryId], [intCommodityId])
	)

	GO
	