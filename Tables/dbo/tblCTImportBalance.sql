CREATE TABLE [dbo].[tblCTImportBalance]
(
	intImportBalanceId  INT IDENTITY(1,1),
    strContractNumber   NVARCHAR(100) COLLATE Latin1_General_CI_AS,
    intContractSeq	    INT,
    strERPPONumber	    NVARCHAR(100) COLLATE Latin1_General_CI_AS,
    strERPItemNumber    NVARCHAR(100) COLLATE Latin1_General_CI_AS,
    strUOM				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
    dblOpenQty		    NUMERIC(18,6),
    dblReceivedQty	    NUMERIC(18,6),
    intContractHeaderId INT,
    intContractDetailId INT,
    ysnImported			BIT,
    intImportedById	    INT,
    dtmImported			DATETIME,
    strErrorMsg			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
    intSession		    BIGINT
)
