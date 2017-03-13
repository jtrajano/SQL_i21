CREATE PROCEDURE [dbo].[uspCTReportCoffeeNeedPlan]
	@xmlParam nvarchar(max) = NULL
AS
BEGIN

  DECLARE @FirstMonth nvarchar(100)
  DECLARE @SecondMonth nvarchar(100)
  DECLARE @ThirdMonth nvarchar(100)
  DECLARE @FourthMonth nvarchar(100)
  DECLARE @FifthMonth nvarchar(100)
  DECLARE @SixthMonth nvarchar(100)
  DECLARE @SeventhMonth NVARCHAR(100)
  DECLARE @EighthMonth NVARCHAR(100)
  DECLARE @NinthMonth NVARCHAR(100)
  DECLARE @TenthMonth NVARCHAR(100)

  DECLARE @xmlDocumentId int

  DECLARE @IntCommodityId int
  DECLARE @IntUOMId int
  DECLARE @strNeedPlan nvarchar(100)
  DECLARE @IntWeekId int
  DECLARE @IntYear int
  DECLARE @companyLogo varbinary(max)
  DECLARE @ReportFooter varbinary(max)

  IF LTRIM(RTRIM(@xmlParam)) = ''
    SET @xmlParam = NULL

  DECLARE @temp_xml_table TABLE 
  (
    [fieldname] nvarchar(50),
    condition nvarchar(20),
    [from] nvarchar(50),
    [to] nvarchar(50),
    [join] nvarchar(10),
    [begingroup] nvarchar(50),
    [endgroup] nvarchar(50),
    [datatype] nvarchar(50)
  )


  EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT,@xmlParam

	INSERT INTO @temp_xml_table
    SELECT *
    FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
    WITH 
	(
		[fieldname] nvarchar(50),
		condition nvarchar(20),
		[from] nvarchar(50),
		[to] nvarchar(50),
		[join] nvarchar(10),
		[begingroup] nvarchar(50),
		[endgroup] nvarchar(50),
		[datatype] nvarchar(50)
    )

  SELECT
  @IntCommodityId = [from]
  FROM @temp_xml_table
  WHERE [fieldname] = 'IntCommodityId'

  SELECT
  @IntUOMId = [from]
  FROM @temp_xml_table
  WHERE [fieldname] = 'IntUOMId'

  SELECT
  @strNeedPlan = [from]
  FROM @temp_xml_table
  WHERE [fieldname] = 'strNeedPlan'

  SET @IntWeekId = LEFT(@strNeedPlan, 2)
  SET @IntYear = RIGHT(@strNeedPlan, 4)

  SELECT @IntUOMId=intUnitMeasureId FROM tblICCommodityUnitMeasure WHERE intCommodityUnitMeasureId=@IntUOMId

  SELECT
  @companyLogo = blbFile
  FROM tblSMUpload
  WHERE intAttachmentId = 
  (
	  SELECT TOP 1
	  intAttachmentId
	  FROM tblSMAttachment
	  WHERE strScreen = 'SystemManager.CompanyPreference'
	  AND strComment = 'Header'
	  ORDER BY intAttachmentId DESC
  )

  SELECT
  @ReportFooter = blbFile
  FROM tblSMUpload
  WHERE intAttachmentId = 
  (
	  SELECT TOP 1
	  intAttachmentId
	  FROM tblSMAttachment
	  WHERE strScreen = 'SystemManager.CompanyPreference'
	  AND strComment = 'Footer'
	  ORDER BY intAttachmentId DESC
  )

  DECLARE @tblRequiredColumns AS TABLE 
  (
    [intColumnKey] int IDENTITY (1, 1),
    [intMonthKey] int,
    [intYearKey] int,
    [strColumnName] nvarchar(100) COLLATE Latin1_General_CI_AS
  )

  INSERT INTO @tblRequiredColumns ([intMonthKey], [intYearKey], [strColumnName])
  SELECT DISTINCT [intMonthKey], [intYearKey], [strColumnName] 
  FROM 
   (SELECT DISTINCT 
		CASE
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jan' THEN 1
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Feb' THEN 2
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Mar' THEN 3
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Apr' THEN 4
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'May' THEN 5
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jun' THEN 6
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jul' THEN 7
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Aug' THEN 8
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Sep' THEN 9
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Oct' THEN 10
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Nov' THEN 11
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Dec' THEN 12
      END 
	  [intMonthKey],
      Stg.[intYear] AS [intYearKey],
      LEFT(LTRIM(Stg.strPeriod), 3) + ' ' + RIGHT(RTRIM(Stg.strPeriod), 2)
      + CHAR(13) + CHAR(10)
      + '01.'
      + CASE
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jan' THEN '01'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Feb' THEN '02'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Mar' THEN '03'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Apr' THEN '04'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'May' THEN '05'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jun' THEN '06'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jul' THEN '07'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Aug' THEN '08'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Sep' THEN '09'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Oct' THEN '10'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Nov' THEN '11'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Dec' THEN '12'
      END
      + '.' + RIGHT(Stg.[intYear], 2)
      + ' | ' +
      +'16.'
      + CASE
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jan' THEN '01'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Feb' THEN '02'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Mar' THEN '03'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Apr' THEN '04'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'May' THEN '05'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jun' THEN '06'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jul' THEN '07'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Aug' THEN '08'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Sep' THEN '09'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Oct' THEN '10'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Nov' THEN '11'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Dec' THEN '12'
      END
      + '.' + RIGHT(Stg.[intYear], 2) AS strColumnName
    FROM tblRKStgBlendDemand Stg
	JOIN tblICItem Item ON Item.intItemId=Stg.intItemId AND Item.intCommodityId=@IntCommodityId AND Stg.dblQuantity >0
    WHERE CONVERT(NVARCHAR,Stg.dtmImportDate,106)=@strNeedPlan
	UNION
	SELECT DISTINCT 
		CASE
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jan' THEN 1
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Feb' THEN 2
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Mar' THEN 3
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Apr' THEN 4
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'May' THEN 5
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jun' THEN 6
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jul' THEN 7
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Aug' THEN 8
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Sep' THEN 9
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Oct' THEN 10
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Nov' THEN 11
        WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Dec' THEN 12
      END 
	  [intMonthKey],
      Stg.[intYear] AS [intYearKey],
      LEFT(LTRIM(Stg.strPeriod), 3) + ' ' + RIGHT(RTRIM(Stg.strPeriod), 2)
      + CHAR(13) + CHAR(10)
      + '01.'
      + CASE
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jan' THEN '01'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Feb' THEN '02'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Mar' THEN '03'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Apr' THEN '04'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'May' THEN '05'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jun' THEN '06'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jul' THEN '07'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Aug' THEN '08'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Sep' THEN '09'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Oct' THEN '10'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Nov' THEN '11'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Dec' THEN '12'
      END
      + '.' + RIGHT(Stg.[intYear], 2)
      + ' | ' +
      +'16.'
      + CASE
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jan' THEN '01'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Feb' THEN '02'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Mar' THEN '03'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Apr' THEN '04'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'May' THEN '05'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jun' THEN '06'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Jul' THEN '07'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Aug' THEN '08'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Sep' THEN '09'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Oct' THEN '10'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Nov' THEN '11'
			WHEN LEFT(LTRIM(Stg.strPeriod), 3) = 'Dec' THEN '12'
      END
      + '.' + RIGHT(Stg.[intYear], 2) AS strColumnName
    FROM tblRKArchBlendDemand Stg
	JOIN tblICItem Item ON Item.intItemId=Stg.intItemId AND Item.intCommodityId=@IntCommodityId AND Stg.dblQuantity >0
    WHERE CONVERT(NVARCHAR,Stg.dtmImportDate,106)=@strNeedPlan
	)t
    ORDER BY 1, 2

  SELECT TOP 1
  @FirstMonth = [strColumnName]
  FROM @tblRequiredColumns
  ORDER BY [intColumnKey]

  IF @FirstMonth IS NOT NULL
  BEGIN
      SELECT TOP 2
      @SecondMonth =
                    CASE
                      WHEN [strColumnName] <> @FirstMonth THEN [strColumnName]
                      ELSE NULL
                    END
	  FROM @tblRequiredColumns
	  ORDER BY [intColumnKey]
  END

  IF @SecondMonth IS NOT NULL
  BEGIN
    SELECT TOP 3
    @ThirdMonth =
                   CASE
                     WHEN [strColumnName] <> @SecondMonth THEN [strColumnName]
                     ELSE NULL
                   END
    FROM @tblRequiredColumns
    ORDER BY [intColumnKey]
  END

  IF @ThirdMonth IS NOT NULL
  BEGIN
    SELECT TOP 4
    @FourthMonth =
                    CASE
                      WHEN [strColumnName] <> @ThirdMonth THEN [strColumnName]
                      ELSE NULL
                    END
    FROM @tblRequiredColumns
    ORDER BY [intColumnKey]
  END

  IF @FourthMonth IS NOT NULL
  BEGIN
    SELECT TOP 5
    @FifthMonth =
                   CASE
                     WHEN [strColumnName] <> @FourthMonth THEN [strColumnName]
                     ELSE NULL
                   END
    FROM @tblRequiredColumns
    ORDER BY [intColumnKey]
  END

  IF @FifthMonth IS NOT NULL
  BEGIN
    SELECT TOP 6
    @SixthMonth =
                   CASE
                     WHEN [strColumnName] <> @FifthMonth THEN [strColumnName]
                     ELSE NULL
                   END
    FROM @tblRequiredColumns
    ORDER BY [intColumnKey]
  END

  IF @SixthMonth IS NOT NULL
  BEGIN
    SELECT TOP 7
    @SeventhMonth =
                   CASE
                     WHEN [strColumnName] <> @SixthMonth THEN [strColumnName]
                     ELSE NULL
                   END
    FROM @tblRequiredColumns
    ORDER BY [intColumnKey]
  END

  IF @SeventhMonth IS NOT NULL
  BEGIN
    SELECT TOP 8
    @EighthMonth =
                   CASE
                     WHEN [strColumnName] <> @SeventhMonth THEN [strColumnName]
                     ELSE NULL
                   END
    FROM @tblRequiredColumns
    ORDER BY [intColumnKey]
  END

  IF @EighthMonth IS NOT NULL
  BEGIN
    SELECT TOP 9
    @NinthMonth =
                   CASE
                     WHEN [strColumnName] <> @EighthMonth THEN [strColumnName]
                     ELSE NULL
                   END
    FROM @tblRequiredColumns
    ORDER BY [intColumnKey]
  END

  IF @NinthMonth IS NOT NULL
  BEGIN
    SELECT TOP 10
    @TenthMonth =
                   CASE
                     WHEN [strColumnName] <> @NinthMonth THEN [strColumnName]
                     ELSE NULL
                   END
    FROM @tblRequiredColumns
    ORDER BY [intColumnKey]
  END


  SELECT
    @FirstMonth AS strFirstMonth,
    @SecondMonth AS strSecondMonth,
    @ThirdMonth AS strThirdMonth,
    @FourthMonth AS strFourthMonth,
    @FifthMonth AS strFifthMonth,
    @SixthMonth AS strSixthMonth,
	@SeventhMonth AS strSeventhMonth,
	@EighthMonth AS strEighthMonth,
	@NinthMonth AS strNinthMonth,
	@TenthMonth AS strTenthMonth,
    @IntCommodityId AS IntCommodityId,
    @IntUOMId AS IntUOMId,
    @strNeedPlan AS strNeedPlan,
    @companyLogo AS blbHeaderLogo,
	@ReportFooter AS blbFooterLogo

END