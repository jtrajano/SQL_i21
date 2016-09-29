CREATE PROCEDURE [dbo].[uspQMInspectionDeleteResult]
	@ReceiptId INT

AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

BEGIN
	-- Remove values from Quality Table for Incoming Inspection Result
	DELETE
	FROM tblQMTestResult
	WHERE intSampleId IS NULL
		AND intControlPointId = 3
		AND intProductTypeId = 3
		AND intProductValueId = @ReceiptId
END