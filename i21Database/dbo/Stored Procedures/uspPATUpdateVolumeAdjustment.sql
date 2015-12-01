CREATE PROCEDURE [dbo].[uspPATUpdateVolumeAdjustment] 
	@intCustomerId INT = NULL,
	@intAdjustmentId INT = NULL
AS
BEGIN
	
	IF(@intCustomerId IS NULL AND @intAdjustmentId IS NULL)
	BEGIN
		RETURN;
	END


	UPDATE tblPATCustomerVolume 
	   SET dblVolume = AVD.dblQuantityAvailable + AVD.dblQuantityAdjusted
	  FROM tblPATCustomerVolume CV
INNER JOIN tblPATAdjustVolume AV
		ON AV.intCustomerId = CV.intCustomerPatronId
INNER JOIN tblPATAdjustVolumeDetails AVD
		ON AVD.intAdjustmentId = AV.intAdjustmentId
	 WHERE AV.intCustomerId = @intCustomerId
	   AND AV.intAdjustmentId = @intAdjustmentId


END

GO