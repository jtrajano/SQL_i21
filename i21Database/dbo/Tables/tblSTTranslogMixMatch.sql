CREATE TABLE [tblSTTranslogMixMatch]
(
    [intTranslogMixMatchId] INT IDENTITY (1, 1) NOT NULL,
	-- trHeader
    [intTermMsgSN] bigint NULL,
    [intScanTransactionId] INT NULL,
    [intStoreId] INT NULL,
	-- trlMatchLine
	[strTrlMatchLineTrlMatchName] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
    [dblTrlMatchLineTrlMatchQuantity] decimal(18, 3) NULL,
    [dblTrlMatchLineTrlMatchPrice] decimal(18, 3) NULL,
    [intTrlMatchLineTrlMatchMixes] int NULL,
    [dblTrlMatchLineTrlPromoAmount] decimal(18, 3) NULL,
    [strTrlMatchLineTrlPromotionID] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
    [strTrlMatchLineTrlPromotionIDPromoType] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intTrlMatchLineTrlMatchNumber] int NULL,
	[dtmDateAdded] DATETIME NULL,
	[intConcurrencyId] int NULL
)

CREATE NONCLUSTERED INDEX [IX_intTermMsgSN]
    ON [dbo].[tblSTTranslogMixMatch]([intTermMsgSN] ASC);


