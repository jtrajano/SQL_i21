﻿CREATE PROCEDURE [dbo].[uspSCShipped]
	@ItemsFromInventoryShipment ShipmentItemTableType READONLY 
	,@intEntityUserSecurityId AS INT = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
