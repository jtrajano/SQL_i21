CREATE TYPE StagingTransactionLogMixMatch AS TABLE
(
	[intRowCount] INT NULL,
	-- trHeader
    [intTermMsgSN] bigint NULL,
    [intTransCount] int NULL,
	-- trlMatchLine
	[strTrlMatchLineTrlMatchName] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
    [dblTrlMatchLineTrlMatchQuantity] decimal(18, 3) NULL,
    [dblTrlMatchLineTrlMatchPrice] decimal(18, 3) NULL,
    [intTrlMatchLineTrlMatchMixes] int NULL,
    [dblTrlMatchLineTrlPromoAmount] decimal(18, 3) NULL,
    [strTrlMatchLineTrlPromotionID] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
    [strTrlMatchLineTrlPromotionIDPromoType] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intTrlMatchLineTrlMatchNumber] int NULL
)

