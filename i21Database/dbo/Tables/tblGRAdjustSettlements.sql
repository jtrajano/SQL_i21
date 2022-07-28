CREATE TABLE [dbo].[tblGRAdjustSettlements]
(
	[intAdjustSettlementId] INT NOT NULL IDENTITY(1,1)
	,[strAdjustSettlementNumber] NVARCHAR(40)
	,[intTypeId] INT --1. Purchase, 2. Sale
	,[intEntityId] INT NULL
	,[intCompanyLocationId] INT
	,[intItemId] INT
	,[intTicketId] INT NULL
	,[strTicketNumber] NVARCHAR(40) NULL
	,[intAdjustmentTypeId] INT
	,[intSplitId] INT NULL
	,[dtmAdjustmentDate] DATETIME
	,[dblAdjustmentAmount] DECIMAL(18,6) NULL
	,[dblWithholdAmount] DECIMAL(18,6) NULL
	,[dblTotalAdjustment] DECIMAL(18,6) NULL
	,[dblCkoffAdjustment] DECIMAL(18,6) NULL
	,[strRailReferenceNumber] NVARCHAR(40) NULL
	,[strCustomerReference] NVARCHAR(500) NULL
	,[strComments] NVARCHAR(500) NULL
	,[intGLAccountId] INT
	,[ysnTransferSettlement] BIT DEFAULT(0)
	,[intTransferEntityId] INT NULL
	,[strTransferComments] NVARCHAR(500) NULL
	,[ysnPosted] BIT DEFAULT(0)
	--FREIGHT
	,[dblFreightUnits] DECIMAL(38,20) NULL
	,[dblFreightRate] DECIMAL(18,6) NULL
	,[dblFreightSettlement] DECIMAL(18,6) NULL
	--CONTRACT
	,[intContractLocationId] INT NULL
	,[intContractDetailId] INT NULL
	,[dtmDateCreated] DATETIME DEFAULT(GETDATE())
	,[intConcurrencyId] INT DEFAULT(1)
	,[intParentAdjustSettlementId] INT NULL
	,[intCreatedUserId] INT
	,CONSTRAINT [PK_tblGRAdjustSettlements_intAdjustSettlementId] PRIMARY KEY ([intAdjustSettlementId])
	,CONSTRAINT [FK_tblGRAdjustSettlements_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId])
	,CONSTRAINT [FK_tblGRAdjustSettlements_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId])
	,CONSTRAINT [FK_tblGRAdjustSettlements_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
	,CONSTRAINT [FK_tblGRAdjustSettlements_intAdjustmentTypeId] FOREIGN KEY ([intAdjustmentTypeId]) REFERENCES [tblGRAdjustmentType]([intAdjustmentTypeId])
	,CONSTRAINT [FK_tblGRAdjustSettlements_intSplitId] FOREIGN KEY ([intSplitId]) REFERENCES [tblEMEntitySplit]([intSplitId])
	,CONSTRAINT [FK_tblGRAdjustSettlements_intCustomerGLAccountId] FOREIGN KEY ([intGLAccountId]) REFERENCES [tblGLAccount]([intAccountId])
	,CONSTRAINT [FK_tblGRAdjustSettlements_intTransferEntityId] FOREIGN KEY ([intTransferEntityId]) REFERENCES [tblEMEntity]([intEntityId])
	,CONSTRAINT [FK_tblGRAdjustSettlements_intContractLocationId] FOREIGN KEY ([intContractLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId])
	,CONSTRAINT [FK_tblGRAdjustSettlements_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId])
	,CONSTRAINT [FK_tblGRAdjustSettlements_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [tblSCTicket]([intTicketId])
)

GO

CREATE TRIGGER trg_tblGRAdjustSettlements
ON dbo.tblGRAdjustSettlements
INSTEAD OF DELETE 
AS
BEGIN
	DECLARE @adjRecord NVARCHAR(50);
	DECLARE @intAdjustSettlementId INT = 0;
	DECLARE @error NVARCHAR(500);
	SELECT @adjRecord = A.strAdjustSettlementNumber
		,@intAdjustSettlementId = A.intAdjustSettlementId
	FROM tblGRAdjustSettlements A
	INNER JOIN DELETED B
		ON B.intAdjustSettlementId = A.intParentAdjustSettlementId	

	IF @intAdjustSettlementId > 0
	BEGIN
		SET @error = 'Unable to delete record. ' + @adjRecord + ' is already posted.';
		RAISERROR(@error, 16, 1);
	END
	ELSE
	BEGIN
		--SELECT '@intAdjustSettlementId'=@intAdjustSettlementId
		DELETE A
		FROM tblGRAdjustSettlements A
		INNER JOIN DELETED B ON (B.intAdjustSettlementId = A.intParentAdjustSettlementId OR B.intAdjustSettlementId = A.intAdjustSettlementId)
		--SELECT * FROM DELETED
	END
END
GO