﻿CREATE TABLE tblIPContractFeedLog (
	intContractFeedLogId INT identity(1, 1)
	,intContractHeaderId INT
	,intContractDetailId INT
	,strCustomerContract NVARCHAR(50) Collate Latin1_General_CI_AS
	,intShipperId INT
	,intDestinationCityId INT
	,intDestinationPortId INT
	,intNumberOfContainers INT
	,intCompanyLocationId INT
	,intHeaderBookId INT
	,CONSTRAINT [PK_tblIPContractFeedLog_intContractFeedLogId] PRIMARY KEY CLUSTERED (intContractFeedLogId ASC)
	)
