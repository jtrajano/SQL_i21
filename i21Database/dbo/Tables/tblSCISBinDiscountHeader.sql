CREATE TABLE tblSCISBinDiscountHeader (
	intBinDiscountHeaderId int identity(1,1)
	,strHeader nvarchar(50) COLLATE Latin1_General_CI_AS 
	, intConcurrencyId int default(1) not null
	,CONSTRAINT [PK_tblSCISBinDiscountHeader] PRIMARY KEY CLUSTERED ([intBinDiscountHeaderId] ASC)	
	,constraint [UQ_BinDiscountHeader] unique nonclustered (strHeader)
)