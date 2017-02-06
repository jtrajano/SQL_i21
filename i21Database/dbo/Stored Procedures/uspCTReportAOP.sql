CREATE PROCEDURE [dbo].[uspCTReportAOP]
	@xmlParam nvarchar(max) = NULL
AS
BEGIN

  DECLARE @FirstBasisItem nvarchar(100)
  DECLARE @SecondBasisItem nvarchar(100)
  DECLARE @ThirdBasisItem nvarchar(100)
  DECLARE @FourthBasisItem nvarchar(100)
  DECLARE @FifthBasisItem nvarchar(100)
  DECLARE @SixthBasisItem nvarchar(100)
  DECLARE @SeventhBasisItem nvarchar(100)
  DECLARE @EighthBasisItem nvarchar(100)

  DECLARE @xmlDocumentId int

  DECLARE @IntCommodityId int
  DECLARE @strCommodityCode NVARCHAR(30) 
  DECLARE @strYear NVARCHAR(10)
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
  
  SELECT @strCommodityCode=strCommodityCode FROM tblICCommodity WHERE intCommodityId=@IntCommodityId
  SELECT
  @strYear = [from]
  FROM @temp_xml_table
  WHERE [fieldname] = 'strYear'

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
    [intBasisItemId] int,    
    [strColumnName] nvarchar(100) COLLATE Latin1_General_CI_AS
  )
  
  INSERT INTO @tblRequiredColumns ([intBasisItemId], [strColumnName])
  SELECT DISTINCT 
  AD.intBasisItemId,Item.strItemNo FROM tblCTAOPDetail AD 
  JOIN tblCTAOP A ON A.intAOPId=AD.intAOPId
  JOIN tblICItem Item ON Item.intItemId=AD.intBasisItemId
  WHERE AD.intCommodityId=1 AND A.strYear=@strYear
  UNION
  SELECT intItemId,strItemNo FROM tblICItem Where strType='Other Charge' AND  ysnBasisContract=1 

  SELECT TOP 1
  @FirstBasisItem = [strColumnName]
  FROM @tblRequiredColumns
  ORDER BY [intColumnKey]

  IF @FirstBasisItem IS NOT NULL
  BEGIN
      SELECT TOP 2
      @SecondBasisItem =
                    CASE
                      WHEN [strColumnName] <> @FirstBasisItem THEN [strColumnName]
                      ELSE NULL
                    END
	  FROM @tblRequiredColumns
	  ORDER BY [intColumnKey]
  END

  IF @SecondBasisItem IS NOT NULL
  BEGIN
    SELECT TOP 3
    @ThirdBasisItem =
                   CASE
                     WHEN [strColumnName] <> @SecondBasisItem THEN [strColumnName]
                     ELSE NULL
                   END
    FROM @tblRequiredColumns
    ORDER BY [intColumnKey]
  END

  IF @ThirdBasisItem IS NOT NULL
  BEGIN
    SELECT TOP 4
    @FourthBasisItem =
                    CASE
                      WHEN [strColumnName] <> @ThirdBasisItem THEN [strColumnName]
                      ELSE NULL
                    END
    FROM @tblRequiredColumns
    ORDER BY [intColumnKey]
  END

  IF @FourthBasisItem IS NOT NULL
  BEGIN
    SELECT TOP 5
    @FifthBasisItem =
                   CASE
                     WHEN [strColumnName] <> @FourthBasisItem THEN [strColumnName]
                     ELSE NULL
                   END
    FROM @tblRequiredColumns
    ORDER BY [intColumnKey]
  END

  IF @FifthBasisItem IS NOT NULL
  BEGIN
    SELECT TOP 6
    @SixthBasisItem =
                   CASE
                     WHEN [strColumnName] <> @FifthBasisItem THEN [strColumnName]
                     ELSE NULL
                   END
    FROM @tblRequiredColumns
    ORDER BY [intColumnKey]
  END

  IF @SixthBasisItem IS NOT NULL
  BEGIN
    SELECT TOP 7
    @SeventhBasisItem =
                   CASE
                     WHEN [strColumnName] <> @SixthBasisItem THEN [strColumnName]
                     ELSE NULL
                   END
    FROM @tblRequiredColumns
    ORDER BY [intColumnKey]
  END

  IF @SeventhBasisItem IS NOT NULL
  BEGIN
    SELECT TOP 8
    @EighthBasisItem =
                   CASE
                     WHEN [strColumnName] <> @SeventhBasisItem THEN [strColumnName]
                     ELSE NULL
                   END
    FROM @tblRequiredColumns
    ORDER BY [intColumnKey]
  END

  SELECT
    @FirstBasisItem AS strFirstBasisItem,
    @SecondBasisItem AS strSecondBasisItem,
    @ThirdBasisItem AS strThirdBasisItem,
    @FourthBasisItem AS strFourthBasisItem,
    @FifthBasisItem AS strFifthBasisItem,
    @SixthBasisItem AS strSixthBasisItem,
	@SeventhBasisItem AS strSeventhBasisItem,
	@EighthBasisItem AS strEighthBasisItem,
    @IntCommodityId AS IntCommodityId,
	@strYear AS strYear,
    @companyLogo AS blbHeaderLogo,
	@ReportFooter AS blbFooterLogo,
	'Annual Operation Planning, '+@strCommodityCode+', '+@strYear AS strCaption

END