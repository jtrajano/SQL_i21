/*
	Used to reverse the stocks from a posted transaction.
*/

CREATE PROCEDURE [dbo].[uspICItemCostingReversal]
	@intTransactionId INT,
	@intTransactionTypeId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


