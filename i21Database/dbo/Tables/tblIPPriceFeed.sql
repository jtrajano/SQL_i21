CREATE TABLE [dbo].[tblIPPriceFeed] (
	intPriceFeedId INT IDENTITY(1, 1) NOT NULL
	,intContractHeaderId INT
	,intContractDetailId INT
	,intSampleId INT
	,intCompanyLocationId INT
	
	,intReferenceNo INT
	,strPurchGroup NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strChannel NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strIncoTerms NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strOrigin NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strAuctionCenter NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strSupplier NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strPlant NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strStorageLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strLoadingPort NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strDestinationPort NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblCashPrice NUMERIC(18, 6)
	,strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblQuantity NUMERIC(18, 6)
	,strContainerType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strShippingLine NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dtmPricingDate DATETIME

	,intEntityId INT
	,strRowState NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strFeedStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dtmFeedCreated DATETIME DEFAULT(GETDATE())
	,ysnMailSent BIT DEFAULT 0
	,intStatusId INT
	,intDocNo INT

	,CONSTRAINT [PK_tblIPPriceFeed_intPriceFeedId] PRIMARY KEY CLUSTERED (intPriceFeedId ASC)
	)
GO

CREATE NONCLUSTERED INDEX [IX_tblIPPriceFeed_intSampleId] ON [dbo].[tblIPPriceFeed] ([intSampleId] ASC)
GO

CREATE NONCLUSTERED INDEX [IX_tblIPPriceFeed_intContractDetailId] ON [dbo].[tblIPPriceFeed] ([intContractDetailId] ASC)
GO
