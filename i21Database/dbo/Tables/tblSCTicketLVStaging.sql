﻿CREATE TABLE [dbo].[tblSCTicketLVStaging]
(
	[intTicketLVStagingId] INT NOT NULL IDENTITY, 
	[strTicketNumber] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
	[strTicketType] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	[strInOutFlag] NVARCHAR(5) COLLATE Latin1_General_CI_AS NULL,
	[dtmTicketDateTime] DATETIME NULL, 
	[strTicketStatus] NVARCHAR(5) COLLATE Latin1_General_CI_AS NULL, 
	[intEntityId] INT NULL,
	[strEntityNo] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[intItemId] INT NULL,
	[strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intCommodityId] INT NULL,
	[strCommodityCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strCommodityDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intCompanyLocationId] INT NULL,
	[strLocationNumber] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL,
	[dblGrossWeight] DECIMAL(13, 3) NULL, 
	[dtmGrossDateTime] DATETIME NULL, 
	[dblTareWeight] DECIMAL(13, 3) NULL,
	[dtmTareDateTime] DATETIME NULL, 
	[strTicketComment] NVARCHAR(80) COLLATE Latin1_General_CI_AS NULL,
	[intDiscountId] INT NULL,
	[strDiscountId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[dblFreightRate] NUMERIC(38, 20) NULL, 
	[intHaulerId] INT NULL,
	[strHaulerName] NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
	[dblTicketFees]	NUMERIC(38, 20) NULL, 
	[ysnFarmerPaysFreight] BIT NULL, 
	[intCurrencyId] INT NULL,
	[strCurrency] NVARCHAR (40)   COLLATE Latin1_General_CI_AS NULL,
	[strBinNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[intContractId] INT NULL,
	[strContractNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intContractSequence] INT NULL, 
	[strScaleOperatorUser] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
	[strTruckName] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
	[strDriverName] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	[strCustomerReference] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
	[intAxleCount] INT NULL, 
	[ysnDriverOff] BIT NULL, 
	[ysnGrossManual] BIT NULL, 
	[ysnTareManual] BIT NULL, 
	[intStorageScheduleTypeId] INT NULL,
	[strDistributionOption] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL, 
	[strPitNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intTicketPoolId] INT NULL, 
	[strTicketPool] NVARCHAR(5) COLLATE Latin1_General_CI_AS NULL, 
	[intScaleSetupId] INT NULL, 
	[intSplitId] INT NULL,
	[strStationShortDescription] NVARCHAR(5) COLLATE Latin1_General_CI_AS NULL, 
	[strSplitNumber] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,    
	[strItemUOM] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
	[ysnProcessedData] BIT NULL DEFAULT((0)),
	[ysnSplitWeightTicket] BIT NULL DEFAULT((0)),
	[intOriginTicketId] INT NOT NULL,
	[intItemUOMIdFrom] INT NULL, 
	[intItemUOMIdTo] INT NULL,
	[strCostMethod] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,   
	CONSTRAINT [PK_tblSCTicketLVStaging_intTicketId] PRIMARY KEY ([intTicketLVStagingId]) 
)