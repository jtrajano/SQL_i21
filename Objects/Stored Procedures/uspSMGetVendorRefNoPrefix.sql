CREATE PROCEDURE [dbo].[uspSMGetVendorRefNoPrefix]
	@intLocationId INT = NULL 
	,@strVendorRefNo NVARCHAR(50) = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

SELECT @strVendorRefNo = dbo.[fnSMGetVendorRefNoPrefix](@intLocationId, @strVendorRefNo)

GO