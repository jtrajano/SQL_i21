CREATE TABLE [dbo].[tblSCTicketApply]
(
	[intTicketApplyId] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	[intEntityId] INT NOT NULL,	
	[intItemId] INT NOT NULL,			   
	[strHoldNo] NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
	
	[intTicketPoolId] INT NULL,
	[intCompanyLocationId] INT NULL,

	[ysnPosted] BIT NULL DEFAULT(0),
	[dtmPosted] DATETIME NULL,
	[intEntityUserId] INT NULL,

	intConcurrencyId INT NOT NULL DEFAULT(1)

		
	CONSTRAINT FK_TicketApply_Entity_EntityId
		FOREIGN KEY (intEntityId)
		REFERENCES dbo.tblEMEntity(intEntityId),

	CONSTRAINT FK_TicketApply_EntityUser_EntityId
		FOREIGN KEY (intEntityUserId)
		REFERENCES dbo.tblEMEntity(intEntityId),

	CONSTRAINT FK_TicketApply_Item_ItemId
		FOREIGN KEY (intItemId)
		REFERENCES dbo.tblICItem(intItemId),

	CONSTRAINT FK_TicketApply_TicketPool_TicketPoolId
		FOREIGN KEY (intTicketPoolId)
		REFERENCES dbo.tblSCTicketPool(intTicketPoolId),

	CONSTRAINT FK_TicketApply_CompanyLocation_CompanyLocationId
		FOREIGN KEY (intCompanyLocationId)
		REFERENCES dbo.tblSMCompanyLocation(intCompanyLocationId),
)
