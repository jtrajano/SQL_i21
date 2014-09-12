/*
	Used to validate the items when doing a post.
*/

CREATE PROCEDURE [dbo].[uspICItemCostingPostValidation]
	@ItemCosting ItemCostingTableType READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
