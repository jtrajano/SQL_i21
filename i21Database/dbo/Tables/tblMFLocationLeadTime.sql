CREATE TABLE [dbo].[tblMFLocationLeadTime]
(
    [intLocationLeadTimeId]	INT IDENTITY (1, 1) NOT NULL,
    [intOriginId]	INT        NULL,
	[strOrigin] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NOT NULL,
	[intBuyingCenterId] INT     NOT NULL,
	[strBuyingCenter]  NVARCHAR(100)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intReceivingPlantId] INT     NOT NULL,
	[strReceivingPlant] NVARCHAR(100)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intReceivingStorageLocation] INT     NOT NULL,
	[strReceivingStorageLocation] NVARCHAR(100) COLLATE Latin1_General_CI_AS    NULL,
    [intChannelId]  INT     NOT NULL,
	[strChannel]  NVARCHAR(100)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intPortOfDispatchId] INT     NOT NULL,
	[strPortOfDispatch] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intPortOfArrivalId] INT     NOT NULL,
	[strPortOfArrival] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblPurchaseToShipment]  NUMERIC(18,6) NULL,
	[dblPortToPort]  NUMERIC(18,6) NULL,
	[dblPortToMixingUnit]  NUMERIC(18,6) NULL,
	[dblMUToAvailableForBlending]  NUMERIC(18,6) NULL,
	[intEntityId] INT  NULL,
	[dtmDateCreated] DATETIME NULL,
    [intConcurrencyId] INT CONSTRAINT [DF_tblMFLeadTime_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	[strShippingLine] [nvarchar](150) NULL,
	CONSTRAINT PK_tblMFLocationLeadTime 
	PRIMARY KEY (strOrigin, intBuyingCenterId, intReceivingPlantId, intReceivingStorageLocation, intChannelId , intPortOfDispatchId , intPortOfArrivalId)

)






