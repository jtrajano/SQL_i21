CREATE TABLE tblARPostItemsForStorageCosting (
	  [intId]                   		INT IDENTITY (1, 1) NOT NULL
	, [intItemId]						INT NOT NULL
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
	, [intSubLocationId]				INT NULL
	, [intStorageLocationId]			INT NULL
	, [ysnIsStorage]					BIT NULL DEFAULT 0
	, [strActualCostId]					NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , [intSourceTransactionId]			INT NULL
	, [strSourceTransactionId]			NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
	, [intInTransitSourceLocationId]	INT NULL
	, [intForexRateTypeId]				INT NULL
	, [dblForexRate]					NUMERIC(38, 20) NULL DEFAULT 1
	, [intStorageScheduleTypeId]		INT NULL
    , [dblUnitRetail]					NUMERIC(38, 20) NULL DEFAULT 0
	, [intCategoryId]					INT NULL 
	, [dblAdjustCostValue]				NUMERIC(38, 20) NULL DEFAULT 0
	, [dblAdjustRetailValue]			NUMERIC(38, 20) NULL DEFAULT 0
	, [strBOLNumber]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL 
	, [strSessionId]                    NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL
	, CONSTRAINT [PK_tblARPostItemsForStorageCosting_intId] PRIMARY KEY CLUSTERED ([intId] ASC)
);
GO
CREATE INDEX [idx_tblARPostItemsForStorageCosting_strSessionId] ON [dbo].[tblARPostItemsForStorageCosting] (strSessionId)
GO