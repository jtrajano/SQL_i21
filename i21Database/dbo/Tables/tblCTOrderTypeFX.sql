
CREATE TABLE [dbo].[tblCTOrderTypeFX](
	[intOrderTypeId] [int] NOT NULL,
	[strOrderType] [nvarchar](50) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblCTOrderTypeFX_intOrderTypeId] PRIMARY KEY (intOrderTypeId)
)

