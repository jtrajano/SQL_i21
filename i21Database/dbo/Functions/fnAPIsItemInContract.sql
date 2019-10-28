CREATE FUNCTION [dbo].[fnAPIsItemInContract]
(
	@itemId INT,
	@contractDetailId INT
)
RETURNS BIT
AS
BEGIN
	DECLARE @exists BIT = 0;

	IF EXISTS(SELECT 1 FROM tblCTContractDetail A WHERE A.intItemId = @itemId AND A.intContractDetailId = @contractDetailId)
	BEGIN
		SET @exists = 1;
	END

	IF @exists = 0
	BEGIN
		IF EXISTS(SELECT 1 FROM tblCTContractCost A WHERE A.intContractDetailId = @contractDetailId AND A.intItemId = @itemId)
		BEGIN
			SET @exists = 1
		END
	END

	RETURN @exists;
END
