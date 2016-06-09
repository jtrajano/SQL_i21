CREATE FUNCTION [dbo].[fnEMPhoneConvert]
(
	@Value		NVARCHAR(200),
	@CountryId	int
)
RETURNS @returntable TABLE(
	strCountry		NVARCHAR(50),
	strArea			NVARCHAR(50),
	strLocal		NVARCHAR(50),
	strExtension	NVARCHAR(50),
	strPhone		NVARCHAR(50)
)
AS
BEGIN
	DECLARE @RetVal			NVARCHAR(MAX)
	DECLARE @CurVal			NVARCHAR(1)
	DECLARE @IsDelim		BIT

	DECLARE @FormatCountry	NVARCHAR(200)
	DECLARE @FormatArea		NVARCHAR(200)
	DECLARE @FormatLocal	NVARCHAR(200)

	DECLARE @PassCountry	BIT
	DECLARE @PassArea		BIT
	DECLARE @PassLocal		BIT

	DECLARE @Country		NVARCHAR(200)
	DECLARE @Area			NVARCHAR(200)
	DECLARE @Local			NVARCHAR(200)
	DECLARE @Extension		NVARCHAR(200)

	select 
		@FormatArea			= strAreaCityFormat, 
		@FormatCountry		= strCountryFormat,
		@FormatLocal		= strLocalNumberFormat
	from tblSMCountry WHERE intCountryID = @CountryId


	DECLARE @Index	INT
	SET @Index			= 1
	SET @PassCountry	= 0
	SET @PassArea		= 0
	SET @PassLocal		= 0
	SET @RetVal			= ''
	SET @Country		= ''
	SET @Area			= ''
	SET @Local			= ''
	SET @Extension		= ''
	
	if @Value not like '+%'
	BEGIN
		SET @PassCountry = 1
	END

	
	WHILE @Index <= LEN(@Value)
	BEGIN
		SET @CurVal = SUBSTRING(@Value, @Index, 1)
		SET @IsDelim = [dbo].[fnEMIsPhoneDelimeter](@CurVal)

		IF @PassCountry = 0
		BEGIN
			IF @IsDelim = 0
			BEGIN
				IF [dbo].[fnEMIsCharNumber](@CurVal) = 1
				BEGIN
					SET @Country = @Country + @CurVal	
				END
				ELSE
				BEGIN
					IF @CurVal = '+' and @Country = ''
					BEGIN
						SET @Country = @CurVal
					END
				END
			END
			ELSE
			BEGIN
				SET @PassCountry = 1;
				
				IF @FormatCountry <> ''
				BEGIN
					SET @Country = [dbo].[fnEMPhoneFormat](@Country, @FormatCountry)
				END
				ELSE
				BEGIN
					SET @Country = @Country + ' '
				END
			END
		END




		IF @PassCountry = 1 and @PassArea = 0
		BEGIN
			IF @IsDelim = 0
			BEGIN
				IF [dbo].[fnEMIsCharNumber](@CurVal) = 1
				BEGIN
					SET @Area = @Area + @CurVal	
				END
			END
			ELSE
			BEGIN
				IF @Area = ''
				BEGIN
					GOTO ContinuePoint
				END
				SET @PassArea = 1;
				
				IF @FormatArea <> ''
				BEGIN
					SET @Area = [dbo].[fnEMPhoneFormat](@Area, @FormatArea)
				END
				ELSE
				BEGIN
					SET @Area = @Area + ' '
				END
			END
		END



		IF @PassCountry = 1 and @PassArea = 1 and @PassLocal = 0
		BEGIN
			IF @IsDelim = 0
			BEGIN
				IF [dbo].[fnEMIsCharNumber](@CurVal) = 1
				BEGIN
					SET @Local = @Local + @CurVal	
				END
			END
			ELSE
			BEGIN
				IF @CurVal = 'x' 
				BEGIN
					SET @PassLocal = 1
					Goto ContinuePoint
				END

			END
		END
        
		IF @PassCountry = 1 and @PassArea = 1 and @PassLocal = 1
		BEGIN
			IF @IsDelim = 0
			BEGIN
				IF [dbo].[fnEMIsCharNumber](@CurVal) = 1
				BEGIN
					SET @Extension = @Extension + @CurVal	
				END
			END			
		END
                
                



		--SET @RetVal = @RetVal + SUBSTRING(@Value, @Index, 1)
ContinuePoint: 
		SET @Index = @Index + 1
	END

	IF LEN(@Extension) > 0 
	BEGIN
		SET @Extension = ' x' + @Extension
	END


	IF @FormatLocal <> ''
	BEGIN
		SET @Local = [dbo].[fnEMPhoneFormat](@Local, @FormatLocal)
	END
	ELSE
	BEGIN
		SET @Local = @Local + ' '
	END
   
	SET @RetVal = @Country + @Area + @Local + @Extension
	--SET @RetVal = @Country 
	--SET @RetVal = @Area 
	--SET @RetVal = @Local 
	--SET @RetVal = @Extension
	--SET @RetVal = @Value
	--SET @RetVal = @FormatCountry
	--SET @RetVal = @FormatArea
	--SET @RetVal = @FormatLocal

	INSERT INTO @returntable(strPhone, strCountry, strArea, strLocal, strExtension)
	select @RetVal, @Country, @Area, @Local, @Extension

	RETURN;
END
