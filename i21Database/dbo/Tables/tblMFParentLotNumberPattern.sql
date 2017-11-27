CREATE TABLE tblMFParentLotNumberPattern (
	intParentLotNumberPattern INT identity(1, 1) CONSTRAINT [PK_tblMFParentLotNumberPattern_intParentLotNumberPattern] PRIMARY KEY (intParentLotNumberPattern)
	,intInventoryReceiptItemId INT
	,strPatternString NVARCHAR(50) COLLATE Latin1_General_CI_AS
	)
