CREATE TABLE [dbo].[tblSCTicketApply]
(
	[intTicketApplyId] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	[intEntityId] INT NOT NULL,	
	[intItemId] INT NOT NULL,			   
	[strHoldNo] NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
	intConcurrencyId INT NOT NULL DEFAULT(1)

		
	CONSTRAINT FK_TicketApply_Entity_EntiyId
		FOREIGN KEY (intEntityId)
		REFERENCES dbo.tblEMEntity(intEntityId),

	CONSTRAINT FK_TicketApply_Item_ItemId
		FOREIGN KEY (intItemId)
		REFERENCES dbo.tblICItem(intItemId),

)
