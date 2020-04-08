﻿CREATE TABLE [dbo].[tblSCTicketLVStaging]
(
	[intTicketLVStagingId] INT NOT NULL IDENTITY, 
	[strTicketNumber] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
	[intTicketType] INT NULL,
	[intTicketTypeId] INT NULL,
	[strTicketType] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	[strInOutFlag] NVARCHAR(5) COLLATE Latin1_General_CI_AS NULL,
	[dtmTicketDateTime] DATETIME NULL, 
	[strTicketStatus] NVARCHAR(5) COLLATE Latin1_General_CI_AS NULL DEFAULT(('O')), 
	[intEntityId] INT NULL,
	[intItemId] INT NULL,
	[intCommodityId] INT NULL,
	[intCompanyLocationId] INT NULL,
	[dblGrossWeight] DECIMAL(13, 3) NULL, 
	[dtmGrossDateTime] DATETIME NULL, 
	[dblTareWeight] DECIMAL(13, 3) NULL,
	[dtmTareDateTime] DATETIME NULL, 
	[dblGrossUnits] NUMERIC(38,20),
	[dblShrink] NUMERIC(38,20),
	[dblNetUnits] NUMERIC(38,20),
	[dblUnitPrice] NUMERIC(38,20),
	[dblUnitBasis] NUMERIC(38,20),
	[strTicketComment] NVARCHAR(80) COLLATE Latin1_General_CI_AS NULL,
	[intDiscountId] INT NULL,
	[intDiscountScheduleId] INT NULL,
	[dblFreightRate] NUMERIC(38, 20) NULL, 
	[intHaulerId] INT NULL,
	[dblTicketFees]	NUMERIC(38, 20) NULL, 
	[ysnFarmerPaysFreight] BIT NULL DEFAULT((0)), 
	[ysnCusVenPaysFees] BIT NULL DEFAULT((0)), 
	[intCurrencyId] INT NULL,
	[strCurrency] NVARCHAR (40)   COLLATE Latin1_General_CI_AS NULL,
	[strBinNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[intContractId] INT NULL,
	[strContractNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intContractSequence] INT NULL, 
	[intEntityScaleOperatorId] INT NULL, 
	[strScaleOperatorUser] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
	[strTruckName] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
	[strDriverName] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	[strCustomerReference] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
	[intAxleCount] INT NULL, 
	[ysnDriverOff] BIT NULL, 
	[ysnGrossManual] BIT NULL, 
	[ysnTareManual] BIT NULL, 
	[intStorageScheduleTypeId] INT NULL,
	[strDistributionOption] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL, 
	[strPitNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intTicketPoolId] INT NULL, 
	[intScaleSetupId] INT NULL, 
	[intSplitId] INT NULL,
	[strSplitNumber] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,    
	[strItemUOM] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
	[ysnSplitWeightTicket] BIT NULL DEFAULT((0)),
	[intOriginTicketId] INT  NULL,
	[intItemUOMIdFrom] INT NULL, 
	[intItemUOMIdTo] INT NULL,
	[strCostMethod] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,   
	[strDiscountComment] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	[strSourceType] NVARCHAR (15) COLLATE Latin1_General_CI_AS NULL,
	[dblConvertedUOMQty] NUMERIC(38, 20) NULL,
	[ysnProcessedData] BIT NULL DEFAULT((0)),
    [intConcurrencyId] INT NULL DEFAULT((1)),
	[intTicketId] INT NULL,
	[strItemNo] NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[strLocationNumber] NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[strDiscountId] NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[strData] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
	[strEntityName]  NVARCHAR (400) COLLATE Latin1_General_CI_AS NULL,
	[strLocationName] NVARCHAR (400) COLLATE Latin1_General_CI_AS NULL,	
	[strStorageLocation] NVARCHAR (400) COLLATE Latin1_General_CI_AS NULL,
	[strStorageSchedule] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strHaulerName] NVARCHAR (400) COLLATE Latin1_General_CI_AS NULL,
	[intDeliverySheetId] INT NULL,
	[strDeliverySheet] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[ysnImported] [bit] NULL,
	[intImportedById] [int] NULL,
	[dtmImported] [datetime] NULL,
	[intSession] [bigint] NULL,
	[strErrorMsg] [nvarchar](max)  COLLATE Latin1_General_CI_AS NULL, 
	[strScaleStationImport] NVARCHAR(5) COLLATE Latin1_General_CI_AS NULL, 
	[strLoadNumber] NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL, 
	CONSTRAINT [PK_tblSCTicketLVStaging_intTicketId] PRIMARY KEY ([intTicketLVStagingId]) 
)