CREATE FUNCTION [dbo].[fnAPInstructionCode]
(
	@instructionCode INT
)
RETURNS NVARCHAR(10)
AS
BEGIN
	DECLARE @strInstructionCode NVARCHAR(10);

	SELECT @strInstructionCode = CASE WHEN @instructionCode = 1 THEN 'URGP'
									  WHEN @instructionCode = 2 THEN 'CHQB'
									  WHEN @instructionCode = 3 THEN 'CMSW'
									  WHEN @instructionCode = 4 THEN 'CMTO'
									  WHEN @instructionCode = 5 THEN 'CMZB'
									  WHEN @instructionCode = 6 THEN 'CORT'
									  WHEN @instructionCode = 7 THEN 'EQUI'
									  WHEN @instructionCode = 8 THEN 'INTC'
									  WHEN @instructionCode = 9 THEN 'NETS'
									  WHEN @instructionCode = 10 THEN 'OTHR'
									  WHEN @instructionCode = 11 THEN 'PHON'
									  WHEN @instructionCode = 12 THEN 'REPA'
									  WHEN @instructionCode = 13 THEN 'RTGS'
									  ELSE NULL END

	RETURN @strInstructionCode
END