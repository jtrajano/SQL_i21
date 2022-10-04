CREATE TABLE [dbo].[tblGRTransferSettlementsHeader]
(
	[intTransferSettlementHeaderId] INT IDENTITY(1,1)
	,[strTransferSettlementNumber] NVARCHAR(40)
	,[intEntityId] INT
	,[intCompanyLocationId] INT
	,[intItemId] INT	
	,[dtmDateTransferred] DATETIME
	,[ysnPosted] BIT
	,[intUserId] INT
	,[intConcurrencyId] INT DEFAULT(1)
	,CONSTRAINT [PK_tblGRTransferSettlementsHeader_intTransferSettlementId] PRIMARY KEY CLUSTERED ([intTransferSettlementHeaderId] ASC)
	,CONSTRAINT [FK_tblGRTransferSettlementsHeader_intEntityId_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId])
    ,CONSTRAINT [FK_tblGRTransferSettlementsHeader_intCompanyLocationId_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].tblSMCompanyLocation ([intCompanyLocationId])
	,CONSTRAINT [FK_tblGRTransferSettlementsHeader_intItemId_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [dbo].tblICItem ([intItemId])
	,CONSTRAINT [FK_tblGRTransferSettlementsHeader_intUserId_intUserId] FOREIGN KEY ([intUserId]) REFERENCES [dbo].tblSMUserSecurity ([intEntityId])
)

GO