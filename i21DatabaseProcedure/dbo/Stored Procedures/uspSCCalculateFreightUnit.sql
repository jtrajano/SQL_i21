CREATE PROCEDURE [dbo].[uspSCCalculateFreightUnit]
	@itemId AS INT
	, @itemUOMIdFrom AS INT
	, @itemUOMIdTo AS INT
	, @dblQty AS NUMERIC (38,20)
	, @result AS NUMERIC (38,20) OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
	 SET @result = dbo.fnCalculateQtyBetweenUOM (@itemUOMIdFrom , dbo.fnGetMatchingItemUOMId(@itemId, @itemUOMIdTo), @dblQty)
END 