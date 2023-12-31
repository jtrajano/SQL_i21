﻿CREATE TABLE [dbo].[tblWHOrderHeader]
(
	[intOrderHeaderId] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NOT NULL,
	[ysnCreatedByEDI] BIT NOT NULL DEFAULT 0,
	[intOrderStatusId] INT NOT NULL,
	[intOrderTypeId] INT NOT NULL,
	[intOrderDirectionId] INT NOT NULL,
	[strBOLNo] NVARCHAR(50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strCustOrderNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	[strReferenceNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	[intOwnerAddressId] INT NULL,
	[intStagingLocationId] INT NOT NULL,
	[strComment] NVARCHAR(2048) COLLATE Latin1_General_CI_AS  NULL,
	[dtmRAD] DATETIME NULL,
	[dtmShipDate] DATETIME NULL,
	[intFreightPaymentAddressId] INT NULL,
	[intFreightTermId] INT NULL,
	[dblFreightCharge] NUMERIC(18,6) NULL,
	[intChep] INT NULL,
	[intShipFromAddressId] INT NOT NULL,
	[intShipToAddressId] INT NOT NULL,
	[intPallets] INT NULL,
	[intTruckId] INT NULL,
	[strShipper] NVARCHAR(64) COLLATE Latin1_General_CI_AS  NULL,
	[strSpecialInstruction] NVARCHAR(2048) COLLATE Latin1_General_CI_AS  NULL,
	[intUpdateCounter] INT NOT NULL,
	[strProNo] NVARCHAR(32) COLLATE Latin1_General_CI_AS  NULL,
	[intContractContainerId] INT NULL,
	[intWorkOrderId] INT NULL,
	[intContractHeaderId] INT NULL,
	[ysnIsSimpleContract] BIT NULL,
	[intCreatedById] INT NULL,
	[dtmCreatedOn] DATETIME DEFAULT GETDATE() NOT NULL,
	[intLastUpdateById] INT NULL,
	[dtmLastUpdateOn] DATETIME DEFAULT GETDATE() NOT NULL,

	CONSTRAINT [PK_tblWHOrderHeader_intOrderHeaderId]  PRIMARY KEY ([intOrderHeaderId]),	
	CONSTRAINT [FK_tblWHOrderHeader_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [tblCTContractHeader]([intContractHeaderId]), 
	CONSTRAINT [FK_tblWHOrderHeader_tblMFWorkOrder_intWorkOrderId] FOREIGN KEY ([intWorkOrderId]) REFERENCES [tblMFWorkOrder]([intWorkOrderId]), 
	CONSTRAINT [FK_tblWHOrderHeader_tblWHOrderStatus_intOrderStatusId] FOREIGN KEY ([intOrderStatusId]) REFERENCES [tblWHOrderStatus]([intOrderStatusId]), 
	CONSTRAINT [FK_tblWHOrderHeader_tblWHOrderType_intOrderTypeId] FOREIGN KEY ([intOrderTypeId]) REFERENCES [tblWHOrderType]([intOrderTypeId]), 
	CONSTRAINT [FK_tblWHOrderHeader_tblWHTruck_intTruckId] FOREIGN KEY ([intTruckId]) REFERENCES [tblWHTruck]([intTruckId]), 
	CONSTRAINT [FK_tblWHOrderHeader_tblWHOrderTerms_intOrderTermsId] FOREIGN KEY ([intFreightTermId]) REFERENCES [tblWHOrderTerms]([intOrderTermsId]), 
	CONSTRAINT [FK_tblWHOrderHeader_tblWHOrderDirection_intOrderDirectionId] FOREIGN KEY ([intOrderDirectionId]) REFERENCES [tblWHOrderDirection]([intOrderDirectionId]), 
)
