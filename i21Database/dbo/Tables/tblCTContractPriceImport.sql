CREATE TABLE [dbo].[tblCTContractPriceImport]
(
	intContractPriceImportId int IDENTITY(1,1) NOT NULL
	,intPriceContractId int null
	,strContractNumber nvarchar(50) COLLATE Latin1_General_CI_AS
	,intContractSeq int null
	,strCurrency nvarchar(50) COLLATE Latin1_General_CI_AS
	,strUOM nvarchar(50) COLLATE Latin1_General_CI_AS
	,dtmDate datetime null
	,dblQuantity numeric(18,6)
	,dblFuturesPrice numeric(18,6)
	,dtmImported datetime NULL
	,ysnImported bit NULL
	,intImportedById int NULL
	,strErrorMsg nvarchar(max)  COLLATE Latin1_General_CI_AS NULL
	,guiUniqueId UNIQUEIDENTIFIER NULL
	,ysnIsProcessed BIT NULL
	,intImportFrom int not null default 1
)
