
/*
	This stored procedure will process the moving average cost. 
*/

CREATE PROCEDURE [dbo].[uspICProcessMovingAverageCost]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@GLAccounts AS ItemGLAccount READONLY 
	,@dblQty AS NUMERIC(18,6)	
	,@dblCost AS NUMERIC(18,6)
	,@NegativeInventoryOption AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

