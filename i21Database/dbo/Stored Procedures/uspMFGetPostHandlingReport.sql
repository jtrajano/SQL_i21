CREATE PROCEDURE uspMFGetPostHandlingReport @intInventoryReceiptId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @FinalActualNetWeight NVARCHAR(500)
	DECLARE @TotalPieces NVARCHAR(500)
	DECLARE @TotalPallets NVARCHAR(500)
	DECLARE @NetWeightPerPiece NVARCHAR(500)
	DECLARE @Comments NVARCHAR(500)
	DECLARE @Table TABLE (
		intID INT identity(1, 1)
		,intRecordId INT
		,strControlName NVARCHAR(500)
		,strValue NVARCHAR(500)
		)

	INSERT INTO @Table
	SELECT T.intRecordId
		,TD.strControlName
		,FV.strValue
	FROM tblSMTabRow TR
	JOIN tblSMFieldValue FV ON TR.intTabRowId = FV.intTabRowId
	JOIN tblSMCustomTabDetail TD ON TD.intCustomTabDetailId = FV.intCustomTabDetailId
		AND LOWER(TD.strControlName) <> 'Id'
	JOIN tblSMTransaction T ON T.intTransactionId = TR.intTransactionId
	JOIN tblSMScreen S ON S.intScreenId = T.intScreenId
		AND S.strNamespace = 'Inventory.view.InventoryReceipt'
	WHERE intRecordId = @intInventoryReceiptId --25 

	SELECT @FinalActualNetWeight = strValue
	FROM @Table
	WHERE strControlName = 'Final Actual Net Weight'

	SELECT @TotalPieces = strValue
	FROM @Table
	WHERE strControlName = 'Total Pieces'

	SELECT @TotalPallets = strValue
	FROM @Table
	WHERE strControlName = 'Total Pallets'

	SELECT @NetWeightPerPiece = strValue
	FROM @Table
	WHERE strControlName = 'Net Weight Per Piece'

	SELECT @Comments = strValue
	FROM @Table
	WHERE strControlName = 'Comments'

	SELECT @FinalActualNetWeight 'Final Actual Net Weight'
		,@TotalPieces 'Total Pieces'
		,@TotalPallets 'Total Pallets'
		,@NetWeightPerPiece 'Net Weight Per Piece'
		,@Comments 'Comments'
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspMFGetPostHandlingReport - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
