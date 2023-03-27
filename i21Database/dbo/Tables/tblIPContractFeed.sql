CREATE TABLE [dbo].[tblIPContractFeed] (
	intContractFeedId INT IDENTITY(1, 1) NOT NULL
	,intLoadId INT
	,intLoadDetailId INT
	,intContractHeaderId INT
	,intContractDetailId INT
	,intSampleId INT
	,intBatchId INT
	,intCompanyLocationId INT
	
	,strLoadNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strVendorAccountNum NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strContractNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,intContractSeq INT
	,strERPContractNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strERPPONumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strERPItemNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,dblQuantity NUMERIC(18, 6)
	,strQuantityUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblNetWeight NUMERIC(18, 6)
	,strNetWeightUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strPricingType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblCashPrice NUMERIC(18, 6)
	,strPriceUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strPriceCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dtmStartDate DATETIME
	,dtmEndDate DATETIME
	,dtmPlannedAvailabilityDate DATETIME
	,dtmUpdatedAvailabilityDate DATETIME
	,strPurchasingGroup NVARCHAR(150) COLLATE Latin1_General_CI_AS
	,strPackingDescription NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strVirtualPlant NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strLoadingPoint NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strDestinationPoint NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,dblLeadTime NUMERIC(18, 6)
	,strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strMarketZoneCode NVARCHAR(20) COLLATE Latin1_General_CI_AS
	,intDetailNumber INT
	
	,intEntityId INT
	,strRowState NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strFeedStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dtmFeedCreated DATETIME DEFAULT(GETDATE())
	,ysnMailSent BIT DEFAULT 0
	,intStatusId INT
	,intDocNo INT

	,CONSTRAINT [PK_tblIPContractFeed_intContractFeedId] PRIMARY KEY CLUSTERED (intContractFeedId ASC)
	)
GO

CREATE NONCLUSTERED INDEX [IX_tblIPContractFeed_intLoadDetailId] ON [dbo].[tblIPContractFeed] ([intLoadDetailId] ASC)
GO

CREATE NONCLUSTERED INDEX [IX_tblIPContractFeed_intContractDetailId] ON [dbo].[tblIPContractFeed] ([intContractDetailId] ASC)
GO
