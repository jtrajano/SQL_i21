CREATE TABLE [dbo].[tblSTRadiantItemTypeCode]
(
	[intRadiantItemTypeCodeId] INT NOT NULL IDENTITY, 
    [intRadiantItemTypeCode] INT NOT NULL, 
    [strDescription] NCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_tblSTRadiantItemTypeCode] PRIMARY KEY CLUSTERED ([intRadiantItemTypeCodeId] ASC),
	CONSTRAINT [AK_tblSTRadiantItemTypeCode_intRadiantItemTypeCode] UNIQUE NONCLUSTERED ([intRadiantItemTypeCode] ASC)
)
