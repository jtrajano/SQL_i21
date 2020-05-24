CREATE TABLE [dbo].[tblIPThirdPartyContractFeed]					
(					
	intThirdPartyContractFeedId		INT NOT NULL Identity(1,1),		
	intContractFeedId		INT NOT NULL,		
	strERPPONumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,				
	strThirdPartyFeedStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS,				
	strThirdPartyMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,				
	ysnThirdPartyMailSent				BIT DEFAULT 0,
	dtmProcessedDate DateTime Constraint DF_tblIPThirdPartyContractFeed_dtmProcessedDate Default GetDATE(),				
	CONSTRAINT [PK_tblIPThirdPartyContractFeed_intThirdPartyContractFeedId] PRIMARY KEY CLUSTERED (intThirdPartyContractFeedId ASC)				
)					
