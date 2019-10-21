CREATE TABLE [dbo].[tblQMListItem]
(
	[intListItemId] INT NOT NULL IDENTITY, 
	[intListId] INT NOT NULL,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMListItem_intConcurrencyId] DEFAULT 0, 
	[strListItemName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[ysnIsDefault] BIT NOT NULL CONSTRAINT [DF_tblQMListItem_ysnIsDefault] DEFAULT 0, 
	[ysnActive] BIT NOT NULL CONSTRAINT [DF_tblQMListItem_ysnActive] DEFAULT 0, 
	
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMListItem_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMListItem_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMListItem] PRIMARY KEY ([intListItemId]), 
	CONSTRAINT [AK_tblQMListItem_strListItemName_intListId] UNIQUE ([strListItemName],[intListId]), 
	CONSTRAINT [FK_tblQMListItem_tblQMList] FOREIGN KEY ([intListId]) REFERENCES [tblQMList]([intListId]) ON DELETE CASCADE
)
