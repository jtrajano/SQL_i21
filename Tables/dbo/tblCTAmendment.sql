CREATE TABLE [dbo].[tblCTAmendment]
(
	intAmendment int IDENTITY(1,1) NOT NULL,

	ysnEntity BIT,
	ysnTerm BIT,
	ysnHeaderQuantity BIT,
	ysnGrade BIT,
	ysnPosition BIT,
	ysnWeight BIT,
	ysnINCOTerm BIT,

	ysnStatus BIT,
	ysnStartDate BIT,
	ysnEndDate BIT,
	ysnItem BIT,
	ysnQuantity BIT,
	ysnQuantityUOM BIT,

	ysnMarket BIT,
	ysnMonth BIT,
	ysnFuture BIT,
	ysnBasis BIT,
	ysnCashPrice BIT,
	ysnCurrency BIT,
	ysnPriceUOM BIT,

	intConcurrencyId INT NOT NULL,
	CONSTRAINT [PK_tblCTAmendment_intAmendment] PRIMARY KEY CLUSTERED (intAmendment ASC)
)
