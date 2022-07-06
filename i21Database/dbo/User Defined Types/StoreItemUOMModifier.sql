CREATE TYPE [dbo].[StoreItemUOMModifier] AS TABLE
(
	intItemId				INT	NULL
	, strUnitMeasure 		VARCHAR(250) COLLATE Latin1_General_CI_AS NULL 
	, intModifier			INT	NULL 
	, dblModifierQuantity	NUMERIC(38,20)	NULL
	, dblModifierPrice		NUMERIC(38,20)	NULL
)