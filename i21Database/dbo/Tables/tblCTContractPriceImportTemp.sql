CREATE TABLE [dbo].[tblCTContractPriceImportTemp]
(
	strContractNumber nvarchar(50) COLLATE Latin1_General_CI_AS
	,intContractSeq int
	,strCurrency nvarchar(50) COLLATE Latin1_General_CI_AS
	,strUOM nvarchar(50) COLLATE Latin1_General_CI_AS
	,dtmDate datetime
	,dblQuantity numeric(18,6)
	,dblFuturesPrice numeric(18,6)
)
