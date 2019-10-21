CREATE TABLE [dbo].[tblSTCheckoutChangeFund]
(
	[intCheckoutChangeFundId]	INT				NOT NULL						IDENTITY, 
	[intCheckoutId]				INT				NOT NULL, 
	[strDescription]			NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL, 
	[dblValue]					NUMERIC(18,6)	NULL, 
    [intConcurrencyId]			INT				NOT NULL,
	CONSTRAINT [PK_tblSTCheckoutChangeFund] PRIMARY KEY CLUSTERED ([intCheckoutChangeFundId]),
	CONSTRAINT [FK_tblSTCheckoutChangeFund_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE,
)
