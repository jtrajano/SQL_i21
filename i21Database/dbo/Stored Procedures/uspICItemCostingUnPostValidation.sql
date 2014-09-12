/*
	Used to validate the items when doing an unpost.
*/

CREATE PROCEDURE [dbo].[uspICItemCostingUnPostValidation]
	@intTransactionId INT,
	@intTransactionTypeId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
