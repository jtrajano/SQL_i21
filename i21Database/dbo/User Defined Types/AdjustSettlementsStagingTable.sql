﻿CREATE TYPE [dbo].[AdjustSettlementsStagingTable] AS TABLE
(
	[intAdjustSettlementId] INT
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
	,[intBillId] INT NULL
	--FREIGHT
	,[dblFreightUnits] DECIMAL(38,20) NULL
	,[dblFreightRate] DECIMAL(18,6) NULL
	,[dblFreightSettlement] DECIMAL(18,6) NULL
	--CONTRACT
	,[intContractLocationId] INT NULL
	,[intContractDetailId] INT NULL
	,[intContractHeaderId] INT NULL
	,[dtmDateCreated] DATETIME
	,[intConcurrencyId] INT DEFAULT(1)
	,[intParentAdjustSettlementId] INT NULL
	,[intCreatedUserId] INT
)