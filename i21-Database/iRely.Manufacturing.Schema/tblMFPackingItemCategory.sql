Create table tblMFPackingItemCategory
(
intId int identity(1,1) CONSTRAINT [PK_tblMFPackingItemCategory] PRIMARY KEY (intId),
strName nvarchar(50)COLLATE Latin1_General_CI_AS,
strValue nvarchar(50)COLLATE Latin1_General_CI_AS
)
