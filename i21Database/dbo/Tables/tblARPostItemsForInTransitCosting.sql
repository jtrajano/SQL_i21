CREATE TABLE tblARPostItemsForInTransitCosting (
	  [intItemId]						INT NOT NULL
	, [intItemLocationId]				INT NULL
	, [intItemUOMId]					INT NOT NULL
	, [dtmDate]							DATETIME NOT NULL
    , [dblQty]							NUMERIC(38, 20) NOT NULL DEFAULT 0
	, [dblUOMQty]						NUMERIC(38, 20) NOT NULL DEFAULT 1
    , [dblCost]							NUMERIC(38, 20) NOT NULL DEFAULT 0
	, [dblValue]						NUMERIC(38, 20) NOT NULL DEFAULT 0
	, [dblSalesPrice]					NUMERIC(18, 6) NOT NULL DEFAULT 0
	, [intCurrencyId]					INT NULL
	, [dblExchangeRate]					NUMERIC (38, 20) DEFAULT 1 NOT NULL
    , [intTransactionId]				INT NOT NULL
	, [intTransactionDetailId]			INT NULL
	, [strTransactionId]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	, [intTransactionTypeId]			INT NOT NULL
	, [intLotId]						INT NULL
    , [intSourceTransactionId]			INT NULL
	, [strSourceTransactionId]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , [intSourceTransactionDetailId]	INT NULL
	, [intFobPointId]					TINYINT NULL
	, [intInTransitSourceLocationId]	INT NULL
	, [intForexRateTypeId]				INT NULL
	, [dblForexRate]					NUMERIC(38, 20) NULL DEFAULT 1
	, [intLinkedItem]					INT NULL
	, [intLinkedItemId]					INT NULL
	, [strBOLNumber]					NVARCHAR(100) NULL 
    , [intTicketId]                     INT NULL
    , [intSourceEntityId]				INT NULL
    , [strSessionId]                    NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL
);
GO
CREATE INDEX [idx_tblARPostItemsForInTransitCosting_strSessionId] ON [dbo].[tblARPostItemsForInTransitCosting] (strSessionId)
GO