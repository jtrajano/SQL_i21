
-- See: https://www.sqlservercentral.com/articles/universal-product-codes-a-database-primer

CREATE FUNCTION [dbo].[fnUPCAtoUPCE](	
	@strUPCA AS NVARCHAR(50) 	
)
RETURNS NVARCHAR(50)
AS
BEGIN
	
	DECLARE @manuf_code NVARCHAR(5)
	DECLARE @product_code NVARCHAR(5)
	DECLARE @strUPCE NVARCHAR(8)

	-- Initial settings
	SET @strUPCA = LTRIM(RTRIM(ISNULL(@strUPCA,'')))
	SET @strUPCE = ''
	
	-- Calculate UPC-E
	IF ( 
		/*
			Required conditions for conversion: 
				length must be at least 12 
				,must start with 0 or 1
				,must have 0000 between positions 5 and 12
		*/
		 LEN(@strUPCA) >= 12
		 AND LEFT(@strUPCA,1) IN ('0','1')
		 AND SUBSTRING(@strUPCA,5,8) LIKE '00%'
		 AND ISNUMERIC(@strUPCA) = 1
	)
	BEGIN
		SET @manuf_code = SUBSTRING(@strUPCA,2,5)
		SET @product_code = SUBSTRING(@strUPCA,7,5)
		-- ----------------------------------------------------------------------------
		-- Note: iterations must be followed in order. If type 1 applies, use it over type 2 and so on.
		-- ----------------------------------------------------------------------------
		-- Type 1
		IF (
			RIGHT(@manuf_code,3) IN ('000','100','200') 
			AND CONVERT(INT,@product_code) BETWEEN 0 AND 999
		) 
		BEGIN
			SET @strUPCE = 
				LEFT(@strUPCA,1)
				+ LEFT(@manuf_code,2)
				+ RIGHT(@product_code,3)
				+ SUBSTRING(@manuf_code,3,1)
				+ RIGHT(@strUPCA,1)
		END
		
		-- Type 2
		ELSE IF (
			RIGHT(@manuf_code,2) = '00' 
			AND CONVERT(INT,@product_code) BETWEEN 0 AND 99
		)
		BEGIN
			SET @strUPCE = 
					LEFT(@strUPCA,1)
					+ LEFT(@manuf_code,3)
					+ RIGHT(@product_code,2)
					+ '3'
					+ RIGHT(@strUPCA,1)
		END
		
		-- Type 3
		ELSE IF (
			RIGHT(@manuf_code,1) = '0' 
			AND CONVERT(INT,@product_code) BETWEEN 0 AND 9
		)
		BEGIN
			SET @strUPCE = 
				LEFT(@strUPCA,1)
				+ LEFT(@manuf_code,4)
				+ RIGHT(@product_code,1)
				+ '4'
				+ RIGHT(@strUPCA,1)
		END

		-- Type 4
		ELSE IF (CONVERT(INT,@product_code) BETWEEN 5 AND 9)
		BEGIN
			SET @strUPCE = 
				LEFT(@strUPCA,1)
				+ LEFT(@manuf_code,5)
				+ RIGHT(@product_code,1)
				+ RIGHT(@strUPCA,1)
		END
	END 

	RETURN @strUPCE
END