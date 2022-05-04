CREATE TABLE tblARPostItemsForContracts (
	  [intInvoiceId]					INT NOT NULL
	, [intInvoiceDetailId]				INT NOT NULL
	, [intOriginalInvoiceId]			INT NULL
	, [intOriginalInvoiceDetailId]		INT NULL
	, [intItemId]						INT NULL
	, [intContractDetailId]				INT NULL
	, [intContractHeaderId]				INT NULL
	, [intEntityId]						INT NULL
	, [intUserId]						INT NULL
	, [dtmDate]							DATETIME NULL
	, [dblQuantity]						NUMERIC(18, 6) NOT NULL DEFAULT 0
    , [dblBalanceQty]					NUMERIC(18, 6) NOT NULL DEFAULT 0
	, [dblSheduledQty]					NUMERIC(18, 6) NOT NULL DEFAULT 0
    , [dblRemainingQty]					NUMERIC(18, 6) NOT NULL DEFAULT 0
	, [strType]							NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, [strTransactionType]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, [strInvoiceNumber]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, [strItemNo]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, [strBatchId]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, [ysnFromReturn]					BIT NULL DEFAULT 0
    , [strSessionId]                    NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL
);
GO
CREATE INDEX [idx_tblARPostItemsForContracts_strSessionId] ON [dbo].[tblARPostItemsForContracts] (strSessionId)
GO