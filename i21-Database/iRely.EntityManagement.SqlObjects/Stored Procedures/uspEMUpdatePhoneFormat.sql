CREATE PROCEDURE [dbo].[uspEMUpdatePhoneFormat]
	@intCountryId int
AS
BEGIN
	SET NOCOUNT ON
	declare @PhoneCountry			NVARCHAR(50)
	declare @PhoneArea				NVARCHAR(50)
	declare @PhoneLocal				NVARCHAR(50)
	declare @PhoneExtension			NVARCHAR(50)
	declare @intId					INT

	declare @FormatedCountry		NVARCHAR(50)
	declare @FormatedPhoneArea		NVARCHAR(50)
	declare @FormatedPhoneLocal		NVARCHAR(50)
	declare @FormatedPhoneExtension	NVARCHAR(50)


	declare @NewFormatCountry		NVARCHAR(50)
	DECLARE @NewFormatArea			NVARCHAR(50)
	DECLARE @NewFormatLocal			NVARCHAR(50)
	DECLARE @FinalFormat			NVARCHAR(400)
	select
		@NewFormatCountry	= strCountryFormat,
		@NewFormatArea		= strAreaCityFormat,
		@NewFormatLocal		= strLocalNumberFormat
		from tblSMCountry
			where intCountryID = @intCountryId


	DECLARE @TmpPhoneNumbers		TABLE(
		strPhoneArea				NVARCHAR(50),
		strPhoneLocal				NVARCHAR(50),
		strPhoneExtension			NVARCHAR(50),
		strPhoneCountry				NVARCHAR(50),
		intEntityPhoneNumberId		INT
	)
	INSERT INTO @TmpPhoneNumbers
	select 
		strPhoneArea,  
		strPhoneLocal,
		strPhoneExtension,
		strPhoneCountry,
		intEntityPhoneNumberId
		from tblEMEntityPhoneNumber where intCountryId = @intCountryId

	WHILE EXISTS(SELECT TOP 1 1 FROM @TmpPhoneNumbers)
	BEGIN
		select top 1 
		@PhoneArea			= strPhoneArea,  
		@PhoneLocal			= strPhoneLocal,
		@PhoneExtension		= strPhoneExtension,
		@PhoneCountry		= strPhoneCountry,
		@intId				= intEntityPhoneNumberId
		from @TmpPhoneNumbers 

		--For Country
			declare @CountryAppender nvarchar(1)
			declare @CountryAppenderFormat nvarchar(50)
			if @NewFormatCountry = 'Dash'
			begin
				set @FormatedCountry = @PhoneCountry + '-'
			end
			else if @NewFormatCountry = 'Period'
			begin
				set @FormatedCountry = @PhoneCountry + '.'
			end
			else if @NewFormatCountry = 'Space'
			begin
				set @FormatedCountry = @PhoneCountry + ' '
			end
			else
			begin
				set @FormatedCountry = @PhoneCountry
			end
			set @FormatedCountry = '+' + @FormatedCountry
		--For Area Number
			declare @AreaAppender nvarchar(1)
			declare @AreaAppenderFormat nvarchar(50)
			if @NewFormatArea = 'Parentheses'
			begin
				set @FormatedPhoneArea = '(' + @PhoneArea + ')'
			end
			else if @NewFormatArea = 'Dash'
			begin
				set @FormatedPhoneArea = @PhoneArea + '-'
			end
			else if @NewFormatArea = 'Period'
			begin
				set @FormatedPhoneArea = @PhoneArea + '.'
			end
			else if @NewFormatArea = 'Space'
			begin
				set @FormatedPhoneArea = @PhoneArea + ' '
			end
			else
			begin
				set @FormatedPhoneArea = @PhoneArea
			end


		--

		--For Local Number
			declare @PreLocalLen int
			declare @LocalAppender nvarchar(1)
			declare @LocalAppenderFormat nvarchar(50)
	
			set @LocalAppenderFormat = SUBSTRING(@NewFormatLocal, 5, LEN(@NewFormatLocal)) 

			BEGIN TRY
				select @PreLocalLen = Cast(SUBSTRING(@NewFormatLocal, 1, 1) as int)
			END TRY
			BEGIN CATCH
				SET @PreLocalLen = 1
			END CATCH
			if @LocalAppenderFormat = 'Dash'
			begin
				set @LocalAppender = '-'
			end
			else if @LocalAppenderFormat = 'Period'
			begin
				set @LocalAppender = '.'
			end
			else if @LocalAppenderFormat = 'Space'
			begin
				set @LocalAppender = ' '
			end


			if @NewFormatLocal = 'None' 
			begin
				select @FormatedPhoneLocal = @PhoneLocal
			end
			else
			begin
				select @FormatedPhoneLocal = SUBSTRING(@PhoneLocal,1, @PreLocalLen) + @LocalAppender + SUBSTRING(@PhoneLocal, @PreLocalLen + 1, Len(@PhoneLocal))
			end
		--
		SET @FinalFormat = @FormatedCountry + @FormatedPhoneArea + @FormatedPhoneLocal + case when @PhoneExtension <> '' then 'x' + @PhoneExtension else '' end
		update tblEMEntityPhoneNumber 
			set strPhone		= ISNULL(@FinalFormat, strPhone) ,
			strFormatArea		= @NewFormatArea,
			strFormatCountry	= @NewFormatCountry,
			strFormatLocal		= @NewFormatLocal 	
			where intEntityPhoneNumberId = @intId


		DELETE FROM @TmpPhoneNumbers where intEntityPhoneNumberId = @intId
	END
END